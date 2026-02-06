import SwiftUI

struct DishRowView: View {

    @Environment(\.horizontalSizeClass) private var horizontalSizeClass

    let dish: Dish

    let canEdit: Bool
    let canDelete: Bool

    let onToggleFavorite: () -> Void
    let onEdit: () -> Void
    let onDelete: () -> Void

    private var isIPad: Bool {
        horizontalSizeClass == .regular
    }

    var body: some View {
        HStack(spacing: MenuSpacing.lg) {

            VStack(
                alignment: isIPad ? .center : .leading,
                spacing: MenuSpacing.sm
            ) {
                Text(dish.name)
                    .font(Typography.dishTitle)
                    .foregroundColor(MenuColors.text)

                Text(dish.category.displayName)
                    .font(Typography.dishSubtitle)
                    .foregroundColor(MenuColors.secondary)
            }

            Spacer()
        }
        .padding(MenuSpacing.xl)
        .background(
            RoundedRectangle(cornerRadius: 16)
                .fill(dish.favourite ? MenuColors.paperSelected : MenuColors.paper)
                .shadow(color: .black.opacity(0.06), radius: 6, y: 2)
        )
        .contentShape(Rectangle())
        // ⭐ ТАП — избранное
        .onTapGesture {
            withAnimation(.easeInOut(duration: 0.25)) {
                onToggleFavorite()
            }
        }
        // ⬅️ СВАЙП ВЛЕВО — УДАЛИТЬ
        .swipeActions(edge: .trailing, allowsFullSwipe: true) {
            if canDelete {
                Button(role: .destructive) {
                    withAnimation(.easeInOut) {
                        onDelete()
                    }
                } label: {
                    Label("Удалить", systemImage: "trash")
                }
            }
        }
        // ➡️ СВАЙП ВПРАВО — РЕДАКТИРОВАТЬ
        .swipeActions(edge: .leading, allowsFullSwipe: false) {
            if canEdit {
                Button {
                    onEdit()
                } label: {
                    Label("Редактировать", systemImage: "pencil")
                }
                .tint(MenuColors.section)
            }
        }
        .listRowBackground(Color.clear)
    }
}
