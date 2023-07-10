// Chapter 26 - Property Wrappers

// Challenge 1

private class StorageBox<StoredValue> {
    
    var value: StoredValue
    
    init(_ value: StoredValue) {
        self.value = value
    }
}

@propertyWrapper
struct CopyOnWrite<Value> {
    
    private var storage: StorageBox<Value>
    
    init (wrappedValue: Value) {
        storage = StorageBox(wrappedValue)
    }
    
    var wrappedValue: Value {
        get {
            storage.value
        }
        set {
            if isKnownUniquelyReferenced(&storage) {
                storage.value = newValue
            } else {
                storage = StorageBox(newValue)
            }
        }
    }
}

struct Foo {
    @CopyOnWrite var x = 5
}

var f = Foo()
var g = f
print(f.x) // => 5
print(g.x) // => 5
f.x = 6
print(f.x) // => 6
print(g.x) // => 5
g.x = 10
print(f.x) // => 6
print(g.x) // => 10

// Challenge 2

protocol DeepCopyable {
    /* Returns a _deep copy_ of the current instance.
     
     If `x` is a deep copy of `y`, then:
     - the instance `x` should have the same value as `y` (for some sensible definition of value -- _not_ just memory location or pointer equality!)
     - it should be impossible to do any operation on `x` that will modify the value of the instance `y`.
     
     Note: a value semantic type implementing this protocol can just return `self` since that fulfills the above requirement.
     */
    func deepCopy() -> Self
}

@propertyWrapper
struct ValueSemantic<T: DeepCopyable>{
    
    private var storage: StorageBox<T>
    
    init (wrappedValue: T){
        storage = StorageBox(wrappedValue)
    }
    
    var wrappedValue: T {
        // get could be getting the reference in order to call a mutating method on a reference type,
        // so we need to be defensive and treat this as a mutation of the value of the instance
        mutating get {
            print("GET")
            if isKnownUniquelyReferenced(&storage) {
                print("   getting the one instance in the uniquely held box")
                return storage.value
            } else {
                // this get might be readonly access to the boxed instance, but it might be
                // to call a method that mutates the boxed instance
                // we cannot know, so if we're sharing the box we need to stop doing so
                print("   getting, after deep copying to ensure we return an isolated instance")
                storage = StorageBox(storage.value.deepCopy())
                return storage.value
            }
        }
        set {
            print("SET")
            if isKnownUniquelyReferenced(&storage) {
                print("   setting by mutating boxed value")
                storage.value = newValue
            } else {
                print("   setting by deep copying the value into a new box")
                storage = StorageBox(newValue.deepCopy())
            }
        }
    }
}

import Foundation

extension NSMutableString: DeepCopyable {
    
    func deepCopy() -> Self {
        self.mutableCopy() as! Self
    }
}

do {
    struct Foo {
        @ValueSemantic var x = NSMutableString(string: "hello")
    }
    
    print("valuesemantics")
    var f = Foo()
    var g = f
    print(f.x) // => "hello"
    print(g.x) // => "hello"
    // mutate the value of f by mutating the reference x
    f.x = NSMutableString(string: "world")
    print(f.x) // => "world"
    print(g.x) // => "hello" // good, no side-effects
    
    var a = Foo()
    var b = a
    print(a.x) // => "hello"
    print(b.x) // => "hello"
    // mutate the value of a by mutating the instance pointed to by the reference x
    a.x.append(" world")
    print(a.x) // => "hello world"
    print(b.x) // => "hello" // good, no side-effects
}

// Chapter 27 - Protocol-Oriented Programming

// Challenge 1

protocol Item: CustomStringConvertible {
    var name: String { get }
    var clearance: Bool { get }
    var msrp: Double { get } // Manufacturer's Suggested Retail Price
    var totalPrice: Double { get }
}

protocol Taxable: Item {
    var taxPercentage: Double { get }
}

protocol Discountable: Item {
    var adjustedMsrp: Double { get }
}

extension Item {
    var description: String {
        name
    }
}

extension Item {
    var totalPrice: Double {
        msrp
    }
}

extension Item where Self: Taxable {
    var totalPrice: Double {
        msrp * (1 + taxPercentage)
    }
}

extension Item where Self: Discountable {
    var totalPrice: Double {
        adjustedMsrp
    }
}

extension Item where Self: Taxable & Discountable {
    var totalPrice: Double {
        adjustedMsrp * (1 + taxPercentage)
    }
}

struct Clothing: Discountable {
    let name: String
    var msrp: Double
    var clearance: Bool
    
    var adjustedMsrp: Double {
        msrp * (clearance ? 0.75 : 1.0)
    }
}

struct Electronics: Taxable, Discountable {
    let name: String
    var msrp: Double
    var clearance: Bool
    
    let taxPercentage = 0.075
    
