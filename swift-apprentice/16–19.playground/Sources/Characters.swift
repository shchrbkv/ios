public enum GameCharacterType {
    case elf, giant, wizard
}

public protocol GameCharacter: AnyObject {
    var name: String { get set }
    var hitPoints: Int { get set }
    var attackPoints: Int { get set }
}

class Elf: GameCharacter {
    var name = "Elf"
    var hitPoints = 5
    var attackPoints = 15
}

class Giant: GameCharacter {
    var name = "Giant"
    var hitPoints = 20
    var attackPoints = 5
}

class Wizard: GameCharacter {
    var name  = "Wizard"
    var hitPoints = 10
    var attackPoints = 10
}

public struct GameCharacterFactory {
    public static func make(ofType type: GameCharacterType) -> GameCharacter{
        switch type {
        case .elf:
            return Elf()
        case .giant:
            return Giant()
        case .wizard:
            return Wizard()
        }
    }
}

public func battle(_ first: GameCharacter, vs second: GameCharacter) {
    second.hitPoints -= first.attackPoints
    if second.hitPoints <= 0 {
        print("\(second.name) was defeated")
        return
    }
    
    first.hitPoints -= second.attackPoints
    if first.hitPoints <= 0 {
        print("\(first.name) was defeated")
        return
    }
    
    print("Both players still active")
    return
}
