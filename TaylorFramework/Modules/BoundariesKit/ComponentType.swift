//
//  ComponentType.swift
//  Taylor
//
//  Created by Alexandru Culeva on 4/12/16.
//  Copyright © 2016 YOPESO. All rights reserved.
//

import Foundation

enum ComponentType {
    case Function, Operator, Subscript, Accessor, Variable
    case Module
    case Class, Struct, Enum, EnumElement, Protocol, Extension
    case AssociatedType, Typealias, Parameter
    case For, While, Repeat, If, Guard, Switch, Case, Brace, Closure
    case Array, Dictionary, Object, Element, Init, ConditionalExpression, Pattern, TypeReference
    
    case And, Or, NilCoalescing, EmptyLines, Comment, Ternary, ElseIf, Else
    case Other
    
    init(rawValue: String) {
        self = componentTypeUIDs[rawValue] ?? .Other
    }
    
    static let ParentComponents = [
        ComponentType.Function, .Class, .Struct, .Enum, .Protocol, .Extension, .For, .Parameter,
                    .For, .While, .Repeat, .If, .Guard, .Switch, .Case, .Brace, .Closure
    ]
    static let BracedComponents = [ComponentType.If, .ElseIf, .For, .While, .Repeat, .Closure, .Guard]
    
    var isBraced: Bool { return ComponentType.BracedComponents.contains(self) }
    
    var isSignificant: Bool { return ComponentType.ParentComponents.contains(self) }
}

let componentTypeUIDs = [
    
    "source.lang.swift.decl.function.free": ComponentType.Function,
    "source.lang.swift.ref.function.free": .Function,
    "source.lang.swift.decl.function.method.instance": .Function,
    "source.lang.swift.ref.function.method.instance": .Function,
    "source.lang.swift.decl.function.method.static": .Function,
    "source.lang.swift.ref.function.method.static": .Function,
    "source.lang.swift.decl.function.method.class": .Function,
    "source.lang.swift.ref.function.method.class": .Function,
    
    "source.lang.swift.decl.function.constructor": .Function,
    "source.lang.swift.ref.function.constructor": .Function,
    "source.lang.swift.decl.function.destructor": .Function,
    "source.lang.swift.ref.function.destructor": .Function,
    
    "source.lang.swift.decl.function.operator.prefix": .Operator,
    "source.lang.swift.decl.function.operator.postfix": .Operator,
    "source.lang.swift.decl.function.operator.infix": .Operator,
    "source.lang.swift.ref.function.operator.prefix": .Operator,
    "source.lang.swift.ref.function.operator.postfix": .Operator,
    "source.lang.swift.ref.function.operator.infix": .Operator,
    
    "source.lang.swift.decl.function.subscript": .Subscript,
    "source.lang.swift.ref.function.subscript": .Subscript,
    
    "source.lang.swift.decl.function.accessor.getter": .Accessor,
    "source.lang.swift.ref.function.accessor.getter": .Accessor,
    "source.lang.swift.decl.function.accessor.setter": .Accessor,
    "source.lang.swift.ref.function.accessor.setter": .Accessor,
    "source.lang.swift.decl.function.accessor.willset": .Accessor,
    "source.lang.swift.ref.function.accessor.willset": .Accessor,
    "source.lang.swift.decl.function.accessor.didset": .Accessor,
    "source.lang.swift.ref.function.accessor.didset": .Accessor,
    "source.lang.swift.decl.function.accessor.address": .Accessor,
    "source.lang.swift.ref.function.accessor.address": .Accessor,
    "source.lang.swift.decl.function.accessor.mutableaddress": .Accessor,
    "source.lang.swift.ref.function.accessor.mutableaddress": .Accessor,
    
    "source.lang.swift.decl.var.global": .Variable,
    "source.lang.swift.ref.var.global": .Variable,
    "source.lang.swift.decl.var.instance": .Variable,
    "source.lang.swift.ref.var.instance": .Variable,
    "source.lang.swift.decl.var.static": .Variable,
    "source.lang.swift.ref.var.static": .Variable,
    "source.lang.swift.decl.var.class": .Variable,
    "source.lang.swift.ref.var.class": .Variable,
    "source.lang.swift.decl.var.local": .Variable,
    "source.lang.swift.ref.var.local": .Variable,
    
    "source.lang.swift.decl.module": .Module,
    "source.lang.swift.ref.module": .Module,
    
    "source.lang.swift.decl.class": .Class,
    "source.lang.swift.ref.class": .Class,
    
    "source.lang.swift.decl.struct": .Struct,
    "source.lang.swift.ref.struct": .Struct,
    
    "source.lang.swift.decl.enum": .Enum,
    "source.lang.swift.ref.enum": .Enum,
    
    "source.lang.swift.decl.enumcase": .EnumElement,
    "source.lang.swift.decl.enumelement": .EnumElement,
    "source.lang.swift.ref.enumelement": .EnumElement,
    
    "source.lang.swift.decl.protocol": .Protocol,
    "source.lang.swift.ref.protocol": .Protocol,
    
    "source.lang.swift.decl.extension": .Extension,
    "source.lang.swift.decl.extension.struct": .Extension,
    "source.lang.swift.decl.extension.class": .Extension,
    "source.lang.swift.decl.extension.enum": .Extension,
    "source.lang.swift.decl.extension.protocol": .Extension,
    
    "source.lang.swift.decl.associatedtype": .AssociatedType,
    "source.lang.swift.ref.associatedtype": .AssociatedType,
    
    "source.lang.swift.decl.typealias": .Typealias,
    "source.lang.swift.ref.typealias": .Typealias,
    
    "source.lang.swift.decl.var.parameter": .Parameter,
    "source.lang.swift.ref.generic_type_param": .Parameter,
    
    "source.lang.swift.stmt.foreach": .For,
    "source.lang.swift.stmt.for": .For,
    "source.lang.swift.stmt.while": .While,
    "source.lang.swift.stmt.repeatwhile": .Repeat,
    "source.lang.swift.stmt.if": .If,
    "source.lang.swift.stmt.guard": .Guard,
    "source.lang.swift.stmt.switch": .Switch,
    "source.lang.swift.stmt.case": .Case,
    "source.lang.swift.stmt.brace": .Brace,
    "source.lang.swift.expr.call": .Closure,
    "source.lang.swift.expr.array": .Array,
    "source.lang.swift.expr.dictionary": .Dictionary,
    "source.lang.swift.expr.object_literal": .Object,
    
    "source.lang.swift.syntaxtype.comment": .Comment,
    "source.lang.swift.syntaxtype.doccomment": .Comment,
    
    "source.lang.swift.structure.elem.id": .Element,
    "source.lang.swift.structure.elem.expr": .Element,
    "source.lang.swift.structure.elem.init_expr": .Init,
    "source.lang.swift.structure.elem.condition_expr": .ConditionalExpression,
    "source.lang.swift.structure.elem.pattern": .Pattern,
    "source.lang.swift.structure.elem.typeref": .TypeReference
]
