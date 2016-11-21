//
//  Temper.swift
//  Temper
//
//  Created by Mihai Seremet on 8/28/15.
//  Copyright © 2015 Yopeso. All rights reserved.
//

import Foundation

internal typealias Result = (isOk: Bool, message: String?, value: Int?)

final class Temper {
    
    var rules: [Rule]
    fileprivate let outputPath: String
    fileprivate var violations: [Violation]
    fileprivate var output: OutputCoordinator
    fileprivate var currentPath: String?
    fileprivate var reporters: [Reporter]
    fileprivate var fileWasChecked = false
    static var statistics = TemperStatistics()
    var resultsOutput = [ResultOutput]()
    
    var path: String {
        return outputPath
    }
    
    /**
     Temper module initializer
     
     If the path is wrong, the current directory path will be used as output path
     
     For reporter customization, call setReporters([Reporter]) method with needed reporters
     For rule customization, call setLimits([String:Int]) method with needed limits
     For check the content for violations, call checkContent(FileContent) method
     For finish and generate the reporters, call finishTempering() method
     
     :param: outputPath The output path when will be created the reporters
     */
    
    init(outputPath: String) {
        if !FileManager.default.fileExists(atPath: outputPath) {
            print("Temper: Wrong output path! The current directory path will be used as output path!")
            self.outputPath = FileManager.default.currentDirectoryPath
        } else {
            self.outputPath = outputPath
        }
        rules = RulesFactory().getRules()
        violations = [Violation]()
        output = OutputCoordinator(filePath: outputPath)
        reporters = [Reporter(PMDReporter())]
    }
    
    /**
     This method check the content of file for violations
     
     For finish and generate the reporters, call finishTempering() method
     
     :param: content The content of file parsed in components
     */
    
    func checkContent(_ content: FileContent) {
        Temper.statistics.totalFiles += 1
        fileWasChecked = false
        currentPath = content.path
        let initialViolations = violations.count
        startAnalazy(content.components)
        
        resultsForFile(currentPath, violations: violations.count - initialViolations)
    }
    
    func resultsForFile(_ currentPath: String?, violations: Int) {
        guard let path = currentPath , path.characters.count > outputPath.characters.count else { return }
        let relativePath: String = (path as NSString).substring(from: outputPath.characters.count + 1)
        resultsOutput.append(ResultOutput(path: relativePath,
            warnings: violations))
    }
    
    /**
     This method set the reporters. If method is not called, PMD reporter will be used as default.
     
     :param: reporters An array of reporters:
     * PMD (xml file)
     * JSON (json file)
     * Xcode (Xcode IDE warnings/error)
     * Plain (text file)
     */
    
    func setReporters(_ reporters: [Reporter]) {
        self.reporters = reporters
    }
    
    /**
     This method is called when there are no more content for checking. It will create the reporters and write the violations.
     */
    
    func finishTempering() {
        output.writeTheOutput(violations, reporters: reporters)
    }
    
    /**
     This method set the limits of the rules. The limits should be greather than 0
     
     :param: limits A dictionary with the rule name as key and unsigned int as value(the limit)
     */
    
    func setLimits(_ limits: [String:Int]) {
        rules = rules.map({ ( rule: Rule) -> Rule in
            var mutableRule = rule
            if let limit = limits[rule.rule] {
                mutableRule.limit = limit
            }
            return mutableRule
        })
    }
    
    // Private methods
    
    fileprivate func startAnalazy(_ components: [Component]) {
        for component in components {
            for rule in rules {
                checkPair(rule: rule, component: component)
            }
            if !component.components.isEmpty {
                startAnalazy(component.components)
            }
        }
    }
    
    fileprivate func checkPair(rule: Rule, component: Component) {
        guard let path = currentPath else { return }
        let result = rule.checkComponent(component)
        guard !result.isOk else { return }
        
        if let message = result.message,
            let value = result.value {
                let violation = Violation(component: component, rule: rule, violationData: ViolationData(message: message, path: path, value: value))
                violations.append(violation)
                updateStatisticsWithViolation(violation)
        }
    }
    
    fileprivate func updateStatisticsWithViolation(_ violation: Violation) {
        if !fileWasChecked {
            fileWasChecked = true
            Temper.statistics.filesWithViolations += 1
        }
        switch violation.rule.priority {
        case 1: Temper.statistics.violationsWithP1 += 1
        case 2: Temper.statistics.violationsWithP2 += 1
        default: Temper.statistics.violationsWithP3 += 1
        }
    }
}


struct TemperStatistics {
    var totalFiles: Int = 0
    var filesWithViolations: Int = 0
    var violationsWithP1: Int = 0
    var violationsWithP2: Int = 0
    var violationsWithP3: Int = 0
}
