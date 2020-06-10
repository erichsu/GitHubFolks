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
import NVActivityIndicatorView
import SwiftMessages

final class ViewController: UIViewController {

    @IBOutlet weak var tableView: UITableView!
    lazy var indicator: NVActivityIndicatorView = {
        let frame = CGRect(origin: .zero, size: .init(width: 30, height: 30))
        return NVActivityIndicatorView(frame: frame, type: .ballPulse, color: .gray)
    }()

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
        setupTable()
        bindViewModel()
    }

    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        super.prepare(for: segue, sender: sender)
        if let info = R.segue.viewController.userDetail(segue: segue), let item = sender as? ViewModel.Item {
            info.destination.viewModel = .init(user: item)
        }
    }

    private func bindViewModel() {
        viewModel.output.users
            .map { [ViewModel.Section(items: $0)] }
            .drive(tableView.rx.items(dataSource: dataSource))
            .disposed(by: rx.disposeBag)
    }

    private func setupTable() {
        dataSource.titleForHeaderInSection = { dataSource, sec in
            let section = dataSource.sectionModels[sec]
            return section.items.count > 0 ? "Users (\(section.items.count))" : "No User found"
        }

        tableView.rx.modelSelected(ViewModel.Item.self)
            .bind(onNext: { [weak self] in self?.performSegue(withIdentifier: R.segue.viewController.userDetail, sender: $0) })
            .disposed(by: rx.disposeBag)
        
        tableView.tableFooterView = indicator
        tableView.rx.contentOffset
            .filter { [tableView, dataSource] offset in
                tableView?.indexPathsForVisibleRows?.last?.row.uInt == dataSource.sectionModels.first?.items.indices.last?.uInt
            }
            .filter { [indicator] _ in !indicator.isAnimating }
            .flatMap { [viewModel, indicator] _ in
                viewModel.fetchUsers(since: viewModel.nextPageSince)
                    .catchMoyaError(ErrorResp.self)
                    .do(
                        onError: SwiftMessages.showError,
                        onSubscribed: { indicator.startAnimating() },
                        onDispose: { indicator.stopAnimating() }
                    )
            }
            .subscribe(viewModel.input.loadUsers)
            .disposed(by: rx.disposeBag)
    }
}

final class UserCell: UITableViewCell {
    @IBOutlet weak var avatarIcon: UIImageView!
    @IBOutlet weak var loginLabel: UILabel!
    @IBOutlet weak var badgeLabel: UILabel!

    func setup(with item: ViewModel.Item) {
        avatarIcon.kf.setImage(with: item.avatarUrl)
        loginLabel.text = item.login
        badgeLabel.text = item.siteAdmin ? "Staff" : nil
        badgeLabel.isHidden = !item.siteAdmin
    }
}
