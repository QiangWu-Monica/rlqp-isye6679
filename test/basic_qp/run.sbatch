#!/bin/bash

#SBATCH -J isye6679-osqp-test-basic-qp
#SBATCH -N 1 --ntasks-per-node=2
#SBATCH -t 15
#SBATCH -p ice-cpu
#SBATCH -oReport-%j.out

module purge
module load python

cd ISYE6679/proj/main/test/basic_qp

pip install --upgrade pip
pip install numpy
python generate_problem.py
