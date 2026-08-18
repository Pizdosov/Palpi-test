import SwiftUI

enum TaskFilter: String, CaseIterable, Identifiable {
    case all = "Все"
    case active = "Активные"
    case done = "Готово"

    var id: String { rawValue }
}

struct TaskListView: View {
    @State private var store: TaskStore
    @State private var newTitle = ""
    @State private var filter: TaskFilter = .all

    init(store: TaskStore = TaskStore()) {
        _store = State(initialValue: store)
    }

    private var visibleTasks: [TaskItem] {
        switch filter {
        case .all:
            store.tasks
        case .active:
            store.tasks.filter { !$0.isDone }
        case .done:
            store.tasks.filter(\.isDone)
        }
    }

    var body: some View {
        NavigationStack {
            Group {
                if store.tasks.isEmpty {
                    emptyState
                } else if visibleTasks.isEmpty {
                    ContentUnavailableView(
                        "Здесь пусто",
                        systemImage: "line.3.horizontal.decrease.circle",
                        description: Text("В этом фильтре пока нет задач.")
                    )
                } else {
                    taskList
                }
            }
            .navigationTitle("Задачи")
            .toolbar {
                ToolbarItem(placement: .principal) {
                    Picker("Фильтр", selection: $filter) {
                        ForEach(TaskFilter.allCases) { item in
                            Text(item.rawValue).tag(item)
                        }
                    }
                    .pickerStyle(.segmented)
                    .frame(maxWidth: 280)
                }
            }
            .safeAreaInset(edge: .bottom) {
                addBar
            }
        }
    }

    private var taskList: some View {
        List {
            Section {
                ForEach(visibleTasks) { task in
                    TaskRowView(task: task) {
                        withAnimation(.snappy) {
                            store.toggle(task)
                        }
                    }
                    .swipeActions(edge: .trailing, allowsFullSwipe: true) {
                        Button(role: .destructive) {
                            withAnimation(.snappy) {
                                store.delete(task)
                            }
                        } label: {
                            Label("Удалить", systemImage: "trash")
                        }
                    }
                }
            } footer: {
                Text(remainingText)
            }
        }
        .listStyle(.insetGrouped)
    }

    private var emptyState: some View {
        ContentUnavailableView(
            "Список пуст",
            systemImage: "checkmark.circle",
            description: Text("Напишите задачу внизу — например, «Купить молоко».")
        )
    }

    private var addBar: some View {
        VStack(spacing: 8) {
            HStack(spacing: 10) {
                TextField("Новая задача", text: $newTitle)
                    .textFieldStyle(.plain)
                    .submitLabel(.done)
                    .onSubmit(addTask)
                    .padding(12)
                    .background(.ultraThinMaterial, in: RoundedRectangle(cornerRadius: 14, style: .continuous))

                Button(action: addTask) {
                    Image(systemName: "arrow.up.circle.fill")
                        .font(.system(size: 34))
                        .symbolRenderingMode(.hierarchical)
                }
                .disabled(newTitle.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty)
                .accessibilityLabel("Добавить задачу")
            }
        }
        .padding(.horizontal, 16)
        .padding(.top, 8)
        .padding(.bottom, 10)
        .background(.bar)
    }

    private var remainingText: String {
        let count = store.remainingCount
        switch count {
        case 0:
            return "Все задачи выполнены"
        case 1:
            return "Осталась 1 задача"
        case 2...4:
            return "Осталось \(count) задачи"
        default:
            return "Осталось \(count) задач"
        }
    }

    private func addTask() {
        guard store.add(newTitle) != nil else { return }
        newTitle = ""
        filter = .all
    }
}

#Preview {
    TaskListView()
}
