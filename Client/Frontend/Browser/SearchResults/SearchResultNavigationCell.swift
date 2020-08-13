//
// Copyright (c) 2017-2020 Cliqz GmbH. All rights reserved.
//
// This Source Code Form is subject to the terms of the Mozilla Public
// License, v. 2.0. If a copy of the MPL was not distributed with this
// file, You can obtain one at https://mozilla.org/MPL/2.0/.
//

import UIKit

protocol SearchResultNavigationCellDelegate: class {
    func didLongPress(result: SearchResult)
}

class SearchResultNavigationCell: UITableViewCell {

    weak var delegate: SearchResultNavigationCellDelegate?

    var result: SearchResult! {
        didSet {
            self.titleLabel.text = self.result.title
            self.descriptionLabel.text = self.result.description
            if let urlString = self.result.imageURL, let url = URL(string: urlString) {
                self.iconImageView.sd_setImage(with: url)
            }
        }
    }

    private let titleLabel = UILabel()
    private let descriptionLabel = UILabel()
    private let iconImageView = UIImageView()

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
        self.iconImageView.tintColor = Theme.homePanel.separatorColor
        self.iconImageView.contentMode = .scaleAspectFill
        self.contentView.addSubview(self.iconImageView)
        self.iconImageView.snp.makeConstraints { (make) in
            make.left.equalTo(10)
            make.top.equalTo(10)
            make.width.height.equalTo(20)
        }
        self.titleLabel.numberOfLines = 2
        self.titleLabel.textColor = Theme.browser.tint
        self.titleLabel.font = DynamicFontHelper.defaultHelper.MediumSizeRegularWeightAS
        self.contentView.addSubview(self.titleLabel)
        self.titleLabel.snp.makeConstraints { (make) in
            make.left.equalTo(self.iconImageView.snp.right).offset(10)
            make.centerY.equalTo(self.iconImageView.snp.centerY)
            make.right.equalToSuperview().offset(-10)
        }
        self.descriptionLabel.textColor = UIColor.Link
        self.descriptionLabel.font = DynamicFontHelper.defaultHelper.SmallSizeRegularWeightAS
        self.contentView.addSubview(self.descriptionLabel)
        self.descriptionLabel.snp.makeConstraints { (make) in
            make.left.equalTo(self.titleLabel.snp.left)
            make.top.equalTo(self.titleLabel.snp.bottom)
            make.right.equalToSuperview().offset(-10)
        }
        let longPress = UILongPressGestureRecognizer(target: self, action: #selector(onLongPressGestureRecognized(_:)))
        self.contentView.addGestureRecognizer(longPress)
    }

    @objc private func onLongPressGestureRecognized(_ longPressGestureRecognizer: UILongPressGestureRecognizer) {
        guard longPressGestureRecognizer.state == .began else { return }
        self.delegate?.didLongPress(result: self.result)
    }

}
