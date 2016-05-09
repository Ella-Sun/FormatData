//
//  File.swift
//  Test
//
//  Created by IOS-Sun on 16/4/29.
//  Copyright © 2016年 IOS-Sun. All rights reserved.
//

import Foundation

@objc class File: NSObject {
    internal func sayHappy(){
        let name = "liChang"
        (1...4).forEach{print("Happy Birthday " + (($0 == 3) ? "dear \(name)":"to You"))}
    }
}
