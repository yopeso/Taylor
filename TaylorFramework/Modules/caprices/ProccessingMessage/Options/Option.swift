//
//  Option.swift
//  Caprices
//
//  Created by Dmitrii Celpan on 9/6/15.
//  Copyright © 2015 yopeso.dmitriicelpan. All rights reserved.
//

protocol Option {
    init(argument: String)
    var analyzePath: String {get set} // Path that currently is analyzed(some options can need them)
    var optionArgument: String {get set}
    var name: String { get }
}
