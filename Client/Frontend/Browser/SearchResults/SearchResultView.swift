//
// Copyright (c) 2017-2020 Cliqz GmbH. All rights reserved.
//
// This Source Code Form is subject to the terms of the Mozilla Public
// License, v. 2.0. If a copy of the MPL was not distributed with this
// file, You can obtain one at https://mozilla.org/MPL/2.0/.
//

import UIKit

class SearchResult {

    enum ResultType: Int {
        case suggestion = 0
        case navigation
    }

    let type: ResultType
    let query: String
    let title: String
    let url: URL
    let description: String?
    let imageURL: String?
    let impressionURL: String?

    init(type: ResultType, query: String, title: String, url: URL, description: String? = nil, imageURL: String? = nil, impressionURL: String? = nil) {
        self.type = type
        self.query = query
        self.title = title
        self.description = description
        self.url = url
        self.imageURL = imageURL
        self.impressionURL = impressionURL
    }

}

private struct SearchResultViewUI {
    static let SuggestionCellHeight: CGFloat = 40.0
    static let NavigationCellHeight: CGFloat = 60.0
}

protocol SearchResultViewDelegate: class {
    func didSelect(result: SearchResult)
    func didLongPress(result: SearchResult)
    func didShow(result: SearchResult)
}

class SearchResultView: UIView {

    private let tableView = UITableView(frame: .zero, style: .plain)

    weak var delegate: SearchResultViewDelegate?

    var results: [[SearchResult]]! {
        didSet {
            self.tableView.reloadData()
            var height: CGFloat = 0.0
            for subResults in (self.results ?? []) {
                for result in subResults {
                    switch result.type {
                    case .suggestion:
                        height += SearchResultViewUI.SuggestionCellHeight
                    case .navigation:
                        height += SearchResultViewUI.NavigationCellHeight
                    }
                }
            }
            let offset = height == 0 ? 0 : UIConstants.TopToolbarHeight / 2
            self.tableView.snp.updateConstraints { (make) in
                make.top.equalToSuperview().offset(offset)
                make.height.equalTo(height).priority(.medium)
            }
        }
    }

    init() {
        super.init(frame: .zero)
        self.backgroundColor = Theme.browser.homeBackground
        self.clipsToBounds = true
        self.configureTableView()
        self.roundBottomCorners()
    }

    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    func clear() {
        self.results?.removeAll()
        self.tableView.reloadData()
        self.tableView.snp.updateConstraints { (make) in
            make.top.equalToSuperview()
            make.height.equalTo(0).priority(.medium)
        }
    }

    // MARK: - Private methods

    private func configureTableView() {
        self.addSubview(self.tableView)
        self.tableView.snp.makeConstraints { (make) in
            make.top.equalToSuperview()
            make.left.right.equalToSuperview()
            make.bottom.equalToSuperview().offset(-10)
            make.height.equalTo(0).priority(.medium)
        }
        self.tableView.keyboardDismissMode = .onDrag
        self.tableView.backgroundColor = .clear
        self.tableView.delegate = self
        self.tableView.dataSource = self
        self.tableView.tableFooterView = UIView()
        self.tableView.separatorStyle = .none
    }

    private func roundBottomCorners() {
        self.layer.maskedCorners = [.layerMinXMaxYCorner, .layerMaxXMaxYCorner]
        self.layer.cornerRadius = UIConstants.TopToolbarHeight / 2
    }
}

extension SearchResultView: UITableViewDataSource {

    func numberOfSections(in tableView: UITableView) -> Int {
        return self.results?.count ?? 0
    }

    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return self.results[section].count
    }

    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let result = self.results[indexPath.section][indexPath.row]
        switch result.type {
        case .suggestion:
            let cell = SearchResultSuggestionCell(style: .default, reuseIdentifier: "aaa")
            cell.title = result.title
            return cell
        case .navigation:
            let cell = SearchResultNavigationCell(style: .default, reuseIdentifier: "aaa")
            cell.result = result
            cell.delegate = self
            self.delegate?.didShow(result: result)
            return cell
        }
    }

}

extension SearchResultView: UITableViewDelegate {

    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        let result = self.results[indexPath.section][indexPath.row]
        switch result.type {
        case .suggestion:
            return SearchResultViewUI.SuggestionCellHeight
        case .navigation:
            return SearchResultViewUI.NavigationCellHeight
        }
    }

    func tableView(_ tableView: UITableView, heightForFooterInSection section: Int) -> CGFloat {
        guard section < self.results.count - 1 && !self.results[section].isEmpty else {
            return 0.0
        }
        return 1.0
    }

    func tableView(_ tableView: UITableView, viewForFooterInSection section: Int) -> UIView? {
        guard section < self.results.count - 1 && !self.results[section].isEmpty else {
            return nil
        }
        let view = UIView()
        view.backgroundColor = Theme.tableView.separator
        return view
    }

    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        tableView.deselectRow(at: indexPath, animated: true)
        let result = self.results[indexPath.section][indexPath.row]
        self.delegate?.didSelect(result: result)
    }

}

extension SearchResultView: SearchResultNavigationCellDelegate {

    func didLongPress(result: SearchResult) {
        self.delegate?.didLongPress(result: result)
    }

}
