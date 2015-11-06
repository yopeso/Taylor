//
//  TestsHelper.swift
//  Temper
//
//  Created by Mihai Seremet on 9/1/15.
//  Copyright © 2015 Yopeso. All rights reserved.
//

import Foundation

@testable import TaylorFramework

class TestsHelper {
    var parametrizedFunctionComponent : Component {
        let component = Component(type: ComponentType.Function, range: ComponentRange(sl: 10, el: 20))
        component.makeComponent(type: ComponentType.Parameter, range: ComponentRange(sl: 10, el: 10))
        component.makeComponent(type: ComponentType.Parameter, range: ComponentRange(sl: 10, el: 10))
        component.makeComponent(type: ComponentType.Parameter, range: ComponentRange(sl: 10, el: 10))
        component.makeComponent(type: ComponentType.Parameter, range: ComponentRange(sl: 10, el: 10))
        return component
    }
    var whileComponent : Component {
        let component = Component(type: ComponentType.Function, range: ComponentRange(sl: 10, el: 20))
        let whileComponent = component.makeComponent(type: ComponentType.While, range: ComponentRange(sl: 10 , el: 12))
        whileComponent.makeComponent(type: ComponentType.Or, range: ComponentRange(sl: 13 , el: 15))
        whileComponent.makeComponent(type: ComponentType.And, range: ComponentRange(sl: 16 , el: 18))
        whileComponent.makeComponent(type: ComponentType.If, range: ComponentRange(sl: 19 , el: 20))
        whileComponent.makeComponent(type: ComponentType.If, range: ComponentRange(sl: 19 , el: 20))
        return component
    }
    
    var ifComponent : Component {
        let component = Component(type: ComponentType.Function, range: ComponentRange(sl: 10, el: 20), name: "if")
        component.makeComponent(type: ComponentType.If, range: ComponentRange(sl: 10 , el: 12)).makeComponent(type: ComponentType.Ternary, range: ComponentRange(sl: 0, el: 0))
        component.makeComponent(type: ComponentType.If, range: ComponentRange(sl: 10 , el: 12)).makeComponent(type: ComponentType.NilCoalescing, range: ComponentRange(sl: 0, el: 0))
        component.makeComponent(type: ComponentType.If, range: ComponentRange(sl: 10 , el: 12)).makeComponent(type: ComponentType.Ternary, range: ComponentRange(sl: 0, el: 0))
        component.makeComponent(type: ComponentType.If, range: ComponentRange(sl: 10 , el: 12)).makeComponent(type: ComponentType.NilCoalescing, range: ComponentRange(sl: 0, el: 0))
        component.makeComponent(type: ComponentType.If, range: ComponentRange(sl: 10 , el: 12)).makeComponent(type: ComponentType.Ternary, range: ComponentRange(sl: 0, el: 0))
        return component
    }
    
    var ifElseComponent : Component {
        let component = Component(type: ComponentType.Function, range: ComponentRange(sl: 10, el: 20))
        component.makeComponent(type: ComponentType.If, range: ComponentRange(sl: 10 , el: 12))
        component.makeComponent(type: ComponentType.Else, range: ComponentRange(sl: 10 , el: 12))
        component.makeComponent(type: ComponentType.If, range: ComponentRange(sl: 10 , el: 12))
        component.makeComponent(type: ComponentType.Else, range: ComponentRange(sl: 10 , el: 12))
        return component
    }
    
    var ifElseIfComponent : Component {
        let component = Component(type: ComponentType.Function, range: ComponentRange(sl: 10, el: 20))
        component.makeComponent(type: ComponentType.If, range: ComponentRange(sl: 10 , el: 12))
        component.makeComponent(type: ComponentType.ElseIf, range: ComponentRange(sl: 10 , el: 12))
        component.makeComponent(type: ComponentType.Else, range: ComponentRange(sl: 10 , el: 12))
        return component
    }
    
    var repeatComponent : Component {
        let component = Component(type: ComponentType.Function, range: ComponentRange(sl: 10, el: 20))
        let repeatComponent = component.makeComponent(type: ComponentType.Repeat, range: ComponentRange(sl: 10 , el: 12))
        repeatComponent.makeComponent(type: ComponentType.And, range: ComponentRange(sl: 10 , el: 12))
        repeatComponent.makeComponent(type: ComponentType.Or, range: ComponentRange(sl: 10 , el: 12))
        repeatComponent.makeComponent(type: ComponentType.And, range: ComponentRange(sl: 10 , el: 12))
        return component
    }
    
