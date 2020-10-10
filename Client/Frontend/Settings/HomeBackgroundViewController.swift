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

class HomeBackgroundViewController: UIViewController {

    private class Item {
        var identifier: String
        var image: UIImage

        init(identifier: String, image: UIImage) {
            self.identifier = identifier
            self.image = image
        }
    }

    var profile: Profile!

    private var collectionView: UICollectionView!
    private var items = [Item]()

    private var isStatusBarOrientationLandscape: Bool {
        return UIApplication.shared.statusBarOrientation == .landscapeLeft || UIApplication.shared.statusBarOrientation == .landscapeRight
    }

    override func viewDidLoad() {
        super.viewDidLoad()
        self.title = Strings.Settings.General.HomeBackground.SectionName
        self.view.backgroundColor = Theme.tableView.headerBackground

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
            make.edges.equalTo(self.view.safeAreaLayoutGuide)
        }
        self.collectImages()
    }

    // MARK: - Private methods

    private func cellSize() -> CGSize {
        let rowCellCount = (UIDevice.current.isPad || self.isStatusBarOrientationLandscape) ? 4 : 3
        let cellWidth = (self.collectionView.frame.width - CGFloat(rowCellCount + 1) * HomeBackgroundViewControllerUI.cellSpace) / CGFloat(rowCellCount)
        return CGSize(width: cellWidth, height: cellWidth)
    }

    private func collectImages() {
        let imageNamePrefix = Features.Home.BackgroundSetting.defaultImageName
        var imageName = imageNamePrefix
        var image = UIImage(named: imageName)
        var i = 0
        self.items.removeAll()
        while image != nil && i < 100 {
            self.items.append(Item(identifier: imageName, image: image!))
            i += 1
            imageName = imageNamePrefix + "-\(i)"
            image = UIImage(named: imageName)
        }
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
        self.navigationController?.popViewController(animated: true)
    }

}

extension HomeBackgroundViewController: UICollectionViewDelegateFlowLayout {

    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        return self.cellSize()
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
