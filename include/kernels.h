#ifndef CUDA_KERNELS_H
#define CUDA_KERNELS_H

#include <cuda_runtime.h>
#include <cstdint>
#include "problem.h"

__global__ void vecAdd(double *a, double *b, double *c, int n);

__global__ 
void osqp_kernel(double const *__restrict__ alpha, 
        uint64_t const *__restrict__ nr_A,
        uint64_t const *__restrict__ nc_A,
        double const *__restrict__ A,
        uint64_t const *__restrict__ nc_B,
        double const *__restrict__ B,
        double const *__restrict__ beta,
        double *__restrict__ C);

__global__ 
void concatenateMatricesKernel(Problem* prob,
                        int m, int n, double rho);

__global__ 
void concatenateVectorsKernel(Problem* prob,
                                         double* vec_con, double sigma, double rho, int size);

__global__ 
__global__ void update(double *x, double *y, double *z, double *x_v, double *z_tilde, double *primal, double* dual,
        double* deltax, double *deltay, double rho, double alpha, double *l, double *u, int m, int n);

__global__ 
void check_primal_infeasibility();

__global__ 
void check_dual_infeasibility(double *x, double *y, double *dual, double *u, double *l, int m);

#endif