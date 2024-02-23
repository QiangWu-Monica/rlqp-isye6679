#include <iostream>
#include <cassert>
#include <kernels.h>
#include <cusolverDn.h>
#include <errs.h>
#include <random>
#include <cstdio>
#include <iomanip>
#include <string>
using namespace std;

/* extern "C" {
    void dgemm_(char*, char*, int*, int*, int*, double*, double*, int*, double*, int*, double*, double*, int*);
} */

Problem::Problem() {
}

Problem::Problem(Data &data, Parameter &parameter, Setting &setting) {
}

void Problem::randinit(std::uint64_t n, std::uint64_t m) {

    std::random_device r;
    std::mt19937 gen(r());
    std::uniform_real_distribution<> distr(1.0, 2.0);

    for(int i = 0; i < data.n * data.m; i++)
        this->data.A.values[i] = distr(gen);
};

void Problem::print() const {
    cout << "The solution vector x is:" << endl;
    for (int i = 0; i < data.n; i++) {
        cout << solution.x[i] << " ";
    }
    cout << endl;
    cout << endl;

    cout << "The solution vector y is:" << endl;
    for (int i=0; i < data.m; i++) {
        cout << solution.y[i] << " ";
    }
};

void Problem::osqp() {
};

void Problem::cuda_allocate(Problem *problem_new) {
    cuErrChk(cudaMalloc((void **)&(problem_new->data.q), sizeof(double)*data.n));
    cuErrChk(cudaMalloc((void **)&(problem_new->data.P.values), sizeof(double)*data.P.nrows*data.P.ncols));
    cuErrChk(cudaMalloc((void **)&(problem_new->data.A.values), sizeof(double)*data.A.nrows*data.A.ncols));
    cuErrChk(cudaMalloc((void **)&(problem_new->data.l), sizeof(double)*data.m));
    cuErrChk(cudaMalloc((void **)&(problem_new->data.u), sizeof(double)*data.m));

    cuErrChk(cudaMalloc((void **)&(problem_new->solution.x), sizeof(double)*data.n));
    cuErrChk(cudaMalloc((void **)&(problem_new->solution.z), sizeof(double)*data.m));
    cuErrChk(cudaMalloc((void **)&(problem_new->solution.y), sizeof(double)*data.m));
    cuErrChk(cudaMalloc((void **)&(problem_new->solution.primal), sizeof(double)));
    cuErrChk(cudaMalloc((void **)&(problem_new->solution.dual), sizeof(double)));
    cuErrChk(cudaMalloc((void **)&(problem_new->solution.x_v), sizeof(double)*(data.m+data.n)));
    cuErrChk(cudaMalloc((void **)&(problem_new->solution.z_tilde), sizeof(double)*data.m));
    cuErrChk(cudaMalloc((void **)&(problem_new->solution.deltax), sizeof(double)*data.n));
    cuErrChk(cudaMalloc((void **)&(problem_new->solution.deltay), sizeof(double)*data.m));

    cuErrChk(cudaMalloc((void **)&(problem_new->solution.norm1_vec), sizeof(double)*data.m));
    cuErrChk(cudaMalloc((void **)&(problem_new->solution.norm2_vec), sizeof(double)*data.n));

    cuErrChk(cudaMalloc((void **) &(problem_new->data.sol_con.values), sizeof(double)*(data.m+data.n)*(data.m+data.n)));
    cuErrChk(cudaMalloc((void **) &(problem_new->data.vec_con), sizeof(double)*(data.m+data.n)));

    cuErrChk(cudaMemcpy(problem_new->data.q, data.q, sizeof(double)*data.n, cudaMemcpyHostToDevice));
    cuErrChk(cudaMemcpy(problem_new->data.l, data.l, sizeof(double)*data.m, cudaMemcpyHostToDevice));
    cuErrChk(cudaMemcpy(problem_new->data.u, data.u, sizeof(double)*data.m, cudaMemcpyHostToDevice));

    cuErrChk(cudaMemcpy(problem_new->data.P.values, data.P.values, sizeof(double)*data.P.nrows*data.P.ncols, cudaMemcpyHostToDevice));
    cuErrChk(cudaMemcpy(problem_new->data.A.values, data.A.values, sizeof(double)*data.A.nrows*data.A.ncols, cudaMemcpyHostToDevice));

    cuErrChk(cudaMemcpy(problem_new->solution.x, solution.x, sizeof(double)*data.n, cudaMemcpyHostToDevice));
    cuErrChk(cudaMemcpy(problem_new->solution.y, solution.y, sizeof(double)*data.m, cudaMemcpyHostToDevice));
    cuErrChk(cudaMemcpy(problem_new->solution.z, solution.z, sizeof(double)*data.m, cudaMemcpyHostToDevice));
    cuErrChk(cudaMemcpy(problem_new->solution.x_v, solution.x_v, sizeof(double)*(data.n+data.m), cudaMemcpyHostToDevice));

    cuErrChk(cudaMemcpy(problem_new->solution.norm1_vec, solution.z, sizeof(double)*data.m, cudaMemcpyHostToDevice));
    cuErrChk(cudaMemcpy(problem_new->solution.norm2_vec, data.q, sizeof(double)*data.n, cudaMemcpyHostToDevice));
};

