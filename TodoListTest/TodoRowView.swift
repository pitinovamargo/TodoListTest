//
//  TodoRowView.swift
//  TodoListTest
//

import SwiftUI

struct TodoRowView: View {
    let todo: Todo
    var onToggle: () -> Void = {}
    var onDelete: () -> Void = {}

    private static let dateFormatter: DateFormatter = {
        let formatter = DateFormatter()
        formatter.dateFormat = "dd/MM/yy"
        return formatter
    }()

    var body: some View {
        HStack(alignment: .top, spacing: 8) {
            Button {
                onToggle()
            } label: {
                Image(systemName: todo.isCompleted ? "checkmark.circle" : "circle")
                    .font(.system(size: 24, weight: .light))
                    .frame(width: 28, height: 28)
                    .foregroundStyle(todo.isCompleted ? Color("AppYellow") : Color("AppStroke"))
                    .contentShape(Rectangle())
            }
            .buttonStyle(.plain)

            VStack(alignment: .leading, spacing: 6) {
                Text(todo.title)
                    .font(.system(size: 17, weight: .medium))
                    .tracking(-0.43)
                    .strikethrough(todo.isCompleted, color: Color("AppGray"))
                    .foregroundStyle(todo.isCompleted ? Color("AppGray") : Color("AppWhite"))

                if !todo.details.isEmpty {
                    Text(todo.details)
                        .font(.system(size: 13, weight: .regular))
                        .lineSpacing(6)
                        .foregroundStyle(todo.isCompleted ? Color("AppGray") : Color("AppWhite"))
                        .lineLimit(2)
                }

                Text(Self.dateFormatter.string(from: todo.createdAt))
                    .font(.system(size: 13, weight: .regular))
                    .foregroundStyle(Color("AppGray"))
            }
        }
        .padding(.horizontal, 20)
        .padding(.vertical, 12)
        .frame(maxWidth: .infinity, alignment: .leading)
        .contextMenu {
            Button {
                // редактирование — позже
            } label: {
                Label("Редактировать", systemImage: "square.and.pencil")
            }

            Button {
                // поделиться — позже
            } label: {
                Label("Поделиться", systemImage: "square.and.arrow.up")
            }

            Button(role: .destructive) {
                onDelete()
            } label: {
                Label("Удалить", systemImage: "trash")
            }
        } preview: {
            contextPreview
        }
    }

    private var contextPreview: some View {
        VStack(alignment: .leading, spacing: 6) {
            Text(todo.title)
                .font(.system(size: 17, weight: .medium))
                .tracking(-0.43)
                .foregroundStyle(Color("AppWhite"))

            if !todo.details.isEmpty {
                Text(todo.details)
                    .font(.system(size: 13, weight: .regular))
                    .lineSpacing(4)
                    .foregroundStyle(Color("AppWhite"))
            }

            Text(Self.dateFormatter.string(from: todo.createdAt))
                .font(.system(size: 13, weight: .regular))
                .foregroundStyle(Color("AppGray"))
                .padding(.top, 6)
        }
        .padding()
        .frame(width: UIScreen.main.bounds.width - 40, alignment: .leading)
        .background(Color("AppSearchBackground"))
    }
}

#Preview("Активная") {
    TodoRowView(todo: Todo.sampleData[0])
        .background(Color("AppBackground"))
        .preferredColorScheme(.dark)
}

#Preview("Выполненная") {
    TodoRowView(todo: Todo.sampleData[1])
        .background(Color("AppBackground"))
        .preferredColorScheme(.dark)
}

#Preview("Без описания") {
    TodoRowView(todo: Todo.sampleData[4])
        .background(Color("AppBackground"))
        .preferredColorScheme(.dark)
}
