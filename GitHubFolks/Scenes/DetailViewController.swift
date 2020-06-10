//
//  DetailViewController.swift
//  GitHubFolks
//
//  Created by Eric Hsu on 2020/6/11.
//  Copyright © 2020 Edgenta UEMS Ltd. All rights reserved.
//

import UIKit
import SwiftMessages
import RxDataSources

final class DetailViewController: UIViewController {

    var viewModel: DetailViewModel!

    @IBOutlet weak var avatarImage: UIImageView!
    @IBOutlet weak var nameLabel: UILabel!
    @IBOutlet weak var bioLabel: UILabel!
    @IBOutlet weak var tableView: UITableView!

    private lazy var dataSource = RxTableViewSectionedReloadDataSource<DetailViewModel.Section>(configureCell: { _, tableView, index, item in
        let cell = tableView.dequeueReusableCell(withIdentifier: item.cellId, for: index) as! DetailCell
        cell.setup(with: item)
        return cell
    })

    override func viewDidLoad() {
        super.viewDidLoad()
        setupUI()
        bindViewModel()
    }

    private func setupUI() {
        avatarImage.kf.setImage(with: viewModel.user.avatarUrl)
    }

    private func bindViewModel() {
        viewModel.fetchUserInfo()
            .catchMoyaError(ErrorResp.self)
            .asObservable()
            .do(
                onError: SwiftMessages.showError
            )
            .subscribe(viewModel.input.loadDetail)
            .disposed(by: rx.disposeBag)

        viewModel.output.detail
            .drive(onNext: { [nameLabel, bioLabel] in
                nameLabel?.text = $0.name
                bioLabel?.text = $0.bio
            })
            .disposed(by: rx.disposeBag)

        viewModel.output.items
            .map { [DetailViewModel.Section(items: $0)] }
            .drive(tableView.rx.items(dataSource: dataSource))
            .disposed(by: rx.disposeBag)
    }
}

class DetailCell: UITableViewCell {
    func setup(with item: DetailViewModel.Item) {
        assertionFailure("should be implemented by subclass")
    }
}

final class DetailLoginCell: DetailCell {
    @IBOutlet weak var avatarIcon: UIImageView!
    @IBOutlet weak var loginLabel: UILabel!
    @IBOutlet weak var badgeLabel: UILabel!

    override func setup(with item: DetailViewModel.Item) {
        guard case let .login(login, isSiteAdmin) = item else { return }
        loginLabel.text = login
        badgeLabel.text = isSiteAdmin ? "Staff" : nil
        badgeLabel.isHidden = !isSiteAdmin
    }
}

final class DetailLabelCell: DetailCell {
    @IBOutlet weak var iconImage: UIImageView!
    @IBOutlet weak var titleLabel: UILabel!

    override func setup(with item: DetailViewModel.Item) {
        guard case let .location(text) = item else { return }
        titleLabel.text = text ?? "N/A"
    }
}

final class DetailLinkCell: DetailCell {
    @IBOutlet weak var iconImage: UIImageView!
    @IBOutlet weak var linkButton: UIButton!

    override func setup(with item: DetailViewModel.Item) {
        guard case let .blog(url) = item else { return }
        linkButton.setTitle(url?.absoluteString ?? "N/A", for: .normal)
        linkButton.rx.tap
            .compactMap { url }
            .bind(onNext: { UIApplication.shared.open($0, options: [:]) })
            .disposed(by: rx.disposeBag)
    }
}
