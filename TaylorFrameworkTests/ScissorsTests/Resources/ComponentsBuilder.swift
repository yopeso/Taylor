//
//  ComponentsBuilder.swift
//  Scissors
//
//  Created by Alexandru Culeva on 9/3/15.
//  Copyright © 2015 com.yopeso.aculeva. All rights reserved.
//

@testable import TaylorFramework

func arrayComponents() -> [ExtendedComponent] {
    return [ExtendedComponent(type: ComponentType.Function, range: OffsetRange(start: 2, end: 4)),
            ExtendedComponent(type: ComponentType.Class, range: OffsetRange(start: 1, end: 8)),
            ExtendedComponent(type: ComponentType.Comment, range: OffsetRange(start: 5, end: 7)),
            ExtendedComponent(type: ComponentType.EmptyLines, range: OffsetRange(start: 3, end: 3)),
            ExtendedComponent(type: ComponentType.Function, range: OffsetRange(start: 9, end: 10))]
}

func componentsForArrayComponents() -> ExtendedComponent {
    let rootComponent = ExtendedComponent(type: ComponentType.Class, range: OffsetRange(start: 0, end: 11))
    let classComponent = rootComponent.addChild(ComponentType.Class, range: OffsetRange(start: 1, end: 8))
    let funcComponent = classComponent.addChild(ComponentType.Function, range: OffsetRange(start: 2, end: 4))
    funcComponent.addChild(ComponentType.EmptyLines, range: OffsetRange(start: 3, end: 3))
    classComponent.addChild(ComponentType.Comment, range: OffsetRange(start: 5, end: 7))
    rootComponent.addChild(ComponentType.Function, range: OffsetRange(start: 9, end: 10))
    
    return rootComponent
}

func componentsOneClass() -> [Component] {
    return [Component(type: .Class,
        range: ComponentRange(sl: 2, el: 3))]
}

func componentsClassAndFunc() -> [Component] {
    return [Component(type: .Class,
        range: ComponentRange(sl: 2, el: 3)),
        Component(type: .Function,
            range: ComponentRange(sl: 4, el: 5))]
}

func componentsEmptyLines() -> [Component] {
    let rootComponent = Component(type: ComponentType.Function, range:ComponentRange(sl: 1, el: 7))
    rootComponent.makeComponent(type: .EmptyLines,
        range: ComponentRange(sl: 2, el: 6))
    return [rootComponent]
}

func componentsComments() -> [Component] {
    return [Component(type: .Comment,
        range: ComponentRange(sl: 1, el: 1)),
        Component(type: .Comment,
            range: ComponentRange(sl: 2, el: 2)),
        Component(type: .Comment,
            range: ComponentRange(sl: 3, el: 5)),
        Component(type: .Comment,
            range: ComponentRange(sl: 6, el: 7)),
        Component(type: .Comment,
            range: ComponentRange(sl: 8, el: 8))]
}

func componentsForStrings() -> [Component] {
    return [Component(type: .Variable,
        range: ComponentRange(sl: 1, el: 1)),
        Component(type: .Variable,
            range: ComponentRange(sl: 2, el: 2)),
        Component(type: .Variable,
            range: ComponentRange(sl: 3, el: 3))]
}

func componentsForRandom() -> [Component] {
    
    let rootComponent = Component(type: ComponentType.Class, range:ComponentRange(sl: 1, el: 8))
    let child = rootComponent.makeComponent(type: .Function, range: ComponentRange(sl: 2, el: 4))
    rootComponent.makeComponent(type: .Comment, range:ComponentRange(sl: 5, el: 7))
    
    child.makeComponent(type: .EmptyLines, range: ComponentRange(sl: 3, el: 3))
    
    return [rootComponent,
        Component(type: .Function,
            range: ComponentRange(sl: 9, el: 10))]
}

func componentsOneStructOneEnum() -> [Component] {
    return [Component(type: ComponentType.Struct,
        range: ComponentRange(sl: 1, el: 2)),
        Component(type:ComponentType.Enum,
            range: ComponentRange(sl: 3, el: 3))]
}

func componentsIfElse() -> [Component] {
    let rootComponent = Component(type: ComponentType.Function,
        range: ComponentRange(sl: 1, el: 7))
    rootComponent.makeComponent(type: .If, range: ComponentRange(sl: 2, el: 3))
    rootComponent.makeComponent(type: .Else, range: ComponentRange(sl: 3, el: 3))
    rootComponent.makeComponent(type: .If, range: ComponentRange(sl: 4, el: 4))
    rootComponent.makeComponent(type: .Else, range: ComponentRange(sl: 5, el: 6))
    
    return [rootComponent]
}

func componentsElseIf() -> [Component] {
    let rootComponent = Component(type: ComponentType.Function, range: ComponentRange(sl: 1, el: 4))
    rootComponent.makeComponent(type: .If, range: ComponentRange(sl: 2, el: 2))
    rootComponent.makeComponent(type: .ElseIf, range: ComponentRange(sl: 3, el: 4))
    return [rootComponent]
}

