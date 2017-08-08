//
//  ComponentsBuilder.swift
//  Scissors
//
//  Created by Alexandru Culeva on 9/3/15.
//  Copyright © 2015 com.yopeso.aculeva. All rights reserved.
//

@testable import TaylorFramework

func arrayComponents() -> [ExtendedComponent] {
    return [ExtendedComponent(type: ComponentType.function, range: OffsetRange(start: 2, end: 4)),
            ExtendedComponent(type: ComponentType.class, range: OffsetRange(start: 1, end: 8)),
            ExtendedComponent(type: ComponentType.comment, range: OffsetRange(start: 5, end: 7)),
            ExtendedComponent(type: ComponentType.emptyLines, range: OffsetRange(start: 3, end: 3)),
            ExtendedComponent(type: ComponentType.function, range: OffsetRange(start: 9, end: 10))]
}

func componentsForArrayComponents() -> ExtendedComponent {
    let rootComponent = ExtendedComponent(type: ComponentType.class, range: OffsetRange(start: 0, end: 11))
    let classComponent = rootComponent.addChild(ComponentType.class, range: OffsetRange(start: 1, end: 8))
    let funcComponent = classComponent.addChild(ComponentType.function, range: OffsetRange(start: 2, end: 4))
    funcComponent.addChild(ComponentType.emptyLines, range: OffsetRange(start: 3, end: 3))
    classComponent.addChild(ComponentType.comment, range: OffsetRange(start: 5, end: 7))
    rootComponent.addChild(ComponentType.function, range: OffsetRange(start: 9, end: 10))
    
    return rootComponent
}

func componentsOneClass() -> [Component] {
    return [Component(type: .class,
                      range: ComponentRange(sl: 2, el: 3), name: "TestClass")]
}

func componentsClassAndFunc() -> [Component] {
    return [Component(type: .class,
                      range: ComponentRange(sl: 2, el: 3), name: "Test"),
        Component(type: .function,
                  range: ComponentRange(sl: 4, el: 5), name: "testFunc()")]
}

func componentsEmptyLines() -> [Component] {
    let rootComponent = Component(type: ComponentType.function, range:ComponentRange(sl: 1, el: 7), name: "testEmpty()")
    rootComponent.makeComponent(type: .emptyLines, range: ComponentRange(sl: 2, el: 6))
    return [rootComponent]
}

func componentsComments() -> [Component] {
    return [Component(type: .comment,
        range: ComponentRange(sl: 1, el: 1)),
        Component(type: .comment,
            range: ComponentRange(sl: 2, el: 2)),
        Component(type: .comment,
            range: ComponentRange(sl: 3, el: 5)),
        Component(type: .comment,
            range: ComponentRange(sl: 6, el: 7)),
        Component(type: .comment,
            range: ComponentRange(sl: 8, el: 8))]
}

func componentsForStrings() -> [Component] {
    return [Component(type: .variable,
                      range: ComponentRange(sl: 1, el: 1), name: "stringComment"),
        Component(type: .variable,
                  range: ComponentRange(sl: 2, el: 2), name: "stringFunc"),
        Component(type: .variable,
                  range: ComponentRange(sl: 3, el: 3), name: "stringClass")]
}

func componentsForRandom() -> [Component] {
    
    let rootComponent = Component(type: ComponentType.class, range:ComponentRange(sl: 1, el: 8), name: "TestFile")
    let child = rootComponent.makeComponent(type: .function, range: ComponentRange(sl: 2, el: 4), name: "testFunction()")
    rootComponent.makeComponent(type: .comment, range:ComponentRange(sl: 5, el: 7))
    
    child.makeComponent(type: .emptyLines, range: ComponentRange(sl: 3, el: 3))
    
    return [rootComponent,
        Component(type: .function,
            range: ComponentRange(sl: 9, el: 10), name: "testFunction()")]
}

func componentsOneStructOneEnum() -> [Component] {
    return [Component(type: ComponentType.struct,
                      range: ComponentRange(sl: 1, el: 2), name: "testStruct"),
        Component(type:ComponentType.enum,
                  range: ComponentRange(sl: 3, el: 3), name: "test")]
}

