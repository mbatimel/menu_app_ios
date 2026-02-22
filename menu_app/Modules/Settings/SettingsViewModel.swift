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
        return !currentChef.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty
    }

    init(
        currentChef: String?,
        chefService: ChefServiceProtocol = ChefService()
    ) {
        self.currentChef = currentChef
        self.chefService = chefService
    }

    func loadCurrentChef() async {
        do {
            let chef = try await chefService.current()
            currentChef = chef.name
        } catch {
            Logger.log(level: .error(error), "Error loading chef")
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

        do {
            try await chefService.create(request: CreateChefRequest(name: name))
            currentChef = name
            chefName = ""
            errorMessage = nil
            return true
        } catch {
            errorMessage = error.localizedDescription
            return false
        }
    }

    @discardableResult
    func deleteChef() async -> Bool {
        guard !isProcessing else { return false }
        isProcessing = true
        defer { isProcessing = false }

        do {
            try await chefService.delete()
            currentChef = nil
            errorMessage = nil
            return true
        } catch {
            errorMessage = error.localizedDescription
            return false
        }
    }
}
