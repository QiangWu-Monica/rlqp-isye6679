#ifndef PROBLEM_H
#define PROBLEM_H

#include <cusolverDn.h>
#include <cublas_v2.h>
#include <cuda_runtime.h>
#include <setup.h>

struct Problem {
    Data data;
    Parameter parameter;
    Setting setting;
    Solution solution;
    public:
        Problem();
        Problem(Data &data, Parameter &parameter, Setting &setting);
        ~Problem() = default;
        Problem(const Problem&) = default;

        void randinit(std::uint64_t n, std::uint64_t m);

        void print() const;
        void cuda_allocate(Problem *new_problem);
        void checknorm(cublasHandle_t cublas_handle, Problem *new_problem);
        void cuda_free(Problem *new_problem);
        void osqp();
        void cu_osqp();
        void cu_all_osqp();
};
#endif