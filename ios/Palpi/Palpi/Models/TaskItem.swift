import Foundation

struct TaskItem: Identifiable, Codable, Equatable {
    var id: UUID
    var title: String
    var isDone: Bool
    var createdAt: Date
}
