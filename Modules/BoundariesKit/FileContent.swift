//
//  FileContent.swift
//  taylor
//
//  Created by Andrei Raifura on 9/1/15.
//  Copyright © 2015 YOPESO. All rights reserved.
//

public struct FileContent {
    public let path: String
    public let components: [Component]
    public init(path: String, components:[Component]) {
        self.path = path
        self.components = components
    }
}


extension FileContent: Equatable {
}

public func ==(lhs: FileContent, rhs: FileContent) -> Bool {
    return lhs.path == rhs.path &&
        lhs.components == rhs.components
}
