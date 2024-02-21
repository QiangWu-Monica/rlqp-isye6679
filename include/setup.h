#ifndef SETUP_H
#define SETUP_H

#include <vector>
#include <cstdint>
#include <sstream>

struct Topology;
/* Struct to store double precision matrices of size nrows x ncols. 
 * The matrix entries are stored in column-major format as 1-D 
 * double vector. 
 * Implements double precision GEMM and semi-ring GEMM
 * operations on matrices.
 */

struct Matrix {
    std::uint64_t nrows;
    std::uint64_t ncols;
    double* values;
    public:
        Matrix(): values(nullptr) {};
        ~Matrix() = default;
        Matrix(const std::vector<std::vector<double>> &mtx);
        void infinit();
};

struct Setting {
    std::uint64_t max_iter;
    double eps_prim;
    double eps_dual;
    public:
        Setting() = default;
        ~Setting() = default;
        Setting(Setting &setting);
};

struct Parameter {
    double alpha;
    double rho;
    double sigma;
    public:
        Parameter() = default;
        ~Parameter() = default;
        Parameter(Parameter &parameter);
};

struct Data {
    int n; // dimension of variables
    int m; // dimension of constraints
    Matrix P;
    double *q;
    Matrix A;
    Matrix sol_con;
    double *vec_con;
    double *l;
    double *u;
    public:
        Data() = default;
        ~Data() = default;
        Data(Data &data);
};

struct Solution {
    double *x;
    double *z;
    double *y;
    double *x_v;
    double *z_tilde;
    double *deltax;
    double *deltay;
    double *primal;
    double *dual;
    double *norm1;
    double *norm2;
    double *norm1_vec;
    double *norm2_vec;
    public:
        Solution() = default;
        ~Solution() = default;
        Solution(Solution &solution);
};

#endif