func componentsForRepeatWhile() -> [Component] {
    let rootComponent = Component(type: .Function, range: ComponentRange(sl: 1, el: 6))
    let repeatComponent = rootComponent.makeComponent(type: .Repeat, range: ComponentRange(sl: 2, el: 5))
    repeatComponent.makeComponent(type: .And, range: ComponentRange(sl: 5, el: 5))
    repeatComponent.makeComponent(type: .Or, range: ComponentRange(sl: 5, el: 5))
    return [rootComponent]
}

func componentsForTernaryNilc() -> [Component] {
    let rootComponent = Component(type: .Function, range: ComponentRange(sl: 1, el: 17))
    var ifComponent = rootComponent.makeComponent(type: .If, range: ComponentRange(sl: 2, el: 4))
    ifComponent.makeComponent(type: .Ternary, range: ComponentRange(sl: 3, el: 3))
    ifComponent = rootComponent.makeComponent(type: .If, range: ComponentRange(sl: 5, el: 7))
    ifComponent.makeComponent(type: .NilCoalescing, range: ComponentRange(sl: 6, el: 6))
    ifComponent = rootComponent.makeComponent(type: .If, range: ComponentRange(sl: 8, el: 10))
    ifComponent.makeComponent(type: .Ternary, range: ComponentRange(sl: 9, el: 9))
    ifComponent = rootComponent.makeComponent(type: .If, range: ComponentRange(sl: 11, el: 13))
    ifComponent.makeComponent(type: .NilCoalescing, range: ComponentRange(sl: 12, el: 12))
    ifComponent = rootComponent.makeComponent(type: .If, range: ComponentRange(sl: 14, el: 16))
    ifComponent.makeComponent(type: .Ternary, range: ComponentRange(sl: 15, el: 15))
    return [rootComponent]
}

func componentsForIfElifElse() -> [Component] {
    let component = Component(type: ComponentType.Function, range: ComponentRange(sl: 1, el: 20))
    let ifComponent = component.makeComponent(type: ComponentType.If, range: ComponentRange(sl: 2, el: 6))
    let whileComponent = ifComponent.makeComponent(type: ComponentType.While, range: ComponentRange(sl: 3, el: 5))
    whileComponent.makeComponent(type: .And, range: ComponentRange(sl: 3, el: 3))
    whileComponent.makeComponent(type: .Ternary, range: ComponentRange(sl: 4, el: 4))
    let elseIfComponent = component.makeComponent(type: ComponentType.ElseIf, range: ComponentRange(sl: 6, el: 10))
    elseIfComponent.makeComponent(type: .Or, range: ComponentRange(sl: 6, el: 6))
    let forComponent = elseIfComponent.makeComponent(type: .For, range: ComponentRange(sl: 7, el: 9))
    forComponent.makeComponent(type: .Or, range: ComponentRange(sl: 7, el: 7))
    forComponent.makeComponent(type: .Ternary, range: ComponentRange(sl: 8, el: 8))
    let elseComponent = component.makeComponent(type: ComponentType.Else, range: ComponentRange(sl: 10, el: 16))
    let switchComponent = elseComponent.makeComponent(type: .Switch, range: ComponentRange(sl: 11, el: 15))
    switchComponent.makeComponent(type: .Case, range: ComponentRange(sl: 12, el: 12))
    switchComponent.makeComponent(type: .Case, range: ComponentRange(sl: 13, el: 13))
    switchComponent.makeComponent(type: .Case, range: ComponentRange(sl: 14, el: 14)).makeComponent(type: .If, range: ComponentRange(sl: 14, el: 14))
    let secondIfComponent = component.makeComponent(type: .If, range: ComponentRange(sl: 17, el: 19))
    secondIfComponent.makeComponent(type: .EmptyLines, range: ComponentRange(sl: 18, el: 18))
    return [component]
}

func componentsForDoCatchInsideIf() -> [Component] {
    let root = Component(type: .Function, range: ComponentRange(sl: 2, el: 8))
    let ifComponent = root.makeComponent(type: .If, range: ComponentRange(sl: 3, el: 7))
    root.makeComponent(type: .Parameter, range: ComponentRange(sl: 2, el: 2))
    ifComponent.makeComponent(type: .Brace, range: ComponentRange(sl: 4, el: 6))
    ifComponent.makeComponent(type: .Brace, range: ComponentRange(sl: 6, el: 6))
    return [root]
}

func componentsForComputedProperty() -> [Component] {
    let root = Component(type: .Class, range: ComponentRange(sl: 1, el: 8))
    let computedProperty = root.makeComponent(type: .Function, range: ComponentRange(sl: 2, el: 4))
    computedProperty.makeComponent(type: .If, range: ComponentRange(sl: 3, el: 3))
    root.makeComponent(type: .Variable, range: ComponentRange(sl: 5, el: 7))
    return [root]
}

