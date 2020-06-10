//
//  GitHubUserDetailResp.swift
//  GitHubFolks
//
//  Created by Eric Hsu on 2020/6/11.
//  Copyright © 2020 Edgenta UEMS Ltd. All rights reserved.
//

import Foundation
struct GitHubUserDetailResp: Codable {
    let location: String?
    let bio: String?
    let avatarUrl: URL
    let name: String
    let siteAdmin: Bool
    let email: String?
    let login: String
    let blog: String?
    private enum CodingKeys: String, CodingKey {
        case location
        case bio
        case avatarUrl = "avatar_url"
        case name
        case siteAdmin = "site_admin"
        case email
        case login
        case blog
    }
}
