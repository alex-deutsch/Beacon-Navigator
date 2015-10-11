//
//  NonLinear.m
//  Group5iBeacons
//
//  Created by Nemanja Joksovic on 6/11/14.
//  Copyright (c) 2014 John Tubert. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "BeaconCalculus.h"
#include <iostream>

#include "LevenbergMarquardt.h"

@implementation BeaconCalculus

/*
 * Non-Linear Least Squares / Levenberg Marquardt
 */
+ (NSArray *)determinePositionUsingNonLinearLeastSquare:(NSArray *)transmissions
{
    if (!transmissions || [transmissions count] == 0) {
        return nil;
    }
    else {
        int count = (int)[transmissions count];
        
        Eigen::VectorXd x(2);
        x << 0, 0;

        Eigen::MatrixXd matrix([transmissions count], 3);

        for (int i = 0; i < count; i++) {
            NSDictionary *transmission = transmissions[i];

            Eigen::VectorXd t(3);
            CGFloat x = [transmission[@"x"] floatValue];
            CGFloat y = [transmission[@"y"] floatValue];
            CGFloat accuracy = [transmission[@"accuracy"] floatValue];
            t << x,
                  y,
                   accuracy;
            
            matrix.row(i) = t;
        }
        
    
        distance_functor functor(matrix, count);
        Eigen::NumericalDiff<distance_functor> numDiff(functor);
        Eigen::LevenbergMarquardt<Eigen::NumericalDiff<distance_functor>,double> lm(numDiff);
        lm.parameters.maxfev = 2000;
        lm.parameters.xtol = 1.49012e-08;
        lm.parameters.ftol = 1.49012e-08;
        lm.parameters.gtol = 0;
        lm.parameters.epsfcn = 0;
        Eigen::LevenbergMarquardtSpace::Status ret = lm.minimize(x);

        if (ret == 1) {
            NSNumber *x1 = [NSNumber numberWithFloat:x[0]];
            NSNumber *y = [NSNumber numberWithFloat:x[1]];
            NSNumber *z = [NSNumber numberWithFloat:0];
            return [[NSArray alloc] initWithObjects:x1,y,z, nil];
        }
        else {
            return nil;
        }
    }
}

/*
 * Least Squares
 */
+ (NSArray *)determinePositionUsingLeastSquare:(NSArray *)transmissions
{
    if (!transmissions || [transmissions count] == 0) {
        return nil;
    }
    else {
        int count = (int)[transmissions count];
        
        Eigen::MatrixXd A([transmissions count], 3);
        Eigen::VectorXd b([transmissions count]);
        
        CGFloat x1 = [transmissions[0][@"x"] floatValue];
        CGFloat y1 = [transmissions[0][@"y"] floatValue];
        CGFloat d1 = [transmissions[0][@"accuracy"] floatValue];
        
        for (int i = 1; i < count; i++) {
            NSDictionary *transmission = transmissions[i];
            
            Eigen::VectorXd t(3);
            Eigen::VectorXd b1(1);
            CGFloat x = [transmission[@"x"] floatValue];
            CGFloat y = [transmission[@"y"] floatValue];
            CGFloat d = [transmission[@"accuracy"] floatValue];
            CGFloat di1 = pow((x - x1),2) + pow((y - y1),2);
            CGFloat bi1 = 0.5 * (pow(d1,2) - pow(d,2) + di1);
            
            t << (x - x1),
            (y - y1),
            0;
            b1 << bi1;
            
            A.row(i) = t;
            
            b.row(i) = b1;
        }
        
        Eigen::VectorXd ret = (A.transpose() * A).ldlt().solve(A.transpose() * b);
        
        Eigen::VectorXd ret1 = A.jacobiSvd(Eigen::ComputeThinU | Eigen::ComputeThinV).solve(b);
        Eigen::VectorXd ret2 = A.colPivHouseholderQr().solve(b);
        
//        std::cout << "RET0 " << ret << "\n" << std::endl;
//        std::cout << "RET1 " << ret1 << "\n" << std::endl;
//        std::cout << "RET2 " << ret2 << "\n" << std::endl;
//        std::cout << "Equation " << A << "*" << b << "\n"  << std::endl;

        NSNumber *x = [NSNumber numberWithFloat:ret[0] + x1];
        NSNumber *y = [NSNumber numberWithFloat:ret[1] + y1];
        NSNumber *z = [NSNumber numberWithFloat:0];
        return [[NSArray alloc] initWithObjects:x,y,z, nil];
    }
}

/*
 * Calculates polynomal curve which fits best by using Least Squares
 * @param values key, value pair with the 2 variables two be fitted
 */

+ (NSArray *)curveFitting:(NSDictionary *)values
{
    if (!values || [values count] == 0) {
        return nil;
    }
    else {
        
        Eigen::VectorXd x(3);
        x.fill(0);
        
        Eigen::MatrixXd matrix(3, 3);
        
        
        float sumX = 0;
        float sumX2 = 0;
        float sumX3 = 0;
        float sumX4 = 0;
        float sumY = 0;
        float sumXY = 0;
        float sumX2Y = 0;
        
        for(NSNumber *key in values) {
            CGFloat x = [key floatValue];
            CGFloat y = [[values objectForKey:key] floatValue];
            
            sumX += x;
            sumX2 += x * x;
            sumX3 += x * x * x;
            sumX4 += x * x * x * x;
            sumY += y;
            sumXY += x * y;
            sumX2Y += x * x * y;
            
        }
        
        Eigen::VectorXd t0(3);
        t0 << sumY,sumXY, sumX2Y;
        
        Eigen::VectorXd t(3);
        t << values.count, sumX, sumX2;
        matrix.row(0) = t;
        Eigen::VectorXd t1(3);
        t1 << sumX, sumX2, sumX3;
        matrix.row(1) = t1;
        Eigen::VectorXd t2(3);
        t2 << sumX2, sumX3, sumX4;
        matrix.row(2) = t2;
        
        Eigen::VectorXd x1 = matrix.inverse() * t0;
        

            NSNumber *a0 = [NSNumber numberWithFloat:x1[0]];
            NSNumber *a1 = [NSNumber numberWithFloat:x1[1]];
            NSNumber *a2 = [NSNumber numberWithFloat:x1[2]];
            return @[a0,a1,a2];

    }
   }

@end
