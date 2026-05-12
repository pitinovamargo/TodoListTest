//
//  TodoListView.swift
//  TodoListTest
//

import SwiftUI

struct TodoListView: View {
    @StateObject private var viewModel = TodoListViewModel()

    var body: some View {
        NavigationStack {
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
                    ForEach(viewModel.todos) { todo in
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
                                }
                            )
                            if todo.id != viewModel.todos.last?.id {
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
            }
            .background(Color("AppBackground"))
            .toolbar(.hidden, for: .navigationBar)
            .safeAreaInset(edge: .bottom, spacing: 0) {
                bottomBar
            }
        }
    }

    private var bottomBar: some View {
        ZStack {
            Text("\(viewModel.todos.count) Задач")
                .font(.system(size: 11, weight: .regular))
                .foregroundStyle(Color("AppWhite"))

            HStack {
                Spacer()
                Image(systemName: "square.and.pencil")
                    .font(.system(size: 22, weight: .regular))
                    .foregroundStyle(Color("AppYellow"))
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

            Image(systemName: "mic.fill")
                .foregroundStyle(Color("AppGray"))
        }
        .padding(.horizontal, 6)
        .padding(.vertical, 8)
        .background(Color("AppSearchBackground"))
        .clipShape(RoundedRectangle(cornerRadius: 10))
    }
}

#Preview {
    TodoListView()
        .preferredColorScheme(.dark)
}
