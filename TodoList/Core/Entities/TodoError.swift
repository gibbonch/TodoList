import Foundation

enum TodoError: Error {
    case initialLoadingFailure
    case fetchingFailure
    case editingFailure
    case deletingFailure
    case creatingFailure
}
