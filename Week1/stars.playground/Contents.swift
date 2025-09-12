//: Creating random pattern from string

import Foundation

// swift must use index to access parts of string

let symbol = "⭐"

func rep(_ s: String, _ n: Int) -> String {
    return String(repeating: s, count: max(0, n))
}

func printLine(indent: Int, leftStars: Int, gap: Int, rightStars: Int) {
    print(rep(" ", indent) + rep(symbol, leftStars) + rep(" ", gap) + rep(symbol, rightStars))
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