    var adjustedMsrp: Double {
        msrp * (clearance ? 0.95 : 1.0)
    }
}

struct Food: Taxable {
    let name: String
    var msrp: Double
    var clearance: Bool
    let expirationDate: (month: Int, year: Int)
    
    let taxPercentage = 0.075
    
    var adjustedMsrp: Double {
        msrp * (clearance ? 0.50 : 1.0)
    }
    
    var description: String {
        "\(name) - expires \(expirationDate.month)/\(expirationDate.year)"
    }
}

Food(name: "Bread", msrp: 2.99, clearance: false, expirationDate: (11, 2016)).totalPrice
Clothing(name: "Shirt", msrp: 12.99, clearance: true).totalPrice
Clothing(name: "Last season shirt", msrp: 12.99, clearance: false).totalPrice
Electronics(name: "Apple TV", msrp: 139.99, clearance: false).totalPrice
Electronics(name: "Apple TV 3rd gen", msrp: 99.99, clearance: true).totalPrice

// Custom string convertible demonstration
Food(name: "Bread", msrp: 2.99, clearance: false, expirationDate: (11, 2016))
Electronics(name: "Apple TV 3rd gen", msrp: 99.99, clearance: true)


// Challenge 2

extension Sequence where Element: Numeric {
    func double() -> [Element] {
        return map {$0 * 2}
    }
}

var seq = [2, 3, 5]
seq.map { print($0) }
seq


// Chapter 28 - Advanced Protocols & Generics

// Challenge 1–3

protocol Toy {
    static var pieces: Int {get}
    var price: Double {get}
    init()
}

protocol VehicleToy: Toy {}


protocol BuilderRobot {
    associatedtype ToyType: Toy
    
    var piecesPerMinute: Int {get}
    
    func build(forMinutes minutes: Int) -> [ToyType]
    
    func build(numberOfToys: Int) -> (toys: [ToyType], time: Int)
}

extension BuilderRobot {
    func build(numberOfToys: Int) -> (toys: [ToyType], time: Int) {
        
        let totalTime: Int = numberOfToys * ToyType.pieces / piecesPerMinute
        
        var toysBuilt: [ToyType] = []
        
        for _ in 0..<numberOfToys {
            toysBuilt.append(ToyType())
        }
        
        return (toysBuilt, totalTime)
    }
    
    func build(forMinutes minutes: Int) -> [ToyType] {
        let totalToysBuilt = minutes * ToyType.pieces / piecesPerMinute
        
        return build(numberOfToys: totalToysBuilt).toys
    }
}

protocol VehicleBuilderRobot: BuilderRobot where ToyType: VehicleToy {}

struct TrainToy: VehicleToy {
    static var pieces = 75
    var price = 10.0
}

struct TrainRobot: VehicleBuilderRobot {
    typealias ToyType = TrainToy
    var piecesPerMinute = 50
}

func makeToyBuilder() -> some BuilderRobot {
    MonsterTruckRobot()
}

let trobot = makeToyBuilder()

trobot.build(numberOfToys: 20).toys.count
trobot.build(forMinutes: 10).count

struct MonsterTruckRobot: VehicleBuilderRobot {
    typealias ToyType = MonsterTruckToy
    var piecesPerMinute: Int = 20
}

struct MonsterTruckToy: VehicleToy {
    static var pieces: Int = 120
    var price: Double = 5.0
}


// Chapter 29 - Concrrency

// Challenge 1–2

import SwiftUI

actor Team {
    let name: String
    let stadium: String
    private var players: [String]
    
    init(name: String, stadium: String, players: [String]) {
        self.name = name
        self.stadium = stadium
        self.players = players
    }
    
    private func add(player: String) {
        players.append(player)
    }
    
    private func remove(player: String) {
        guard !players.isEmpty, let index = players.firstIndex(of: player) else {return}
        players.remove(at: index)
    }
    
    func buy(player: String, from team: Team) async {
        await team.remove(player: player)
        add(player: player)
    }
    
    func sell(player: String, to team: Team) async {
        await team.add(player: player)
        remove(player: player)
    }
}

let madridTeam = Team(name: "Real Madrid", stadium: "Santiago Bernabeu", players: ["Lionel Messi"])
let barcelonaTeam = Team(name: "FC Barcelona" , stadium: "Camp Nou", players: ["Cristiano Ronaldo"])

Task {
    await madridTeam.buy(player: "Cristiano Ronaldo", from: barcelonaTeam)
    await madridTeam.sell(player: "Lionel Messi", to: barcelonaTeam)
    print(madridTeam)
}

extension Team: CustomStringConvertible {
    nonisolated var description: String {
        "\(name) based at \(stadium) stadium"
    }
}

// Challenge 3

final class BasicTeam: Sendable {
  let name: String
  let stadium: String

  init(name: String, stadium: String) {
    self.name = name
    self.stadium = stadium
  }
}

