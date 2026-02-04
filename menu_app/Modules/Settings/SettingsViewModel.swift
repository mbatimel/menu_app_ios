import Foundation

@Observable
final class SettingsViewModel {

    var chefName = ""
    var secretId = UserDefaults.standard.string(forKey: "secretId") ?? ""

    let chefService: ChefServiceProtocol

    init(chefService: ChefServiceProtocol = ChefService()) {
        self.chefService = chefService
    }

    func createChef() async {
        _ = await chefService.create(
            request: CreateChefRequest(name: chefName)
        )
    }

    func deleteChef() async -> Bool {
        let result = await chefService.delete()

        switch result {
        case .success:
            return true
        case .networkError:
            return false
        }
    }
}
