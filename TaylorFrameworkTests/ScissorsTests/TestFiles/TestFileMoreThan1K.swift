//
//  File.swift
//  SourceKitten
//
//  Created by JP Simard on 2015-01-03.
//  Copyright (c) 2015 SourceKitten. All rights reserved.
//

import Foundation
import SwiftXPC

/// Represents a source file.
struct File {
    /// File path. Nil if initialized directly with `File(contents:)`.
    let path: String?
    /// File contents.
    let contents: String
    /// File lines.
    let lines: [Line]
    
    let startLine: Int
    let startOffset: Int
    let size: Int
    
    
    /**
    Failable initializer by path. Fails if file contents could not be read as a UTF8 string.
    
    - parameter path: File path.
    */
    init?(path: String, startLine: Int = 1, startOffset: Int = 0, size: Int = 0) {
        do {
            let sourceCode = try NSString(contentsOfFile: path, encoding: NSUTF8StringEncoding) as String
            //sourceCode.filterCharacters()
            let data = sourceCode.dataUsingEncoding(NSASCIIStringEncoding, allowLossyConversion: true)
            contents = NSString(data: data!, encoding: NSUTF8StringEncoding) as! String
            lines = contents.lines()
        } catch {
            fputs("Could not read contents of `\(path)`\n", stderr)
            return nil
        }
        
        self.path = nil
        self.startLine = startLine
        self.startOffset = startOffset
        self.size = size
    }
    
    /**
    Initializer by file contents. File path is nil.
    
    - parameter contents: File contents.
    */
    init(contents: String, startLine: Int = 1, startOffset: Int = 0, size: Int = 0) {
        path = nil
        self.contents = contents
        self.lines = self.contents.lines()
        
        self.startLine = startLine
        self.startOffset = startOffset
        self.size = size
    }
    
    
    init(lines: [String], startLine: Int = 1, startOffset: Int = 0, size: Int = 0) {
        path = nil
        self.contents = String(lines.reduce("", combine: { $0 + "\n" + $1 }).characters.dropFirst())
        self.lines = self.contents.lines()
        
        self.startLine = startLine
        self.startOffset = startOffset
        self.size = self.contents.characters.count
    }
    
    /**
    Parse source declaration string from XPC dictionary.
    
    - parameter dictionary: XPC dictionary to extract declaration from.
    
    - returns: Source declaration if successfully parsed.
    */
    func parseDeclaration(dictionary: XPCDictionary) -> String? {
        if !shouldParseDeclaration(dictionary) {
            return nil
        }
        return SwiftDocKey.getOffset(dictionary).flatMap { start in
            let end = SwiftDocKey.getBodyOffset(dictionary).map { Int($0) }
            let start = Int(start)
            let length = (end ?? start) - start
            return contents.substringLinesWithByteRange(start: start, length: length)?
                .stringByTrimmingWhitespaceAndOpeningCurlyBrace()
        }
    }
    
    /**
    Parse line numbers containing the declaration's implementation from XPC dictionary.
    
    - parameter dictionary: XPC dictionary to extract declaration from.
    
    - returns: Line numbers containing the declaration's implementation.
    */
    func parseScopeRange(dictionary: XPCDictionary) -> (start: Int, end: Int)? {
        if !shouldParseDeclaration(dictionary) {
            return nil
        }
        return SwiftDocKey.getOffset(dictionary).flatMap { start in
            let start = Int(start)
            let end = SwiftDocKey.getBodyOffset(dictionary).flatMap { bodyOffset in
                return SwiftDocKey.getBodyLength(dictionary).map { bodyLength in
                    return Int(bodyOffset + bodyLength)
                }
                } ?? start
            let length = end - start
            return contents.lineRangeWithByteRange(start: start, length: length)
        }
    }
    
    /**
    Extract mark-style comment string from doc dictionary. e.g. '// MARK: - The Name'
    
    - parameter dictionary: Doc dictionary to parse.
    
    - returns: Mark name if successfully parsed.
    */
    private func markNameFromDictionary(dictionary: XPCDictionary) -> String? {
        precondition(SwiftDocKey.getKind(dictionary)! == SyntaxKind.CommentMark.rawValue)
        let offset = Int(SwiftDocKey.getOffset(dictionary)!)
        let length = Int(SwiftDocKey.getLength(dictionary)!)
        if let fileContentsData = contents.dataUsingEncoding(NSUTF8StringEncoding),
            subdata = Optional(fileContentsData.subdataWithRange(NSRange(location: offset, length: length))),
            substring = NSString(data: subdata, encoding: NSUTF8StringEncoding) as String? {
                return substring
        }
        return nil
    }
    
