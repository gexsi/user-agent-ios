/* This Source Code Form is subject to the terms of the Mozilla Public
 * License, v. 2.0. If a copy of the MPL was not distributed with this
 * file, You can obtain one at http://mozilla.org/MPL/2.0/. */
import UIKit

class ThemedTableViewCell: UITableViewCell, Themeable {
    var detailTextColor = Theme.tableView.rowDetailText

    override init(style: UITableViewCell.CellStyle, reuseIdentifier: String?) {
        super.init(style: style, reuseIdentifier: reuseIdentifier)
        applyTheme()
    }

    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    func applyTheme() {
        var needToChangeTextColor = true
        if textLabel?.attributedText?.length ?? 0 > 0 {
             needToChangeTextColor = textLabel?.attributedText?.attribute(NSAttributedString.Key.foregroundColor, at: 0, effectiveRange: nil) == nil
        }
        if needToChangeTextColor {
            textLabel?.textColor = Theme.tableView.rowText
        }
        var needToChangeDetailTextColor = true
        if detailTextLabel?.attributedText?.length ?? 0 > 0 {
            needToChangeDetailTextColor = detailTextLabel?.attributedText?.attribute(NSAttributedString.Key.foregroundColor, at: 0, effectiveRange: nil) == nil
        }
        if needToChangeDetailTextColor {
            detailTextLabel?.textColor = detailTextColor
        }
        backgroundColor = Theme.tableView.rowBackground
        tintColor = Theme.general.controlTint
    }
}

class ThemedTableViewController: UITableViewController, Themeable {
    override init(style: UITableView.Style = .grouped) {
        super.init(style: style)
    }

    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
    }

    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = ThemedTableViewCell(style: .subtitle, reuseIdentifier: nil)
        return cell
    }

    override func viewDidLoad() {
        super.viewDidLoad()
        applyTheme()
    }

    func reloadData() {
        self.applyTheme()
    }

    func applyTheme() {
        tableView.separatorColor = Theme.tableView.separator
        tableView.backgroundColor = Theme.tableView.headerBackground
        tableView.reloadData()

        (tableView.tableHeaderView as? Themeable)?.applyTheme()
    }
}

class ThemedTableSectionHeaderFooterView: UITableViewHeaderFooterView, Themeable {
    private struct UX {
        static let titleHorizontalPadding: CGFloat = 15
        static let titleVerticalPadding: CGFloat = 6
        static let titleVerticalLongPadding: CGFloat = 20
    }

    enum TitleAlignment {
        case top
        case bottom
    }

    var titleAlignment: TitleAlignment = .bottom {
        didSet {
            remakeTitleAlignmentConstraints()
        }
    }

    var showTopBorder: Bool = true {
        didSet {
            topBorder.isHidden = !showTopBorder
        }
    }

    var showBottomBorder: Bool = true {
        didSet {
            bottomBorder.isHidden = !showBottomBorder
        }
    }

    lazy var titleLabel: UILabel = {
        var headerLabel = UILabel()
        headerLabel.font = UIFont.systemFont(ofSize: 12.0, weight: UIFont.Weight.regular)
        headerLabel.numberOfLines = 0
        return headerLabel
    }()

    fileprivate lazy var topBorder: UIView = {
        let topBorder = UIView()
       return topBorder
    }()

    fileprivate lazy var bottomBorder: UIView = {
        let bottomBorder = UIView()
        return bottomBorder
    }()

    override init(reuseIdentifier: String?) {
        super.init(reuseIdentifier: reuseIdentifier)
        addSubview(titleLabel)
        addSubview(topBorder)
        addSubview(bottomBorder)
        setupInitialConstraints()
        applyTheme()
    }

    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    func applyTheme() {
        topBorder.backgroundColor = Theme.tableView.separator
        bottomBorder.backgroundColor = Theme.tableView.separator
        contentView.backgroundColor = Theme.tableView.headerBackground
        titleLabel.textColor = Theme.tableView.headerTextLight
    }

    func setupInitialConstraints() {
        bottomBorder.snp.makeConstraints { make in
            make.bottom.left.right.equalTo(self)
            make.height.equalTo(0.5)
        }

        topBorder.snp.makeConstraints { make in
            make.top.left.right.equalTo(self)
            make.height.equalTo(0.5)
        }

        remakeTitleAlignmentConstraints()
    }

    override func prepareForReuse() {
        super.prepareForReuse()
        showTopBorder = true
        showBottomBorder = true
        titleLabel.text = nil
        titleAlignment = .bottom

        applyTheme()
    }

    fileprivate func remakeTitleAlignmentConstraints() {
        switch titleAlignment {
        case .top:
            titleLabel.snp.remakeConstraints { make in
                make.left.right.equalTo(self.contentView).inset(UX.titleHorizontalPadding)
                make.top.equalTo(self).offset(UX.titleVerticalPadding)
                make.bottom.equalTo(self).offset(-UX.titleVerticalLongPadding)
            }
        case .bottom:
            titleLabel.snp.remakeConstraints { make in
                make.left.right.equalTo(self.contentView).inset(UX.titleHorizontalPadding)
                make.bottom.equalTo(self).offset(-UX.titleVerticalPadding)
                make.top.equalTo(self).offset(UX.titleVerticalLongPadding)
            }
        }
    }
}

class UISwitchThemed: UISwitch {
    override func layoutSubviews() {
        super.layoutSubviews()
        onTintColor = Theme.general.controlTint
    }
}