    var forComponent : Component {
        let component = Component(type: ComponentType.Function, range: ComponentRange(sl: 10, el: 20))
        let forComponent = component.makeComponent(type: ComponentType.For, range: ComponentRange(sl: 10 , el: 12))
        forComponent.makeComponent(type: ComponentType.And, range: ComponentRange(sl: 10 , el: 12))
        forComponent.makeComponent(type: ComponentType.Or, range: ComponentRange(sl: 10 , el: 12))
        forComponent.makeComponent(type: ComponentType.Repeat, range: ComponentRange(sl: 10 , el: 12)).makeComponent(type: ComponentType.And, range: ComponentRange(sl: 0, el: 0))
        return component
    }
    
    var switchComponent : Component {
        let component = Component(type: ComponentType.Function, range: ComponentRange(sl: 10, el: 20))
        let switchComponent = component.makeComponent(type: ComponentType.Switch, range: ComponentRange(sl: 10 , el: 12))
        switchComponent.makeComponent(type: ComponentType.Case, range: ComponentRange(sl: 10, el: 12)).makeComponent(type: ComponentType.If, range: ComponentRange(sl: 0, el: 0))
        switchComponent.makeComponent(type: ComponentType.Case, range: ComponentRange(sl: 10, el: 12)).makeComponent(type: ComponentType.If, range: ComponentRange(sl: 0, el: 0))
        switchComponent.makeComponent(type: ComponentType.Case, range: ComponentRange(sl: 10, el: 12)).makeComponent(type: ComponentType.If, range: ComponentRange(sl: 0, el: 0))
        switchComponent.makeComponent(type: ComponentType.Case, range: ComponentRange(sl: 10, el: 12)).makeComponent(type: ComponentType.If, range: ComponentRange(sl: 0, el: 0))
        return component
    }
    
    var ternaryComponent : Component {
        let component = Component(type: ComponentType.Function, range: ComponentRange(sl: 10, el: 20))
        let ternary1 = component.makeComponent(type: ComponentType.Ternary, range: ComponentRange(sl: 10, el: 12))
        let ternary2 = component.makeComponent(type: ComponentType.Ternary, range: ComponentRange(sl: 10, el: 12))
        ternary1.makeComponent(type: ComponentType.And, range: ComponentRange(sl: 10, el: 12))
        ternary2.makeComponent(type: ComponentType.Or, range: ComponentRange(sl: 10, el: 12))
        return component
    }
    
    var nilCoalescingComponent : Component {
        let component = Component(type: ComponentType.Function, range: ComponentRange(sl: 10, el: 20))
        let nilCoalesing1 = component.makeComponent(type: ComponentType.NilCoalescing, range: ComponentRange(sl: 10, el: 12))
        let nilCoalesing2 = component.makeComponent(type: ComponentType.NilCoalescing, range: ComponentRange(sl: 10, el: 12))
        nilCoalesing1.makeComponent(type: ComponentType.And, range: ComponentRange(sl: 10, el: 12))
        nilCoalesing2.makeComponent(type: ComponentType.Or, range: ComponentRange(sl: 10, el: 12))
        return component
    }
    
