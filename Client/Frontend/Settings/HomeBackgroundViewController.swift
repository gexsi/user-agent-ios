//
// Copyright (c) 2017-2019 Cliqz GmbH. All rights reserved.
//
// This Source Code Form is subject to the terms of the Mozilla Public
// License, v. 2.0. If a copy of the MPL was not distributed with this
// file, You can obtain one at https://mozilla.org/MPL/2.0/.
//

import UIKit
import Shared

struct HomeBackgroundViewControllerUI {
    static let cellSpace: CGFloat = 20.0
}

class HomeBackgroundHelper {

    class Item {
        var identifier: String
        var image: UIImage

        init(identifier: String, image: UIImage) {
            self.identifier = identifier
            self.image = image
        }
    }

    enum Option: Int32, CaseIterable {
        case randomImage = 0
        case staticImage
    }

    static func collectItems() -> [Item] {
        let imageNamePrefix = Features.Home.BackgroundSetting.defaultImageName
        var imageName = imageNamePrefix
        var image = UIImage(named: imageName)
        var i = 0
        var items = [Item]()
        while image != nil && i < 100 {
            items.append(Item(identifier: imageName, image: image!))
            i += 1
            imageName = imageNamePrefix + "-\(i)"
            image = UIImage(named: imageName)
        }
        return items
    }

}

class HomeBackgroundViewController: UIViewController {

    var profile: Profile!

    var completion: (() -> Void)?

    private var collectionView: UICollectionView!
    private var tableView: UITableView!
    private var items = [HomeBackgroundHelper.Item]()

    private var isStatusBarOrientationLandscape: Bool {
        return UIApplication.shared.statusBarOrientation == .landscapeLeft || UIApplication.shared.statusBarOrientation == .landscapeRight
    }

    override func viewDidLoad() {
        super.viewDidLoad()
        self.title = Strings.Settings.General.HomeBackground.SectionName
        self.view.backgroundColor = Theme.tableView.headerBackground

        self.configureOptionsTableView()
        self.configureItemsCollectionView()
        self.items = HomeBackgroundHelper.collectItems()
    }

    // MARK: - Private methods

    private func configureItemsCollectionView() {
        let layout = UICollectionViewFlowLayout()
        layout.sectionInset = UIEdgeInsets(equalInset: HomeBackgroundViewControllerUI.cellSpace)
        layout.scrollDirection = .vertical
        layout.minimumLineSpacing = HomeBackgroundViewControllerUI.cellSpace / 2
        layout.minimumInteritemSpacing = HomeBackgroundViewControllerUI.cellSpace
        self.collectionView = UICollectionView(frame: .zero, collectionViewLayout: layout)
        self.collectionView.dataSource = self
        self.collectionView.delegate = self
        self.collectionView.backgroundColor = Theme.tableView.headerBackground
        self.collectionView.register(HomeBackgroundCell.self, forCellWithReuseIdentifier: "cell")
        self.view.addSubview(self.collectionView)

        self.collectionView.snp.makeConstraints { make in
            make.left.right.bottom.equalTo(self.view.safeAreaLayoutGuide)
            make.top.equalTo(self.tableView.snp.bottom)
        }
    }

    private func configureOptionsTableView() {
        let tableView = UITableView()
        tableView.isScrollEnabled = false
        tableView.dataSource = self
        tableView.delegate = self
        tableView.backgroundColor = Theme.tableView.headerBackground
        tableView.separatorInset = UIEdgeInsets(top: 0, left: HomeBackgroundViewControllerUI.cellSpace, bottom: 0, right: HomeBackgroundViewControllerUI.cellSpace)
        self.view.addSubview(tableView)
        tableView.snp.makeConstraints { (make) in
            make.top.left.right.equalTo(self.view.safeAreaLayoutGuide)
            make.height.equalTo(88)
        }
        self.tableView = tableView
    }

    private func cellSize() -> CGSize {
        let rowCellCount = (UIDevice.current.isPad || self.isStatusBarOrientationLandscape) ? 4 : 3
        let cellWidth = (self.collectionView.frame.width - CGFloat(rowCellCount + 1) * HomeBackgroundViewControllerUI.cellSpace) / CGFloat(rowCellCount)
        return CGSize(width: cellWidth, height: cellWidth)
    }

}

extension HomeBackgroundViewController: UICollectionViewDataSource {
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return self.items.count
    }

    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "cell", for: indexPath) as! HomeBackgroundCell
        let item = self.items[indexPath.row]
        cell.imageView.image = item.image
        let identifier = self.profile.prefs.stringForKey(PrefsKeys.HomeBackgroundImage) ?? Features.Home.BackgroundSetting.defaultImageName
        if identifier == item.identifier {
            cell.imageView.layer.borderWidth = 3
            cell.imageView.layer.borderColor = UIColor.Grey60.cgColor
        }
        return cell
    }

}

extension HomeBackgroundViewController: UICollectionViewDelegate {

    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        let item = self.items[indexPath.row]
        self.profile.prefs.setString(item.identifier, forKey: PrefsKeys.HomeBackgroundImage)
        NotificationCenter.default.post(name: .HomeBackgroundSettingsDidChange, object: nil)
        if let completion = self.completion {
            completion()
        } else {
            self.navigationController?.popViewController(animated: true)
        }
    }

}

extension HomeBackgroundViewController: UICollectionViewDelegateFlowLayout {

    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        return self.cellSize()
    }

}

extension HomeBackgroundViewController: UITableViewDataSource {

    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return HomeBackgroundHelper.Option.allCases.count
    }

    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = ThemedTableViewCell()
        cell.selectionStyle = .none
        cell.backgroundColor = Theme.tableView.headerBackground
        let option = HomeBackgroundHelper.Option(rawValue: Int32(indexPath.row))!
        switch option {
        case .randomImage:
            cell.titleLabel.text = Strings.Settings.General.HomeBackground.RandomImageOption
        case .staticImage:
            cell.titleLabel.text = Strings.Settings.General.HomeBackground.StaticImageOption
        }
        let selectedOptionValue = self.profile.prefs.intForKey(PrefsKeys.HomeBackgroundOption) ?? 0
        let selectedOption = HomeBackgroundHelper.Option(rawValue: selectedOptionValue)!
        cell.accessoryType = selectedOption == option ? .checkmark : .none
        return cell
    }

}

extension HomeBackgroundViewController: UITableViewDelegate {

    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        let option = HomeBackgroundHelper.Option(rawValue: Int32(indexPath.row))!
        self.profile.prefs.setInt(option.rawValue, forKey: PrefsKeys.HomeBackgroundOption)
        self.tableView.reloadData()
    }
}

class HomeBackgroundCell: UICollectionViewCell {

    var imageView: UIImageView = {
        let imageView = UIImageView()
        imageView.backgroundColor = .clear
        imageView.clipsToBounds = true
        imageView.layer.cornerRadius = 15.0
        return imageView
    }()

    override init(frame: CGRect) {
        super.init(frame: frame)
        self.contentView.addSubview(self.imageView)
        self.imageView.snp.makeConstraints { (make) in
            make.edges.equalToSuperview()
        }
    }

    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

}
