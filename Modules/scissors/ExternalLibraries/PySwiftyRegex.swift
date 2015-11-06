// PySwiftyRegex.swift
// Copyright (c) 2015 Ce Zheng
//
// Permission is hereby granted, free of charge, to any person obtaining a copy
// of this software and associated documentation files (the "Software"), to deal
// in the Software without restriction, including without limitation the rights
// to use, copy, modify, merge, publish, distribute, sublicense, and/or sell
// copies of the Software, and to permit persons to whom the Software is
// furnished to do so, subject to the following conditions:
//
// The above copyright notice and this permission notice shall be included in
// all copies or substantial portions of the Software.
//
// THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR
// IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY,
// FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE
// AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER
// LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM,
// OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN
// THE SOFTWARE.

import Foundation

public class re {
    public static func compile(pattern: String, flags: RegexObject.Flag = []) -> RegexObject  {
        return RegexObject(pattern: pattern, flags: flags)
    }

    public static func findall(pattern: String, _ string: String, flags: RegexObject.Flag = []) -> [String] {
        return re.compile(pattern, flags: flags).findall(string)
    }
    
    /**
    Return an array of MatchObject instances over all non-overlapping matches for the RE pattern in string. The string is scanned left-to-right, and matches are returned in the order found. Empty matches are included in the result unless they touch the beginning of another match.
    
    See https://docs.python.org/2/library/re.html#re.finditer
    
    :param: pattern regular expression pattern string
    :param: string  string to be searched
    :param: flags   NSRegularExpressionOptions value
    
    :returns: Array of match results as MatchObject instances
    */
    public static func finditer(pattern: String, _ string: String, flags: RegexObject.Flag = []) -> [MatchObject] {
        return re.compile(pattern, flags: flags).finditer(string)
    }
    
    /**
    Return the string obtained by replacing the leftmost non-overlapping occurrences of pattern in string by the replacement repl. If the pattern isn’t found, string is returned unchanged. Different from python, passing a repl as a closure is not supported.
    
    See https://docs.python.org/2/library/re.html#re.sub
    
    :param: pattern regular expression pattern string
    :param: repl    replacement string
    :param: string  string to be searched and replaced
    :param: count   maximum number of times to perform replace operations to the string
    :param: flags   NSRegularExpressionOptions value
    
    :returns: replaced string
    */
    public static func sub(pattern: String, _ repl: String, _ string: String, _ count: Int = 0, flags: RegexObject.Flag = []) -> String {
        return re.compile(pattern, flags: flags).sub(repl, string, count)
    }
    
    /**
    Perform the same operation as sub(), but return a tuple (new_string, number_of_subs_made) as (String, Int)
    
    See https://docs.python.org/2/library/re.html#re.subn
    
    :param: pattern regular expression pattern string
    :param: repl    replacement string
    :param: string  string to be searched and replaced
    :param: count   maximum number of times to perform replace operations to the string
    :param: flags   NSRegularExpressionOptions value
    
    :returns: a tuple (new_string, number_of_subs_made) as (String, Int)
    */
    public static func subn(pattern: String, _ repl: String, _ string: String, _ count: Int = 0, flags: RegexObject.Flag = []) -> (String, Int) {
        return re.compile(pattern, flags: flags).subn(repl, string, count)
    }
    
    // MARK: - RegexObject
    /**
    *  Counterpart of Python's re.RegexObject
    */
    public class RegexObject {
        /// Typealias for NSRegularExpressionOptions
        public typealias Flag = NSRegularExpressionOptions
        
        /// Whether this object is valid or not
        public var isValid: Bool {
            return regex != nil
        }
        
        /// Pattern used to construct this RegexObject
        public let pattern: String
        
        private let regex: NSRegularExpression?
        
        /// Underlying NSRegularExpression Object
        public var nsRegex: NSRegularExpression? {
            return regex
        }
        
        /// NSRegularExpressionOptions used to contructor this RegexObject
        public var flags: Flag {
            return regex?.options ?? Flag(rawValue: 0)
        }
        
