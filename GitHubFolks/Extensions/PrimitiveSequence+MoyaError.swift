//
//  PrimitiveSequence+MoyaError.swift
//  GitHubFolks
//
//  Created by Eric Hsu on 2020/6/10.
//  Copyright © 2020 Anonymous Ltd. All rights reserved.
//

import RxSwift
import Moya

extension PrimitiveSequence where Element: Decodable {
    func catchMoyaError<D>(_ type: D.Type) -> PrimitiveSequence<Trait, Element> where D: Decodable, D: Error {
        catchError { error in
            guard let moyaError = error as? MoyaError else { throw error }
            guard let decoded = try moyaError.response?.map(type) else { throw moyaError }
            throw decoded
        }
    }
}
