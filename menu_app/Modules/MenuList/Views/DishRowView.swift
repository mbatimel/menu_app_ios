import SwiftUI

struct DishRowView: View {

    let dish: Dish
    let isSelected: Bool
    let canToggleFavorite: Bool
    let canEdit: Bool
    let canDelete: Bool

    let onToggleSelection: () -> Void
    let onToggleFavorite: () -> Void
    let onEdit: () -> Void
    let onDelete: () -> Void
    let index: Int


    var body: some View {
        HStack(spacing: 12) {
            VStack(alignment: .leading, spacing: 4) {
                Text(dish.name)
                    .font(.body)
					.foregroundStyle(.primary)

                Text(dish.category.displayName)
                    .font(.caption)
                    .foregroundColor(.secondary)
            }

            Spacer()

            // Избранное ⭐
            if canToggleFavorite {
                Button(action: onToggleFavorite) {
                    Image(systemName: dish.favourite ? "star.fill" : "star")
                        .foregroundColor(dish.favourite ? .yellow : .gray)
                }
                .buttonStyle(.plain)
            }

            // Меню действий
            Menu {
                if canEdit {
                    Button("Редактировать", action: onEdit)
                }

                if canDelete {
                    Button("Удалить", role: .destructive, action: onDelete)
                }
            } label: {
                Image(systemName: "ellipsis")
                    .foregroundColor(.secondary)
            }

        }
        .padding(.vertical, 6)
    }
}

#Preview {
	DishRowView(
		dish: .init(
			id: 1,
			name: "Test",
			category: .hotDishes,
			favourite: true
		),
		isSelected: false,
		canToggleFavorite: true,
		canEdit: true,
		canDelete: true,
		onToggleSelection: {
		},
		onToggleFavorite: {},
		onEdit: {},
		onDelete: {},
		index: 1)
	.padding(.horizontal, 16)
}