        /// Number of capturing groups
        public var groups: Int {
            return regex?.numberOfCaptureGroups ?? 0
        }
        
        /**
        Create A re.RegexObject Instance
        
        :param: pattern regular expression pattern string
        :param: flags   NSRegularExpressionOptions value
        
        :returns: The created RegexObject object. If the pattern is invalid, RegexObject.isValid is false, and all methods have a default return value.
        */
        public required init(pattern: String, flags: Flag = [])  {
            self.pattern = pattern
            do {
                self.regex = try NSRegularExpression(pattern: pattern, options: flags)
            } catch let error as NSError {
                self.regex = nil
                print(error)
            }
        }
        
        /**
        Scan through string looking for a location where this regular expression produces a match, and return a corresponding MatchObject instance. Return nil if no position in the string matches the pattern; note that this is different from finding a zero-length match at some point in the string.
        
        See https://docs.python.org/2/library/re.html#re.RegexObject.search
        
        :param: string  string to be searched
        :param: pos     position in string where the search is to start, defaults to 0
        :param: endpos  position in string where the search it to end (non-inclusive), defaults to nil, meaning the end of the string. If endpos is less than pos, no match will be found.
        :param: options NSMatchOptions value
        
        :returns: search result as MatchObject instance if a match is found, otherwise return nil
        */
        public func search(string: String, _ pos: Int = 0, _ endpos: Int? = nil, options: NSMatchingOptions = []) -> MatchObject? {
            guard let regex = regex else {
                return nil
            }
            let start = pos > 0 ?pos :0
            let end = endpos ?? string.characters.count
            let length = max(0, end - start)
            let range = NSRange(location: start, length: length)
            let match = regex.firstMatchInString(string, options: options, range: range)
            if let match = match {
                return MatchObject(string: string, match: match)
            }
            return nil
        }
        
        /**
        If zero or more characters at the beginning of string match this regular expression, return a corresponding MatchObject instance. Return nil if the string does not match the pattern; note that this is different from a zero-length match.
        
        See https://docs.python.org/2/library/re.html#re.RegexObject.match
        
        :param: string string to be matched
        :param: pos     position in string where the search is to start, defaults to 0
        :param: endpos  position in string where the search it to end (non-inclusive), defaults to nil, meaning the end of the string. If endpos is less than pos, no match will be found.
        
        :returns: match result as MatchObject instance if a match is found, otherwise return nil
        */
        public func match(string: String, _ pos: Int = 0, _ endpos: Int? = nil) -> MatchObject? {
            return search(string, pos, endpos, options: [.Anchored])
        }
        
        /**
        Identical to the re.split() function, using the compiled pattern.
        
        See https://docs.python.org/2/library/re.html#re.RegexObject.split
        
        :param: string   string to be splitted
        :param: maxsplit maximum number of times to split the string, defaults to 0, meaning no limit is applied
        
        :returns: Array of splitted strings
        */
        public func split(string: String, _ maxsplit: Int = 0) -> [String?] {
            guard let regex = regex else {
                return []
            }
            var splitsLeft = maxsplit == 0 ? Int.max : (maxsplit < 0 ? 0 : maxsplit)
            let range = NSRange(location: 0, length: string.characters.count)
            var results = [String?]()
            var start = string.startIndex
            var end = string.startIndex
            regex.enumerateMatchesInString(string, options: [], range: range) { result, _, stop in
                if splitsLeft <= 0 {
                    stop.memory = true
                    return
                }
                
                guard let result = result where result.range.length > 0 else {
                    return
                }
                
                end = string.startIndex.advancedBy(result.range.location)
                results.append(string.substringWithRange(start..<end))
                if regex.numberOfCaptureGroups > 0 {
                    results.appendContentsOf(MatchObject(string: string, match: result).groups())
                }
                splitsLeft--
                start = end.advancedBy(result.range.length)
            }
            if start <= string.endIndex {
                results.append(string.substringWithRange(start..<string.endIndex))
            }
            return results
        }
        