    /**
    Returns a copy of the input dictionary with comment mark names, cursor.info information and
    parsed declarations for the top-level of the input dictionary and its substructures.
    
    - parameter dictionary:        Dictionary to process.
    - parameter cursorInfoRequest: Cursor.Info request to get declaration information.
    */
    func processDictionary(var dictionary: XPCDictionary, cursorInfoRequest: xpc_object_t? = nil, syntaxMap: SyntaxMap? = nil) -> XPCDictionary {
        if let cursorInfoRequest = cursorInfoRequest {
            dictionary = merge(
                dictionary,
                dictWithCommentMarkNamesCursorInfo(dictionary, cursorInfoRequest: cursorInfoRequest)
            )
        }
        
        // Parse declaration and add to dictionary
        if let parsedDeclaration = parseDeclaration(dictionary) {
            dictionary[SwiftDocKey.ParsedDeclaration.rawValue] = parsedDeclaration
        }
        
        // Parse scope range and add to dictionary
        if let parsedScopeRange = parseScopeRange(dictionary) {
            dictionary[SwiftDocKey.ParsedScopeStart.rawValue] = Int64(parsedScopeRange.start)
            dictionary[SwiftDocKey.ParsedScopeEnd.rawValue] = Int64(parsedScopeRange.end)
        }
        
        // Parse `key.doc.full_as_xml` and add to dictionary
        if let parsedXMLDocs = (SwiftDocKey.getFullXMLDocs(dictionary).flatMap(parseFullXMLDocs)) {
            dictionary = merge(dictionary, parsedXMLDocs)
            
            // Parse documentation comment and add to dictionary
            if let commentBody = (syntaxMap.flatMap { getDocumentationCommentBody(dictionary, syntaxMap: $0) }) {
                dictionary[SwiftDocKey.DocumentationComment.rawValue] = commentBody
            }
        }
        
        // Update substructure
        if let substructure = newSubstructure(dictionary, cursorInfoRequest: cursorInfoRequest, syntaxMap: syntaxMap) {
            dictionary[SwiftDocKey.Substructure.rawValue] = substructure
        }
        return dictionary
    }
    
    /**
    Returns a copy of the input dictionary with additional cursorinfo information at the given
    `documentationTokenOffsets` that haven't yet been documented.
    
    - parameter dictionary:             Dictionary to insert new docs into.
    - parameter documentedTokenOffsets: Offsets that are likely documented.
    - parameter cursorInfoRequest:      Cursor.Info request to get declaration information.
    */
    internal func furtherProcessDictionary(var dictionary: XPCDictionary, documentedTokenOffsets: [Int], cursorInfoRequest: xpc_object_t, syntaxMap: SyntaxMap) -> XPCDictionary {
        let offsetMap = generateOffsetMap(documentedTokenOffsets, dictionary: dictionary)
        for offset in offsetMap.keys.reverse() { // Do this in reverse to insert the doc at the correct offset
            let response = processDictionary(Request.sendCursorInfoRequest(cursorInfoRequest, atOffset: Int64(offset))!, cursorInfoRequest: nil, syntaxMap: syntaxMap)
            if let kind = SwiftDocKey.getKind(response),
                _ = SwiftDeclarationKind(rawValue: kind),
                parentOffset = offsetMap[offset].flatMap({ Int64($0) }),
                inserted = insertDoc(response, parent: dictionary, offset: parentOffset) {
                    dictionary = inserted
            }
        }
        return dictionary
    }
    
    /**
    Update input dictionary's substructure by running `processDictionary(_:cursorInfoRequest:syntaxMap:)` on
    its elements, only keeping comment marks and declarations.
    
    - parameter dictionary:        Input dictionary to process its substructure.
    - parameter cursorInfoRequest: Cursor.Info request to get declaration information.
    
    - returns: A copy of the input dictionary's substructure processed by running
    `processDictionary(_:cursorInfoRequest:syntaxMap:)` on its elements, only keeping comment marks
    and declarations.
    */
    private func newSubstructure(dictionary: XPCDictionary, cursorInfoRequest: xpc_object_t?, syntaxMap: SyntaxMap?) -> XPCArray? {
        return SwiftDocKey.getSubstructure(dictionary)?
            .map({ $0 as! XPCDictionary })
            //            .filter(isDeclarationOrCommentMark)
            .map {
                processDictionary($0, cursorInfoRequest: cursorInfoRequest, syntaxMap: syntaxMap)
        }
    }
    
