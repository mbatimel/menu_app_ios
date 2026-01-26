import SwiftUI

struct DishRowView: View {

    @Environment(\.horizontalSizeClass) private var horizontalSizeClass

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

    private var isIPad: Bool {
        horizontalSizeClass == .regular
    }

    var body: some View {
        HStack(spacing: 12) {

            VStack(
                alignment: isIPad ? .center : .leading,
                spacing: 4
            ) {
                Text(dish.name)
                    .font(.body)
                    .foregroundStyle(.primary)
                    .frame(
                        maxWidth: .infinity,
                        alignment: isIPad ? .center : .leading
                    )

                Text(dish.category.displayName)
                    .font(.caption)
                    .foregroundStyle(.secondary)
                    .frame(
                        maxWidth: .infinity,
                        alignment: isIPad ? .center : .leading
                    )
            }

            Spacer()

            // ⭐ Избранное
            if canToggleFavorite {
                Button(action: onToggleFavorite) {
                    Image(systemName: dish.favourite ? "star.fill" : "star")
                        .foregroundColor(dish.favourite ? .yellow : .gray)
                }
                .buttonStyle(.plain)
            }

            // ⋯ Меню
            if canEdit || canDelete {
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
                        .padding(8)
                }
            }
        }
        .padding(.vertical, 6)
    }
}