void Problem::checknorm(cublasHandle_t cublas_handle, Problem *problem_new) {
    double scalar = 1.0;

    dim3 grid_size, block_size;
    size_t shmem_size;
    grid_size.x = (int)((data.m + 127) / 128);
    grid_size.y = (int)((data.n + 127) / 128);
    block_size.x = 16;
    block_size.y = 16;
    shmem_size = 1;

    cuErrChk(cublasDgemv(cublas_handle, CUBLAS_OP_N, data.m, data.n, &scalar, problem_new->data.A.values, data.m, problem_new->solution.x, 1, &scalar, problem_new->solution.norm1_vec, 1));
    vecminus <<< grid_size, block_size, shmem_size >>> (problem_new->solution.norm1_vec, problem_new->solution.z, data.m);
    cuErrChk(cublasDnrm2(cublas_handle, data.m, problem_new->solution.norm1_vec, 1, solution.norm1));
    // norm1 = norm(A*x-z)

    cuErrChk(cublasDgemv(cublas_handle, CUBLAS_OP_T, data.n, data.m, &scalar, problem_new->data.A.values, data.n, problem_new->solution.y, 1, &scalar, problem_new->solution.norm2_vec, 1));
    cuErrChk(cublasDgemv(cublas_handle, CUBLAS_OP_N, data.n, data.n, &scalar, problem_new->data.P.values, data.n, problem_new->solution.x, 1, &scalar, problem_new->solution.norm2_vec, 1));
    cuErrChk(cublasDnrm2(cublas_handle, data.n, problem_new->solution.norm2_vec, 1, solution.norm2));
    // norm2 = norm(P*x+q+A*y)
};

void Problem::cuda_free(Problem *problem_new) {
    cuErrChk(cudaFree(problem_new->data.q));
    cuErrChk(cudaFree(problem_new->data.P.values));
    problem_new->data.P.values = nullptr;
    cuErrChk(cudaFree(problem_new->data.A.values));
    problem_new->data.A.values = nullptr;
    cuErrChk(cudaFree(problem_new->data.l));
    cuErrChk(cudaFree(problem_new->data.u));

    cuErrChk(cudaFree(problem_new->solution.x));
    cuErrChk(cudaFree(problem_new->solution.z));
    cuErrChk(cudaFree(problem_new->solution.y));
    cuErrChk(cudaFree(problem_new->solution.x_v));
    cuErrChk(cudaFree(problem_new->solution.z_tilde));
    cuErrChk(cudaFree(problem_new->solution.deltax));
    cuErrChk(cudaFree(problem_new->solution.deltay));
    cuErrChk(cudaFree(problem_new->solution.primal));
    cuErrChk(cudaFree(problem_new->solution.dual));    

    cuErrChk(cudaFree(problem_new->solution.norm1_vec));
    cuErrChk(cudaFree(problem_new->solution.norm2_vec));
    cuErrChk(cudaFree(problem_new->data.sol_con.values));
    problem_new->data.sol_con.values = nullptr;
    cuErrChk(cudaFree(problem_new->data.vec_con));
};

/* Function to implement CUDA version OSQP
 * Minimize 1/2 * x^T * P * x + q^T * x
 * Subject to l <= A^T * x <= u
 */
