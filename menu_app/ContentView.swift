import SwiftUI

struct ContentView: View {

	var body: some View {
		NavigationStack {
			MenuListView(viewModel: MenuViewModel())
		}
    }
}

 #Preview {
     ContentView()
 }
