#include <stdio.h>
//define kernel
__global__ void vectorAdd(const float *a,const float *b,float *c,int N){
    //set index for each thread
    //kernel launched as Grid
    // each grid composed of thread blocks
    // block is a collection of threads
    int i = (blockDim.x*blockIdx.x)+threadIdx.x;
    // make sure no invalid memory access
    if (i < N){
        c[i] = a[i]+b[i];
    }
}

int main(void){
    //define vector size and memmory size
    int numElements = 50000;
    size_t size = numElements * sizeof(float);
    printf("Vector addition of %d elements\n", numElements);
    //allocate memory on CPU
    float *h_a = (float *)malloc(size);
    float *h_b = (float *)malloc(size);
    float *h_c = (float *)malloc(size);
    //fill cpu with dummy variables
    for (int i=0; i<numElements; i++){
        h_a[i]=rand()/(float)RAND_MAX;
        h_b[i]=rand()/(float)RAND_MAX;
    }   
    //allocate memory on gpu dynamic allocation -> initalize null array to get memmory malloc after with pointer to void *
    float *d_a = NULL;//use float here since we need to fill those array
    float *d_b = NULL;
    float *d_c = NULL;
    cudaMalloc((void **)&d_a,size);//cudamalloc here cause we use GPU duhhh
    cudaMalloc((void **)&d_b,size);
    cudaMalloc((void **)&d_c,size);    
    //copy arrays in GPU
    cudaMemcpy(d_a,h_a,size,cudaMemcpyHostToDevice);
    cudaMemcpy(d_b,h_b,size,cudaMemcpyHostToDevice);
    //excecute kernel
    int threads_block = 256;
    int blocks_perGrid = (numElements+threads_block-1)/threads_block;//just calculate ratio
    printf("Kernel runs with %d blocks of %dthreads\n",blocks_perGrid,threads_block);
    vectorAdd<<<blocks_perGrid,threads_block>>>(d_a,d_b,d_c,numElements);
    //check for kernel Error
    cudaError_t err = cudaGetLastError();
    if (err!=cudaSuccess){
        fprintf(stderr,"Failed Cuda vec_add lunch %s\n",cudaGetErrorString(err));
        exit(EXIT_FAILURE);
    }
    //copy array back
    cudaMemcpy(h_c,d_c,size,cudaMemcpyDeviceToHost);
    //verify if gpu did calculation and output some message
    for(int i =0;i <numElements;i++){
        if(fabs(h_a[i]+h_b[i]-h_c[i]>1e-4)){
            fprintf(stderr,"epsilon at Element larger than epsilon at idx %d\n",i);
            exit(EXIT_FAILURE);
        }
        
    }
    printf("Passed epsilon test");
    //free allocated memmory on h_ and d_
    cudaFree(&d_a);
    cudaFree(&d_b);
    cudaFree(&d_c);
    //return exit code int
    free(h_a);
    free(h_b);
    free(h_c);
    printf("Done\n");
    return 0;
}