    /**
    Returns an updated copy of the input dictionary with comment mark names and cursor.info information.
    
    - parameter dictionary:        Dictionary to update.
    - parameter cursorInfoRequest: Cursor.Info request to get declaration information.
    */
    private func dictWithCommentMarkNamesCursorInfo(dictionary: XPCDictionary, cursorInfoRequest: xpc_object_t) -> XPCDictionary? {
        if let kind = SwiftDocKey.getKind(dictionary) {
            // Only update dictionaries with a 'kind' key
            if kind == SyntaxKind.CommentMark.rawValue {
                // Update comment marks
                if let markName = markNameFromDictionary(dictionary) {
                    return [SwiftDocKey.Name.rawValue: markName]
                }
            } else if let decl = SwiftDeclarationKind(rawValue: kind) where decl != .VarParameter {
                // Update if kind is a declaration (but not a parameter)
                var updateDict = Request.sendCursorInfoRequest(cursorInfoRequest,
                    atOffset: SwiftDocKey.getNameOffset(dictionary)!) ?? XPCDictionary()
                
                // Skip kinds, since values from editor.open are more accurate than cursorinfo
                updateDict.removeValueForKey(SwiftDocKey.Kind.rawValue)
                return updateDict
            }
        }
        return nil
    }
    
    /**
    Returns whether or not a doc should be inserted into a parent at the provided offset.
    
    - parameter parent: Parent dictionary to evaluate.
    - parameter offset: Offset to search for in parent dictionary.
    
    - returns: True if a doc should be inserted in the parent at the provided offset.
    */
    private func shouldInsert(parent: XPCDictionary, offset: Int64) -> Bool {
        return (offset == 0) ||
            (shouldTreatAsSameFile(parent) && SwiftDocKey.getOffset(parent) == offset)
    }
    
    /**
    Inserts a document dictionary at the specified offset.
    Parent will be traversed until the offset is found.
    Returns nil if offset could not be found.
    
    - parameter doc:    Document dictionary to insert.
    - parameter parent: Parent to traverse to find insertion point.
    - parameter offset: Offset to insert document dictionary.
    
    - returns: Parent with doc inserted if successful.
    */
    private func insertDoc(doc: XPCDictionary, var parent: XPCDictionary, offset: Int64) -> XPCDictionary? {
        if shouldInsert(parent, offset: offset) {
            var substructure = SwiftDocKey.getSubstructure(parent)!
            var insertIndex = substructure.count
            for (index, structure) in substructure.reverse().enumerate() {
                if SwiftDocKey.getOffset(structure as! XPCDictionary)! < offset {
                    break
                }
                insertIndex = substructure.count - index
            }
            substructure.insert(doc, atIndex: insertIndex)
            parent[SwiftDocKey.Substructure.rawValue] = substructure
            return parent
        }
        for key in parent.keys {
            if var subArray = parent[key] as? XPCArray {
                for i in 0..<subArray.count {
                    if let subDict = insertDoc(doc, parent: subArray[i] as! XPCDictionary, offset: offset) {
                        subArray[i] = subDict
                        parent[key] = subArray
                        return parent
                    }
                }
            }
        }
        return nil
    }
    
    /**
    Returns true if path is nil or if path has the same last path component as `key.filepath` in the
    input dictionary.
    
    - parameter dictionary: Dictionary to parse.
    */
    internal func shouldTreatAsSameFile(dictionary: XPCDictionary) -> Bool {
        return path == SwiftDocKey.getFilePath(dictionary)
    }
    
    /**
    Returns true if the input dictionary contains a parseable declaration.
    
    - parameter dictionary: Dictionary to parse.
    */
    private func shouldParseDeclaration(dictionary: XPCDictionary) -> Bool {
        let sameFile                = shouldTreatAsSameFile(dictionary)
        let hasTypeName             = SwiftDocKey.getTypeName(dictionary) != nil
        let hasAnnotatedDeclaration = SwiftDocKey.getAnnotatedDeclaration(dictionary) != nil
        let hasOffset               = SwiftDocKey.getOffset(dictionary) != nil
        let isntExtension           = SwiftDocKey.getKind(dictionary) != SwiftDeclarationKind.Extension.rawValue
        return sameFile && hasTypeName && hasAnnotatedDeclaration && hasOffset && isntExtension
    }
    
    /**
    Parses `dictionary`'s documentation comment body.
    
    - parameter dictionary: Dictionary to parse.
    - parameter syntaxMap:  SyntaxMap for current file.
    
    - returns: `dictionary`'s documentation comment body as a string, without any documentation
    syntax (`/** ... */` or `/// ...`).
    */
    func getDocumentationCommentBody(dictionary: XPCDictionary, syntaxMap: SyntaxMap) -> String? {
        return SwiftDocKey.getOffset(dictionary).flatMap { offset in
            return syntaxMap.commentRangeBeforeOffset(Int(offset)).flatMap { commentByteRange in
                return contents.byteRangeToNSRange(start: commentByteRange.start, length: commentByteRange.length).flatMap { nsRange in
                    return contents.commentBody(nsRange)
                }
            }
        }
    }
    
