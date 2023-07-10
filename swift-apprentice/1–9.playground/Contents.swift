/*
let array1 = [Int]()
let array3: [String] = []

let array4 = [1, 2, 3]
array4[1...2]

var array5 = [1, 2, 3, 2, 9, 7, 9]
array5[0] = array5[1]
array5[0...1] = [4, 5]

func removingOnce(_ item: Int, from array: [Int]) -> [Int] {
    var result = array
    if let index = array.firstIndex(of: item) {
        result.remove(at: index)
    }
    return result
}

removingOnce(4, from: array5)

func removing(_ item: Int, from array: [Int]) -> [Int] {
    var result: [Int] = []
    for element in array where element != item {
        result.append(element)
    }
    return result
}

removing(9, from: array5)


func reversed(_ array: [Int]) -> [Int] {
    var result: [Int] = []
    for item in array {
        result.insert(item, at: 0)
    }
    return result
}

reversed(array5)


func middle(_ array: [Int]) -> Int? {
    if array.isEmpty {
        return nil
    }
    return array[(array.count-1)/2]
}

let cum: [Int] = [1, 2, 3, 4]

middle(cum)

func minMax(of numbers: [Int]) -> (min: Int, max: Int)? {
    if numbers.isEmpty {
        return nil
    }
    
    var min = numbers[0]
    var max = numbers[0]
    
    for number in numbers {
        if number < min { min = number }
        if number > max { max = number }
    }
    
    return (min, max)
}

minMax(of: array5)

// Dictionaries

var dict1 = ["NY": "New York", "CA": "California"]
var dict2 = ["WA": "Washington", "FL": "Florida"]

func printLongNames(for dict: [String: String]) -> Void {
    for name in dict.values where name.count > 8{
        print(name)
    }
}

printLongNames(for: dict1)

func combine(dict1: [String: String], with dict2: [String: String]) -> [String: String] {
    var result = dict1
    for (key, value) in dict2 {
      result[key] = value
    }
    return result
}

combine(dict1: dict1, with: dict2)

func occurrencesOfCharacters(in text: String) -> [Character: Int] {
    var occurences: [Character: Int] = [:]
    for char in text {
        occurences[char, default: 0] += 1
    }
    return occurences
}

occurrencesOfCharacters(in: "Cum inside me sempai uwu ^^")

func isInvertible(_ dictionary: [String:Int]) -> Bool {
    var valueSet: Set<Int> = []
    for value in dictionary.values {
        if !valueSet.insert(value).inserted {
            return false
        }
    }
    return true
}

let uniques = ["One": 1, "Two": 2, "Uno": 1]

isInvertible(uniques)
 
 
 

// CLOSURES --

// Challenge 1

func repeatTask(times: Int, task: () -> Void) {
    for _ in 0..<times {
        task()
    }
}

//repeatTask(times: 2) { print("Cum") }

// Challenge 2

func mathSum(length: Int, series: (Int) -> Int) -> Int {
    return (1...length).map { series($0) }.reduce(0, +)
}

print(mathSum(length: 10) { $0 * $0 })

func fibonacci(for number: Int) -> Int {
    if number == 1 || number == 2 { return 1 }
    return fibonacci(for: number - 1) + fibonacci(for: number - 2)
}

print(mathSum(length: 10) {
    fibonacci(for: $0)
})

// Challenge 3

let appRatings = [
  "Calendar Pro": [1, 5, 5, 4, 2, 1, 5, 4],
  "The Messenger": [5, 4, 2, 5, 4, 1, 1, 2],
  "Socialise": [2, 1, 2, 2, 1, 2, 4, 2]
 ]

var averageRatings: [String: Double] = [:]

appRatings.forEach {(key: String, ratings: [Int]) in
    let total = ratings.reduce(0, +)
    let average = Double(total) / Double(ratings.count)
    averageRatings[key] = average
}

averageRatings

averageRatings.filter {
    $0.value > 3
}.map {
    $0.key
}

*/


// STRINGS --

// Challenge 1

var input = "cumming inside cumburger"

let counts = input.reduce(into: [Character: Int]()) { $0[$1, default: 0] += 1}

counts

func buildHistogram(for data: [Character: Int]) {
    let sortedKeys = data.keys.sorted { counts[$0]! > counts[$1]! }

    let max = data[sortedKeys.first!]!
    
    for key in sortedKeys {
      let value = counts[key]!
      let widthOfHashes = (value * 20) / max
      let hashes = String(repeating: "#", count: widthOfHashes)
      print("\(key) : \(hashes) \(value)")
    }
}

buildHistogram(for: counts)

// Challenge 3

func sanitize(name: String) -> String? {
    guard let indexOfComma = name.firstIndex(of: ",") else { return nil }
    
    let lastName = name[..<indexOfComma]
    let firstName = name[indexOfComma...].dropFirst(2)
    
    return "\(firstName) \(lastName)"
}

let myName = "Shcherbakov, Alex"

sanitize(name: myName)

// Challenge 4

func split(string: String, by separator: Character) -> [String] {
    var current = string
    var components: [String] = []
    
    repeat {
        guard let separatorIndex = current.firstIndex(of: separator) else {
            components.append(current)
            break
        }
        components.append(String(current[..<separatorIndex]))
        current = String(current[separatorIndex...].dropFirst(1))
    } while !current.isEmpty
    
    return components
}

split(string: "Cum inside this bucket, coomer", by: "t")


// Challenge 5

func wordReverse(for string: String) -> String {
    var output = ""
    var lastWordIndex = string.startIndex
    
    for i in string.indices {
        if string[i] == " " {
            output += string[lastWordIndex..<i].reversed() + " "
            lastWordIndex = string.index(after: i)
        }
    }
    
    output += string[lastWordIndex...].reversed()
    
    return output
}

wordReverse(for: "Cum inside this bucket, coomer")
