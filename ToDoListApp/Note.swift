struct Note: Identifiable, Equatable {
    let id: Int64
    var title: String
    var content: String?
    var date: String
    var isDone: Bool
}
