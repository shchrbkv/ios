// Chapter 21 - Pattern Matching

import Foundation

// Challenge 1

enum FormField {
  case firstName(String)
  case lastName(String)
  case emailAddress(String)
  case age(Int)
}

let minimumAge = 21
let submittedAge = FormField.age(22)

if case .age(let years) = submittedAge, years > minimumAge {
  print("Welcome!")
} else {
  print("Sorry, you're too young!")
}

// Challenge 2

enum CelestialBody {
  case star
  case planet(liquidWater: Bool)
  case comet
}

let telescopeCensus = [
  CelestialBody.star,
  .planet(liquidWater: false),
  .planet(liquidWater: true),
  .planet(liquidWater: true),
  .comet
]

for case .planet(let waterStatus) in telescopeCensus where waterStatus {
    print("This planet has water!")
}


// Challenge 3

let queenAlbums = [
    ("A Night at the Opera", 1974),
    ("Sheer Heart Attack", 1974),
    ("Jazz", 1978),
    ("The Game", 1980)
]

for case (let title, 1974) in queenAlbums {
    print("\(title) was released in 1974")
}


// Challenge 4

let coordinates = (lat: 37.334890, long: -122.009000)

switch coordinates {
case (let lat, _) where lat == 0:
    print("You're on equator")
case (let lat, _) where lat > 0:
    print("You're in Northern hemisphere")
case (let lat, _) where lat < 0:
    print("You're in Southern hemisphere")
default:
    break
}


// Chapter 22 - Error Handling

// Challenge 1

extension String: Error {}

func stringToEvenInt(_ string: String) throws -> Int {
    guard let int = Int(string) else { throw "Can't parse the string" }
    return int - int % 2
}

do {
    try stringToEvenInt("11")
    try stringToEvenInt("LOL")
} catch {
    print(error)
}

// Chapter 23 - Encoding & Decoding Types

// Challenge 1–4

struct Spaceship: Encodable {
    var name: String
    var crew: [CrewMember]
    
    enum CodingKeys: String, CodingKey {
        case name = "spaceship_name"
        case crew
    }
}

struct CrewMember: Codable {
    var name: String
    var race: String
}

let encoder = JSONEncoder()
let decoder = JSONDecoder()

let s = Spaceship(name: "Enterprise", crew: [
    CrewMember(name: "Spock", race: "Vulkan")
])

let encodedSpaceship = try encoder.encode(s)

String(data: encodedSpaceship, encoding: .utf8)

extension Spaceship: Decodable {
    enum CrewKeys: String, CodingKey {
        case captain
        case officer
    }
    init(from decoder: Decoder) throws {
        let values = try decoder.container(keyedBy: CodingKeys.self)
        name = try values.decode(String.self, forKey: .name)
        
        let crewValues = try decoder.container(keyedBy: CrewKeys.self)
        let captain = try crewValues.decodeIfPresent(CrewMember.self, forKey: .captain)
        let officer = try crewValues.decodeIfPresent(CrewMember.self, forKey: .officer)
        
        crew = [captain, officer].compactMap() { $0 }
    }
}

let incoming = "{\"spaceship_name\": \"USS Enterprise\", \"captain\":{\"name\":\"Spock\", \"race\":\"Human\"}, \"officer\":{\"name\": \"Worf\", \"race\":\"Klingon\"}}"

let newSpaceship = try decoder.decode(Spaceship.self, from: incoming.data(using: .utf8)!)

print(newSpaceship)

var klingonSpaceship = Spaceship(name: "IKS NEGH'VAR", crew: [])
let klingonMessage = try PropertyListEncoder().encode(klingonSpaceship)

let extractedMessage = try PropertyListDecoder().decode(Spaceship.self, from: klingonMessage)

print(extractedMessage)

// Challenge 5

enum Item {
  case message(String)
  case numbers([Int])
  case mixed(String, [Int])
  case person(name: String)
}

let items: [Item] = [.message("Hi"),
                     .mixed("Numbers", [1,2]),
                     .person(name: "Kirk"),
                     .message("Bye")]

extension Item: Codable {}

