import SwiftUI

struct CreateDishView: View {

	@State private var viewModel = CreateDishViewModel()
	@Environment(\.dismiss) var dismiss
	@FocusState private var isNameFieldFocused: Bool

	var body: some View {
		contentView
			.navigationTitle("Новое блюдо")
			.scrollContentBackground(.hidden)
			.background(MenuColors.background)
			.navigationBarTitleDisplayMode(.inline)
			.onAppear {
				isNameFieldFocused = true
			}
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
	
	private var contentView: some View {
		Form {
			Section {
				dishName
				categoryPicker
			} header: {
				Text("Информация о блюде")
					.font(Typography.formSectionHeader)
					.foregroundStyle(MenuColors.section)
			}
			.listRowBackground(MenuColors.paper)
		}
	}

	private var dishName: some View {
		VStack(alignment: .leading, spacing: MenuSpacing.sm) {
			Text("Название блюда")
				.font(Typography.fieldLabel)
				.foregroundStyle(MenuColors.text)

			TextField("Введите название блюда", text: $viewModel.name)
				.focused($isNameFieldFocused)
				.foregroundStyle(MenuColors.text)
				.tint(MenuColors.section)
				.font(Typography.fieldValue)
		}
	}

	private var categoryPicker: some View {
		VStack(alignment: .leading, spacing: MenuSpacing.sm) {
			Text("Категория")
				.font(Typography.fieldLabel)
				.foregroundStyle(MenuColors.text)

			Picker("", selection: $viewModel.selectedCategory) {
				ForEach(DishCategory.allCases) { category in
					Text(category.displayName)
						.font(Typography.fieldValue)
						.foregroundStyle(MenuColors.text)
						.tag(category)
				}
			}
			.tint(MenuColors.section)
		}
	}

}

#Preview {
	NavigationStack {
		CreateDishView()
	}
}
