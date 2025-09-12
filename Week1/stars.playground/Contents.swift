//: Creating random pattern from string

import Foundation

// swift must use index to access parts of string

let symbol = "⭐"

func printLine(indent: Int, leftStars: Int, gap: Int, rightStars: Int) {
    print(String(repeating: " ", count: indent) +
          String(repeating: symbol, count: leftStars) +
          String(repeating: " ", count: gap) +
          String(repeating: symbol, count: rightStars))
}

func printStars() {
    let rows = [
        (1, 1, 6, 1),
        (0, 2, 4, 2),
        (1, 1, 3, 4),
        (4, 0, 0, 6),
        (1, 1, 3, 4),
        (0, 2, 4, 2),
        (1, 1, 6, 1)
    ]
    
    for (indent, left, gap, right) in rows {
        printLine(indent: indent, leftStars: left, gap: gap, rightStars: right)
    }
}

printStars()


