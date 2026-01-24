import SwiftUI

struct CreateDishView: View {
	@State private var viewModel = CreateDishViewModel()
	@Environment(\.dismiss) var dismiss
	
	var body: some View {
		Form {
			Section("Информация о блюде") {
				TextField("Название блюда", text: $viewModel.name)

				Picker("Категория", selection: $viewModel.selectedCategory) {
					ForEach(DishCategory.allCases, id: \.self) { category in
						Text(category.displayName).tag(category)
					}
				}
			}
		}
		.navigationTitle("Новое блюдо")
		.navigationBarTitleDisplayMode(.inline)
		.toolbar {
			ToolbarItem(placement: .navigationBarLeading) {
				Button("Отмена") {
					dismiss()
				}
			}
			
			ToolbarItem(placement: .navigationBarTrailing) {
				Button("Создать") {
					viewModel.createDish()
                    dismiss()
				}
				.disabled(viewModel.name.isEmpty)
			}
		}
	}
}

#Preview {
	CreateDishView()
}
