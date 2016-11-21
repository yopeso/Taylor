//
//  InformationalOption.swift
//  Caprices
//
//  Created by Alex Culeva on 11/2/15.
//  Copyright © 2015 yopeso.dmitriicelpan. All rights reserved.
//

import Foundation

protocol InformationalOption: Option {
    var argumentSeparator: String { get }
    func validateArgumentComponents(_ components: [String]) throws
}