    /**
    Returns tuple consisting of starting line and ending line of structure.
    */
    func getLines(dictionary: XPCDictionary) -> (start: Int, end: Int)? {
        return SwiftDocKey.getOffset(dictionary).flatMap { start in
            let start = Int(start)
            let end = SwiftDocKey.getBodyOffset(dictionary).flatMap { bodyOffset in
                return SwiftDocKey.getBodyLength(dictionary).map { bodyLength in
                    return Int(bodyOffset + bodyLength)
                }
                } ?? start
            let length = end - start
            return self.contents.lineRangeWithByteRange(start: start, length: length)
        }
    }
    
    /**
    Returns tuple consisting of line offset. Anyone is free to modify it to return
    a single value.
    */
    func getLineByOffset(offset: Int, length: Int) -> (start: Int, end: Int) {
        return self.contents.lineRangeWithByteRange(start: offset, length: 0) ?? (lines.count, lines.count)
    }
}

/**
Traverse the dictionary replacing SourceKit UIDs with their string value.

- parameter dictionary: Dictionary to replace UIDs.

- returns: Dictionary with UIDs replaced by strings.
*/
internal func replaceUIDsWithSourceKitStrings(var dictionary: XPCDictionary) -> XPCDictionary {
    for key in dictionary.keys {
        if let uid = dictionary[key] as? UInt64, uidString = stringForSourceKitUID(uid) {
            dictionary[key] = uidString
        } else if let array = dictionary[key] as? XPCArray {
            dictionary[key] = array.map { replaceUIDsWithSourceKitStrings($0 as! XPCDictionary) } as XPCArray
        } else if let dict = dictionary[key] as? XPCDictionary {
            dictionary[key] = replaceUIDsWithSourceKitStrings(dict)
        }
    }
    return dictionary
}

/**
Returns true if the dictionary represents a source declaration or a mark-style comment.

- parameter dictionary: Dictionary to parse.
*/
private func isDeclarationOrCommentMark(dictionary: XPCDictionary) -> Bool {
    if let kind = SwiftDocKey.getKind(dictionary) {
        return kind != SwiftDeclarationKind.VarParameter.rawValue &&
            (kind == SyntaxKind.CommentMark.rawValue || SwiftDeclarationKind(rawValue: kind) != nil)
    }
    return false
}
//
//  String+SourceKitten.swift
//  SourceKitten
//
//  Created by JP Simard on 2015-01-05.
//  Copyright (c) 2015 SourceKitten. All rights reserved.
//

import Foundation
import AppKit

typealias Line = (index: Int, content: String)

private let whitespaceAndNewlineCharacterSet = NSCharacterSet.whitespaceAndNewlineCharacterSet()

extension NSString {
    /**
    Binary search for NSString index equivalent to byte offset.
    
    - parameter offset: Byte offset.
    
    - returns: NSString index, if any.
    */
    private func indexOfByteOffset(offset: Int) -> Int? {
        var usedLength = 0
        
        var left = Int(floor(Double(offset)/2))
        var right = min(length, offset + 1)
        var midpoint = (left + right) / 2
        
        for _ in left..<right {
            getBytes(nil,
                maxLength: Int.max,
                usedLength: &usedLength,
                encoding: NSUTF8StringEncoding,
                options: [],
                range: NSRange(location: 0, length: midpoint),
                remainingRange: nil)
            if usedLength < offset {
                left = midpoint
                midpoint = (right + left) / 2
            } else if usedLength > offset {
                right = midpoint
                midpoint = (right + left) / 2
            } else {
                return midpoint
            }
        }
        return nil
    }
    
    /**
    Returns a copy of `self` with the trailing contiguous characters belonging to `characterSet`
    removed.
    
    - parameter characterSet: Character set to check for membership.
    */
    func stringByTrimmingTrailingCharactersInSet(characterSet: NSCharacterSet) -> String {
        if length == 0 {
            return self as String
        }
        var charBuffer = [unichar](count: length, repeatedValue: 0)
        getCharacters(&charBuffer)
        for newLength in (1...length).reverse() {
            if !characterSet.characterIsMember(charBuffer[newLength - 1]) {
                return substringWithRange(NSRange(location: 0, length: newLength))
            }
        }
        return self as String
    }
    
    /**
    Returns self represented as an absolute path.
    
    - parameter rootDirectory: Absolute parent path if not already an absolute path.
    */
    func absolutePathRepresentation(rootDirectory: String = NSFileManager.defaultManager().currentDirectoryPath) -> String {
        if absolutePath {
            return self as String
        }
        return (NSString.pathWithComponents([rootDirectory, self as String]) as NSString).stringByStandardizingPath
    }
    
