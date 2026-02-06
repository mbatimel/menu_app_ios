import SwiftUI
#if canImport(UIKit)
import UIKit
#endif

enum Typography {
    static let screenTitle = Font.system(size: 32, weight: .bold, design: .serif)
    static let sectionHeader = Font.system(size: 15, weight: .semibold, design: .serif)
    static let formSectionHeader = Font.system(size: 14, weight: .semibold, design: .serif)

    static let dishTitle = Font.system(size: 16, weight: .medium, design: .serif)
    static let dishSubtitle = Font.system(size: 13, weight: .regular, design: .serif)

    static let fieldLabel = Font.system(size: 13, weight: .semibold, design: .serif)
    static let fieldValue = Font.system(size: 16, weight: .regular, design: .serif)
    static let fieldValueMedium = Font.system(size: 16, weight: .medium, design: .serif)
    static let actionPrimary = Font.system(size: 16, weight: .semibold, design: .serif)
    static let actionSecondary = Font.system(size: 16, weight: .medium, design: .serif)

    static let helperFootnote = Font.footnote
    static let caption = Font.caption

    static let settingsSectionTitle = Font.system(size: 18, weight: .semibold, design: .serif)
    static let settingsChefValue = Font.system(size: 17, weight: .semibold, design: .serif)
    static let settingsNavTitle = Font.system(size: 20, weight: .semibold, design: .serif)

    static let menuChefName = Font.system(size: 15, weight: .semibold, design: .serif)
    static let menuChefDate = Font.system(size: 14, weight: .medium, design: .serif)
    static let toggleButton = Font.system(size: 14, weight: .semibold, design: .serif)

    static let authIcon = Font.system(size: 44)
    static let authTitle = Font.title2.weight(.bold)
    static let toolbarAction = Font.body.weight(.semibold)

    static let segmentedSelected = UIFont.systemFont(ofSize: 14, weight: .semibold)
    static let segmentedNormal = UIFont.systemFont(ofSize: 14, weight: .medium)
}
