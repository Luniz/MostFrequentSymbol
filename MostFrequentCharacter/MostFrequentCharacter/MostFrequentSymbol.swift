//
//  TheMostFrequentSymbol.swift
//  MostFrequentSymbol
//
//  Created by Chinara on 5/14/16.
//  Copyright © 2016 Chinara. All rights reserved.
//

import Foundation

extension String {
    
    subscript (i: Int) -> Character {
        return self[self.startIndex.advancedBy(i)]
    }
    
    func ASCIIRepresentation() -> [CChar] {
        var scalars : [CChar] = []
        for (i:scalar) in self.unicodeScalars {
            scalars.append(CChar(scalar.value))
        }
        return scalars
    }
}


class MostFrequentSymbol {
    
    func mapAndCountSymbolsInArray(array : [CChar]) -> [CChar:Int]? {
        
        if (array.count == 0) {
            return nil
        }
        
        var result = [CChar: Int]()
        array.forEach { (char) in
            result[char] = (result[char] ?? 0) + 1
        }
        return result
    }
    
    
    func mergeMappedDictionaries(leftSlice : [CChar:Int], rightSlice : [CChar:Int]) -> [CChar:Int]? {
        
        let source : [CChar:Int] = leftSlice.count > rightSlice.count ? leftSlice : rightSlice
        var result : [CChar:Int] = leftSlice.count <= rightSlice.count ? leftSlice : rightSlice
        
        source.forEach { key, value in
            if let existedValue = result[key] {
                result[key] = value + existedValue
            } else {
                result[key] = value
            }
        }

        return result
    }
    
    func findTheMostFrequentSymbolInArray(array : [CChar]) -> (CChar, Int)? {
        
        assert(array.count > 2, "array must contain 2 or more symbols")
        
        let range = NSMakeRange(0, Int(array.count/2))
        
        let leftSplit = array[range.location..<range.length]
        let rightSplit = array[range.length..<array.count]

        let concurrentQueue = dispatch_queue_create("TheMostFrequentSymbolConcurrentQueue", DISPATCH_QUEUE_CONCURRENT)
        
        var result : [CChar:Int]? = nil
        var leftSlice : [CChar:Int]? = nil
        var rightSlice : [CChar:Int]? = nil
        
        dispatch_async(concurrentQueue) {
            leftSlice = self.mapAndCountSymbolsInArray(Array(leftSplit))
        }
        
        dispatch_async(concurrentQueue) {
            rightSlice = self.mapAndCountSymbolsInArray(Array(rightSplit))
        }

        dispatch_barrier_sync(concurrentQueue) {
            result = self.mergeMappedDictionaries(leftSlice!, rightSlice: rightSlice!);
        }
        
        let maxElement = result?.maxElement { (a, b) -> Bool in
            return a.1 < b.1
        }

        return maxElement
    }
    
    
    func findTheMostFrequentCharacterInString(string : String) -> (character:CChar, count:Int, representation:String) {
        
        let charsArray : [CChar]? = string.ASCIIRepresentation()
        
        // If string is ascii string
        
        //        let array = string.componentsSeparatedByString(" ");
        //        let charsArray = array.map { (str) -> CChar in
        //            return CChar(str)!
        //        }
        // else
        if (charsArray?.count == 0) {
            return (0, 0, "")
        }
        
        
        if let tuple = self.findTheMostFrequentSymbolInArray(charsArray!) {
            
            let symbol : Int = Int(tuple.0)
            let stringRepresentation = String(Character(UnicodeScalar(symbol)))
            return (tuple.0, tuple.1, stringRepresentation)
        }
        
        return (0, 0, "")
    }
}