        /**
        Similar to the re.findall() function, using the compiled pattern, but also accepts optional pos and endpos parameters that limit the search region like for match().
        
        See https://docs.python.org/2/library/re.html#re.RegexObject.findall
        
        :param: string string to be matched
        :param: pos     position in string where the search is to start, defaults to 0
        :param: endpos  position in string where the search it to end (non-inclusive), defaults to nil, meaning the end of the string. If endpos is less than pos, no match will be found.
        
        :returns: Array of matched substrings
        */
        public func findall(string: String, _ pos: Int = 0, _ endpos: Int? = nil) -> [String] {
            return finditer(string, pos, endpos).map { $0.group()! }
        }
        
        /**
        Similar to the re.finditer() function, using the compiled pattern, but also accepts optional pos and endpos parameters that limit the search region like for match().
        
        https://docs.python.org/2/library/re.html#re.RegexObject.finditer
        
        :param: string string to be matched
        :param: pos     position in string where the search is to start, defaults to 0
        :param: endpos  position in string where the search it to end (non-inclusive), defaults to nil, meaning the end of the string. If endpos is less than pos, no match will be found.
        
        :returns: Array of match results as MatchObject instances
        */
        public func finditer(string: String, _ pos: Int = 0, _ endpos: Int? = nil) -> [MatchObject] {
            guard let regex = regex else {
                return []
            }
            let start = pos > 0 ?pos :0
            let end = endpos ?? string.characters.count
            let length = max(0, end - start)
            let range = NSRange(location: start, length: length)
            return regex.matchesInString(string, options: [], range: range).map { MatchObject(string: string, match: $0) }
        }
        
        /**
        Identical to the re.sub() function, using the compiled pattern.
        
        See https://docs.python.org/2/library/re.html#re.RegexObject.sub
        
        :param: repl    replacement string
        :param: string  string to be searched and replaced
        :param: count   maximum number of times to perform replace operations to the string
        
        :returns: replaced string
        */
        public func sub(repl: String, _ string: String, _ count: Int = 0) -> String {
            return subn(repl, string, count).0
        }
        
        /**
        Identical to the re.subn() function, using the compiled pattern.
        
        See https://docs.python.org/2/library/re.html#re.RegexObject.subn
        
        :param: repl    replacement string
        :param: string  string to be searched and replaced
        :param: count   maximum number of times to perform replace operations to the string
        
        :returns: a tuple (new_string, number_of_subs_made) as (String, Int)
        */
        public func subn(repl: String, _ string: String, _ count: Int = 0) -> (String, Int) {
            guard let regex = regex else {
                return (string, 0)
            }
            let range = NSRange(location: 0, length: string.characters.count)
            let mutable = NSMutableString(string: string)
            let maxCount = count == 0 ? Int.max : (count > 0 ? count : 0)
            var n = 0
            var offset = 0
            regex.enumerateMatchesInString(string, options: [], range: range) { result, _, stop in
                if maxCount <= n {
                    stop.memory = true
                    return
                }
                if let result = result {
                    n++
                    let resultRange = NSRange(location: result.range.location + offset, length: result.range.length)
                    let lengthBeforeReplace = mutable.length
                    regex.replaceMatchesInString(mutable, options: [], range: resultRange, withTemplate: repl)
                    offset += mutable.length - lengthBeforeReplace
                }
            }
            return (mutable as String, n)
        }
    }
    
    // MARK: - MatchObject
    /**
    *  Counterpart of Python's re.MatchObject
    */
    public final class MatchObject {
        /// String matched
        public let string: String
        
        /// Underlying NSTextCheckingResult
        public let match: NSTextCheckingResult
        
        init(string: String, match: NSTextCheckingResult) {
            self.string = string
            self.match = match
        }
        
