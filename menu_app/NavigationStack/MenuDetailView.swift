//
//  MenuDetail.swift
//  menu_app_ios
//
//  Created on 2024
//
import SwiftUI

struct MenuDetailView: View {
    @State var menu: LocalMenu
    @State private var showAddDish = false

    var body: some View {
        List {
            ForEach(LocalDishType.allCases, id: \.self) { type in
                Section(type.rawValue) {
                    ForEach(menu.dishes.filter { $0.type == type }) { dish in
                        Text(dish.name)
                    }
                }
            }
        }
        .navigationTitle("Меню от \(menu.author)")
        .toolbar {
            ToolbarItem(placement: .navigationBarTrailing) {
                Button("Добавить") {
                    showAddDish = true
                }
            }
        }
        .sheet(isPresented: $showAddDish) {
            AddDishView { dish in
                menu.dishes.append(dish)
            }
        }
    }
}
