//
//  ViewController.swift
//  GitHubFolks
//
//  Created by Eric Hsu on 2020/6/10.
//  Copyright © 2020 Anonymous Ltd. All rights reserved.
//

import UIKit
import RxSwift
import RxDataSources

final class ViewController: UIViewController {

    @IBOutlet weak var tableView: UITableView!
    private lazy var dataSource: RxTableViewSectionedReloadDataSource<ViewModel.Section> = {
        RxTableViewSectionedReloadDataSource<ViewModel.Section>(configureCell: { _, tableView, index, item in
            let cell = tableView.dequeueReusableCell(withIdentifier: R.reuseIdentifier.user, for: index)!
            cell.setup(with: item)
            return cell
        })
    }()

    var viewModel = ViewModel()

    override func viewDidLoad() {
        super.viewDidLoad()
        bindViewModel()

    }

    private func bindViewModel() {
        viewModel.output.users
            .map { [ViewModel.Section(items: $0)] }
            .drive(tableView.rx.items(dataSource: dataSource))
            .disposed(by: rx.disposeBag)

        fetchUsers()
            .asObservable()
            .subscribe(viewModel.input.loadUsers)
            .disposed(by: rx.disposeBag)
    }

    private func fetchUsers(page: Int = 0, count: Int = 20) -> Single<GitHubUsersResp> {
        githubProvider.request(.users(page: page, count: count))
            .map(GitHubUsersResp.self)
    }
}

final class UserCell: UITableViewCell {
    @IBOutlet weak var avatarIcon: UIImageView!
    @IBOutlet weak var loginLabel: UILabel!
    @IBOutlet weak var badgeLabel: UILabel!

    func setup(with item: ViewModel.Item) {
        avatarIcon.kf.setImage(with: item.avatarUrl)
        loginLabel.text = item.login
        badgeLabel.text = item.siteAdmin ? "SiteAdmin" : "--"
    }
}