        /**
        Return the string obtained by doing backslash substitution on the template string template, as done by the sub() method.
        
        Note that named backreferences in python is not supported here since NSRegularExpression does not have this feature.
        
        See https://docs.python.org/2/library/re.html#re.MatchObject.expand
        
        :param: template regular expression template decribing the expanded format
        
        :returns: expanded string
        */
        public func expand(template: String) -> String {
            guard let regex = match.regularExpression else {
                return ""
            }
            return regex.replacementStringForResult(match, inString: string, offset: 0, template: template)
        }
        
        /**
        Returns one subgroup of the match. If the group number is negative or larger than the number of groups defined in the pattern, nil returned. If a group is contained in a part of the pattern that did not match, the corresponding result is nil. If a group is contained in a part of the pattern that matched multiple times, the last match is returned.
        
        Note that different from python's group function this function does not accept multiple arguments due to ambiguous syntax. If you would like to use multiple arguments pass in an array instead.
        
        See https://docs.python.org/2/library/re.html#re.MatchObject.group
        
        :param: index group index, defaults to 0, meaning the entire matching string
        
        :returns: string of the matching group
        */
        public func group(index: Int = 0) -> String? {
            guard let range = span(index) where range.startIndex < string.endIndex else {
                return nil
            }
            return string.substringWithRange(range)
        }
        
        /**
        Returns one or more subgroups of the match. If a group number is negative or larger than the number of groups defined in the pattern, nil is inserted at the relevant index of the returned array. If a group is contained in a part of the pattern that did not match, the corresponding result is None. If a group is contained in a part of the pattern that matched multiple times, the last match is returned.
        
        See https://docs.python.org/2/library/re.html#re.MatchObject.group
        
        :param: indexes array of group indexes to get
        
        :returns: array of strings of the matching groups
        */
        public func group(indexes: [Int]) -> [String?] {
            return indexes.map { group($0) }
        }
        
        /**
        Return an array containing all the subgroups of the match, from 1 up to however many groups are in the pattern. The default argument is used for groups that did not participate in the match.
        
        Note that python version of this function returns a tuple while this one returns an array due to the fact that swift cannot specify a variadic tuple as return value.
        
        See https://docs.python.org/2/library/re.html#re.MatchObject.groups
        
        :param: defaultValue default value string
        
        :returns: array of all matching subgroups as String
        */
        public func groups(defaultValue: String) -> [String] {
            return (1..<match.numberOfRanges).map { group($0) ?? defaultValue }
        }
        
        /**
        Return an array containing all the subgroups of the match, from 1 up to however many groups are in the pattern. For groups that did not participate in the match, nil is inserted at the relevant index of the return array.
        
        Note that python version of this function returns a tuple while this one returns an array due to the fact that swift cannot specify a variadic tuple as return value.
        
        See https://docs.python.org/2/library/re.html#re.MatchObject.groups
        
        :returns: array of all matching subgroups as String? (nil when relevant optional capture group is not matched)
        */
        public func groups() -> [String?] {
            return (1..<match.numberOfRanges).map { group($0) }
        }
        
        /**
        Return the range of substring matched by group; group defaults to zero (meaning the whole matched substring). Return nil if paremeter is invalid or group exists but did not contribute to the match.
        
        See https://docs.python.org/2/library/re.html#re.MatchObject.span
        
        :param: index group index
        
        :returns: range of matching group substring
        */
        public func span(index: Int = 0) -> Range<String.Index>? {
            if index >= match.numberOfRanges {
                return nil
            }
            let nsrange = match.rangeAtIndex(index)
            
            if nsrange.location == NSNotFound {
                return string.endIndex..<string.endIndex
            }
            let startIndex = string.startIndex.advancedBy(nsrange.location)
            let endIndex = startIndex.advancedBy(nsrange.length)
            return startIndex..<endIndex
        }
        
        public func spanNSRange(index: Int = 0) -> NSRange? {
            if index >= match.numberOfRanges {
                return nil
            }
            return  match.rangeAtIndex(index)
        }
    }
}