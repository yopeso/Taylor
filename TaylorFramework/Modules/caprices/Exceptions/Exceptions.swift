//
//  ExceptionAnalyzer.swift
//  Caprices
//
//  Created by Dmitrii Celpan on 9/4/15.
//  Copyright © 2015 yopeso.dmitriicelpan. All rights reserved.
//

enum CommandLineError: ErrorType {
    case InvalidOption(String)
    case AbuseOfOptions(String)
    case InvalidExclude(String)
    case InvalidArguments(String)
    case ExcludesFileError(String)
    case CannotReadFromHelpFile
    case InvalidInformationalOption(String)
}