func componentsIfElse() -> [Component] {
    let rootComponent = Component(type: ComponentType.function,
                                  range: ComponentRange(sl: 1, el: 7), name: "testIf()")
    rootComponent.makeComponent(type: .if, range: ComponentRange(sl: 2, el: 3))
    rootComponent.makeComponent(type: .else, range: ComponentRange(sl: 3, el: 3))
    rootComponent.makeComponent(type: .if, range: ComponentRange(sl: 4, el: 4))
    rootComponent.makeComponent(type: .else, range: ComponentRange(sl: 5, el: 6))
    
    return [rootComponent]
}

func componentsElseIf() -> [Component] {
    let rootComponent = Component(type: ComponentType.function, range: ComponentRange(sl: 1, el: 4), name: "testElseIf()")
    rootComponent.makeComponent(type: .if, range: ComponentRange(sl: 2, el: 2))
    rootComponent.makeComponent(type: .elseIf, range: ComponentRange(sl: 3, el: 4))
    return [rootComponent]
}

func componentsForRepeatWhile() -> [Component] {
    let rootComponent = Component(type: .function, range: ComponentRange(sl: 1, el: 6), name: "testRepeatWhile()")
    let repeatComponent = rootComponent.makeComponent(type: .repeat, range: ComponentRange(sl: 2, el: 5))
    repeatComponent.makeComponent(type: .and, range: ComponentRange(sl: 5, el: 5))
    repeatComponent.makeComponent(type: .or, range: ComponentRange(sl: 5, el: 5))
    return [rootComponent]
}

func componentsForTernaryNilc() -> [Component] {
    let rootComponent = Component(type: .function, range: ComponentRange(sl: 1, el: 17), name: "funcForNPathComplexity()")
    var ifComponent = rootComponent.makeComponent(type: .if, range: ComponentRange(sl: 2, el: 4))
    ifComponent.makeComponent(type: .ternary, range: ComponentRange(sl: 3, el: 3))
    ifComponent = rootComponent.makeComponent(type: .if, range: ComponentRange(sl: 5, el: 7))
    ifComponent.makeComponent(type: .nilCoalescing, range: ComponentRange(sl: 6, el: 6))
    ifComponent = rootComponent.makeComponent(type: .if, range: ComponentRange(sl: 8, el: 10))
    ifComponent.makeComponent(type: .ternary, range: ComponentRange(sl: 9, el: 9))
    ifComponent = rootComponent.makeComponent(type: .if, range: ComponentRange(sl: 11, el: 13))
    ifComponent.makeComponent(type: .nilCoalescing, range: ComponentRange(sl: 12, el: 12))
    ifComponent = rootComponent.makeComponent(type: .if, range: ComponentRange(sl: 14, el: 16))
    ifComponent.makeComponent(type: .ternary, range: ComponentRange(sl: 15, el: 15))
    return [rootComponent]
}

func componentsForIfElifElse() -> [Component] {
    let component = Component(type: ComponentType.function, range: ComponentRange(sl: 1, el: 20), name: "nestedIfFunc()")
    let ifComponent = component.makeComponent(type: ComponentType.if, range: ComponentRange(sl: 2, el: 6))
    let whileComponent = ifComponent.makeComponent(type: ComponentType.while, range: ComponentRange(sl: 3, el: 5))
    whileComponent.makeComponent(type: .and, range: ComponentRange(sl: 3, el: 3))
    whileComponent.makeComponent(type: .ternary, range: ComponentRange(sl: 4, el: 4))
    let elseIfComponent = component.makeComponent(type: ComponentType.elseIf, range: ComponentRange(sl: 6, el: 10))
    elseIfComponent.makeComponent(type: .or, range: ComponentRange(sl: 6, el: 6))
    let forComponent = elseIfComponent.makeComponent(type: .for, range: ComponentRange(sl: 7, el: 9))
    forComponent.makeComponent(type: .or, range: ComponentRange(sl: 7, el: 7))
    forComponent.makeComponent(type: .ternary, range: ComponentRange(sl: 8, el: 8))
    let elseComponent = component.makeComponent(type: ComponentType.else, range: ComponentRange(sl: 10, el: 16))
    let switchComponent = elseComponent.makeComponent(type: .switch, range: ComponentRange(sl: 11, el: 15))
    switchComponent.makeComponent(type: .case, range: ComponentRange(sl: 12, el: 12))
    switchComponent.makeComponent(type: .case, range: ComponentRange(sl: 13, el: 13))
    switchComponent.makeComponent(type: .case, range: ComponentRange(sl: 14, el: 14)).makeComponent(type: .if, range: ComponentRange(sl: 14, el: 14))
    let secondIfComponent = component.makeComponent(type: .if, range: ComponentRange(sl: 17, el: 19))
    secondIfComponent.makeComponent(type: .emptyLines, range: ComponentRange(sl: 18, el: 18))
    return [component]
}

