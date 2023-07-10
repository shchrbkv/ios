// Chapter 10 - Structs

// Challenge 1

enum FruitKind {
    case apple
    case orange
    case pear
}

struct Fruit {
    let kind: FruitKind
    let weight: Int
}

let truck = [Fruit(kind: .apple, weight: 78),
             Fruit(kind: .pear, weight: 54),
             Fruit(kind: .orange, weight: 103),
             Fruit(kind: .apple, weight: 98)]

struct SortingFacility {
    var inventory: [FruitKind:[Fruit]] = [:]
    var totalWeight: [FruitKind:Int] = [:]
    
    mutating func supply(_ fruits: [Fruit]) {
        for fruit in fruits {
            inventory[fruit.kind, default: []].append(fruit)
            totalWeight[fruit.kind, default: 0] += fruit.weight
        }
    }
    
    func inventoryCount() -> [FruitKind:Int] {
        inventory.mapValues { $0.count }
    }
}

var sf = SortingFacility()

sf.supply(truck)

sf.totalWeight
sf.inventoryCount()


// Chapter 11 - Properties

// Challenge 1

struct IceCream {
    var name: String = "Vanilla"
    lazy var ingredients: [String] = {
        ["Cream", "Butter", "Vanilla Extract"]
    }()
    
    init(name: String) {
        self.name = name
    }
}

var ic = IceCream(name: "Cum")

ic.name
ic.ingredients


// Challenge 2

struct FuelTank {
    var lowFuel: Bool = false
    var level: Double {
        didSet {
            level = min(max(level, 0), 1)
            lowFuel = level < 0.1
        }
    }
}

struct Car {
  let make: String
  let color: String
  var tank: FuelTank
}

var car = Car(make: "DeLorean", color: "Silver", tank: FuelTank(lowFuel: false, level: 1))

car.tank.level = -1 // level: 0, lowFuel: true
car.tank.level = 1.1 // level: 1, lowFuel: false
car.tank.level = 0.6 // level: 0.6, lowFuel: false


// Chapter 12 - Methods

// Challenge 1

struct Circle {
    
    var radius = 0.0
    
    var area: Double {
        get {
            .pi * radius * radius
        }
        set {
            radius = (newValue / .pi).squareRoot()
        }
    }
    
    mutating func grow(byFactor factor: Double) {
        area *= factor
    }
}

var circ = Circle(radius: 2)

circ.area

circ.grow(byFactor: 2)

circ.radius
circ.area


// Challenge 3

struct Math {}

extension Math {
    static func isEven(_ number: Int) -> Bool {
        number % 2 == 0
    }
    static func isOdd(_ number: Int) -> Bool {
        number % 2 == 1
    }
}

Math.isEven(5)
Math.isOdd(5)


// Challenge 4

extension Int {
    var isEven: Bool {
        self % 2 == 0
    }
    var isOdd: Bool {
        self % 2 == 1
    }
}

var even = 4
even.isOdd


// Challenge 5

extension Int {
    func primeFactors() -> [Int] {
        var remaining = self
        var factor = 2
        
        var factors: [Int] = []
        
        while factor * factor <= remaining {
            if remaining % factor == 0 {
                factors.append(factor)
                remaining /= factor
            }
            else {
                factor += 1
            }
        }
        if remaining > 1 {
            factors.append(remaining)
        }
        
        return factors
    }
}

151.primeFactors()
144.primeFactors()



// Chapter 13 - Classes

// Challenge 1

class List {
    var name: String = "My List"
    var movies: [String] = []
    
    init(name: String, movies: [String]) {
        self.name = name
        self.movies = movies
    }
    
    func print() {
        Swift.print(movies, separator: " ")
    }
}

class User {
    var lists: [String:List] = [:]
    
    func addList(_ list: List) {
        lists[list.name] = list
    }
    
    func list(forName name: String) -> List? {
        lists[name]
    }
}


let actionList = List(name: "Action", movies: ["Mission Impossible", "Cum Wars II"])

let comedyList = List(name: "Comedy", movies: ["Scrotie McBoogieballs"])

let john = User()
let jane = User()

john.addList(actionList)
john.addList(comedyList)

jane.addList(comedyList)

john.list(forName: "Action")?.print()
jane.list(forName: "Comedy")?.print()


// Chapter 14 - Advanced Classes

// Challenge 1

class A {
    init() {
        print("I'm A")
    }
    deinit {
      print("Destroy A")
    }
}

class B: A {
    override init() {
        print("I'm B")
        super.init()
        print("I'm B")
    }
    deinit {
      print("Destroy B")
    }
}

class C: B {
    override init() {
        print("I'm C")
        super.init()
        print("I'm C")
    }
    deinit {
      print("Destroy C")
    }
}

do {
    let c = C()
    c as A
}


// Chapter 15 - Enumerations

// Challenge 1

enum Coin: Int {
    case penny = 1
    case nickel = 5
    case dime = 10
    case quarter = 25
}

let coinPurse: [Coin] = [.penny, .quarter, .nickel, .dime, .penny, .dime, .quarter]

func countCentsIn(purse: [Coin]) -> Int {
    purse.reduce(0) {
        $0 + $1.rawValue
    }
}

countCentsIn(purse: coinPurse)


// Challenge 2

enum Month: Int {
    case january = 1, february, march, april, may, june, july,
         august, september, october, november, december
    
    var monthsTillSummer: Int {
        (18 - rawValue) % 12
    }
}

var mon: Month = .march

mon.monthsTillSummer


// Challenge 3

enum Direction {
    case north
    case south
    case east
    case west
}

let movements: [Direction] = [.north, .north, .west, .south, .west, .south, .south, .east, .east, .south, .east]

var location = (x: 0, y: 0)

for movement in movements {
    switch movement {
    case .north:
      location.y += 1
    case .south:
      location.y -= 1
    case .east:
      location.x += 1
    case .west:
      location.x -= 1
    }
}

location
