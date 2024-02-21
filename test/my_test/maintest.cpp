#include <iostream>
#include <string>
#include "problem.h"
using namespace std;

int main() {
    Problem *prob1;
    prob1->data.n = 2;
    prob1->data.m = 4;

    prob1->data.P.values = new double[4];
    prob1->data.P.values[0] = 4.0;
    prob1->data.P.values[1] = 1.0;
    prob1->data.P.values[2] = 1.0;
    prob1->data.P.values[3] = 2.0;
    prob1->data.q = new double[2];
    prob1->data.q[0] = 1.0;
    prob1->data.q[1] = 1.0;

    prob1->data.A.values = new double[8];
    prob1->data.A.values[0] = 1.0;
    prob1->data.A.values[1] = 1.0;
    prob1->data.A.values[2] = 0.0;
    prob1->data.A.values[3] = 0.0;
    prob1->data.A.values[4] = 1.0;
    prob1->data.A.values[5] = 0.0;
    prob1->data.A.values[6] = 1.0;
    prob1->data.A.values[7] = 1.0;

    prob1->data.l = new double[4];
    prob1->data.l[0] = 1.0;
    prob1->data.l[1] = 0.0;
    prob1->data.l[2] = 0.0;
    prob1->data.l[3] = -INFINITY;

    prob1->data.u = new double[4];
    prob1->data.u[0] = 1.0;
    prob1->data.u[1] = 0.7;
    prob1->data.u[2] = 0.7;
    prob1->data.u[3] = INFINITY;

    prob1->solution.x = new double[2];
    prob1->solution.y = new double[4];
    prob1->solution.z = new double[4];

    prob1->solution.x[0] = 1.0;
    prob1->solution.x[1] = 1.0;
    prob1->solution.y[0] = 1.0;
    prob1->solution.y[1] = 1.0;
    prob1->solution.y[2] = 1.0;
    prob1->solution.y[3] = 1.0;
    prob1->solution.z[0] = 1.0;
    prob1->solution.z[1] = 1.0;
    prob1->solution.z[2] = 1.0;
    prob1->solution.z[3] = 1.0;

    prob1->setting.eps_dual = 0.01;
    prob1->setting.eps_prim = 0.01;

    prob1->parameter.alpha = 1.0;
    prob1->parameter.sigma = 0.8;
    prob1->parameter.rho = 0.9;

    prob1->cu_all_osqp();

    prob1->print();

    delete[] prob1->data.P.values;
    delete[] prob1->data.q;
    delete[] prob1->data.A.values;
    delete[] prob1->data.l;
    delete[] prob1->data.u;
    delete[] prob1->solution.x;
    delete[] prob1->solution.y;
    delete[] prob1->solution.z;
    return 0;
}