func componentsForDoCatchInsideIf() -> [Component] {
    let root = Component(type: .function, range: ComponentRange(sl: 2, el: 8), name: "removeFileAtPath(path:)")
    let ifComponent = root.makeComponent(type: .if, range: ComponentRange(sl: 3, el: 7))
    root.makeComponent(type: .parameter, range: ComponentRange(sl: 2, el: 2), name: "path")
    ifComponent.makeComponent(type: .brace, range: ComponentRange(sl: 4, el: 6))
    ifComponent.makeComponent(type: .brace, range: ComponentRange(sl: 6, el: 6))
    return [root]
}

func componentsForComputedProperty() -> [Component] {
    let root = Component(type: .class, range: ComponentRange(sl: 1, el: 8), name: "TestComputedProperties")
    let computedProperty = root.makeComponent(type: .function, range: ComponentRange(sl: 2, el: 4), name: "b")
    computedProperty.makeComponent(type: .if, range: ComponentRange(sl: 3, el: 3))
    root.makeComponent(type: .variable, range: ComponentRange(sl: 5, el: 7), name: "c")
    return [root]
}

func componentsForClosures() -> [Component] {
    let root = Component(type: .class, range: ComponentRange(sl: 1, el: 20), name: "TestClosures")
    let var1 = root.makeComponent(type: .closure, range: ComponentRange(sl: 2, el: 4), name: "[1].map")
    var1.makeComponent(type: .parameter, range: ComponentRange(sl: 2, el: 2), name: "i")
    root.makeComponent(type: .closure, range: ComponentRange(sl: 5, el: 5), name: "[1,1].map")
    let var3 = root.makeComponent(type: .closure, range: ComponentRange(sl: 6, el: 8), name: "{ (param)-> Int in\n        return 1\n    }")
    var3.makeComponent(type: .parameter, range: ComponentRange(sl: 6, el: 6), name: "param")
    let var4 = root.makeComponent(type: .closure, range: ComponentRange(sl: 9, el: 12), name: "{\n        if true {}\n        return 1.0\n    }")
    var4.makeComponent(type: .if, range: ComponentRange(sl: 10, el: 10))
    let function = root.makeComponent(type: .function, range: ComponentRange(sl: 13, el: 19), name: "test()")
    function.makeComponent(type: .closure, range: ComponentRange(sl: 14, el: 14), name: "[1].map")
    let var6 = function.makeComponent(type: .closure, range: ComponentRange(sl: 15, el: 17), name: "[].sort")
    var6.makeComponent(type: .parameter, range: ComponentRange(sl: 15, el: 15), name: "s1")
    var6.makeComponent(type: .parameter, range: ComponentRange(sl: 15, el: 15), name: "s2")
    let var7 = function.makeComponent(type: .closure, range: ComponentRange(sl: 18, el: 18), name: "[].sort")
    var7.makeComponent(type: .parameter, range: ComponentRange(sl: 18, el: 18), name: "s1")
    var7.makeComponent(type: .parameter, range: ComponentRange(sl: 18, el: 18), name: "s2")
    
    return [root]
}

