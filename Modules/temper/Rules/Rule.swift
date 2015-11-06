//
//  Rule.swift
//  Temper
//
//  Created by Mihai Seremet on 8/28/15.
//  Copyright © 2015 Yopeso. All rights reserved.
//


public protocol Rule {
    
    /**
        The rule name
    */
    
    var rule : String { get }
    
    /**
        The rule priority
    */
    
    var priority : Int { get set }
    
    /**
        The external info about the rule
    */
    
    var externalInfoUrl : String { get }
    
    /**
        The rule limit
    */
    
    var limit : Int { get set }
    
    /**
        The method check the component for violations
        
        :param: component The component for checking
        :param: atPath The path of file that contains the component
    
        :returns: bool isOk A bool value that indicates if the component is violationg the rule
        :returns: String? message The message with the infor of the violations, in the component is violationg the rule
        :returns: Int? value The value of the violation, if the component is violation the rule
    */
    
    func checkComponent(component: Component, atPath: String) -> (isOk: Bool, message: String?, value: Int?)
    
    /**
        The method format the message for reporters
        
        :param: name The name of the component
        :param: value The violation value
        
        :returns: String The formatted message for reporters
    */
    
    func formatMessage(name: String, value: Int) -> String
}