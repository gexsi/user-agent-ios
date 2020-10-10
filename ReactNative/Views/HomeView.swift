//
// Copyright (c) 2017-2019 Cliqz GmbH. All rights reserved.
//
// This Source Code Form is subject to the terms of the Mozilla Public
// License, v. 2.0. If a copy of the MPL was not distributed with this
// file, You can obtain one at https://mozilla.org/MPL/2.0/.
//

import Foundation
import React
import Storage
import Shared

class HomeView: UIView {
    private var speedDials: [Site]?
    private var pinnedSites: [Site]?
    private var isTopSitesEnabled = true
    private var isNewsEnabled = true
    private var isNewsImagesEnabled = true
    private var reactView: UIView?
    private var backgroundImageUri: String?
    private var height: Int?
    private var toolbarHeight: CGFloat

    override init(frame: CGRect) {
        self.toolbarHeight = 0
        super.init(frame: frame)
    }

    convenience init(
        toolbarHeight: CGFloat,
        speedDials: [Site],
        pinnedSites: [Site],
        isTopSitesEnabled: Bool,
        isNewsEnabled: Bool,
        isNewsImagesEnabled: Bool,
        backgroundImageUri: String
    ) {
        self.init(frame: .zero)
        self.toolbarHeight = toolbarHeight
        self.pinnedSites = pinnedSites
        self.speedDials = speedDials
        self.isTopSitesEnabled = isTopSitesEnabled
        self.isNewsEnabled = isNewsEnabled
        self.isNewsImagesEnabled = isNewsImagesEnabled
        self.backgroundImageUri = backgroundImageUri
    }

    required init(coder aDecoder: NSCoder) {
        fatalError("This class does not support NSCoding")
    }

    override func layoutSubviews() {
        let height = Int(self.bounds.height)
        if height == self.height ?? 0 {
            super.layoutSubviews()
            return
        } else {
            self.height = height
        }

        if let reactView = self.reactView {
            reactView.removeFromSuperview()
            self.reactView = nil
        }

        let reactView = RCTRootView(
            bridge: ReactNativeBridge.sharedInstance.bridge,
            moduleName: "Home",
            initialProperties: [
                "speedDials": self.speedDials!.map { $0.toDict() },
                "pinnedSites": self.pinnedSites!.map { $0.toDict() },
                "isTopSitesEnabled": self.isTopSitesEnabled,
                "isNewsEnabled": self.isNewsEnabled,
                "isNewsImagesEnabled": self.isNewsImagesEnabled,
                "backgroundImageUri": self.backgroundImageUri ?? "",
                "height": height,
                "toolbarHeight": self.toolbarHeight,
                "Features": Features.toDict(),
            ]
        )

        reactView.backgroundColor = .clear
        reactView.frame = self.bounds
        self.reactView = reactView

        self.addSubview(reactView)

        super.layoutSubviews()
    }
}
