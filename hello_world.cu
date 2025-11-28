#include <stdio.h>

//set up kernel
__global__ void hello_world(){
    printf("Hello World from Thread %d !\n",threadIdx.x);
}

int main(void){
    //call kernel
    hello_world<<<1,1>>>();
    //wait for gpu
    cudaDeviceSynchronize();
    return 0;
}