    /**
    Converts a range of byte offsets in `self` to an `NSRange` suitable for filtering `self` as an
    `NSString`.
    
    - parameter start: Starting byte offset.
    - parameter length: Length of bytes to include in range.
    
    - returns: An equivalent `NSRange`.
    */
    func byteRangeToNSRange(start start: Int, length: Int) -> NSRange? {
        return indexOfByteOffset(start).flatMap { stringStart in
            return indexOfByteOffset(start + length).map { stringEnd in
                return NSRange(location: stringStart, length: stringEnd - stringStart)
            }
        }
    }
    
    /**
    Returns a substring with the provided byte range.
    
    - parameter start: Starting byte offset.
    - parameter length: Length of bytes to include in range.
    */
    func substringWithByteRange(start start: Int, length: Int) -> String? {
        return byteRangeToNSRange(start: start, length: length).map(substringWithRange)
    }
    
    /**
    Returns a substring starting at the beginning of `start`'s line and ending at the end of `end`'s
    line. Returns `start`'s entire line if `end` is nil.
    
    - parameter start: Starting byte offset.
    - parameter length: Length of bytes to include in range.
    */
    func substringLinesWithByteRange(start start: Int, length: Int) -> String? {
        return byteRangeToNSRange(start: start, length: length).map { range in
            var lineStart = 0, lineEnd = 0
            getLineStart(&lineStart, end: &lineEnd, contentsEnd: nil, forRange: range)
            return substringWithRange(NSRange(location: lineStart, length: lineEnd - lineStart))
        }
    }
    
    /**
    Returns line numbers containing starting and ending byte offsets.
    
    - parameter start: Starting byte offset.
    - parameter length: Length of bytes to include in range.
    */
    func lineRangeWithByteRange(start start: Int, length: Int) -> (start: Int, end: Int)? {
        return byteRangeToNSRange(start: start, length: length).flatMap { range in
            var numberOfLines = 0, index = 0, lineRangeStart = 0
            while index < self.length {
                numberOfLines++
                if index <= range.location {
                    lineRangeStart = numberOfLines
                }
                index = NSMaxRange(lineRangeForRange(NSRange(location: index, length: 1)))
                if index > NSMaxRange(range) {
                    return (lineRangeStart, numberOfLines)
                }
            }
            return nil
        }
    }
    
    /**
    Returns an array of Lines for each line in the file.
    */
    internal func lines() -> [Line] {
        var lines = [Line]()
        var lineIndex = 1
        enumerateLinesUsingBlock { line, _ in
            lines.append((lineIndex++, line))
        }
        return lines
    }
    
    /**
    Returns true if self is an Objective-C header file.
    */
    func isObjectiveCHeaderFile() -> Bool {
        return ["h", "hpp", "hh"].contains(pathExtension)
    }
    
    /**
    Returns true if self is a Swift file.
    */
    func isSwiftFile() -> Bool {
        return pathExtension == "swift"
    }
}

extension String {
    /**
    Returns whether or not the `token` can be documented. Either because it is a
    `SyntaxKind.Identifier` or because it is a function treated as a `SyntaxKind.Keyword`:
    
    - `subscript`
    - `init`
    - `deinit`
    
    - parameter token: Token to process.
    */
    func isTokenDocumentable(token: SyntaxToken) -> Bool {
        if token.type == SyntaxKind.Keyword.rawValue {
            let keywordFunctions = ["subscript", "init", "deinit"]
            return ((self as NSString).substringWithByteRange(start: token.offset, length: token.length))
                .map(keywordFunctions.contains) ?? false
        }
        return token.type == SyntaxKind.Identifier.rawValue
    }
    
    /**
    Find integer offsets of documented Swift tokens in self.
    
    - parameter syntaxMap: Syntax Map returned from SourceKit editor.open request.
    
    - returns: Array of documented token offsets.
    */
    func documentedTokenOffsets(syntaxMap: SyntaxMap) -> [Int] {
        let documentableOffsets = syntaxMap.tokens.filter(isTokenDocumentable).map {
            $0.offset
        }
        
        let regex = try! NSRegularExpression(pattern: "(///.*\\n|\\*/\\n)", options: []) // Safe to force try
        let range = NSRange(location: 0, length: utf16.count)
        let matches = regex.matchesInString(self, options: [], range: range)
        
        return matches.flatMap { match in
            documentableOffsets.filter({ $0 >= match.range.location }).first
        }
    }
    
