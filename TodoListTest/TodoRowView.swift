//
//  TodoRowView.swift
//  TodoListTest
//

import SwiftUI

struct TodoRowView: View {
    @Binding var todo: Todo

    private static let dateFormatter: DateFormatter = {
        let formatter = DateFormatter()
        formatter.dateFormat = "dd/MM/yy"
        return formatter
    }()

    var body: some View {
        HStack(alignment: .top, spacing: 8) {
            Button {
                withAnimation(.easeInOut(duration: 0.2)) {
                    todo.isCompleted.toggle()
                }
            } label: {
                Image(systemName: todo.isCompleted ? "checkmark.circle" : "circle")
                    .font(.system(size: 24, weight: .light))
                    .frame(width: 24, height: 24)
                    .foregroundStyle(todo.isCompleted ? Color("AppYellow") : Color("AppStroke"))
                    .contentShape(Rectangle())
            }
            .buttonStyle(.plain)

            VStack(alignment: .leading, spacing: 6) {
                Text(todo.title)
                    .font(.system(size: 16, weight: .medium))
                    .tracking(-0.43)
                    .strikethrough(todo.isCompleted, color: Color("AppGray"))
                    .foregroundStyle(todo.isCompleted ? Color("AppGray") : Color("AppWhite"))

                if !todo.details.isEmpty {
                    Text(todo.details)
                        .font(.system(size: 12, weight: .regular))
                        .lineSpacing(16 - 12)
                        .foregroundStyle(Color("AppGray"))
                        .lineLimit(2)
                }

                Text(Self.dateFormatter.string(from: todo.createdAt))
                    .font(.system(size: 12, weight: .regular))
                    .foregroundStyle(Color("AppGray"))
            }
        }
        .padding(.horizontal, 20)
        .padding(.vertical, 12)
        .frame(maxWidth: .infinity, alignment: .leading)
    }
}

#Preview("Активная") {
    TodoRowView(todo: .constant(Todo.sampleData[0]))
        .background(Color("AppBackground"))
        .preferredColorScheme(.dark)
}

#Preview("Выполненная") {
    TodoRowView(todo: .constant(Todo.sampleData[1]))
        .background(Color("AppBackground"))
        .preferredColorScheme(.dark)
}

#Preview("Без описания") {
    TodoRowView(todo: .constant(Todo.sampleData[4]))
        .background(Color("AppBackground"))
        .preferredColorScheme(.dark)
}
