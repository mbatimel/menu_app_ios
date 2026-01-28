import SwiftUI

struct EditDishView: View {

    @State var viewModel: EditDishViewModel
    @Environment(\.dismiss) var dismiss

    var body: some View {
        Form {
            Section {
                
                VStack(alignment: .leading, spacing: 6) {
                    Text("Название блюда")
                        .font(.system(size: 13, weight: .semibold, design: .serif))
                        .foregroundStyle(MenuColors.text)

                    TextField("", text: $viewModel.selectedDish.name)
                        .foregroundStyle(MenuColors.text)
                        .tint(MenuColors.section)
                        .font(.system(size: 16, design: .serif))
                }

                
                VStack(alignment: .leading, spacing: 6) {
                    Text("Категория")
                        .font(.system(size: 13, weight: .semibold, design: .serif))
                        .foregroundStyle(MenuColors.text)

                    Picker("", selection: $viewModel.selectedDish.category) {
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
                Text("Редактировать блюдо")
                    .font(.system(size: 14, weight: .semibold, design: .serif))
                    .foregroundStyle(MenuColors.section)
            }
            .listRowBackground(MenuColors.paper)
        }
        .scrollContentBackground(.hidden)
        .background(MenuColors.background)
        .navigationTitle("Редактировать")
        .navigationBarTitleDisplayMode(.inline)
        .toolbar {
            ToolbarItem(placement: .navigationBarLeading) {
                Button("Отмена") {
                    dismiss()
                }
                .foregroundStyle(MenuColors.secondary)
            }

            ToolbarItem(placement: .navigationBarTrailing) {
                Button("Сохранить") {
                    viewModel.updateDish()
                    dismiss()
                }
                .foregroundStyle(MenuColors.section)
                .fontWeight(.semibold)
            }
        }
    }
}