    var nestedComponent : Component {
        let component = Component(type: ComponentType.Function, range: ComponentRange(sl: 10, el: 20))
        let ifComponent = component.makeComponent(type: ComponentType.If, range: ComponentRange(sl: 10, el: 12))
        ifComponent.makeComponent(type: ComponentType.And, range: ComponentRange(sl: 0, el: 0))
        let wC = ifComponent.makeComponent(type: ComponentType.While, range: ComponentRange(sl: 10, el: 12))
        wC.makeComponent(type: ComponentType.For, range: ComponentRange(sl: 0, el: 0)).makeComponent(type: ComponentType.Or, range: ComponentRange(sl: 0, el: 0))
        let repeatComponent = component.makeComponent(type: ComponentType.Repeat, range: ComponentRange(sl: 10, el: 12))
        repeatComponent.makeComponent(type: ComponentType.If, range: ComponentRange(sl: 10, el: 12)).makeComponent(type: ComponentType.Or, range: ComponentRange(sl: 0, el: 0))
        repeatComponent.makeComponent(type: ComponentType.Else, range: ComponentRange(sl: 10, el: 12))
        repeatComponent.makeComponent(type: ComponentType.And, range: ComponentRange(sl: 10, el: 12))
        repeatComponent.makeComponent(type: ComponentType.Or, range: ComponentRange(sl: 10, el: 12))
        let switchComponent = component.makeComponent(type: ComponentType.Switch, range: ComponentRange(sl: 10, el: 12))
        switchComponent.makeComponent(type: ComponentType.Or, range: ComponentRange(sl: 0, el: 0))
        let caseComponent1 = switchComponent.makeComponent(type: ComponentType.Case, range: ComponentRange(sl: 0, el: 0))
        let caseComponent2 = switchComponent.makeComponent(type: ComponentType.Case, range: ComponentRange(sl: 0, el: 0))
        let caseComponent3 = switchComponent.makeComponent(type: ComponentType.Case, range: ComponentRange(sl: 0, el: 0))
        caseComponent1.makeComponent(type: ComponentType.If, range: ComponentRange(sl: 0, el: 0))
        caseComponent1.makeComponent(type: ComponentType.Else, range: ComponentRange(sl: 0, el: 0)).makeComponent(type: ComponentType.Ternary, range: ComponentRange(sl: 0, el: 0))
        caseComponent2.makeComponent(type: ComponentType.If, range: ComponentRange(sl: 0, el: 0))
        caseComponent2.makeComponent(type: ComponentType.Else, range: ComponentRange(sl: 0, el: 0)).makeComponent(type: ComponentType.NilCoalescing, range: ComponentRange(sl: 0, el: 0))
        caseComponent3.makeComponent(type: ComponentType.For, range: ComponentRange(sl: 0, el: 0)).makeComponent(type: ComponentType.If, range: ComponentRange(sl: 0, el: 0))
        component.makeComponent(type: ComponentType.Ternary, range: ComponentRange(sl: 10, el: 12))
        let whileComponent = component.makeComponent(type: ComponentType.While, range: ComponentRange(sl: 10, el: 12))
        whileComponent.makeComponent(type: ComponentType.And, range: ComponentRange(sl: 0, el: 0))
        whileComponent.makeComponent(type: ComponentType.If, range: ComponentRange(sl: 0, el: 0)).makeComponent(type: ComponentType.Or, range: ComponentRange(sl: 0, el: 0))
        whileComponent.makeComponent(type: ComponentType.Else, range: ComponentRange(sl: 0, el: 0))
        return component
    }
    
    var ifElseIfElseNestedComponent : Component {
        let component = Component(type: ComponentType.Function, range: ComponentRange(sl: 10, el: 20))
        let ifComponent = component.makeComponent(type: ComponentType.If, range: ComponentRange(sl: 10, el: 12))
        let whileComponent = ifComponent.makeComponent(type: ComponentType.While, range: ComponentRange(sl: 0, el: 0))
        whileComponent.makeComponent(type: .And, range: ComponentRange(sl: 0, el: 0))
        whileComponent.makeComponent(type: .Ternary, range: ComponentRange(sl: 0, el: 0))
        let elseIfComponent = component.makeComponent(type: ComponentType.ElseIf, range: ComponentRange(sl: 10, el: 12))
        elseIfComponent.makeComponent(type: .Or, range: ComponentRange(sl: 0, el: 0))
        let forComponent = elseIfComponent.makeComponent(type: .For, range: ComponentRange(sl: 0, el: 0))
        forComponent.makeComponent(type: .Or, range: ComponentRange(sl: 0, el: 0))
        forComponent.makeComponent(type: .NilCoalescing, range: ComponentRange(sl: 0, el: 0))
        let elseComponent = component.makeComponent(type: ComponentType.Else, range: ComponentRange(sl: 10, el: 12))
        let switchComponent = elseComponent.makeComponent(type: .Switch, range: ComponentRange(sl: 0, el: 0))
        switchComponent.makeComponent(type: .Case, range: ComponentRange(sl: 0, el: 0))
        switchComponent.makeComponent(type: .Case, range: ComponentRange(sl: 0, el: 0))
        switchComponent.makeComponent(type: .Case, range: ComponentRange(sl: 0, el: 0)).makeComponent(type: .If, range: ComponentRange(sl: 0, el: 0))
        component.makeComponent(type: .If, range: ComponentRange(sl: 0, el: 0))
        return component
    }
    
    var aComponent : Component {
        let range = ComponentRange(sl: 84, el: 629)
        let component = Component(type: ComponentType.Class, range: range, name: "MyClass")
        return component
    }
    
    var anotherComponent : Component {       
        let range = ComponentRange(sl: 458, el: 550)
        let component = Component(type: ComponentType.Class, range: range, name: "deinit")
        return component
    }
    
