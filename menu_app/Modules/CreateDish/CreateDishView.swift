import SwiftUI

struct CreateDishView: View {

    @State private var viewModel = CreateDishViewModel()
    @Environment(\.dismiss) var dismiss

    var body: some View {
        Form {
            Section {
                
                VStack(alignment: .leading, spacing: 6) {
                    Text("Название блюда")
                        .font(.system(size: 13, weight: .semibold, design: .serif))
                        .foregroundStyle(MenuColors.text)

                    TextField("", text: $viewModel.name)
                        .foregroundStyle(MenuColors.text)
                        .tint(MenuColors.section)
                        .font(.system(size: 16, design: .serif))
                }

                
                VStack(alignment: .leading, spacing: 6) {
                    Text("Категория")
                        .font(.system(size: 13, weight: .semibold, design: .serif))
                        .foregroundStyle(MenuColors.text)

                    Picker("", selection: $viewModel.selectedCategory) {
                        ForEach(DishCategory.allCases, id: \.self) { category in
                            Text(category.displayName)
                                .font(.system(size: 16, design: .serif))
                                .foregroundStyle(MenuColors.text)
                                .tag(category)
                        }
                    }
                    .tint(MenuColors.section)
                }

            } header: {
                Text("Информация о блюде")
                    .font(.system(size: 14, weight: .semibold, design: .serif))
                    .foregroundStyle(MenuColors.section)
            }
            .listRowBackground(MenuColors.paper)
        }
        .scrollContentBackground(.hidden)
        .background(MenuColors.background)
        .navigationTitle("Новое блюдо")
        .navigationBarTitleDisplayMode(.inline)
        .toolbar {
            ToolbarItem(placement: .navigationBarLeading) {
                Button("Отмена") {
                    dismiss()
                }
                .foregroundStyle(MenuColors.secondary)
            }

            ToolbarItem(placement: .navigationBarTrailing) {
                Button("Создать") {
                    viewModel.createDish()
                    dismiss()
                }
                .disabled(viewModel.name.isEmpty)
                .foregroundStyle(MenuColors.section)
                .fontWeight(.semibold)
            }
        }
    }
}
