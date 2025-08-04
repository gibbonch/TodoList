import Foundation

enum TodoCellType {
    case placeholder(String = UUID().uuidString)
    case `default`(TodoCellModel)
}

extension TodoCellType: Hashable {
    
    static func == (lhs: TodoCellType, rhs: TodoCellType) -> Bool {
        switch (lhs, rhs) {
        case (.placeholder(let lhsId), .placeholder(let rhsId)):
            return lhsId == rhsId
        case (.default(let lhsModel), .default(let rhsModel)):
            return lhsModel == rhsModel
        default:
            return false
        }
    }
    
    func hash(into hasher: inout Hasher) {
        switch self {
        case .placeholder(let id):
            hasher.combine(id)
        case .default(let model):
            hasher.combine(model)
        }
    }
}
