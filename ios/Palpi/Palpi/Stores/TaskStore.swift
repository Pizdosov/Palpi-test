import Foundation
import Observation

@Observable
final class TaskStore {
    private let defaults: UserDefaults
    private let storageKey = "palpi.tasks"

    private(set) var tasks: [TaskItem] = []

    var remainingCount: Int {
        tasks.filter { !$0.isDone }.count
    }

    init(defaults: UserDefaults = .standard) {
        self.defaults = defaults
        load()
    }

    @discardableResult
    func add(_ title: String) -> TaskItem? {
        let trimmed = title.trimmingCharacters(in: .whitespacesAndNewlines)
        guard !trimmed.isEmpty else { return nil }

        let task = TaskItem(
            id: UUID(),
            title: trimmed,
            isDone: false,
            createdAt: .now
        )
        tasks.insert(task, at: 0)
        save()
        return task
    }

    func toggle(_ task: TaskItem) {
        guard let index = tasks.firstIndex(of: task) else { return }
        tasks[index].isDone.toggle()
        save()
    }

    func delete(_ task: TaskItem) {
        tasks.removeAll { $0.id == task.id }
        save()
    }

    private func save() {
        guard let data = try? JSONEncoder().encode(tasks) else { return }
        defaults.set(data, forKey: storageKey)
    }

    private func load() {
        guard
            let data = defaults.data(forKey: storageKey),
            let decoded = try? JSONDecoder().decode([TaskItem].self, from: data)
        else {
            tasks = []
            return
        }
        tasks = decoded
    }
}
