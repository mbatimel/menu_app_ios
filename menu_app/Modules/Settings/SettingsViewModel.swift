import Foundation

@MainActor
@Observable
final class SettingsViewModel {

    var currentChef: String?
    var chefName = ""
    var errorMessage: String?
    var isProcessing = false
    var secretId = UserDefaults.standard.string(forKey: "secretId") ?? ""

    private let chefService: ChefServiceProtocol

    var hasChef: Bool {
        guard let currentChef else { return false }
        return !currentChef.trimmingCharacters(
            in: .whitespacesAndNewlines
        ).isEmpty
    }

    init(
        currentChef: String?,
        chefService: ChefServiceProtocol = ChefService()
    ) {
        self.currentChef = currentChef
        self.chefService = chefService
    }

    func loadCurrentChef() async {
        let result = await chefService.current()
        if case .success(let chef) = result {
            currentChef = chef.name
        }
    }

    @discardableResult
    func createChef() async -> Bool {
        guard !isProcessing else { return false }

        let name = chefName.trimmingCharacters(in: .whitespacesAndNewlines)
        guard !name.isEmpty else {
            errorMessage = "Введите имя шеф-повара"
            return false
        }

        isProcessing = true
        defer { isProcessing = false }

        let result = await chefService.create(request: CreateChefRequest(name: name))
        switch result {
        case .success:
            currentChef = name
            chefName = ""
            errorMessage = nil
            return true
        case .networkError(let error):
            errorMessage = error
            return false
        }
    }

    @discardableResult
    func deleteChef() async -> Bool {
        guard !isProcessing else { return false }
        isProcessing = true
        defer { isProcessing = false }

        let result = await chefService.delete()

        switch result {
        case .success:
            currentChef = nil
            errorMessage = nil
            return true
        case .networkError(let error):
            errorMessage = error
            return false
        }
    }
}
