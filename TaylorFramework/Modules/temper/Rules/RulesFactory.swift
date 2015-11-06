//
//  RulesFactory.swift
//  Temper
//
//  Created by Mihai Seremet on 8/28/15.
//  Copyright © 2015 Yopeso. All rights reserved.
//


class RulesFactory {
    func getRules() -> [Rule] {
        return [NumberOfLinesInMethodRule(), NumberOfLinesInClassRule(), NumberOfMethodsInClassRule(),
                CyclomaticComplexityRule(),  NestedBlockDepthRule(),     NPathComplexityRule(),
                ExcessiveParameterListRule()]
    }
}