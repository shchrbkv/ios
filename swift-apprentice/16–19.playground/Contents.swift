// Chapter 16 - Protocols

import os

// Challenge 1
/*
protocol Feedable {
  func feed()
}

protocol Cleanable {
  func clean()
}

protocol Cageable: Cleanable {
  func cage()
}

protocol Tankable: Cleanable {
  func tank()
}

protocol Walkable {
  func walk()
}

class Dog: Feedable, Walkable {
  func feed() {
    print("Woof...thanks!")
  }

  func walk() {
    print("Walk the dog")
  }
}

class Cat: Feedable, Cleanable {
  func feed() {
    print("Yummy meow")
  }

  func clean() {
    print("Litter box cleaned")
  }
}

class Fish: Feedable, Tankable {
  func feed() {
    print("Fish goes blub")
  }

  func tank() {
    print("Fish has been tanked")
  }

  func clean() {
    print("Fish tank has been cleaned")
  }
}

class Bird: Feedable, Cageable {
  func feed() {
    print("Tweet!")
  }

  func cage() {
    print("Cage the bird")
  }

  func clean() {
    print("Clean the cage")
  }
}
*/

// Chapter 17 - Generics

// Challenge 1

class Cat {
    var name: String
    
    init(name: String) {
        self.name = name
    }
}

class Dog {
    var name: String
    
    init(name: String) {
        self.name = name
    }
}

class Keeper<Animal> {
    var name: String
    var care: [Animal] = []
    
    init(name: String) {
        self.name = name
    }
    
    var countAnimals: Int {
        care.count
    }
    
    func lookAfter(_ animal: Animal) {
        care.append(animal)
    }
    
    func animalAtIndex(at index: Int) -> Animal {
        care[index]
    }
}

let k = Keeper<Cat>(name: "Toby")
k.lookAfter(Cat(name: "Pickles"))
k.countAnimals
k.animalAtIndex(at: 0).name


// Chapter 18 - Access Control, Code Organization & Testing

// Challenge 1

class Logger {
    
    static let instance = Logger()
    
    private init() {}
    
    func log(_ string: String) {
        print(string)
    }
}

Logger.instance.log("cum")


// Challenge 2

struct Stack<Element> {
    private var array: [Element] = []
    
    var count: Int {
        array.count
    }
    
    var peek: Element? {
        array.last
    }

    init () {}
    
    init(fromArray array: [Element]) {
        self.array = array
    }
    
    
    mutating func pop() -> Element? {
        return array.popLast()
    }
    
    mutating func push(_ element: Element) {
        array.append(element)
    }
}

var stack = Stack(fromArray: [1,2,3])
stack.count
stack.peek!
stack.pop()
stack.push(0)
stack.peek!


// Challenge 3

let elf = GameCharacterFactory.make(ofType: .elf)
let giant = GameCharacterFactory.make(ofType: .giant)
let wizard = GameCharacterFactory.make(ofType: .wizard)

battle(elf, vs: giant)
battle(wizard, vs: giant)
battle(wizard, vs: elf)


// Chapter 19 - Custom Operators, Subscripts & Keypaths

// Challenge 1

extension Array {
  subscript(index index: Int) -> (String, String)? {
    guard let value = self[index] as? Int else {return nil}
    switch (value >= 0, abs(value) % 2) {
      case (true, 0): return ("positive", "even")
      case (true, 1): return ("positive", "odd")
      case (false, 0): return ("negative", "even")
      case (false, 1): return ("negative", "odd")
      default: return nil
    }
  }
}

let numbers = [-2, -1, 0, 1, 2]
numbers[index: 0]
numbers[index: 1]
numbers[index: 2]
numbers[index: 3]
numbers[index: 4]

// Challenge 2

extension String {
    subscript(index: Int) -> Character? {
        guard 0..<count ~= index else { return nil }
        return self[self.index(startIndex, offsetBy: index)]
    }
}

let s = "Cum inside"
s[10]

// Challenge 3

import CoreGraphics

infix operator **
func **<T: FloatingPoint>(base: T, power: Int) -> T {
    precondition(power >= 2)
    var result = base
    for _ in 2...power {
        result *= base
    }
    return result
}

let exponent = 3
let baseDouble = 2.0
var resultDouble = baseDouble ** exponent
let baseFloat: Float = 2.0
var resultFloat = baseFloat ** exponent
let baseCG: CGFloat = 2.0
var resultCG = baseCG ** exponent

infix operator **=
func **=<T: FloatingPoint>(lhs: inout T, rhs: Int){
    lhs = lhs**rhs
}

resultDouble **= exponent
resultFloat **= exponent
resultCG **= exponent


// Chapter 20 - Result Builders

// Challenge 1

