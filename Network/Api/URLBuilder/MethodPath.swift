public enum MethodPath: Equatable {
    case todos(identifier: Int)

    public var path: String {
        switch self {

        case let .todos(identifier):
            return "todos/\(identifier)"
        }
    }
}
