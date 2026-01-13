//
//  DishRowView.swift
//  menu_app
//
//  Created by M-batimel@ on 13.01.2026.
//

import SwiftUI

struct DishRowView: View {

    let dish: Dish
    let isSelected: Bool
    let onToggleSelection: () -> Void
    let onToggleFavorite: () -> Void
    let onEdit: () -> Void
    let onDelete: () -> Void
    let index: Int

    var body: some View {
        HStack(spacing: 12) {

            // Номер блюда (как в меню)
            Text("\(index).")
                .foregroundColor(.secondary)
                .frame(width: 24, alignment: .leading)

            // Выбор (чекбокс)
            Button(action: onToggleSelection) {
                Image(systemName: isSelected
                      ? "checkmark.circle.fill"
                      : "circle")
                    .foregroundColor(isSelected ? .blue : .gray)
            }
            .buttonStyle(.plain)

            // Название + категория
            VStack(alignment: .leading, spacing: 4) {
                Text(dish.name)
                    .font(.body)

                Text(dish.category.displayName)
                    .font(.caption)
                    .foregroundColor(.secondary)
            }

            Spacer()

            // Избранное ⭐
            Button(action: onToggleFavorite) {
                Image(systemName: dish.favorite
                      ? "star.fill"
                      : "star")
                    .foregroundColor(dish.favorite ? .yellow : .gray)
            }
            .buttonStyle(.plain)

            // Меню действий
            Menu {
                Button("Редактировать", action: onEdit)
                Button("Удалить", role: .destructive, action: onDelete)
            } label: {
                Image(systemName: "ellipsis")
                    .foregroundColor(.secondary)
            }
        }
        .padding(.vertical, 6)
    }
}
