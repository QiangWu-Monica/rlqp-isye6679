#include <setup.h>
#include <limits>
#include <cassert>
#include <random>
#include <cstdint>
#include <vector>
#include <cstdio>
#include <iomanip>
#include <sstream>

Matrix::Matrix(const std::vector<std::vector<double>> &mtx) {
    nrows = mtx.size();
    ncols = mtx[0].size();
    for (int j = 0; j < ncols; j++) {
        for (int i = 0; i < nrows; i++) {
            values[j*nrows+i] = mtx[i][j];
        }
    }
}

Setting::Setting(Setting &setting) {
    max_iter = setting.max_iter;
    eps_prim = setting.eps_prim;
    eps_dual = setting.eps_dual;
}

Parameter::Parameter(Parameter &parameter) {
    alpha = parameter.alpha;
    rho = parameter.rho;
    sigma = parameter.sigma;
}

Data::Data(Data &data) {
    n = data.n;
    m = data.m;
    P.values = data.P.values;
    A.values = data.A.values;
    l = data.l;
    u = data.u;

}

Solution::Solution(Solution &solution) {
    norm1 = solution.norm1;
    norm2 = solution.norm2;
}