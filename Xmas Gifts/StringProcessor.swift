//
//  StringProcessor.swift
//  Xmas List
//
//  Created by David Figge on 1/2/17.
//  Copyright © 2017 David Figge. All rights reserved.
//
//  This class simplifies processing of strings and substring retrieval
//  To use: construct the StringProcessor passing in the string to be examined, then call
//  firstDelimiter -- Returns the first specified delimiter found in the string. Ignores the current location in the string value
//  lastIndexOf -- Returns an integer of the last specified delimiter found in the string. Ignores the current location in the string value
//  wordBefore -- Returns the word found before and ending at the current index, using the supplied delimiters for determining word breaks
//  nextString -- Returns the next string found starting from the current location and ending when one of the specified delimiter is found. Current position is moved passed the delimiter. Default value is passed if no string found
//  In general, quote marks (") within the string are used to identify parts of the string that should not be broken up.

import UIKit

class StringProcessor: NSObject {
    private var target : String
    private var current : String.Index
    private var done = false
    
    // Public constructor. Establishes the target string
    public init(line : String) {
        target = line
        current = line.startIndex
    }
    
    // Indicates if the current character being evaluated is a quote mark
    private func isQuote() -> Bool {
        if done {
            return false
        }
        let c = target[current]
        let retValue = c == "\"" || c == "\u{201c}" || c == "\u{201d}"
        return retValue
    }
    
    // Moves current to the next character, returning false if the end of the string is reached
    private func nextCharacter() -> Bool {
        if done {
            return false                    // If already at end, abort
        }
        if current < target.endIndex {      // If there is a next character...
            current = target.index(current, offsetBy:1) // Move to next character
        }
        if current == target.endIndex {
            done = true
        }
        return !done
    }
    
    // Return the first occurrence of one of the delimiters in the string. Return nil if none found
    public func firstDelimiter(delimiters:String) -> Character? {
        var inQuotes = false
        for c in target {
            if c == "\"" {
                inQuotes = !inQuotes
            }
            if !inQuotes {
                for d in delimiters {
                    if c == d {
                        return d
                    }
                }
            }
        }
        return nil
    }
//    public func firstDelimiter(delimiters:String) -> Character? {
//        var inQuotes = false
//        for c in target.characters {
//            if c == "\"" {
//                inQuotes = !inQuotes
//            }
//            if !inQuotes {
//                for d in delimiters.characters {
//                    if (c == d) {
//                        return d
//                    }
//                }
//            }
//        }
//        return nil
//    }
    
    // Return the index of the last occurrence of one of the delimiters specified, or -1 if none found
    public func lastIndexOf(delimiters:String) -> Int {
        var lastIndex = -1;
        var index = -1;
        var inQuotes = false;
        for c in target {
            index += 1
            if c == "\"" {
                inQuotes = !inQuotes
            }
            if !inQuotes {
                for d in delimiters {
                    if (c == d) {
                        lastIndex = index
                    }
                }
            }
        }
        return lastIndex
    }
//    public func lastIndexOf(delimiters:String) -> Int {
//        var lastIndex = -1
//        var index = -1
//        var inQuotes = false
//        for c in target.characters {
//            index += 1
//            if c == "\"" {
//                inQuotes = !inQuotes
//            }
//            if !inQuotes {
//                for d in delimiters.characters {
//                    if (c == d) {
//                        lastIndex = index
//                    }
//                }
//            }
//        }
//        return lastIndex
//    }
    
    // Return the word located before the specified index value, using the delimiters specified to determine the start of the word
    public func wordBefore(index:Int, delimiters:String) -> String {
        var currentIndex = index - 1
        var previousDelimiter = -1
        while currentIndex > 0 && previousDelimiter < 0 {
            let c = target[target.index(target.startIndex, offsetBy:currentIndex)]
            for d in delimiters {
                if c == d {
                    previousDelimiter = currentIndex
                }
            }
            currentIndex -= 1
        }
        let startIndex = target.index(target.startIndex, offsetBy:previousDelimiter+1)
        let endIndex = target.index(target.startIndex, offsetBy:index-1)
        return String(target[startIndex...endIndex])
    }
//    public func wordBefore(index:Int, delimiters:String) -> String {
//        var currentIndex = index-1
//        var previousDelimiter = -1
//        var stringIndex = target.index(target.startIndex, offsetBy:currentIndex)
//        while index >= 0 && previousDelimiter < 0 {
//            let c = target.characters[stringIndex]
//            for d in delimiters.characters {
//                if c == d {
//                    previousDelimiter = currentIndex
//                }
//            }
//            currentIndex -= 1
//            stringIndex = target.index(target.startIndex, offsetBy:currentIndex)
//        }
//        let startIndex = target.index(target.startIndex, offsetBy:previousDelimiter+1)
//        let endIndex = target.index(target.startIndex, offsetBy:index-1)
//        return String(target[startIndex...endIndex])
//    }
    
    // Return the next sub-string in the target, using the delimiters specified to locate the end of the string
    public func nextString(delimiter:String, defaultValue:String="") -> String {
        if (done) {
            return defaultValue
        }
        let start = current
        var inQuotes = false
        repeat {
            if isQuote() {
                inQuotes = !inQuotes
                _ = nextCharacter()
                if done {
                    break;
                }
            }
            if !inQuotes {
                let ch = target[current]
                _ = target.utf8CString[target.distance(from:target.startIndex, to:current)]
                let index = delimiter.index(of:ch)
                if index != nil {
                    let end = target.index(current,offsetBy:-1)
                    _ = nextCharacter()         // Skip past delimiter
                    if (end <= start) { return "" }
                    return trim(string: String(target[start...end]))
                }
            }
            _ = nextCharacter()
        } while !done
        let end = target.index(current, offsetBy:-1)
        if end <= start { return "" }
        return trim(string: String(target[start...end]))
    }
    
    // Trim the start and end of the string, removing standard whitespace characters
    private func trim(string : String) -> String {
        let whiteSpace = "\" ,.()*&^%$#@!;`~\\/':;=+"
        var start = string.startIndex
        var end = string.index(string.endIndex,offsetBy:-1)
        var startMoved = false
        var endMoved = false
        while start < end && isDelimiter(string:string, index:start, delimiters:whiteSpace) {
            start = string.index(start, offsetBy:1)
            startMoved = true
        }
        while end > start && isDelimiter(string:string, index: string.index(end,offsetBy:-1), delimiters:whiteSpace) {
            end = string.index(end,offsetBy:-1)
            endMoved = true
        }
        if startMoved || endMoved {
            return (String(string[start...end]))
        }
        return string
    }
    
    // Return true if the character at the specified index is a delimiter character
    private func isDelimiter(string: String, index: String.Index, delimiters: String) -> Bool {
        return isDelimiter(char: string[index], delimiters:delimiters)
    }
    
    // Return true if the passed-in character is in the delimiters list
    private func isDelimiter(char : Character, delimiters: String) -> Bool {
        for c in delimiters {
            if (char == c) {
                return true
            }
        }
        return false
    }
}
