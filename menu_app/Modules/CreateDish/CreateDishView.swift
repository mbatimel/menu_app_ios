import SwiftUI

struct CreateDishView: View {

    @State private var viewModel = CreateDishViewModel()
    @Environment(\.dismiss) var dismiss
    @FocusState private var isNameFieldFocused: Bool

    var body: some View {
        Form {
            Section {
                
                VStack(alignment: .leading, spacing: MenuSpacing.sm) {
                    Text("Название блюда")
                        .font(Typography.fieldLabel)
                        .foregroundStyle(MenuColors.text)

                    TextField("", text: $viewModel.name)
                        .focused($isNameFieldFocused)
                        .foregroundStyle(MenuColors.text)
                        .tint(MenuColors.section)
                        .font(Typography.fieldValue)
                }

                
                VStack(alignment: .leading, spacing: MenuSpacing.sm) {
                    Text("Категория")
                        .font(Typography.fieldLabel)
                        .foregroundStyle(MenuColors.text)

                    Picker("", selection: $viewModel.selectedCategory) {
                        ForEach(DishCategory.allCases, id: \.self) { category in
                            Text(category.displayName)
                                .font(Typography.fieldValue)
                                .foregroundStyle(MenuColors.text)
                                .tag(category)
                        }
                    }
                    .tint(MenuColors.section)
                }

            } header: {
                Text("Информация о блюде")
                    .font(Typography.formSectionHeader)
                    .foregroundStyle(MenuColors.section)
            }
            .listRowBackground(MenuColors.paper)
        }
        .scrollContentBackground(.hidden)
        .background(MenuColors.background)
        .navigationTitle("Новое блюдо")
        .navigationBarTitleDisplayMode(.inline)
        .onAppear {
            isNameFieldFocused = true
        }
        .dismissKeyboardOnTap()
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
                .font(Typography.toolbarAction)
            }
        }
    }
}
