import SwiftUI

struct EditDishView: View {

    @State var viewModel: EditDishViewModel
    @Environment(\.dismiss) var dismiss

	let onSaved: () async -> Void

    init(
        viewModel: EditDishViewModel,
        onSaved: @escaping () async -> Void = {}
    ) {
        _viewModel = State(initialValue: viewModel)
        self.onSaved = onSaved
    }

    private var isSaveDisabled: Bool {
        viewModel.isSaving
        || viewModel.selectedDish.name.trimmingCharacters(
            in: .whitespacesAndNewlines
        ).isEmpty
    }

    var body: some View {
        Form {
            Section {
                VStack(alignment: .leading, spacing: MenuSpacing.sm) {
                    Text("Название блюда")
                        .font(Typography.fieldLabel)
                        .foregroundStyle(MenuColors.text)

                    TextField("", text: $viewModel.selectedDish.name)
                        .foregroundStyle(MenuColors.text)
                        .tint(MenuColors.section)
                        .font(Typography.fieldValue)
                }

                
                VStack(alignment: .leading, spacing: MenuSpacing.sm) {
                    Text("Категория")
                        .font(Typography.fieldLabel)
                        .foregroundStyle(MenuColors.text)

                    Picker("", selection: $viewModel.selectedDish.category) {
                        ForEach(DishCategory.allCases) { category in
                            Text(category.displayName)
                                .font(Typography.fieldValue)
                                .foregroundStyle(MenuColors.text)
                                .tag(category)
                        }
                    }
                    .tint(MenuColors.section)
                }

            } header: {
                Text("Редактировать блюдо")
                    .font(Typography.formSectionHeader)
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
                    Task {
                        let didSave = await viewModel.updateDish()
                        guard didSave else { return }

                        await onSaved()
                        dismiss()
                    }
                }
                .disabled(isSaveDisabled)
                .foregroundStyle(MenuColors.section)
                .font(Typography.toolbarAction)
            }
        }
        .alert(
            "Ошибка",
            isPresented: Binding(
                get: { viewModel.errorMessage != nil },
                set: { isPresented in
                    if !isPresented {
                        viewModel.errorMessage = nil
                    }
                }
            ),
            actions: {
                Button("OK", role: .cancel) {}
            },
            message: {
                Text(viewModel.errorMessage ?? "")
            }
        )
    }
}

#Preview {
	NavigationStack {
		EditDishView(
			viewModel: EditDishViewModel(
				selectedDish: .init(
					id: 1,
					name: "Паста Болоньеза",
					category: .hotDishes,
					favourite: true
				)
			),
			onSaved: {}
		)
	}
}