    /**
    Returns the body of the comment if the string is a comment.
    
    - parameter range: Range to restrict the search for a comment body.
    */
    func commentBody(range: NSRange? = nil) -> String? {
        let nsString = self as NSString
        let patterns: [(pattern: String, options: NSRegularExpressionOptions)] = [
            ("^\\s*\\/\\*\\*\\s*(.+)\\*\\/", [.AnchorsMatchLines, .DotMatchesLineSeparators]),   // multi: ^\s*\/\*\*\s*(.+)\*\/
            ("^\\s*\\/\\/\\/(.+)?",          .AnchorsMatchLines)                                 // single: ^\s*\/\/\/(.+)?
        ]
        let range = range ?? NSRange(location: 0, length: nsString.length)
        for pattern in patterns {
            let regex = try! NSRegularExpression(pattern: pattern.pattern, options: pattern.options) // Safe to force try
            let matches = regex.matchesInString(self, options: [], range: range)
            let bodyParts = matches.flatMap { match -> [String] in
                let numberOfRanges = match.numberOfRanges
                if numberOfRanges < 1 {
                    return []
                }
                return (1..<numberOfRanges).map { rangeIndex in
                    let range = match.rangeAtIndex(rangeIndex)
                    if range.location == NSNotFound {
                        return "" // empty capture group, return empty string
                    }
                    var lineStart = 0
                    var lineEnd = nsString.length
                    guard let indexRange = self.byteRangeToNSRange(start: range.location, length: 0) else {
                        return "" // out of range, return empty string
                    }
                    nsString.getLineStart(&lineStart, end: &lineEnd, contentsEnd: nil, forRange: indexRange)
                    let leadingWhitespaceCountToAdd = nsString.substringWithRange(NSRange(location: lineStart, length: lineEnd - lineStart)).countOfLeadingCharactersInSet(whitespaceAndNewlineCharacterSet)
                    let leadingWhitespaceToAdd = String(count: leadingWhitespaceCountToAdd, repeatedValue: Character(" "))
                    
                    let bodySubstring = nsString.substringWithRange(range)
                    return leadingWhitespaceToAdd + bodySubstring
                }
            }
            if bodyParts.count > 0 {
                return bodyParts
                    .joinWithSeparator("\n")
                    .stringByTrimmingTrailingCharactersInSet(whitespaceAndNewlineCharacterSet)
                    .stringByRemovingCommonLeadingWhitespaceFromLines()
            }
        }
        return nil
    }
    
    /// Returns a copy of `self` with the leading whitespace common in each line removed.
    func stringByRemovingCommonLeadingWhitespaceFromLines() -> String {
        var minLeadingWhitespace = Int.max
        enumerateLines { line, _ in
            let lineLeadingWhitespace = line.countOfLeadingCharactersInSet(whitespaceAndNewlineCharacterSet)
            if lineLeadingWhitespace < minLeadingWhitespace && lineLeadingWhitespace != line.characters.count {
                minLeadingWhitespace = lineLeadingWhitespace
            }
        }
        var lines = [String]()
        enumerateLines { line, _ in
            if line.characters.count >= minLeadingWhitespace {
                lines.append(line[line.startIndex.advancedBy(minLeadingWhitespace)..<line.endIndex])
            } else {
                lines.append(line)
            }
        }
        return lines.joinWithSeparator("\n")
    }
    
    /**
    Returns the number of contiguous characters at the start of `self` belonging to `characterSet`.
    
    - parameter characterSet: Character set to check for membership.
    */
    func countOfLeadingCharactersInSet(characterSet: NSCharacterSet) -> Int {
        let utf16View = utf16
        var count = 0
        for char in utf16View {
            if !characterSet.characterIsMember(char) {
                break
            }
            count++
        }
        return count
    }
    
    /// Returns a copy of the string by trimming whitespace and the opening curly brace (`{`).
    internal func stringByTrimmingWhitespaceAndOpeningCurlyBrace() -> String? {
        let unwantedSet = whitespaceAndNewlineCharacterSet.mutableCopy() as! NSMutableCharacterSet
        unwantedSet.addCharactersInString("{")
        return stringByTrimmingCharactersInSet(unwantedSet)
    }
    
    
    mutating internal func filterCharacters() {
        let str = NSMutableString(string: self)
        let cfstr = str.mutableCopy() as! CFMutableString
        var rng = CFRangeMake(0, CFStringGetLength(cfstr))
        CFStringTransform(cfstr, &rng, kCFStringTransformToUnicodeName, false)
        self = String(cfstr)
    }
}
//
//  SwiftXPC.swift
//  SwiftXPC
//
//  Created by JP Simard on 10/29/14.
//  Copyright (c) 2014 JP Simard. All rights reserved.
//

import Foundation
import XPC

// MARK: General

