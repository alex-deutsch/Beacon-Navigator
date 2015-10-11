//
//  NonLinear.h
//  Group5iBeacons
//
//  Created by Nemanja Joksovic on 6/11/14.
//  Copyright (c) 2014 John Tubert. All rights reserved.
//

#import <Foundation/Foundation.h>
@interface BeaconCalculus : NSObject

+ (NSArray *)determinePositionUsingNonLinearLeastSquare:(NSArray *)transmissions;
+ (NSArray *)determinePositionUsingLeastSquare:(NSArray *)transmissions;
+ (NSArray *)curveFitting:(NSDictionary *)values;

@end
