#include <kernels.h>
#include <vector>
#include <cuda_runtime.h>
#include <float.h>
#include <stdio.h>

/*
   * Global device kernel function to implement semi-ring
   * DGEMM.
   */

__global__ void vecAdd(double *a, double *b, double *c, int n)
{
    // Get our global thread ID
    int id = blockIdx.x*blockDim.x+threadIdx.x;
 
    // Make sure we do not go out of bounds
    if (id < n)
        c[id] = a[id] + b[id];
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
void concatenateMatricesKernel(Problem* prob,
                        int m, int n, double rho) {
    int idx = threadIdx.x + blockIdx.x * blockDim.x;

    // Concatenate P + rho*I
    if (idx < n * n) {
        int i = idx / n;
        int j = idx % n;
        prob->data.sol_con.values[idx] = prob->data.P.values[idx] + ((i == j) ? rho : 0.0);
    }

    // Concatenate A^T
    if (idx >= n * n && idx < n * n + n * m) {
        int i = (idx - n * n) / m;
        int j = (idx - n * n) % m;
        prob->data.sol_con.values[idx] = prob->data.A.values[j * n + i];
    }

    // Concatenate A
    if (idx >= n * n + n * m && idx < n * n + 2 * n * m) {
        int i = (idx - n * n - n * m) / n;
        int j = (idx - n * n - n * m) % n;
        prob->data.sol_con.values[idx] = prob->data.A.values[i * n + j];
    }

    // Concatenate -(1/rho)*I
    if (idx >= n * n + 2 * n * m && idx < n * n + 3 * n * m) {
        int i = (idx - n * n - 2 * n * m) / m;
        int j = (idx - n * n - 2 * n * m) % m;
        prob->data.sol_con.values[idx] = ((i == j) ? -1.0 / rho : 0.0);
    }
}

__global__ void concatenateVectorsKernel(Problem* prob, double sigma, double rho, int size) {
    int idx = threadIdx.x + blockIdx.x * blockDim.x;

    if (idx < size) {
        // Concatenate [sigma*x - q]
        prob->data.vec_con[idx] = sigma * prob->solution.x[idx] - prob->data.q[idx];

        // Concatenate [z - (1/rho)*y]
        prob->data.vec_con[idx + size] = prob->solution.z[idx] - prob->solution.y[idx] / rho;
    }
}

__global__ void update(double *x, double *y, double *z, double *x_v, double *z_tilde, double *primal, double* dual,
        double *deltax, double *deltay, double rho, double alpha, double *l, double *u, int m, int n) {
    int idx = threadIdx.x + blockIdx.x * blockDim.x;

    // Compute z_tilde = z_k + (1/rho) * (v - y)
    // x_new = alpha*x+(1-alpha) * x;
    // z_new = multiply(alpha*z_tilde + (1-alpha)*z + (1/rho)*y);
    // y_new = y + rho * (alpha * z_tilde + (1-alpha) * z - z*new);
    __shared__ double *delta_x_norm;
    __shared__ double *delta_y_norm;

    // Initialize shared variables to 0
    if (threadIdx.x == 0) {
        *delta_x_norm = 0.0;
        *delta_y_norm = 0.0;
    }

    __syncthreads();

    if (idx < n) {
        z_tilde[idx] = z[idx] + (x_v[idx + m] - y[idx]) / rho;
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
        *delta_y_norm += deltay[idx];
    }

    if (n <= idx < n+m) {
        deltax[idx-n] = alpha * (x_v[idx-n] - x[idx-n]);
        x[idx-n] = x[idx-n] + deltax[idx-n];

        // Atomic add to accumulate the result
        *delta_x_norm += deltax[idx-n];

    }

    __syncthreads();

    // Store the final result in global memory
    if (threadIdx.x == 0) {
        // Atomic add to accumulate the final result
        *primal += *delta_x_norm;
        *dual += *delta_y_norm;
    }
    __syncthreads();
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