/**
Converts an XPCRepresentable object to its xpc_object_t value.

- parameter object: XPCRepresentable object to convert.

- returns: Converted XPC object.
*/
func toXPCGeneral(object: XPCRepresentable) -> xpc_object_t? {
    switch object {
    case let object as XPCArray:
        return toXPC(object)
    case let object as XPCDictionary:
        return toXPC(object)
    case let object as String:
        return toXPC(object)
    case let object as NSDate:
        return toXPC(object)
    case let object as NSData:
        return toXPC(object)
    case let object as UInt64:
        return toXPC(object)
    case let object as Int64:
        return toXPC(object)
    case let object as Double:
        return toXPC(object)
    case let object as Bool:
        return toXPC(object)
    case let object as NSFileHandle:
        return toXPC(object)
    case let object as NSUUID:
        return toXPC(object)
    default:
        // Should never happen because we've checked all XPCRepresentable types
        return nil
    }
}

/**
Converts an xpc_object_t to its Swift value (XPCRepresentable).

- parameter xpcObject: xpc_object_t object to to convert.

- returns: Converted XPCRepresentable object.
*/
func fromXPCGeneral(xpcObject: xpc_object_t) -> XPCRepresentable? {
    let type = xpc_get_type(xpcObject)
    switch typeMap[type]! {
    case .Array:
        return fromXPC(xpcObject) as XPCArray
    case .Dictionary:
        return fromXPC(xpcObject) as XPCDictionary
    case .String:
        return fromXPC(xpcObject) as String!
    case .Date:
        return fromXPC(xpcObject) as NSDate!
    case .Data:
        return fromXPC(xpcObject) as NSData!
    case .UInt64:
        return fromXPC(xpcObject) as UInt64!
    case .Int64:
        return fromXPC(xpcObject) as Int64!
    case .Double:
        return fromXPC(xpcObject) as Double!
    case .Bool:
        return fromXPC(xpcObject) as Bool!
    case .FileHandle:
        return fromXPC(xpcObject) as NSFileHandle!
    case .UUID:
        return fromXPC(xpcObject) as NSUUID!
    }
}

// MARK: Array

/**
Converts an Array of XPCRepresentable objects to its xpc_object_t value.

- parameter array: Array of XPCRepresentable objects to convert.

- returns: Converted XPC array.
*/
func toXPC(array: XPCArray) -> xpc_object_t {
    let xpcArray = xpc_array_create(nil, 0)
    for value in array {
        if let xpcValue = toXPCGeneral(value) {
            xpc_array_append_value(xpcArray, xpcValue)
        }
    }
    return xpcArray
}

/**
Converts an xpc_object_t array to an Array of XPCRepresentable objects.

- parameter xpcObject: XPC array to to convert.

- returns: Converted Array of XPCRepresentable objects.
*/
func fromXPC(xpcObject: xpc_object_t) -> XPCArray {
    var array = XPCArray()
    xpc_array_apply(xpcObject) { index, value in
        if let value = fromXPCGeneral(value) {
            array.insert(value, atIndex: Int(index))
        }
        return true
    }
    return array
}

// MARK: Dictionary

/**
Converts a Dictionary of XPCRepresentable objects to its xpc_object_t value.

- parameter dictionary: Dictionary of XPCRepresentable objects to convert.

- returns: Converted XPC dictionary.
*/
func toXPC(dictionary: XPCDictionary) -> xpc_object_t {
    let xpcDictionary = xpc_dictionary_create(nil, nil, 0)
    for (key, value) in dictionary {
        xpc_dictionary_set_value(xpcDictionary, key, toXPCGeneral(value))
    }
    return xpcDictionary
}

/**
Converts an xpc_object_t dictionary to a Dictionary of XPCRepresentable objects.

- parameter xpcObject: XPC dictionary to to convert.

- returns: Converted Dictionary of XPCRepresentable objects.
*/
func fromXPC(xpcObject: xpc_object_t) -> XPCDictionary {
    var dict = XPCDictionary()
    xpc_dictionary_apply(xpcObject) { key, value in
        if let key = String(UTF8String: key), let value = fromXPCGeneral(value) {
            dict[key] = value
        }
        return true
    }
    return dict
}

// MARK: String

/**
Converts a String to an xpc_object_t string.

- parameter string: String to convert.

- returns: Converted XPC string.
*/
func toXPC(string: String) -> xpc_object_t? {
    return xpc_string_create(string)
}

/**
Converts an xpc_object_t string to a String.

- parameter xpcObject: XPC string to to convert.

- returns: Converted String.
*/
func fromXPC(xpcObject: xpc_object_t) -> String? {
    return String(UTF8String: xpc_string_get_string_ptr(xpcObject))
}

// MARK: Date

private let xpcDateInterval: NSTimeInterval = 1000000000

/**
Converts an NSDate to an xpc_object_t date.

- parameter date: NSDate to convert.

- returns: Converted XPC date.
*/
func toXPC(date: NSDate) -> xpc_object_t? {
    return xpc_date_create(Int64(date.timeIntervalSince1970 * xpcDateInterval))
}