void Problem::cu_all_osqp() {
    Problem *problem_new = new Problem();
    cuda_allocate(problem_new);

    cusolverDnHandle_t solver_handle;
    cuErrChk(cusolverDnCreate(&solver_handle));

    cublasHandle_t cublas_handle;
    cuErrChk(cublasCreate(&cublas_handle));

    cudaStream_t stream = nullptr;
    cuErrChk(cudaStreamCreate(&stream));
    cuErrChk(cusolverDnSetStream(solver_handle, stream));

    dim3 grid_size, block_size;
    size_t shmem_size;
    grid_size.x = (int)((data.m + 127) / 128);
    grid_size.y = (int)((data.n + 127) / 128);
    block_size.x = 16;
    block_size.y = 16;
    shmem_size = 1;

    int size = data.m + data.n;
    cudaDeviceSynchronize();

    concatenateMatricesKernel<<<grid_size, block_size, shmem_size>>>(problem_new->data.sol_con.values, problem_new->data.P.values,
                problem_new->data.A.values, data.m, data.n, parameter.rho, parameter.sigma);

    // cuErrChk(cudaMemcpy(data.sol_con.values, problem_new->data.sol_con.values, sizeof(double)*(data.m+data.n)*(data.m+data.n), cudaMemcpyDeviceToHost));
    int Lwork = 0;
    cuErrChk(cusolverDnDgetrf_bufferSize(solver_handle, size, size, problem_new->data.sol_con.values, size, &Lwork));
    double* d_Work;
    cuErrChk(cudaMalloc((void**)&d_Work, sizeof(double) * Lwork));
    int* d_info;
    cuErrChk(cudaMalloc((void**)&d_info, sizeof(int)));
    int* devIpiv;
    cuErrChk(cudaMalloc((void**)&devIpiv, sizeof(int) * size));
    // LU factorization
    cuErrChk(cusolverDnDgetrf(solver_handle, size, size, problem_new->data.sol_con.values, size, d_Work, devIpiv, d_info));
    
    cudaDeviceSynchronize();

    int iters = 1;

    while (iters < setting.max_iter && (*solution.norm1 >= setting.eps_prim || *solution.norm2 >= setting.eps_dual)) {

        process_xv <<< grid_size, block_size, shmem_size >>> (parameter.sigma, parameter.rho, problem_new->solution.x, problem_new->solution.y, problem_new->solution.z, problem_new->data.q, data.n, data.m, problem_new->solution.x_v);
        // Solve the linear system [[P+rho*I, A^T], [A, -(1/rho)*I]]*x_v = [rho*x-q, z-(1/rho)*y];
        cuErrChk(cudaDeviceSynchronize());
        cuErrChk(cusolverDnDgetrs(solver_handle, CUBLAS_OP_N, size, 1, problem_new->data.sol_con.values, size, devIpiv, problem_new->solution.x_v, size, d_info));
        cuErrChk(cudaDeviceSynchronize());

        // z_tilde = z + (1/rho) * (vecAdd <<< grid_size, block_size, shmem_size  >>> (v, -y));
        // x_new = alpha*x+(1-alpha) * x;
        // z_new = multiply(alpha*z_tilde + (1-alpha)*z + (1/rho)*y);
        // y_new = y + rho * (alpha * z_tilde + (1-alpha) * z - z*new);

        update <<< grid_size, block_size, shmem_size >>> (problem_new->solution.x,
            problem_new->solution.y, problem_new->solution.z, problem_new->solution.x_v, 
            problem_new->solution.z_tilde, problem_new->solution.primal, problem_new->solution.dual,
            problem_new->solution.deltax, problem_new->solution.deltay, parameter.rho, 
                parameter.alpha, problem_new->data.l, problem_new->data.u, data.m, data.n);
        /*cuErrChk(cudaMemcpy(solution.primal, problem_new.solution.primal, sizeof(double), cudaMemcpyDeviceToHost));
        cuErrChk(cudaMemcpy(solution.dual, problem_new.solution.dual, sizeof(double), cudaMemcpyDeviceToHost));

        if (solution.primal == 0.0) {
            continue;
        } else {
            check_primal_infeasibility <<< grid_size, block_size, shmem_size >>> (&(problem_new.solution));
        }

        if (solution.dual == 0.0) {
            continue;
        } else {
            check_dual_infeasibility <<< grid_size, block_size, shmem_size >>> (&(problem_new.solution, problem_new.data.u, problem_new.data.l, data.m));
        }

        cuErrChk(cudaMemcpy(solution.primal, problem_new.solution.primal, sizeof(double), cudaMemcpyDeviceToHost));
        cuErrChk(cudaMemcpy(solution.dual, problem_new.solution.dual, sizeof(double), cudaMemcpyDeviceToHost));

        if (solution.primal != 0 || solution.dual != 0) {
            cout << "Infeasibility detected!" << endl;
            break;
        }*/
        
        checknorm(cublas_handle, problem_new);
        iters++;
    }

    cuErrChk(cudaMemcpy(solution.x, problem_new->solution.x, sizeof(double)*data.n, cudaMemcpyDeviceToHost));
    cuErrChk(cudaMemcpy(solution.y, problem_new->solution.y, sizeof(double)*data.m, cudaMemcpyDeviceToHost));

    cuda_free(problem_new);

    cuErrChk(cudaFree(d_Work));
    cuErrChk(cudaFree(d_info));
    cuErrChk(cudaFree(devIpiv));

    cuErrChk(cudaStreamDestroy(stream));
    cuErrChk(cusolverDnDestroy(solver_handle));
    cuErrChk(cublasDestroy(cublas_handle));

    delete problem_new;
};

void Problem::cu_osqp() {
};
