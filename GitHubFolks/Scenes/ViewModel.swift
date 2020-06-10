//
//  ViewModel.swift
//  GitHubFolks
//
//  Created by Eric Hsu on 2020/6/10.
//  Copyright © 2020 Anonymous Ltd. All rights reserved.
//

import RxSwift
import RxCocoa
import RxDataSources

final class ViewModel {

    private let usersRelay = BehaviorRelay<[GitHubUser]>(value: [])
    private let pagingSub = PublishSubject<GitHubUsersResp>()
    private let scrollSub = PublishSubject<Void>()
    private let disposeBag = DisposeBag()

    let input: Input
    let output: Output
    var nextPageSince: Int? = nil

    init() {
        input = Input(
            loadUsers: pagingSub.asObserver(),
            scrollBottom: scrollSub.asObserver()
        )
        output = Output(
            users: usersRelay.asDriver(),
            didScrollBottom: scrollSub.asDriver(onErrorDriveWith: .empty())
        )

        pagingSub.asDriver(onErrorDriveWith: .empty())
            .map { [usersRelay] in usersRelay.value + $0 }
            .drive(usersRelay)
            .disposed(by: disposeBag)
    }

    func fetchUsers(since: Int? = nil, count: Int = 20) -> Single<GitHubUsersResp> {
        githubProvider.request(.users(since: since, count: count))
            .do(onSuccess: { [weak self] in
                let link = $0.response?.headers.value(for: "Link")
                let nextItem = link?.split(separator: ",").first(where: { $0.contains("rel=\"next\"") })?.description ?? ""
                let pattern = try NSRegularExpression(pattern: ".*since=(\\d+).*", options: [])
                if let matched = pattern.firstMatch(in: nextItem, range: nextItem.nsString.range(of: nextItem)) {
                    self?.nextPageSince = Int(nextItem[Range(matched.range(at: 1), in: nextItem)!])
                }
            })
            .map(GitHubUsersResp.self)
    }
}

extension ViewModel {
    struct Input {
        let loadUsers: AnyObserver<GitHubUsersResp>
        let scrollBottom: AnyObserver<Void>
    }

    struct Output {
        let users: Driver<[GitHubUser]>
        let didScrollBottom: Driver<Void>
    }
}

extension ViewModel {
    typealias Item = GitHubUser
    struct Section: SectionModelType {
        var items: [Item]
        init(original: Section, items: [Item]) {
            self = original
            self.items = items
        }
        init(items: [Item]) {
            self.items = items
        }
    }
}
