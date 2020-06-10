//
//  Session+ResponseDetective.swift
//  GitHubFolks
//
//  Created by Eric Hsu on 2020/6/10.
//  Copyright © 2020 Anonymous Ltd. All rights reserved.
//

import Alamofire
import Moya

#if DEBUG
import ResponseDetective
#endif

extension Session {
    static var custom: Session {
        let configuration = URLSessionConfiguration.default
        #if DEBUG
        ResponseDetective.enable(inConfiguration: configuration)
        #endif
        configuration.headers = .default
        return Session(configuration: configuration, startRequestsImmediately: false)
    }
}