let data = try JSONEncoder().encode(items)
print("\nEncoded Items:")
print(String(data: data, encoding: .utf8)!)


// Chapter 24 - Memory Management

// Challenge 1

class Person {
  let name: String
  let email: String
  weak var car: Car? // Moved to weak ref
  init(name: String, email: String) {
    self.name = name
    self.email = email
  }
  deinit {
    print("Goodbye \(name)!")
  }
}

class Car {
  let id: Int
  let type: String
    var owner: Person?
  init(id: Int, type: String) {
    self.id = id
    self.type = type
  }
  deinit {
    print("Goodbye \(type)!")
  }
}
var owner: Person? = Person(name: "Cosmin", email: "cosmin@whatever.com")
var car: Car? = Car(id: 10, type: "BMW")
owner?.car = car
car?.owner = owner
owner = nil
car = nil

// Challenge 2

class Customer {
  let name: String
  let email: String
  var account: Account?

  init(name: String, email: String) {
    self.name = name
    self.email = email
  }

  deinit {
    print("Goodbye \(name)!")
  }
}

class Account {
  let number: Int
  let type: String
  unowned let customer: Customer

  init(number: Int, type: String, customer: Customer) {
    self.number = number
    self.type = type
    self.customer = customer
  }

  deinit {
    print("Goodbye \(type) account number \(number)!")
  }
}

var customer: Customer? = Customer(name: "George", email: "george@whatever.com")
var account: Account? = Account(number: 10, type: "PayPal", customer: customer!)

customer?.account = account

account = nil
customer = nil


// Chapter 25 - Value Types & Reference Types

// Challenge 1

private class Pixels {
    let storageBuffer: UnsafeMutableBufferPointer<UInt8>
    
    init(size: Int, value: UInt8) {
        let p = UnsafeMutablePointer<UInt8>.allocate(capacity: size)
        storageBuffer = UnsafeMutableBufferPointer<UInt8>(start: p, count: size)
        storageBuffer.initialize(from: repeatElement(value, count: size))
    }
    
    init(pixels: Pixels) {
        let otherStorage = pixels.storageBuffer
        let p  = UnsafeMutablePointer<UInt8>.allocate(capacity: otherStorage.count)
        storageBuffer = UnsafeMutableBufferPointer<UInt8>(start: p, count: otherStorage.count)
        storageBuffer.initialize(from: otherStorage)
    }
    
    subscript(offset: Int) -> UInt8 {
        get {
            storageBuffer[offset]
        }
        set {
            storageBuffer[offset] = newValue
        }
    }
    
    deinit {
        storageBuffer.baseAddress!.deallocate()
    }
}

struct Image {
    private(set) var width: Int
    private(set) var height: Int
    private var pixels: Pixels
    private var mutatingPixels: Pixels {
        mutating get {
            if !isKnownUniquelyReferenced(&pixels) {
                pixels = Pixels(pixels: pixels)
            }
            return pixels
        }
    }
    
    init(width: Int, height: Int, value: UInt8) {
      self.width = width
      self.height = height
      self.pixels = Pixels(size: width * height, value: value)
    }
    
    subscript(x: Int, y: Int) -> UInt8 {
      get {
        return pixels[y * width + x]
      }
      set {
        mutatingPixels[y * width + x] = newValue
      }
    }
    
    mutating func clear(with value: UInt8) {
      for (i, _) in mutatingPixels.storageBuffer.enumerated() {
        mutatingPixels.storageBuffer[i] = value
      }
    }
  }

  var image1 = Image(width: 4, height: 4, value: 0)

  // test setting and getting
  image1[0,0] // -> 0
  image1[0,0] = 100
  image1[0,0] // -> 100
  image1[1,1] // -> 0

  // copy
  var image2 = image1
  image2[0,0] // -> 100
  image1[0,0] = 2
  image1[0,0] // -> 2
  image2[0,0] // -> 100 because of copy-on-write

  var image3 = image2
  image3.clear(with: 255)
  image3[0,0] // -> 255
  image2[0,0] // -> 100 thanks again, copy-on-write