func componentsForClosures() -> [Component] {
    let root = Component(type: .Class, range: ComponentRange(sl: 1, el: 20))
    let var1 = root.makeComponent(type: .Closure, range: ComponentRange(sl: 2, el: 4))
    var1.makeComponent(type: .Parameter, range: ComponentRange(sl: 2, el: 2))
    let var2 = root.makeComponent(type: .Closure, range: ComponentRange(sl: 5, el: 5))
    var2.makeComponent(type: .Parameter, range: ComponentRange(sl: 5, el: 5))
    let var3 = root.makeComponent(type: .Closure, range: ComponentRange(sl: 6, el: 8))
    var3.makeComponent(type: .Parameter, range: ComponentRange(sl: 6, el: 6))
    let var4 = root.makeComponent(type: .Closure, range: ComponentRange(sl: 9, el: 12))
    var4.makeComponent(type: .If, range: ComponentRange(sl: 10, el: 10))
    let function = root.makeComponent(type: .Function, range: ComponentRange(sl: 13, el: 19))
    let var5 = function.makeComponent(type: .Closure, range: ComponentRange(sl: 14, el: 14))
    var5.makeComponent(type: .Parameter, range: ComponentRange(sl: 14, el: 14))
    let var6 = function.makeComponent(type: .Closure, range: ComponentRange(sl: 15, el: 17))
    var6.makeComponent(type: .Parameter, range: ComponentRange(sl: 15, el: 15))
    var6.makeComponent(type: .Parameter, range: ComponentRange(sl: 15, el: 15))
    let var7 = function.makeComponent(type: .Closure, range: ComponentRange(sl: 18, el: 18))
    var7.makeComponent(type: .Parameter, range: ComponentRange(sl: 18, el: 18))
    var7.makeComponent(type: .Parameter, range: ComponentRange(sl: 18, el: 18))
    
    return [root]
}

func componentsForGettersSetters() -> [Component] {
    let root = Component(type: .Class, range: ComponentRange(sl: 1, el: 14))
    let var1 = root.makeComponent(type: .Function, range: ComponentRange(sl: 2, el: 8))
    var1.makeComponent(type: .Function, range: ComponentRange(sl: 3, el: 5), name: "get")
    let setter = var1.makeComponent(type: .Function, range: ComponentRange(sl: 5, el: 8), name: "set") //Incorrect range
    setter.makeComponent(type: .If, range: ComponentRange(sl: 6, el: 6))
    let var2 = root.makeComponent(type: .Function, range: ComponentRange(sl: 9, el: 13))
    var2.makeComponent(type: .Function, range: ComponentRange(sl: 10, el: 11), name: "didSet")
    var2.makeComponent(type: .Function, range: ComponentRange(sl: 11, el: 13), name: "willSet") //Incorrect range
    let root2 = Component(type: .Class, range: ComponentRange(sl: 15, el: 24))
    let var3 = root2.makeComponent(type: .Function, range: ComponentRange(sl: 16, el: 20))
    var3.makeComponent(type: .Function, range: ComponentRange(sl: 17, el: 20), name: "get")
    let var4 = root2.makeComponent(type: .Function, range: ComponentRange(sl: 21, el: 23))
    var4.makeComponent(type: .Function, range: ComponentRange(sl: 22, el: 23), name: "willSet")
    
    
    return [root, root2]
}

func componentsForBraceWithParameters() -> [Component] {
    let root = Component(type: .Function, range: ComponentRange(sl: 1, el: 6))
    let var1 = root.makeComponent(type: .Closure, range: ComponentRange(sl: 2, el: 5))
    var1.makeComponent(type: .Parameter, range: ComponentRange(sl: 2, el: 2))
    var1.makeComponent(type: .If, range: ComponentRange(sl: 3, el: 3))
    return [root]
}

func componentsForClosureParameters() -> [Component] {
    let function1 = Component(type: .Function, range: ComponentRange(sl: 1, el: 3))
    function1.makeComponent(type: .Parameter, range: ComponentRange(sl: 1, el: 1))
    function1.makeComponent(type: .Parameter, range: ComponentRange(sl: 1, el: 1))
    function1.makeComponent(type: .Parameter, range: ComponentRange(sl: 1, el: 1))
    let closure = function1.makeComponent(type: .Closure, range: ComponentRange(sl: 2, el: 2))
    closure.makeComponent(type: .Parameter, range: ComponentRange(sl: 2, el: 2))
    closure.makeComponent(type: .Parameter, range: ComponentRange(sl: 2, el: 2))
    closure.makeComponent(type: .Parameter, range: ComponentRange(sl: 2, el: 2))
    
    let function2 = Component(type: .Function, range: ComponentRange(sl: 4, el: 7))
    function2.makeComponent(type: .Parameter, range: ComponentRange(sl: 4, el: 4))
    function2.makeComponent(type: .Parameter, range: ComponentRange(sl: 4, el: 4))
    function2.makeComponent(type: .Parameter, range: ComponentRange(sl: 4, el: 4))

    return [function1, function2]
}
