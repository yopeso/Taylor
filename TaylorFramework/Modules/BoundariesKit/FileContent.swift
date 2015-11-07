//
//  FileContent.swift
//  taylor
//
//  Created by Andrei Raifura on 9/1/15.
//  Copyright © 2015 YOPESO. All rights reserved.
//

struct FileContent {
    let path: String
    let components: [Component]
    init(path: String, components:[Component]) {
        self.path = path
        self.components = components
    }
}


extension FileContent: Equatable {
}

func ==(lhs: FileContent, rhs: FileContent) -> Bool {
    return lhs.path == rhs.path &&
        lhs.components == rhs.components
}
