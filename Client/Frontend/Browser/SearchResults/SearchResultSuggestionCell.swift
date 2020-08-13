//
// Copyright (c) 2017-2020 Cliqz GmbH. All rights reserved.
//
// This Source Code Form is subject to the terms of the Mozilla Public
// License, v. 2.0. If a copy of the MPL was not distributed with this
// file, You can obtain one at https://mozilla.org/MPL/2.0/.
//

import UIKit

class SearchResultSuggestionCell: UITableViewCell {

    var title: String? {
        didSet {
            self.titleLabel.text = title
        }
    }

    private let titleLabel = UILabel()

    override init(style: UITableViewCell.CellStyle, reuseIdentifier: String?) {
        super.init(style: style, reuseIdentifier: reuseIdentifier)
        self.configureContent()
    }

    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    private func configureContent() {
        self.backgroundColor = .clear
        self.contentView.backgroundColor = .clear
        self.selectionStyle = .none
        let imageView = UIImageView(image: UIImage(named: "search")?.withRenderingMode(.alwaysTemplate))
        imageView.tintColor = Theme.homePanel.separatorColor
        imageView.contentMode = .scaleAspectFill
        self.contentView.addSubview(imageView)
        imageView.snp.makeConstraints { (make) in
            make.left.equalTo(10)
            make.centerY.equalToSuperview()
            make.width.height.equalTo(20)
        }
        self.titleLabel.textColor = Theme.browser.tint
        self.titleLabel.font = DynamicFontHelper.defaultHelper.MediumSizeRegularWeightAS
        self.contentView.addSubview(self.titleLabel)
        self.titleLabel.snp.makeConstraints { (make) in
            make.left.equalTo(imageView.snp.right).offset(10)
            make.centerY.equalToSuperview()
            make.right.equalToSuperview().offset(-10)
        }
    }

}
