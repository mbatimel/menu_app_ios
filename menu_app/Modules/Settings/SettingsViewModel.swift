import Foundation

@Observable
final class SettingsViewModel {
	var chefName: String = ""
	var secretId: String = UserDefaults.standard.string(forKey: "secretId") ?? "YOUR_SECRET_UUID_HERE"
	
	let chefService: ChefServiceProtocol
	
	init(chefService: ChefServiceProtocol = ChefService()) {
		self.chefService = chefService
	}
	
	// MARK: - Public Methods
	
	func createChef() {
		Task {
			await createChefRequest()
		}
	}
	
	// MARK: - Private Methods
	
	private func createChefRequest() async {
		let result = await chefService.create(name: chefName)

		switch result {
		case .success:
			UserDefaults.standard.set(chefName, forKey: "currentChef")
		case .networkError(let error):
			Logger.log(level: .warning, "Error while create new chef \(error)")
		}

//		do {
//			UserDefaults.standard.set(chefName, forKey: "currentChef")
//			viewModel.currentChef = chefName
//		} catch {
//			print("Ошибка создания шефа: \(error)")
//		}
	}
}
