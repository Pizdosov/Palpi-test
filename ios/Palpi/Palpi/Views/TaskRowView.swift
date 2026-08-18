import SwiftUI

struct TaskRowView: View {
    let task: TaskItem
    let onToggle: () -> Void

    var body: some View {
        Button(action: onToggle) {
            HStack(spacing: 12) {
                Image(systemName: task.isDone ? "checkmark.circle.fill" : "circle")
                    .font(.title2)
                    .symbolRenderingMode(.hierarchical)
                    .foregroundStyle(task.isDone ? Color.accentColor : Color.secondary)

                Text(task.title)
                    .foregroundStyle(task.isDone ? .secondary : .primary)
                    .strikethrough(task.isDone, color: .secondary)
                    .frame(maxWidth: .infinity, alignment: .leading)
            }
            .padding(.vertical, 4)
            .contentShape(Rectangle())
        }
        .buttonStyle(.plain)
        .accessibilityLabel(task.title)
        .accessibilityValue(task.isDone ? "Выполнено" : "Не выполнено")
        .accessibilityHint("Нажмите, чтобы переключить статус")
    }
}

#Preview {
    List {
        TaskRowView(
            task: TaskItem(id: UUID(), title: "Купить молоко", isDone: false, createdAt: .now),
            onToggle: {}
        )
        TaskRowView(
            task: TaskItem(id: UUID(), title: "Позвонить маме", isDone: true, createdAt: .now),
            onToggle: {}
        )
    }
}
