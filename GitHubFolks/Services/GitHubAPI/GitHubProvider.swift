//
//  GitHubProvider.swift
//  GitHubFolks
//
//  Created by Eric Hsu on 2020/6/10.
//  Copyright © 2020 Anonymous Ltd. All rights reserved.
//

import MoyaSugar
import RxSwift
import Alamofire

let githubProvider = GitHubProvider<GitHubTarget>()

enum GitHubTarget {
    case users(page: Int, count: Int)
    case userDetail(id: String)
}

final class GitHubProvider<Target> where Target: Moya.TargetType {

    private let provider: MoyaProvider<Target>
    init(endpointClosure: @escaping MoyaProvider<Target>.EndpointClosure = MoyaProvider.defaultEndpointMapping,
         requestClosure: @escaping MoyaProvider<Target>.RequestClosure = MoyaProvider<Target>.defaultRequestMapping,
         stubClosure: @escaping MoyaProvider<Target>.StubClosure = MoyaProvider.neverStub,
         callbackQueue: DispatchQueue? = nil,
         session: Session = .custom,
         plugins: [PluginType] = [],
         trackInflights: Bool = false) {

        self.provider = MoyaProvider<Target>(
            endpointClosure: endpointClosure,
            requestClosure: requestClosure,
            stubClosure: stubClosure,
            callbackQueue: callbackQueue,
            session: session,
            plugins: plugins,
            trackInflights: trackInflights
        )
    }

    func request(_ token: Target) -> Single<Moya.Response> {
        provider.rx.request(token)
    }
}

extension GitHubTarget: SugarTargetType {

    var route: Route {
        switch self {
        case .users: return .get("/users")
        case .userDetail(let id): return .get("/users/\(id)")
        }
    }

    var parameters: MoyaSugar.Parameters? { return nil }

    var baseURL: URL { "https://api.github.com".url! }

    var sampleData: Data { Data() }

    var headers: [String : String]? { return nil }
}
