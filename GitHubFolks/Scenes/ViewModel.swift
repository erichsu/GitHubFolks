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
    private let disposeBag = DisposeBag()

    let input: Input
    let output: Output

    init() {
        input = Input(loadUsers: pagingSub.asObserver())
        output = Output(users: usersRelay.asDriver())

        pagingSub.asDriver(onErrorDriveWith: .empty())
            .map { [usersRelay] in $0 + usersRelay.value }
            .drive(usersRelay)
            .disposed(by: disposeBag)
    }
}

extension ViewModel {
    struct Input {
        let loadUsers: AnyObserver<GitHubUsersResp>
    }

    struct Output {
        let users: Driver<[GitHubUser]>
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
