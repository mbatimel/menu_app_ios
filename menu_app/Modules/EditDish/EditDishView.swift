import SwiftUI

struct EditDishView: View {
	
	@State var viewModel: EditDishViewModel
	@Environment(\.dismiss) var dismiss
	
	var body: some View {
		Form {
			Section("Редактировать блюдо") {
				TextField("Название блюда", text: $viewModel.selectedDish.name)
				
				Picker("Категория", selection: $viewModel.selectedDish.category) {
					ForEach(DishCategory.allCases, id: \.self) { category in
						Text(category.displayName).tag(category)
					}
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
					viewModel.updateDish()
					dismiss()
				}
			}
		}
	}
}

#Preview {
	EditDishView(
		viewModel: EditDishViewModel(
			selectedDish: .init(
				id: 1,
				name: "Карбонара",
				category: .hotDishes,
				favourite: true
			)
		)
	)
}