/**
Converts an xpc_object_t date to an NSDate.

- parameter xpcObject: XPC date to to convert.

- returns: Converted NSDate.
*/
func fromXPC(xpcObject: xpc_object_t) -> NSDate? {
    let nanosecondsInterval = xpc_date_get_value(xpcObject)
    return NSDate(timeIntervalSince1970: NSTimeInterval(nanosecondsInterval) / xpcDateInterval)
}

// MARK: Data

/**
Converts an NSData to an xpc_object_t data.

- parameter data: Data to convert.

- returns: Converted XPC data.
*/
func toXPC(data: NSData) -> xpc_object_t? {
    return xpc_data_create(data.bytes, data.length)
}

/**
Converts an xpc_object_t data to an NSData.

- parameter xpcObject: XPC data to to convert.

- returns: Converted NSData.
*/
func fromXPC(xpcObject: xpc_object_t) -> NSData? {
    return NSData(bytes: xpc_data_get_bytes_ptr(xpcObject), length: Int(xpc_data_get_length(xpcObject)))
}

// MARK: UInt64

/**
Converts a UInt64 to an xpc_object_t uint64.

- parameter number: UInt64 to convert.

- returns: Converted XPC uint64.
*/
func toXPC(number: UInt64) -> xpc_object_t? {
    return xpc_uint64_create(number)
}

/**
Converts an xpc_object_t uint64 to a UInt64.

- parameter xpcObject: XPC uint64 to to convert.

- returns: Converted UInt64.
*/
func fromXPC(xpcObject: xpc_object_t) -> UInt64? {
    return xpc_uint64_get_value(xpcObject)
}

// MARK: Int64

/**
Converts an Int64 to an xpc_object_t int64.

- parameter number: Int64 to convert.

- returns: Converted XPC int64.
*/
func toXPC(number: Int64) -> xpc_object_t? {
    return xpc_int64_create(number)
}

/**
Converts an xpc_object_t int64 to a Int64.

- parameter xpcObject: XPC int64 to to convert.

- returns: Converted Int64.
*/
func fromXPC(xpcObject: xpc_object_t) -> Int64? {
    return xpc_int64_get_value(xpcObject)
}

// MARK: Double

/**
Converts a Double to an xpc_object_t double.

- parameter number: Double to convert.

- returns: Converted XPC double.
*/
func toXPC(number: Double) -> xpc_object_t? {
    return xpc_double_create(number)
}

/**
Converts an xpc_object_t double to a Double.

- parameter xpcObject: XPC double to to convert.

- returns: Converted Double.
*/
func fromXPC(xpcObject: xpc_object_t) -> Double? {
    return xpc_double_get_value(xpcObject)
}

// MARK: Bool

/**
Converts a Bool to an xpc_object_t bool.

- parameter bool: Bool to convert.

- returns: Converted XPC bool.
*/
func toXPC(bool: Bool) -> xpc_object_t? {
    return xpc_bool_create(bool)
}

/**
Converts an xpc_object_t bool to a Bool.

- parameter xpcObject: XPC bool to to convert.

- returns: Converted Bool.
*/
func fromXPC(xpcObject: xpc_object_t) -> Bool? {
    return xpc_bool_get_value(xpcObject)
}

// MARK: FileHandle

/**
Converts an NSFileHandle to an equivalent xpc_object_t file handle.

- parameter fileHandle: NSFileHandle to convert.

- returns: Converted XPC file handle. Equivalent but not necessarily identical to the input.
*/
func toXPC(fileHandle: NSFileHandle) -> xpc_object_t? {
    return xpc_fd_create(fileHandle.fileDescriptor)
}

/**
Converts an xpc_object_t file handle to an equivalent NSFileHandle.

- parameter xpcObject: XPC file handle to to convert.

- returns: Converted NSFileHandle. Equivalent but not necessarily identical to the input.
*/
func fromXPC(xpcObject: xpc_object_t) -> NSFileHandle? {
    return NSFileHandle(fileDescriptor: xpc_fd_dup(xpcObject), closeOnDealloc: true)
}

/**
Converts an NSUUID to an equivalent xpc_object_t uuid.

- parameter uuid: NSUUID to convert.

- returns: Converted XPC uuid. Equivalent but not necessarily identical to the input.
*/
func toXPC(uuid: NSUUID) -> xpc_object_t? {
    var bytes = [UInt8](count: 16, repeatedValue: 0)
    uuid.getUUIDBytes(&bytes)
    return xpc_uuid_create(bytes)
}

/**
Converts an xpc_object_t uuid to an equivalent NSUUID.

- parameter xpcObject: XPC uuid to to convert.

- returns: Converted NSUUID. Equivalent but not necessarily identical to the input.
*/
func fromXPC(xpcObject: xpc_object_t) -> NSUUID? {
    return NSUUID(UUIDBytes: xpc_uuid_get_bytes(xpcObject))
}
