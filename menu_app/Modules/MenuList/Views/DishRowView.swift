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
                spacing: 6
            ) {
                Text(dish.name)
                    .font(.system(size: 16, weight: .medium, design: .serif))
                    .foregroundColor(MenuColors.text)

                Text(dish.category.displayName)
                    .font(.system(size: 13, design: .serif))
                    .foregroundColor(MenuColors.secondary)
            }

            Spacer()

            if canToggleFavorite {
                Button(action: onToggleFavorite) {
                    Image(systemName: dish.favourite ? "star.fill" : "star")
                        .foregroundColor(MenuColors.section)
                }
                .buttonStyle(.plain)
            }

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
                        .foregroundColor(MenuColors.secondary)
                        .padding(8)
                }
            }
        }
        .padding()
        .background(
            RoundedRectangle(cornerRadius: 16)
                .fill(MenuColors.paper)
                .shadow(color: .black.opacity(0.06), radius: 6, y: 2)
        )
        .listRowBackground(Color.clear) // 🔥 КЛЮЧЕВОЕ
    }
}
