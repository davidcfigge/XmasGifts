//
//  DataUtils.swift
//  Xmas Gifts
//
//  Created by David Figge on 3/2/17.
//  Copyright © 2017 WildTangent. All rights reserved.
//
//  Various (static) utility functions having to do with People and Gifts

import Foundation

class DataUtils {
        static func getSummaryString(person:Person!) -> String {
        let result = DataUtils.getDollarString(amount:(person?.spent())!) + " / " + DataUtils.getDollarString(amount:(person?.Budget)!)
        return result
    }
    
    // Return the total amount of money budgeted for gifts (i.e. the sum of all people's budgets) in cents
    static func getTotalBudget() -> Int {
        var budget = 0
        for key in People.keys {
            budget += People.Entries[key].Budget
        }
        return budget
    }
    
    // Return the total amount of money spent so far in cents
    static func getTotalSpent() -> Int {
        var spent = 0
        for key in People.keys {
            spent += People.Entries[key].spent()
        }
        return spent
    }
    
    // Return the amount of money remaining in the budgets for additional purchases in cents
    static func getBudgetRemaining() -> Int {
        return DataUtils.getTotalBudget() - DataUtils.getTotalSpent()
    }
    
    // Retrun a summary string suitable for display containing: spent / budgeted
    static func getSummaryString() -> String {
        let totalBudget = getTotalBudget()
        let totalSpent = getTotalSpent()
        let result = getDollarString(amount:totalSpent) + " / " + DataUtils.getDollarString(amount:totalBudget)
        return result
    }
    
    // Convert from cents to dollars, ignoring cents
    static func getDollarInt(amount:Int) -> Int {
        return amount/100
    }
    
    // Convert cents into a printable dollar value (but not editable) form, as in $xxx
    static func getDollarString(amount:Int) -> String {
        return "$" + String(getDollarInt(amount:amount))
    }
    
    // Convert cents into a printable dollar.cent value (but not editable) for, as in $xxx.xx
    static func getDollarCentString(amount:Int) -> String {
        return "$" + getEditableDollarCentString(amount: amount)
    }
    
    // Convert cents into an editable value containing dollars and cents, as int xxx.xx
    static func getEditableDollarCentString(amount:Int) -> String {
        var amountString = String(amount)
        var len = amountString.count
        if (len == 0) {
            amountString = "000"
            len = 3
        } else if len == 1 {
            amountString = "00" + amountString
            len = 3
        } else if (len == 2) {
            amountString = "0" + amountString
            len = 3
        }
        let centIndex = amountString.index(amountString.endIndex,offsetBy: -2)
        let dollarIndex = amountString.index(amountString.endIndex,offsetBy:-3)
        return String(amountString[...dollarIndex]) + "." + String(amountString[centIndex...])
    }
    
    // Convert a dollar.cent string into cents. Prefacing $ is ignored. Basically returns int(amount * 100)
    static func getIntFromAmountString(amountString: String) -> Int {
        var amtStr = amountString
        if (amtStr.first == "$") {
            let startIndex = amtStr.index(amountString.startIndex, offsetBy:1)
            amtStr = String(amountString[startIndex...])
//            amtStr = amtStr.substring(from:amtStr.index(amountString.startIndex, offsetBy:1))
        }
        var amt = Double(amtStr)
        if amt == nil {
            amt = 0
        }
        return (Int)(amt! * 100)
    }
}
