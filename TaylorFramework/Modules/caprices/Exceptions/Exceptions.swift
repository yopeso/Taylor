//
//  ExceptionAnalyzer.swift
//  Caprices
//
//  Created by Dmitrii Celpan on 9/4/15.
//  Copyright © 2015 yopeso.dmitriicelpan. All rights reserved.
//

enum CommandLineError: Error {
    case invalidOption(String)
    case abuseOfOptions(String)
    case invalidExclude(String)
    case invalidArguments(String)
    case cannotReadFromHelpFile
    case invalidInformationalOption(String)
}
