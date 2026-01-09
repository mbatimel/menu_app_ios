import SwiftUI

struct ContentView: View {

    var body: some View {
        ScrollView {
            VStack(alignment: .leading, spacing: 16) {

                // MARK: - Header
                VStack(alignment: .leading, spacing: 4) {
                    Text("Меню от Ильдара")
                        .font(.title2)
                        .fontWeight(.bold)

                    HStack {
                        Text("16.12.2025")
                            .font(.subheadline)

                        Spacer()

                        Button("Сохранить") {
                            // save action
                        }
                    }
                }

                Divider()

                // MARK: - Add Button
                Button(action: {
                    // add dish
                }) {
                    Text("Добавить")
                        .frame(maxWidth: .infinity)
                        .padding(8)
                        .overlay(
                            RoundedRectangle(cornerRadius: 6)
                                .stroke(Color.gray)
                        )
                }

                // MARK: - Dishes (top block)
                VStack(alignment: .leading, spacing: 8) {
                    Text("2. Картопляники с овощами подается сливочным соусом")
                    Text("1. Дачный салат с добавлением говядины.")
                    Text("2. Салат «Таверна» с мякотью кролика")
                    Text("1. Холодная закуска слойка из баклажанов, томатов, пряной зелени")
                }

                // MARK: - Categories
                VStack(alignment: .leading, spacing: 4) {
                    Text("Закуски")
                    Text("Салаты")
                    Text("Супы")
                    Text("Горячие блюда")
                    Text("Гарниры")
                }
                .font(.headline)

                // MARK: - Dishes (bottom block)
                VStack(alignment: .leading, spacing: 8) {
                    Text("1. Медальоны из телятины с соусом демиглаз")
                    Text("Жаренный картофель с грибами")
                    Text("1. Чукотский суп с тефтелями из оленя на зерновой лапше")
                    Text("2. Греческий суп из зеленой чечевицы с говядиной")
                    Text("2. Джизбыз по Бакински из потрошков молодого ягненка")
                }

                Spacer()
            }
            .padding()
        }
    }
}

 #Preview {
     ContentView()
 }