    var componentWithManyMethods : Component {
        let range = ComponentRange(sl: 1, el: 2)
        let component = Component(type: ComponentType.Class, range: range, name: "deinit")
        
        return component
    }
    
    var aRule : Rule {
        let rules = RulesFactory().getRules()
        if let first = rules.first {
            return first
        } else {
            return CyclomaticComplexityRule()
        }
    }
    
    var componentForCyclomaticComplexity : Component {
        let component = Component(type: .Function, range: ComponentRange(sl: 3, el: 36), name: nil)
        let component1 = component.makeComponent(type: .If, range: ComponentRange(sl: 4, el: 11))
        let component2 = component.makeComponent(type: .ElseIf, range: ComponentRange(sl: 12, el: 15))
        let component3 = component.makeComponent(type: .ElseIf, range: ComponentRange(sl: 16, el: 19))
        let component4 = component.makeComponent(type: .Else, range: ComponentRange(sl: 20, el: 35))
        component1.makeComponent(type: .If, range: ComponentRange(sl: 5, el: 7))
        component1.makeComponent(type: .ElseIf, range: ComponentRange(sl: 7, el: 9))
        component1.makeComponent(type: .Else, range: ComponentRange(sl: 91, el: 11))
        component2.makeComponent(type: .While, range: ComponentRange(sl: 13, el: 15))
        component3.makeComponent(type: .For, range: ComponentRange(sl: 17, el: 19))
        let component5 = component4.makeComponent(type: .Switch, range: ComponentRange(sl: 21, el: 34))
        component5.makeComponent(type: .Case, range: ComponentRange(sl: 22, el: 24))
        component5.makeComponent(type: .Case, range: ComponentRange(sl: 25, el: 27))
        component5.makeComponent(type: .Case, range: ComponentRange(sl: 28, el: 30))
        component5.makeComponent(type: .Case, range: ComponentRange(sl: 31, el: 33))
        return component
    }
    
    var badComponentForNPathComplexity : Component {
        let component = Component(type: .Function, range: ComponentRange(sl: 3, el: 36), name: "someFunc")
        let component1 = component.makeComponent(type: .If, range: ComponentRange(sl: 4, el: 11))
        let component2 = component.makeComponent(type: .Else, range: ComponentRange(sl: 12, el: 15))
        component.components.append(makeSwitchComponent())
        _ = component.makeComponent(type: .If, range: ComponentRange(sl: 20, el: 35))
        _ = component.makeComponent(type: .Else, range: ComponentRange(sl: 12, el: 15))
        component1.makeComponent(type: .If, range: ComponentRange(sl: 5, el: 7))
        component1.makeComponent(type: .ElseIf, range: ComponentRange(sl: 7, el: 9))
        component1.makeComponent(type: .Else, range: ComponentRange(sl: 9, el: 11))
        component2.makeComponent(type: .If, range: ComponentRange(sl: 5, el: 7))
        component2.makeComponent(type: .Else, range: ComponentRange(sl: 7, el: 9))
        return component
    }
    
    func makeSwitchComponent() -> Component {
        let component = Component(type: .Switch, range: ComponentRange(sl: 16, el: 19))
        component.makeComponent(type: .Case, range: ComponentRange(sl: 22, el: 24))
        component.makeComponent(type: .Case, range: ComponentRange(sl: 25, el: 27))
        component.makeComponent(type: .Case, range: ComponentRange(sl: 28, el: 30))
        component.makeComponent(type: .Case, range: ComponentRange(sl: 31, el: 33))
        component.makeComponent(type: .Case, range: ComponentRange(sl: 31, el: 33))
        for subComponent in component.components {
            subComponent.makeComponent(type: .If, range: ComponentRange(sl: 5, el: 7))
            subComponent.makeComponent(type: .Else, range: ComponentRange(sl: 5, el: 7))
        }
        return component
    }
    
