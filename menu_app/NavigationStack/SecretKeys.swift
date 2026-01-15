//
//  SecretKeys.swift
//  menu_app
//
//  Created by M-batimel@ on 15.01.2026.
//

import Foundation

enum SecretKeys {
    static let admin = "8a0c9e87-5d2b-4b0a-b7e2-11df612c8294"
    static let chef = "3ef94d0a-2c0d-41cb-8b91-7a1bbfc73904"
    static let user  = "e6b17882-9bf1-4f85-9aa4-2da98173a6ae"
}

func roleFromSecret(_ secret: String) -> UserRole {
    switch secret {
    case SecretKeys.admin:
        return .admin
    case SecretKeys.chef:
        return .chef
    default:
        return .user
    }
}
