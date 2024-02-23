#include <kernels.h>
#include <vector>
#include <cuda_runtime.h>
#include <float.h>
#include <stdio.h>

/*
   * Global device kernel function to implement semi-ring
   * DGEMM.
   */

__global__ void vecminus(double* vec, double* minvec, int size) {
    int idx = threadIdx.x + blockIdx.x * blockDim.x;
    int idy = threadIdx.y + blockIdx.y * blockDim.y;    

    if (idx < size && idy == 1) {
        vec[idx] = vec[idx] - minvec[idx];
    }

    __syncthreads();
}

__global__ void process_xv(double sigma, double rho, double *x, double *y, double *z, double *q, int n, int m, double *x_v) {
    int idx = threadIdx.x + blockIdx.x * blockDim.x;
    int idy = threadIdx.y + blockIdx.y * blockDim.y;

    if (idx < n && idy == 1) {
        x_v[idx] = sigma * x[idx] - q[idx];
    } else if (n <= idx && idx < n+m) {
        x_v[idx] = z[idx-n] - (1/rho) * y[idx-n];
    }

    __syncthreads();
}

__global__ 
void osqp_kernel(uint64_t const *__restrict__ nr_A,
        uint64_t const *__restrict__ nc_A,
        double const *__restrict__ A,
        uint64_t const *__restrict__ nc_B,
        double const *__restrict__ B,
        double *__restrict__ C) {
}

__global__ 
void concatenateMatricesKernel(double* sol_con, double* P, double* A,
                        int m, int n, double rho, double sigma) {
    int idx = threadIdx.x + blockDim.x * blockIdx.x;
    int idy = threadIdx.y + blockDim.y * blockIdx.y;

    if (idx < m+n && idy < m+n) {
        // Concatenate P + rho*I
        if (idx < n && idy < n) {
            sol_con[idy*(n+m)+idx] = P[idy*n+idx] + ((idx == idy) ? sigma : 0.0);
        } else if (n <= idy && idy < m+n && idx < n) { // Concatenate A^T
            sol_con[idy*(n+m)+idx] = A[idx*m+(idy-n)];
        } else if (n <= idx && idx < n+m && idy < n) { // Concatenate A
            sol_con[idy*(n+m)+idx] = A[idy*m+(idx-n)];
        } else if (n <= idx && n <= idy && idx < n+m && idy < n+m) { // Concatenate -(1/rho)*I
            sol_con[idy*(n+m)+idx] = ((idx == idy) ? -1.0/rho : 0.0);
        }
    }

    __syncthreads();
}

__global__ void concatenateVectorsKernel(Problem* prob, double sigma, double rho, int size) {
    int idx = threadIdx.x + blockIdx.x * blockDim.x;

    if (idx < size) {
        // Concatenate [sigma*x - q]
        prob->data.vec_con[idx] = sigma * prob->solution.x[idx] - prob->data.q[idx];

        // Concatenate [z - (1/rho)*y]
        prob->data.vec_con[idx + size] = prob->solution.z[idx] - prob->solution.y[idx] / rho;
    }

    __syncthreads();
}

__global__ void update(double *x, double *y, double *z, double *x_v, double *z_tilde, double *primal, double* dual,
        double *deltax, double *deltay, double rho, double alpha, double *l, double *u, int m, int n) {
    int idx = threadIdx.x + blockIdx.x * blockDim.x;

    // Compute z_tilde = z_k + (1/rho) * (v - y)
    // x_new = alpha*x+(1-alpha) * x;
    // z_new = multiply(alpha*z_tilde + (1-alpha)*z + (1/rho)*y);
    // y_new = y + rho * (alpha * z_tilde + (1-alpha) * z - z*new);
    // __shared__ double *delta_x_norm;
    // __shared__ double *delta_y_norm;

    // Initialize shared variables to 0
    // if (threadIdx.x == 0) {
    //     *delta_x_norm = 0.0;
    //     *delta_y_norm = 0.0;
    // }

    __syncthreads();

    if (idx < m) {
        z_tilde[idx] = z[idx] + (x_v[idx + n] - y[idx]) / rho;
        z_tilde[idx] = alpha * z_tilde[idx] + (1-alpha) * z[idx];

        if (z_tilde[idx]+(1/rho)*y[idx] < l[idx]) {
                z[idx] = l[idx];
        } else if (z_tilde[idx] + (1/rho)*y[idx] > u[idx]) {
                z[idx] = u[idx];
        } else {
                z[idx] = z_tilde[idx];
        }

        deltay[idx] = (1/rho) * (z_tilde[idx] - z[idx]);
        y[idx] = y[idx] + deltay[idx];

        // Atomic add to accumulate the result
        // *delta_y_norm += deltay[idx];
    } else if (m <= idx && idx < m+n) {
        deltax[idx-m] = alpha * (x_v[idx-m] - x[idx-m]);
        x[idx-m] = x[idx-m] + deltax[idx-m];

        // Atomic add to accumulate the result
        // *delta_x_norm += deltax[idx-n];

    }

    __syncthreads();

    // Store the final result in global memory
    // if (threadIdx.x == 0) {
        // Atomic add to accumulate the final result
    //     *primal += *delta_x_norm;
    //     *dual += *delta_y_norm;
    // }
    // __syncthreads();
}

__global__ 
void check_primal_infeasibility() {

}

__global__ 
void check_dual_infeasibility(double *x, double *y, double *dual, double *u, double *l, int m) {
    int idx = threadIdx.x + blockIdx.x * blockDim.x;

    __shared__ double vec_sum;
    __syncthreads();

    if (idx < m) {
        if (y[idx] < 0) {
            vec_sum += y[idx] * l[idx];
        } else if (y[idx] > 0) {
            vec_sum += y[idx] * u[idx];
        }
    }

    __syncthreads();

    if (threadIdx.x == 0) {
        *dual += vec_sum;
    }

    __syncthreads();
}