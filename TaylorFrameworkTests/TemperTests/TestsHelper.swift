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
        let component = Component(type: ComponentType.function, range: ComponentRange(sl: 10, el: 20))
        _ = component.makeComponent(type: ComponentType.parameter, range: ComponentRange(sl: 10, el: 10))
        _ = component.makeComponent(type: ComponentType.parameter, range: ComponentRange(sl: 10, el: 10))
        _ = component.makeComponent(type: ComponentType.parameter, range: ComponentRange(sl: 10, el: 10))
        _ = component.makeComponent(type: ComponentType.parameter, range: ComponentRange(sl: 10, el: 10))
        return component
    }
    var whileComponent : Component {
        let component = Component(type: ComponentType.function, range: ComponentRange(sl: 10, el: 20))
        let whileComponent = component.makeComponent(type: ComponentType.while, range: ComponentRange(sl: 10 , el: 12))
        _ = whileComponent.makeComponent(type: ComponentType.or, range: ComponentRange(sl: 13 , el: 15))
        _ = whileComponent.makeComponent(type: ComponentType.and, range: ComponentRange(sl: 16 , el: 18))
        _ = whileComponent.makeComponent(type: ComponentType.if, range: ComponentRange(sl: 19 , el: 20))
        _ = whileComponent.makeComponent(type: ComponentType.if, range: ComponentRange(sl: 19 , el: 20))
        return component
    }
    
    var ifComponent : Component {
        let component = Component(type: ComponentType.function, range: ComponentRange(sl: 10, el: 20), name: "if")
        _ = component.makeComponent(type: ComponentType.if, range: ComponentRange(sl: 10 , el: 12)).makeComponent(type: ComponentType.ternary, range: ComponentRange(sl: 0, el: 0))
        _ = component.makeComponent(type: ComponentType.if, range: ComponentRange(sl: 10 , el: 12)).makeComponent(type: ComponentType.nilCoalescing, range: ComponentRange(sl: 0, el: 0))
        _ = component.makeComponent(type: ComponentType.if, range: ComponentRange(sl: 10 , el: 12)).makeComponent(type: ComponentType.ternary, range: ComponentRange(sl: 0, el: 0))
        _ = component.makeComponent(type: ComponentType.if, range: ComponentRange(sl: 10 , el: 12)).makeComponent(type: ComponentType.nilCoalescing, range: ComponentRange(sl: 0, el: 0))
        _ = component.makeComponent(type: ComponentType.if, range: ComponentRange(sl: 10 , el: 12)).makeComponent(type: ComponentType.ternary, range: ComponentRange(sl: 0, el: 0))
        return component
    }
    
    var ifElseComponent : Component {
        let component = Component(type: ComponentType.function, range: ComponentRange(sl: 10, el: 20))
        _ = component.makeComponent(type: ComponentType.if, range: ComponentRange(sl: 10 , el: 12))
        _ = component.makeComponent(type: ComponentType.else, range: ComponentRange(sl: 10 , el: 12))
        _ = component.makeComponent(type: ComponentType.if, range: ComponentRange(sl: 10 , el: 12))
        _ = component.makeComponent(type: ComponentType.else, range: ComponentRange(sl: 10 , el: 12))
        return component
    }
    
    var ifElseIfComponent : Component {
        let component = Component(type: ComponentType.function, range: ComponentRange(sl: 10, el: 20))
        _ = component.makeComponent(type: ComponentType.if, range: ComponentRange(sl: 10 , el: 12))
        _ = component.makeComponent(type: ComponentType.elseIf, range: ComponentRange(sl: 10 , el: 12))
        _ = component.makeComponent(type: ComponentType.else, range: ComponentRange(sl: 10 , el: 12))
        return component
    }
    
    var repeatComponent : Component {
        let component = Component(type: ComponentType.function, range: ComponentRange(sl: 10, el: 20))
        let repeatComponent = component.makeComponent(type: ComponentType.repeat, range: ComponentRange(sl: 10 , el: 12))
        _ = repeatComponent.makeComponent(type: ComponentType.and, range: ComponentRange(sl: 10 , el: 12))
        _ = repeatComponent.makeComponent(type: ComponentType.or, range: ComponentRange(sl: 10 , el: 12))
        _ = repeatComponent.makeComponent(type: ComponentType.and, range: ComponentRange(sl: 10 , el: 12))
        return component
    }
    
    var forComponent : Component {
        let component = Component(type: ComponentType.function, range: ComponentRange(sl: 10, el: 20))
        let forComponent = component.makeComponent(type: ComponentType.for, range: ComponentRange(sl: 10 , el: 12))
        _ = forComponent.makeComponent(type: ComponentType.and, range: ComponentRange(sl: 10 , el: 12))
        _ = forComponent.makeComponent(type: ComponentType.or, range: ComponentRange(sl: 10 , el: 12))
        _ = forComponent.makeComponent(type: ComponentType.repeat, range: ComponentRange(sl: 10 , el: 12)).makeComponent(type: ComponentType.and, range: ComponentRange(sl: 0, el: 0))
        return component
    }
    
    var switchComponent : Component {
        let component = Component(type: ComponentType.function, range: ComponentRange(sl: 10, el: 20))
        let switchComponent = component.makeComponent(type: ComponentType.switch, range: ComponentRange(sl: 10 , el: 12))
        _ = switchComponent.makeComponent(type: ComponentType.case, range: ComponentRange(sl: 10, el: 12)).makeComponent(type: ComponentType.if, range: ComponentRange(sl: 0, el: 0))
        _ = switchComponent.makeComponent(type: ComponentType.case, range: ComponentRange(sl: 10, el: 12)).makeComponent(type: ComponentType.if, range: ComponentRange(sl: 0, el: 0))
        _ = switchComponent.makeComponent(type: ComponentType.case, range: ComponentRange(sl: 10, el: 12)).makeComponent(type: ComponentType.if, range: ComponentRange(sl: 0, el: 0))
        _ = switchComponent.makeComponent(type: ComponentType.case, range: ComponentRange(sl: 10, el: 12)).makeComponent(type: ComponentType.if, range: ComponentRange(sl: 0, el: 0))
        return component
    }
    
    var ternaryComponent : Component {
        let component = Component(type: ComponentType.function, range: ComponentRange(sl: 10, el: 20))
        let ternary1 = component.makeComponent(type: ComponentType.ternary, range: ComponentRange(sl: 10, el: 12))
        let ternary2 = component.makeComponent(type: ComponentType.ternary, range: ComponentRange(sl: 10, el: 12))
        _ = ternary1.makeComponent(type: ComponentType.and, range: ComponentRange(sl: 10, el: 12))
        _ = ternary2.makeComponent(type: ComponentType.or, range: ComponentRange(sl: 10, el: 12))
        return component
    }
    
    var nilCoalescingComponent : Component {
        let component = Component(type: ComponentType.function, range: ComponentRange(sl: 10, el: 20))
        let nilCoalesing1 = component.makeComponent(type: ComponentType.nilCoalescing, range: ComponentRange(sl: 10, el: 12))
        let nilCoalesing2 = component.makeComponent(type: ComponentType.nilCoalescing, range: ComponentRange(sl: 10, el: 12))
        _ = nilCoalesing1.makeComponent(type: ComponentType.and, range: ComponentRange(sl: 10, el: 12))
        _ = nilCoalesing2.makeComponent(type: ComponentType.or, range: ComponentRange(sl: 10, el: 12))
        return component
    }
    
    var nestedComponent : Component {
        let component = Component(type: ComponentType.function, range: ComponentRange(sl: 10, el: 20))
        let ifComponent = component.makeComponent(type: ComponentType.if, range: ComponentRange(sl: 10, el: 12))
        _ = ifComponent.makeComponent(type: ComponentType.and, range: ComponentRange(sl: 0, el: 0))
        let wC = ifComponent.makeComponent(type: ComponentType.while, range: ComponentRange(sl: 10, el: 12))
        _ = wC.makeComponent(type: ComponentType.for, range: ComponentRange(sl: 0, el: 0)).makeComponent(type: ComponentType.or, range: ComponentRange(sl: 0, el: 0))
        let repeatComponent = component.makeComponent(type: ComponentType.repeat, range: ComponentRange(sl: 10, el: 12))
        _ = repeatComponent.makeComponent(type: ComponentType.if, range: ComponentRange(sl: 10, el: 12)).makeComponent(type: ComponentType.or, range: ComponentRange(sl: 0, el: 0))
        _ = repeatComponent.makeComponent(type: ComponentType.else, range: ComponentRange(sl: 10, el: 12))
        _ = repeatComponent.makeComponent(type: ComponentType.and, range: ComponentRange(sl: 10, el: 12))
        _ = repeatComponent.makeComponent(type: ComponentType.or, range: ComponentRange(sl: 10, el: 12))
        let switchComponent = component.makeComponent(type: ComponentType.switch, range: ComponentRange(sl: 10, el: 12))
        _ = switchComponent.makeComponent(type: ComponentType.or, range: ComponentRange(sl: 0, el: 0))
        let caseComponent1 = switchComponent.makeComponent(type: ComponentType.case, range: ComponentRange(sl: 0, el: 0))
        let caseComponent2 = switchComponent.makeComponent(type: ComponentType.case, range: ComponentRange(sl: 0, el: 0))
        let caseComponent3 = switchComponent.makeComponent(type: ComponentType.case, range: ComponentRange(sl: 0, el: 0))
        _ = caseComponent1.makeComponent(type: ComponentType.if, range: ComponentRange(sl: 0, el: 0))
        _ = caseComponent1.makeComponent(type: ComponentType.else, range: ComponentRange(sl: 0, el: 0)).makeComponent(type: ComponentType.ternary, range: ComponentRange(sl: 0, el: 0))
        _ = caseComponent2.makeComponent(type: ComponentType.if, range: ComponentRange(sl: 0, el: 0))
        _ = caseComponent2.makeComponent(type: ComponentType.else, range: ComponentRange(sl: 0, el: 0)).makeComponent(type: ComponentType.nilCoalescing, range: ComponentRange(sl: 0, el: 0))
        _ = caseComponent3.makeComponent(type: ComponentType.for, range: ComponentRange(sl: 0, el: 0)).makeComponent(type: ComponentType.if, range: ComponentRange(sl: 0, el: 0))
        _ = component.makeComponent(type: ComponentType.ternary, range: ComponentRange(sl: 10, el: 12))
        let whileComponent = component.makeComponent(type: ComponentType.while, range: ComponentRange(sl: 10, el: 12))
        _ = whileComponent.makeComponent(type: ComponentType.and, range: ComponentRange(sl: 0, el: 0))
        _ = whileComponent.makeComponent(type: ComponentType.if, range: ComponentRange(sl: 0, el: 0)).makeComponent(type: ComponentType.or, range: ComponentRange(sl: 0, el: 0))
        _ = whileComponent.makeComponent(type: ComponentType.else, range: ComponentRange(sl: 0, el: 0))
        return component
    }
    
    var ifElseIfElseNestedComponent : Component {
        let component = Component(type: ComponentType.function, range: ComponentRange(sl: 10, el: 20))
        let ifComponent = component.makeComponent(type: ComponentType.if, range: ComponentRange(sl: 10, el: 12))
        let whileComponent = ifComponent.makeComponent(type: ComponentType.while, range: ComponentRange(sl: 0, el: 0))
        _ = whileComponent.makeComponent(type: .and, range: ComponentRange(sl: 0, el: 0))
        _ = whileComponent.makeComponent(type: .ternary, range: ComponentRange(sl: 0, el: 0))
        let elseIfComponent = component.makeComponent(type: ComponentType.elseIf, range: ComponentRange(sl: 10, el: 12))
        _ = elseIfComponent.makeComponent(type: .or, range: ComponentRange(sl: 0, el: 0))
        let forComponent = elseIfComponent.makeComponent(type: .for, range: ComponentRange(sl: 0, el: 0))
        _ = forComponent.makeComponent(type: .or, range: ComponentRange(sl: 0, el: 0))
        _ = forComponent.makeComponent(type: .nilCoalescing, range: ComponentRange(sl: 0, el: 0))
        let elseComponent = component.makeComponent(type: ComponentType.else, range: ComponentRange(sl: 10, el: 12))
        let switchComponent = elseComponent.makeComponent(type: .switch, range: ComponentRange(sl: 0, el: 0))
        _ = switchComponent.makeComponent(type: .case, range: ComponentRange(sl: 0, el: 0))
        _ = switchComponent.makeComponent(type: .case, range: ComponentRange(sl: 0, el: 0))
        _ = switchComponent.makeComponent(type: .case, range: ComponentRange(sl: 0, el: 0)).makeComponent(type: .if, range: ComponentRange(sl: 0, el: 0))
        _ = component.makeComponent(type: .if, range: ComponentRange(sl: 0, el: 0))
        return component
    }
    
    var aComponent : Component {
        let range = ComponentRange(sl: 84, el: 629)
        let component = Component(type: ComponentType.class, range: range, name: "MyClass")
        return component
    }
    
    var anotherComponent : Component {       
        let range = ComponentRange(sl: 458, el: 550)
        let component = Component(type: ComponentType.class, range: range, name: "deinit")
        return component
    }
    
    var componentWithManyMethods : Component {
        let range = ComponentRange(sl: 1, el: 2)
        let component = Component(type: ComponentType.class, range: range, name: "deinit")
        
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
        let component = Component(type: .function, range: ComponentRange(sl: 3, el: 36), name: nil)
        let component1 = component.makeComponent(type: .if, range: ComponentRange(sl: 4, el: 11))
        let component2 = component.makeComponent(type: .elseIf, range: ComponentRange(sl: 12, el: 15))
        let component3 = component.makeComponent(type: .elseIf, range: ComponentRange(sl: 16, el: 19))
        let component4 = component.makeComponent(type: .else, range: ComponentRange(sl: 20, el: 35))
        _ = component1.makeComponent(type: .if, range: ComponentRange(sl: 5, el: 7))
        _ = component1.makeComponent(type: .elseIf, range: ComponentRange(sl: 7, el: 9))
        _ = component1.makeComponent(type: .else, range: ComponentRange(sl: 91, el: 11))
        _ = component2.makeComponent(type: .while, range: ComponentRange(sl: 13, el: 15))
        _ = component3.makeComponent(type: .for, range: ComponentRange(sl: 17, el: 19))
        let component5 = component4.makeComponent(type: .switch, range: ComponentRange(sl: 21, el: 34))
        _ = component5.makeComponent(type: .case, range: ComponentRange(sl: 22, el: 24))
        _ = component5.makeComponent(type: .case, range: ComponentRange(sl: 25, el: 27))
        _ = component5.makeComponent(type: .case, range: ComponentRange(sl: 28, el: 30))
        _ = component5.makeComponent(type: .case, range: ComponentRange(sl: 31, el: 33))
        return component
    }
    
    var badComponentForNPathComplexity : Component {
        let component = Component(type: .function, range: ComponentRange(sl: 3, el: 36), name: "someFunc")
        let component1 = component.makeComponent(type: .if, range: ComponentRange(sl: 4, el: 11))
        let component2 = component.makeComponent(type: .else, range: ComponentRange(sl: 12, el: 15))
        component.components.append(makeSwitchComponent())
        _ = component.makeComponent(type: .if, range: ComponentRange(sl: 20, el: 35))
        _ = component.makeComponent(type: .else, range: ComponentRange(sl: 12, el: 15))
        _ = component1.makeComponent(type: .if, range: ComponentRange(sl: 5, el: 7))
        _ = component1.makeComponent(type: .elseIf, range: ComponentRange(sl: 7, el: 9))
        _ = component1.makeComponent(type: .else, range: ComponentRange(sl: 9, el: 11))
        _ = component2.makeComponent(type: .if, range: ComponentRange(sl: 5, el: 7))
        _ = component2.makeComponent(type: .else, range: ComponentRange(sl: 7, el: 9))
        return component
    }
    
    func makeSwitchComponent() -> Component {
        let component = Component(type: .switch, range: ComponentRange(sl: 16, el: 19))
        _ = component.makeComponent(type: .case, range: ComponentRange(sl: 22, el: 24))
        _ = component.makeComponent(type: .case, range: ComponentRange(sl: 25, el: 27))
        _ = component.makeComponent(type: .case, range: ComponentRange(sl: 28, el: 30))
        _ = component.makeComponent(type: .case, range: ComponentRange(sl: 31, el: 33))
        _ = component.makeComponent(type: .case, range: ComponentRange(sl: 31, el: 33))
        for subComponent in component.components {
            _ = subComponent.makeComponent(type: .if, range: ComponentRange(sl: 5, el: 7))
            _ = subComponent.makeComponent(type: .else, range: ComponentRange(sl: 5, el: 7))
        }
        return component
    }
    
    var componentForNPathComplexity : Component {
        let component = Component(type: .function, range: ComponentRange(sl: 3, el: 36))
        _ = component.makeComponent(type: .if, range: ComponentRange(sl: 4, el: 11))
        _ = component.makeComponent(type: .else, range: ComponentRange(sl: 20, el: 35))
        _ = component.makeComponent(type: .if, range: ComponentRange(sl: 4, el: 11))
        _ = component.makeComponent(type: .else, range: ComponentRange(sl: 20, el: 35))
        _ = component.makeComponent(type: .if, range: ComponentRange(sl: 4, el: 11))
        _ = component.makeComponent(type: .else, range: ComponentRange(sl: 20, el: 35))
        _ = component.makeComponent(type: .if, range: ComponentRange(sl: 4, el: 11))
        _ = component.makeComponent(type: .else, range: ComponentRange(sl: 20, el: 35))
        _ = component.makeComponent(type: .if, range: ComponentRange(sl: 4, el: 11))
        _ = component.makeComponent(type: .else, range: ComponentRange(sl: 20, el: 35))
        _ = component.makeComponent(type: .if, range: ComponentRange(sl: 4, el: 11))
        _ = component.makeComponent(type: .else, range: ComponentRange(sl: 20, el: 35))
        let switchComponent = component.makeComponent(type: .switch, range: ComponentRange(sl: 20, el: 35))
        _ = switchComponent.makeComponent(type: .case, range: ComponentRange(sl: 0, el: 0))
        _ = switchComponent.makeComponent(type: .case, range: ComponentRange(sl: 0, el: 0))
        _ = switchComponent.makeComponent(type: .case, range: ComponentRange(sl: 0, el: 0))
        _ = switchComponent.makeComponent(type: .case, range: ComponentRange(sl: 0, el: 0))
        _ = switchComponent.makeComponent(type: .case, range: ComponentRange(sl: 0, el: 0))
        return component
    }
    
    var testComponent : Component {
        let component = Component(type: .function, range: ComponentRange(sl: 0, el: 0))
        let repeatComponent = component.makeComponent(type: .repeat, range: ComponentRange(sl: 0, el: 0))
        let ifComponent = repeatComponent.makeComponent(type: .if, range: ComponentRange(sl: 0, el: 0))
        let elseComponent = repeatComponent.makeComponent(type: .else, range: ComponentRange(sl: 0, el: 0))
        _ = ifComponent.makeComponent(type: .and, range: ComponentRange(sl: 0, el: 0))
        _ = elseComponent.makeComponent(type: .ternary, range: ComponentRange(sl: 0, el: 0))
        _ = component.makeComponent(type: .if, range: ComponentRange(sl: 0, el: 0))
        _ = component.makeComponent(type: .elseIf, range: ComponentRange(sl: 0, el: 0))
        _ = component.makeComponent(type: .else, range: ComponentRange(sl: 0, el: 0))
        let forComponent = component.makeComponent(type: .for, range: ComponentRange(sl: 0, el: 0))
        _ = forComponent.makeComponent(type: .or, range: ComponentRange(sl: 0, el: 0))
        let forComponent2 = forComponent.makeComponent(type: .for, range: ComponentRange(sl: 0, el: 0))
        _ = forComponent2.makeComponent(type: .and, range: ComponentRange(sl: 0, el: 0))
        _ = forComponent2.makeComponent(type: .if, range: ComponentRange(sl: 0, el: 0))
        let switchComponent = component.makeComponent(type: .switch, range: ComponentRange(sl: 0, el: 0))
        let case1 = switchComponent.makeComponent(type: .case, range: ComponentRange(sl: 0, el: 0))
        let case2 = switchComponent.makeComponent(type: .case, range: ComponentRange(sl: 0, el: 0))
        let case3 = switchComponent.makeComponent(type: .case, range: ComponentRange(sl: 0, el: 0))
        _ = case1.makeComponent(type: .nilCoalescing, range: ComponentRange(sl: 0, el: 0))
        _ = case2.makeComponent(type: .ternary, range: ComponentRange(sl: 0, el: 0))
        _ = case3.makeComponent(type: .if, range: ComponentRange(sl: 0, el: 0))
        _ = case3.makeComponent(type: .else, range: ComponentRange(sl: 0, el: 0))
        return component
    }
    
    func addComponentsInDepthToComponent(_ component: Component) -> Component {
        let depth = 10
        func makeComponent(_ component: Component, depth: Int) {
            let admisibleComponents = [ComponentType.if, ComponentType.while, ComponentType.for, ComponentType.case, ComponentType.brace]
            let type = admisibleComponents[Int(arc4random_uniform(5))]
            let component1 = component.makeComponent(type: type, range: ComponentRange(sl: 0, el: 0))
            let decrementedDepth = depth - 1
            if decrementedDepth > 0 {
                makeComponent(component1, depth: decrementedDepth)
            }
        }
        makeComponent(component, depth: 10)
        return component
    }
    
    func makeClassComponentWithNrOfMethods(_ count: Int) -> Component {
        let component = Component(type: ComponentType.class, range: ComponentRange(sl: 0, el: 0))
        (0..<count).forEach {_ in
            _ = component.makeComponent(type: ComponentType.function, range: ComponentRange(sl: 1, el: 10))
        }
        return component
    }
}



