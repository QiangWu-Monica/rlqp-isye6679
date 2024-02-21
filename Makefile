CUDA_ROOT_DIR=/usr/local/cuda
SDIR=src
ODIR=build
IDIR=include

CC=g++
CCFLAGS=-I$(IDIR)
CCLIBS=

NVCC=nvcc
NVCCFLAGS=-I$(IDIR) -g -O0 -acc=gpu

CUDALIBDIR=-L$(CUDA_ROOT_DIR)/lib64
CUDAINCDIR=-I$(CUDA_ROOT_DIR)/include
CUDALINKLIBS=-lcudart -lcublas -lcusolver

all: my_osqp

OBJS=$(ODIR)/setup.o $(ODIR)/my_test.o $(ODIR)/problem.o $(ODIR)/kernels.o

$(ODIR)/setup.o: $(SDIR)/setup.cpp $(IDIR)/setup.h
	$(NVCC) -c -G -diag-suppress 549 -o $@ $< $(CCFLAGS) $(CUDAINCDIR)
	$(info Compiled $@)

$(ODIR)/my_test.o: test/my_test/maintest.cpp
	$(NVCC) -c -G -diag-suppress 549 -o $@ $< $(CCFLAGS) $(CUDAINCDIR)
	$(info Compiled $@)

$(ODIR)/kernels.o: $(SDIR)/kernels.cu $(IDIR)/kernels.h
	$(NVCC) -c -G -diag-suppress 549 -o $@ $< $(CCFLAGS) $(CUDAINCDIR)
	$(info Compiled $@)

$(ODIR)/problem.o: $(SDIR)/problem.cu $(IDIR)/problem.h $(IDIR)/errs.h $(IDIR)/setup.h $(ODIR)/kernels.o
	$(NVCC) -c -G -diag-suppress 549 -o $@ $< $(CCFLAGS) $(CUDAINCDIR)
	$(info Compiled $@)

my_osqp: $(OBJS)
	$(NVCC) -o $@ -G -O0 -g $^ $(CCFLAGS) $(CUDALIBDIR) $(CUDALINKLIBS)
	$(info Linked $@)

clean:
	$(RM) $(ODIR)/*.o my_osqp