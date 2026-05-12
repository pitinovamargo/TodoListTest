//
//  TodoEditView.swift
//  TodoListTest
//

import SwiftUI

struct TodoEditView: View {
    let onSave: (Todo) -> Void

    @StateObject private var viewModel: TodoEditViewModel
    @Environment(\.dismiss) private var dismiss
    @FocusState private var focusedField: Field?

    private enum Field {
        case title, details
    }

    init(todo: Todo, onSave: @escaping (Todo) -> Void) {
        self.onSave = onSave
        _viewModel = StateObject(wrappedValue: TodoEditViewModel(todo: todo))
    }

    var body: some View {
        VStack(alignment: .leading) {
            backButton
                .padding(.bottom)

            TextField("Заголовок", text: $viewModel.title, axis: .vertical)
                .font(.system(size: 34, weight: .bold))
                .foregroundStyle(Color("AppWhite"))
                .tint(Color("AppYellow"))
                .focused($focusedField, equals: .title)
                .padding(.bottom, 8)

            Text(viewModel.formattedDate)
                .font(.system(size: 13, weight: .regular))
                .foregroundStyle(Color("AppGray"))
                .padding(.bottom, 12)

            TextField("Описание", text: $viewModel.details, axis: .vertical)
                .font(.system(size: 17, weight: .regular))
                .foregroundStyle(Color("AppWhite"))
                .tint(Color("AppYellow"))
                .focused($focusedField, equals: .details)

            Spacer()
        }
        .padding(.horizontal, 20)
        .padding(.top, 12)
        .frame(maxWidth: .infinity, maxHeight: .infinity, alignment: .topLeading)
        .background(Color("AppBackground"))
        .toolbar(.hidden, for: .navigationBar)
        .onAppear {
            focusedField = .title
        }
        .onDisappear {
            if viewModel.canSave {
                onSave(viewModel.updatedTodo())
            }
        }
    }

    private var backButton: some View {
        Button {
            dismiss()
        } label: {
            HStack(spacing: 6) {
                Image(systemName: "chevron.left")
                    .font(.system(size: 22, weight: .semibold))
                Text("Назад")
                    .font(.system(size: 17))
            }
            .foregroundStyle(Color("AppYellow"))
        }
    }
}

#Preview {
    NavigationStack {
        TodoEditView(todo: Todo.sampleData[0]) { _ in }
    }
    .preferredColorScheme(.dark)
}
