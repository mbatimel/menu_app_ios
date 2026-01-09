//
//  AddDishView .swift
//  
//
//  Created by M-batimel@ on 09.01.2026.
//

import SwiftUI

struct AddDishView: View {
    @Environment(\.dismiss) var dismiss

    @State private var name = ""
    @State private var type: LocalDishType = .snacks

    var onAdd: (LocalDish) -> Void

    var body: some View {
        NavigationStack {
            Form {
                TextField("Название блюда", text: $name)

                Picker("Тип блюда", selection: $type) {
                    ForEach(LocalDishType.allCases, id: \.self) {
                        Text($0.rawValue)
                    }
                }
            }
            .navigationTitle("Добавить блюдо")
            .toolbar {
                Button("Сохранить") {
                    onAdd(LocalDish(name: name, type: type))
                    dismiss()
                }
            }
        }
    }
}
