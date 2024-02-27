#include <getopt.h>
#include <sys/time.h>
#include <unistd.h>
#include "utils/tensor.cuh"
#include "ops/op_mm.cuh"
#include "ops/op_elemwise.cuh"

unsigned long long randgen_seed = 0;
void test_matmul(int m, int n, int k, bool on_gpu) {
    Tensor<float> A{m, k, on_gpu};
    op_uniform_init(A);
    Tensor<float> B{k, n, on_gpu};
    op_uniform_init(B);
    Tensor<float> C{m, n, on_gpu};
    op_mm(A, B, C);
    Tensor<float> C2{n, m, on_gpu};
    op_mm(B.transpose(), A.transpose(), C2);
    assert(op_allclose(C2.transpose(), C)); // test transpose
}

int main(int argc, char *argv[]) {
    bool test_gpu = true;
    int test_m = 335, test_n = 587, test_k= 699;
    for (;;) {
        switch (getopt(argc, argv, "s:cm:n:k:")) {
        case 's':
            randgen_seed = atoll(optarg);
            continue;
        case 'c': //cpu testing only
            test_gpu = false;
            continue;
        case 'm':
            test_m = atoi(optarg);
            continue;
        case 'n':
            test_n = atoi(optarg);
            continue;
        case 'k':
            test_k = atoi(optarg);
            continue;
        case -1:
            break;
        }
        break;
    }
    struct timeval start, finish;
    gettimeofday(&start, NULL);
    test_matmul(test_m, test_n, test_k, test_gpu);
    cudaDeviceSynchronize();
    gettimeofday(&finish, NULL);
    double t = (finish.tv_sec - start.tv_sec) * 1000000 + (finish.tv_usec - start.tv_usec);
    std::cout << t / 1000 << std::endl;  // ms
    return 0;
}
