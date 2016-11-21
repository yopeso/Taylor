//
//  ComponentType.swift
//  Taylor
//
//  Created by Alexandru Culeva on 4/12/16.
//  Copyright © 2016 YOPESO. All rights reserved.
//

import Foundation

enum ComponentType {
    case function, `operator`, `subscript`, accessor, variable
    case module
    case `class`, `struct`, `enum`, enumElement, `protocol`, `extension`
    case associatedType, `typealias`, parameter
    case `for`, `while`, `repeat`, `if`, `guard`, `switch`, `case`, brace, closure
    case array, dictionary, object, element, `Init`, conditionalExpression, pattern, typeReference
    
    case and, or, nilCoalescing, emptyLines, comment, ternary, elseIf, `else`
    case other
    
    init(rawValue: String) {
        self = componentTypeUIDs[rawValue] ?? .other
    }

    static let ParentComponents = [
        ComponentType.function, .class, .struct, .enum, .protocol, .extension, .for, .parameter,
                    .for, .while, .repeat, .if, .guard, .switch, .case, .brace, .closure
    ]
    static let BracedComponents = [ComponentType.if, .elseIf, .for, .while, .repeat, .closure, .guard]
    
    var isBraced: Bool { return ComponentType.BracedComponents.contains(self) }
    
    var isSignificant: Bool { return ComponentType.ParentComponents.contains(self) }
}

let componentTypeUIDs = [
    
    "source.lang.swift.decl.function.free": ComponentType.function,
    "source.lang.swift.ref.function.free": .function,
    "source.lang.swift.decl.function.method.instance": .function,
    "source.lang.swift.ref.function.method.instance": .function,
    "source.lang.swift.decl.function.method.static": .function,
    "source.lang.swift.ref.function.method.static": .function,
    "source.lang.swift.decl.function.method.class": .function,
    "source.lang.swift.ref.function.method.class": .function,
    
    "source.lang.swift.decl.function.constructor": .function,
    "source.lang.swift.ref.function.constructor": .function,
    "source.lang.swift.decl.function.destructor": .function,
    "source.lang.swift.ref.function.destructor": .function,
    
    "source.lang.swift.decl.function.operator.prefix": .operator,
    "source.lang.swift.decl.function.operator.postfix": .operator,
    "source.lang.swift.decl.function.operator.infix": .operator,
    "source.lang.swift.ref.function.operator.prefix": .operator,
    "source.lang.swift.ref.function.operator.postfix": .operator,
    "source.lang.swift.ref.function.operator.infix": .operator,
    
    "source.lang.swift.decl.function.subscript": .subscript,
    "source.lang.swift.ref.function.subscript": .subscript,
    
    "source.lang.swift.decl.function.accessor.getter": .accessor,
    "source.lang.swift.ref.function.accessor.getter": .accessor,
    "source.lang.swift.decl.function.accessor.setter": .accessor,
    "source.lang.swift.ref.function.accessor.setter": .accessor,
    "source.lang.swift.decl.function.accessor.willset": .accessor,
    "source.lang.swift.ref.function.accessor.willset": .accessor,
    "source.lang.swift.decl.function.accessor.didset": .accessor,
    "source.lang.swift.ref.function.accessor.didset": .accessor,
    "source.lang.swift.decl.function.accessor.address": .accessor,
    "source.lang.swift.ref.function.accessor.address": .accessor,
    "source.lang.swift.decl.function.accessor.mutableaddress": .accessor,
    "source.lang.swift.ref.function.accessor.mutableaddress": .accessor,
    
    "source.lang.swift.decl.var.global": .variable,
    "source.lang.swift.ref.var.global": .variable,
    "source.lang.swift.decl.var.instance": .variable,
    "source.lang.swift.ref.var.instance": .variable,
    "source.lang.swift.decl.var.static": .variable,
    "source.lang.swift.ref.var.static": .variable,
    "source.lang.swift.decl.var.class": .variable,
    "source.lang.swift.ref.var.class": .variable,
    "source.lang.swift.decl.var.local": .variable,
    "source.lang.swift.ref.var.local": .variable,
    
    "source.lang.swift.decl.module": .module,
    "source.lang.swift.ref.module": .module,
    
    "source.lang.swift.decl.class": .class,
    "source.lang.swift.ref.class": .class,
    
    "source.lang.swift.decl.struct": .struct,
    "source.lang.swift.ref.struct": .struct,
    
    "source.lang.swift.decl.enum": .enum,
    "source.lang.swift.ref.enum": .enum,
    
    "source.lang.swift.decl.enumcase": .enumElement,
    "source.lang.swift.decl.enumelement": .enumElement,
    "source.lang.swift.ref.enumelement": .enumElement,
    
    "source.lang.swift.decl.protocol": .protocol,
    "source.lang.swift.ref.protocol": .protocol,
    
    "source.lang.swift.decl.extension": .extension,
    "source.lang.swift.decl.extension.struct": .extension,
    "source.lang.swift.decl.extension.class": .extension,
    "source.lang.swift.decl.extension.enum": .extension,
    "source.lang.swift.decl.extension.protocol": .extension,
    
    "source.lang.swift.decl.associatedtype": .associatedType,
    "source.lang.swift.ref.associatedtype": .associatedType,
    
    "source.lang.swift.decl.typealias": .typealias,
    "source.lang.swift.ref.typealias": .typealias,
    
    "source.lang.swift.decl.var.parameter": .parameter,
    "source.lang.swift.ref.generic_type_param": .parameter,
    
    "source.lang.swift.stmt.foreach": .for,
    "source.lang.swift.stmt.for": .for,
    "source.lang.swift.stmt.while": .while,
    "source.lang.swift.stmt.repeatwhile": .repeat,
    "source.lang.swift.stmt.if": .if,
    "source.lang.swift.stmt.guard": .guard,
    "source.lang.swift.stmt.switch": .switch,
    "source.lang.swift.stmt.case": .case,
    "source.lang.swift.stmt.brace": .brace,
    "source.lang.swift.expr.call": .closure,
    "source.lang.swift.expr.array": .array,
    "source.lang.swift.expr.dictionary": .dictionary,
    "source.lang.swift.expr.object_literal": .object,
    
    "source.lang.swift.syntaxtype.comment": .comment,
    "source.lang.swift.syntaxtype.doccomment": .comment,
    
    "source.lang.swift.structure.elem.id": .element,
    "source.lang.swift.structure.elem.expr": .element,
    "source.lang.swift.structure.elem.init_expr": .Init,
    "source.lang.swift.structure.elem.condition_expr": .conditionalExpression,
    "source.lang.swift.structure.elem.pattern": .pattern,
    "source.lang.swift.structure.elem.typeref": .typeReference
]
