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
        Button {
            withAnimation(.easeInOut(duration: 0.25)) {
                onToggleFavorite()
            }
        } label: {
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
                    .fill(dish.favourite ? MenuColors.paperSelected : MenuColors.paper)
                    .shadow(color: .black.opacity(0.06), radius: 6, y: 2)
            )
        }
        .buttonStyle(.plain) 
        .listRowBackground(Color.clear)
    }
}
