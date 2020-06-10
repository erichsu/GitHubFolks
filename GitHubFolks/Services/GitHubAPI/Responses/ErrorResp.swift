//
//  ErrorResp.swift
//  GitHubFolks
//
//  Created by Eric Hsu on 2020/6/10.
//  Copyright © 2020 Anonymous Ltd. All rights reserved.
//

import Foundation
struct ErrorResp: Codable, LocalizedError {
    let message: String
    var errorDescription: String? { message }
}
