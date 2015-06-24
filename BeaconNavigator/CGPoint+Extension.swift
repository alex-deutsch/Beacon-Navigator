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
}