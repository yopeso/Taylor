//
//  Exceptions.swift
//  Taylor
//
//  Created by Seremet Mihai on 11/26/15.
//  Copyright © 2015 YOPESO. All rights reserved.
//

import Foundation

enum TestError: ErrorType {
    case FileNotFound(String)
    case BundleResourcePathNotFound
    case CurrentDirectoryPathNotAccesible
}