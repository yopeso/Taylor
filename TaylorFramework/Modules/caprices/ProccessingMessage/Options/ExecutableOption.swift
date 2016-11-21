//
//  ExecutableOption.swift
//  Caprices
//
//  Created by Alex Culeva on 11/2/15.
//  Copyright © 2015 yopeso.dmitriicelpan. All rights reserved.
//

import Foundation

protocol ExecutableOption: Option {
    func executeOnDictionary(_ dictionary: inout Options)
}
