//
//  SwiftMessage+Error.swift
//  GitHubFolks
//
//  Created by Eric Hsu on 2020/6/10.
//  Copyright © 2020 Anonymous Ltd. All rights reserved.
//

import SwiftMessages

extension SwiftMessages {
    static func showError(_ error: Error) {
        guard let error = error as? LocalizedError else { return }
        let config = SwiftMessages.defaultConfig
        let view = MessageView.viewFromNib(layout: .messageView)
        view.configureContent(title: "Server Error", body: error.localizedDescription)
        view.configureTheme(.warning)
        view.button?.isHidden = true

        show(config: config, view: view)
    }
}