func componentsForGettersSetters() -> [Component] {
    let root = Component(type: .class, range: ComponentRange(sl: 1, el: 14), name: "TestGettersSetters")
    let var1 = root.makeComponent(type: .function, range: ComponentRange(sl: 2, el: 8), name: "a")
    var1.makeComponent(type: .function, range: ComponentRange(sl: 3, el: 5), name: "get")
    let setter = var1.makeComponent(type: .function, range: ComponentRange(sl: 5, el: 8), name: "set") //Incorrect range
    setter.makeComponent(type: .if, range: ComponentRange(sl: 6, el: 6))
    let var2 = root.makeComponent(type: .function, range: ComponentRange(sl: 9, el: 13), name: "b")
    var2.makeComponent(type: .function, range: ComponentRange(sl: 10, el: 11), name: "didSet")
    var2.makeComponent(type: .function, range: ComponentRange(sl: 11, el: 13), name: "willSet") //Incorrect range
    let root2 = Component(type: .class, range: ComponentRange(sl: 15, el: 24), name: "TestGetter")
    let var3 = root2.makeComponent(type: .function, range: ComponentRange(sl: 16, el: 20), name: "b")
    var3.makeComponent(type: .function, range: ComponentRange(sl: 17, el: 20), name: "get")
    let var4 = root2.makeComponent(type: .function, range: ComponentRange(sl: 21, el: 23), name: "c")
    var4.makeComponent(type: .function, range: ComponentRange(sl: 22, el: 23), name: "willSet")
    
    
    return [root, root2]
}

func componentsForBraceWithParameters() -> [Component] {
    let root = Component(type: .function, range: ComponentRange(sl: 1, el: 6), name: "funcForClosures()")
    let var1 = root.makeComponent(type: .closure, range: ComponentRange(sl: 2, el: 5))
    var1.makeComponent(type: .parameter, range: ComponentRange(sl: 2, el: 2), name: "i")
    var1.makeComponent(type: .if, range: ComponentRange(sl: 3, el: 3))
    return [root]
}

func componentsForClosureParameters() -> [Component] {
    let function1 = Component(type: .function, range: ComponentRange(sl: 1, el: 3), name: "testClosureParameters(a:b:c:)")
    function1.makeComponent(type: .parameter, range: ComponentRange(sl: 1, el: 1), name: "a")
    function1.makeComponent(type: .parameter, range: ComponentRange(sl: 1, el: 1), name: "b")
    function1.makeComponent(type: .parameter, range: ComponentRange(sl: 1, el: 1), name: "c")
    function1.makeComponent(type: .closure, range: ComponentRange(sl: 2, el: 2), name: "[1, 2, 3].reduce")
    
    let function2 = Component(type: .function, range: ComponentRange(sl: 4, el: 7), name: "testFilterClosureParameters(a:b:c:)")
    function2.makeComponent(type: .parameter, range: ComponentRange(sl: 4, el: 4), name: "a")
    function2.makeComponent(type: .parameter, range: ComponentRange(sl: 4, el: 4), name: "b")
    function2.makeComponent(type: .parameter, range: ComponentRange(sl: 4, el: 4), name: "c")
    function2.makeComponent(type: .closure, range: ComponentRange(sl: 5, el: 5), name: "[1, 2, 3].filter")
    let closure2 = function2.makeComponent(type: .closure, range: ComponentRange(sl: 6, el: 6), name: "[1, 2, 3, 4].map")
    closure2.makeComponent(type: .parameter, range: ComponentRange(sl: 6, el: 6), name: "a")

    return [function1, function2]
}

func componentsForGuard() -> [Component] {
    let function = Component(type: .function, range: ComponentRange(sl: 1, el: 3), name: "testFunc()")
    function.makeComponent(type: .guard, range: ComponentRange(sl: 2, el: 2))
    
    return [function]
}

func componentsForNumberOfParameters() -> [Component] {
    let function = Component(type: .function, range: ComponentRange(sl: 1, el: 6), name: "httpBody(for:encoding:)")
    function.makeComponent(type: .parameter, range: ComponentRange(sl: 1, el: 1), name: "parameters")
    function.makeComponent(type: .parameter, range: ComponentRange(sl: 1, el: 1), name: "encoding")
    let newline = Component(type: .emptyLines, range: ComponentRange(sl: 6, el: 6))

    return [function, newline]
}
