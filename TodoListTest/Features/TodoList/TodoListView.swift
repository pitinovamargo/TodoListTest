//
//  TodoListView.swift
//  TodoListTest
//

import SwiftUI

struct TodoListView: View {
    @StateObject private var viewModel: TodoListViewModel

    init(storage: TodoStorageProtocol) {
        _viewModel = StateObject(wrappedValue: TodoListViewModel(storage: storage))
    }

    var body: some View {
        NavigationStack(path: $viewModel.path) {
            VStack(alignment: .leading, spacing: 0) {
                Text("Задачи")
                    .font(.system(size: 36, weight: .bold))
                    .foregroundStyle(Color("AppWhite"))
                    .padding(.horizontal, 20)
                    .padding(.top, 20)
                    .padding(.bottom)

                searchField
                    .padding(.horizontal, 20)
                    .padding(.bottom)

                List {
                    ForEach(viewModel.displayedTodos) { todo in
                        VStack(spacing: 0) {
                            TodoRowView(
                                todo: todo,
                                onToggle: {
                                    withAnimation(.easeInOut(duration: 0.2)) {
                                        viewModel.toggle(todo)
                                    }
                                },
                                onDelete: {
                                    withAnimation {
                                        viewModel.delete(todo)
                                    }
                                },
                                onEdit: {
                                    viewModel.path.append(todo)
                                }
                            )
                            .contentShape(Rectangle())
                            .onTapGesture {
                                viewModel.path.append(todo)
                            }
                            if todo.id != viewModel.displayedTodos.last?.id {
                                Rectangle()
                                    .fill(Color("AppStroke"))
                                    .frame(height: 0.5)
                                    .padding(.horizontal, 20)
                            }
                        }
                        .listRowInsets(EdgeInsets())
                        .listRowBackground(Color("AppBackground"))
                        .listRowSeparator(.hidden)
                    }
                }
                .listStyle(.plain)
                .scrollContentBackground(.hidden)
                .scrollDismissesKeyboard(.immediately)
            }
            .background(Color("AppBackground"))
            .toolbar(.hidden, for: .navigationBar)
            .safeAreaInset(edge: .bottom, spacing: 0) {
                bottomBar
            }
            .navigationDestination(for: Todo.self) { todo in
                TodoEditView(todo: todo) { updatedTodo in
                    viewModel.save(updatedTodo)
                }
            }
        }
        .task {
            await viewModel.load()
        }
    }

    private var bottomBar: some View {
        ZStack {
            Text("\(viewModel.todos.count) Задач")
                .font(.system(size: 11, weight: .regular))
                .foregroundStyle(Color("AppWhite"))

            HStack {
                Spacer()
                Button {
                    viewModel.startNewTodo()
                } label: {
                    Image(systemName: "square.and.pencil")
                        .font(.system(size: 22, weight: .regular))
                        .foregroundStyle(Color("AppYellow"))
                }
                .padding(.trailing, 20)
            }
        }
        .padding(.top, 20)
        .padding(.bottom, 15)
        .background(Color("AppToolbarBackground"))
    }

    private var searchField: some View {
        HStack(spacing: 3) {
            Image(systemName: "magnifyingglass")
                .foregroundStyle(Color("AppGray"))

            TextField("Search", text: $viewModel.searchQuery)
                .foregroundStyle(Color("AppGray"))
                .font(.system(size: 17, weight: .regular))

            if viewModel.searchQuery.isEmpty {
                Image(systemName: "mic.fill")
                    .foregroundStyle(Color("AppGray"))
            } else {
                Button {
                    viewModel.searchQuery = ""
                } label: {
                    Image(systemName: "xmark.circle.fill")
                        .foregroundStyle(Color("AppGray"))
                }
                .buttonStyle(.plain)
            }
        }
        .padding(.horizontal, 6)
        .padding(.vertical, 8)
        .background(Color("AppSearchBackground"))
        .clipShape(RoundedRectangle(cornerRadius: 10))
    }
}

#Preview {
    TodoListView(storage: TodoStorage(stack: CoreDataStack(inMemory: true)))
        .preferredColorScheme(.dark)
}
