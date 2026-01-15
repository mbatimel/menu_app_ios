import SwiftUI

struct EditDishView: View {

    @ObservedObject var viewModel: MenuViewModel
    @Environment(\.dismiss) var dismiss

    let dishId: Int
    @State private var dishName: String = ""

    var body: some View {
        NavigationStack {
            Form {
                Section("Редактировать блюдо") {
                    TextField("Название блюда", text: $dishName)

                    if let dish = viewModel.dishes.first(where: { $0.id == dishId }) {
                        Text("Категория: \(dish.category.displayName)")
                            .foregroundColor(.secondary)
                    }
                }
            }
            .navigationTitle("Редактировать")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {

                ToolbarItem(placement: .navigationBarLeading) {
                    Button("Отмена") {
                        dismiss()
                    }
                }

                ToolbarItem(placement: .navigationBarTrailing) {
                    Button("Сохранить") {
                        Task {
                            await viewModel.updateDish(
                                id: dishId,
                                newName: dishName
                            )
                            if viewModel.errorMessage == nil {
                                dismiss()
                            }
                        }
                    }
                    .disabled(dishName.isEmpty || viewModel.isLoading)
                }
            }
            .onAppear {
                if let dish = viewModel.dishes.first(where: { $0.id == dishId }) {
                    dishName = dish.name
                }
            }
        }
    }
}
