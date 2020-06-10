//
//  DetailViewModel.swift
//  GitHubFolks
//
//  Created by Eric Hsu on 2020/6/11.
//  Copyright © 2020 Edgenta UEMS Ltd. All rights reserved.
//

import RxSwift
import RxDataSources
import RxCocoa

final class DetailViewModel {

    let user: GitHubUser
    let input: Input
    let output: Output

    private let detailSub = PublishSubject<GitHubUserDetailResp>()
    private let disposeBag = DisposeBag()

    init(user: GitHubUser) {
        self.user = user
        self.input = Input(loadDetail: detailSub.asObserver())
        self.output = Output(
            items: detailSub.asDriver(onErrorDriveWith: .empty()).map {
                [
                    .login(login: $0.login, isSiteAdmin: $0.siteAdmin),
                    .location($0.location),
                    .blog($0.blog)
                ]
            },
            detail: detailSub.asDriver(onErrorDriveWith: .empty())
        )
    }

    func fetchUserInfo() -> Single<GitHubUserDetailResp> {
        githubProvider.request(.userDetail(id: user.login))
            .map(GitHubUserDetailResp.self)
    }
}

extension DetailViewModel {

    struct Input {
        let loadDetail: AnyObserver<GitHubUserDetailResp>
    }

    struct Output {
        let items: Driver<[Item]>
        let detail: Driver<GitHubUserDetailResp>
    }

    enum Item {
        case login(login: String, isSiteAdmin: Bool), location(String?), blog(URL?)

        var cellId: String {
            switch self {
            case .login: return R.reuseIdentifier.detailLogin.identifier
            case .location: return R.reuseIdentifier.detailLabel.identifier
            case .blog: return R.reuseIdentifier.detailLink.identifier
            }
        }
    }
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
