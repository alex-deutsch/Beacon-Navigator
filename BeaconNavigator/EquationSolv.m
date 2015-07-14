//
//  EquationSolv.m
//  BeaconNavigator
//
//  Created by Alex Deutsch on 14.07.15.
//  Copyright (c) 2015 Alexander Deutsch. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <Accelerate/Accelerate.h>

#define N 3
#define NRHS 1
#define LDA N
#define LDB N

void print_matrix(size_t rows, size_t columns, __CLPK_real *mat) {
    for(size_t r = 0; r < rows; ++r) {
        for(size_t c = 0; c < columns; ++c) {
            printf("%6.2f ", mat[r * columns + c]);
        }
        printf("\n");
    }
}

void solve_system() {
    __CLPK_integer n = N, nrhs = NRHS, lda = LDA, ldb = LDB, info;
    __CLPK_integer ipiv[N];
    
    __CLPK_real a[LDA * N] = {
        2, 3, 0,
        0, 2, 0,
        3, 2, 0,
    };
    
    __CLPK_real b[LDB * NRHS] = {
        1, 2, 1,
    };
    
    // Solve A * x = b
    sgesv_(&n, &nrhs, a, &lda, ipiv, b, &ldb, &info);
    
    if(info > 0) {
        // A is singular; solution is not unique.
    }
    
    print_matrix(N, NRHS, b);
}

