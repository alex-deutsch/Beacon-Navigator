//
//  CGPoint+Extension.swift
//  BeaconNavigator
//
//  Created by Alex Deutsch on 24.06.15.
//  Copyright (c) 2015 Alexander Deutsch. All rights reserved.
//

import Foundation
import UIKit

extension CGPoint {
    func formatedString() -> String {
        return String.localizedStringWithFormat("( %.2f | %.2f )", Double(self.x), Double(self.y))
    }
    
    /* Calculates Distance between 2 Points
    *
    @param pointA the first point
    @param pointB the second point
    @return distance between given points
    *
    */
    func distanceToPoint(otherPoint : CGPoint) -> CGFloat {
        let value = pow(otherPoint.x - self.x, 2) + pow(otherPoint.y - self.y, 2)
        let value2 = fabsf(Float(value))
        let value3 = sqrt(value2)
        return CGFloat(value3)
    }

}