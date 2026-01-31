//
//  UserRole.swift
//  menu_app
//
//  Created by M-batimel@ on 15.01.2026.
//
import Foundation

enum UserRole: String {
    case admin
    case chef
    case user
}

struct Permissions {
    let canCreateDish: Bool
    let canEditDish: Bool
    let canDeleteDish: Bool
    let canToggleFavorite: Bool
}

extension UserRole {
    var permissions: Permissions {
        switch self {
        case .admin:
            return Permissions(
                canCreateDish: true,
                canEditDish: true,
                canDeleteDish: true,
                canToggleFavorite: true
            )
        case .chef:
            return Permissions(
                canCreateDish: true,
                canEditDish: true,
                canDeleteDish: true,
                canToggleFavorite: false
            )
        case .user:
            return Permissions(
                canCreateDish: true,
                canEditDish: true,
                canDeleteDish: true,
                canToggleFavorite: true
            )
        }
    }
}