    var componentForNPathComplexity : Component {
        let component = Component(type: .Function, range: ComponentRange(sl: 3, el: 36))
        component.makeComponent(type: .If, range: ComponentRange(sl: 4, el: 11))
        component.makeComponent(type: .Else, range: ComponentRange(sl: 20, el: 35))
        component.makeComponent(type: .If, range: ComponentRange(sl: 4, el: 11))
        component.makeComponent(type: .Else, range: ComponentRange(sl: 20, el: 35))
        component.makeComponent(type: .If, range: ComponentRange(sl: 4, el: 11))
        component.makeComponent(type: .Else, range: ComponentRange(sl: 20, el: 35))
        component.makeComponent(type: .If, range: ComponentRange(sl: 4, el: 11))
        component.makeComponent(type: .Else, range: ComponentRange(sl: 20, el: 35))
        component.makeComponent(type: .If, range: ComponentRange(sl: 4, el: 11))
        component.makeComponent(type: .Else, range: ComponentRange(sl: 20, el: 35))
        component.makeComponent(type: .If, range: ComponentRange(sl: 4, el: 11))
        component.makeComponent(type: .Else, range: ComponentRange(sl: 20, el: 35))
        let switchComponent = component.makeComponent(type: .Switch, range: ComponentRange(sl: 20, el: 35))
        switchComponent.makeComponent(type: .Case, range: ComponentRange(sl: 0, el: 0))
        switchComponent.makeComponent(type: .Case, range: ComponentRange(sl: 0, el: 0))
        switchComponent.makeComponent(type: .Case, range: ComponentRange(sl: 0, el: 0))
        switchComponent.makeComponent(type: .Case, range: ComponentRange(sl: 0, el: 0))
        switchComponent.makeComponent(type: .Case, range: ComponentRange(sl: 0, el: 0))
        return component
    }
    
    var testComponent : Component {
        let component = Component(type: .Function, range: ComponentRange(sl: 0, el: 0))
        let repeatComponent = component.makeComponent(type: .Repeat, range: ComponentRange(sl: 0, el: 0))
        let ifComponent = repeatComponent.makeComponent(type: .If, range: ComponentRange(sl: 0, el: 0))
        let elseComponent = repeatComponent.makeComponent(type: .Else, range: ComponentRange(sl: 0, el: 0))
        ifComponent.makeComponent(type: .And, range: ComponentRange(sl: 0, el: 0))
        elseComponent.makeComponent(type: .Ternary, range: ComponentRange(sl: 0, el: 0))
        component.makeComponent(type: .If, range: ComponentRange(sl: 0, el: 0))
        component.makeComponent(type: .ElseIf, range: ComponentRange(sl: 0, el: 0))
        component.makeComponent(type: .Else, range: ComponentRange(sl: 0, el: 0))
        let forComponent = component.makeComponent(type: .For, range: ComponentRange(sl: 0, el: 0))
        forComponent.makeComponent(type: .Or, range: ComponentRange(sl: 0, el: 0))
        let forComponent2 = forComponent.makeComponent(type: .For, range: ComponentRange(sl: 0, el: 0))
        forComponent2.makeComponent(type: .And, range: ComponentRange(sl: 0, el: 0))
        forComponent2.makeComponent(type: .If, range: ComponentRange(sl: 0, el: 0))
        let switchComponent = component.makeComponent(type: .Switch, range: ComponentRange(sl: 0, el: 0))
        let case1 = switchComponent.makeComponent(type: .Case, range: ComponentRange(sl: 0, el: 0))
        let case2 = switchComponent.makeComponent(type: .Case, range: ComponentRange(sl: 0, el: 0))
        let case3 = switchComponent.makeComponent(type: .Case, range: ComponentRange(sl: 0, el: 0))
        case1.makeComponent(type: .NilCoalescing, range: ComponentRange(sl: 0, el: 0))
        case2.makeComponent(type: .Ternary, range: ComponentRange(sl: 0, el: 0))
        case3.makeComponent(type: .If, range: ComponentRange(sl: 0, el: 0))
        case3.makeComponent(type: .Else, range: ComponentRange(sl: 0, el: 0))
        return component
    }
    
    func addComponentsInDepthToComponent(component: Component) -> Component {
        let depth = 10
        func makeComponent(component: Component, var depth: Int) {
            let admisibleComponents = [ComponentType.If, ComponentType.While, ComponentType.For, ComponentType.Case, ComponentType.Brace]
            let type = admisibleComponents[Int(arc4random_uniform(5))]
            let component1 = component.makeComponent(type: type, range: ComponentRange(sl: 0, el: 0))
            if --depth > 0 {
                makeComponent(component1, depth: depth)
            }
        }
        makeComponent(component, depth: 10)
        return component
    }
    
    func makeClassComponentWithNrOfMethods(var count: Int) -> Component {
        let component = Component(type: ComponentType.Class, range: ComponentRange(sl: 0, el: 0))
        repeat {
            component.makeComponent(type: ComponentType.Function, range: ComponentRange(sl: 1, el: 10))
        } while --count > 0
        return component
    }
}



