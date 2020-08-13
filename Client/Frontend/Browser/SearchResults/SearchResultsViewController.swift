//
// Copyright (c) 2017-2020 Cliqz GmbH. All rights reserved.
//
// This Source Code Form is subject to the terms of the Mozilla Public
// License, v. 2.0. If a copy of the MPL was not distributed with this
// file, You can obtain one at https://mozilla.org/MPL/2.0/.
//

import UIKit
import Storage
import Shared

class SearchResultsViewController: UIViewController {
    public var isLastCharacterRemoved = false

    // MARK: Properties
    public private(set) var cache = [String: [[SearchResult]]]()
    public private(set) var lastQuery: String = ""

    public var searchQuery: String = "" {
        didSet {
            guard !self.searchQuery.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty else {
                self.clear()
                return
            }
            let lastStringLength = self.lastQuery.count
            if lastStringLength - self.searchQuery.count == 1 {
                self.isLastCharacterRemoved = true
                self.cache.removeValue(forKey: self.lastQuery)
                if let results = self.cache[self.searchQuery] {
                    self.searchView.results = results
                } else {
                    self.searchQuery(self.searchQuery)
                }
            } else if self.searchQuery.count > lastStringLength {
                self.isLastCharacterRemoved = false
                self.searchQuery(self.searchQuery)
            }
            self.lastQuery = self.searchQuery
        }
    }

    public let searchView = SearchResultView()

    private let profile: Profile
    private let useCases: UseCases
    private let suggestClient: SearchSuggestClient

    // MARK: - Initialization
    init(profile: Profile, useCases: UseCases) {
        self.profile = profile
        self.useCases = useCases
        let engine = self.profile.searchEngines.defaultEngine
        let ua = UserAgent.desktopUserAgent()
        self.suggestClient = SearchSuggestClient(searchEngine: engine, userAgent: ua)
        super.init(nibName: nil, bundle: nil)
    }

    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    // MARK: - View Lifecycle
    override func viewDidLoad() {
        super.viewDidLoad()
        self.searchView.delegate = self
        self.view.addSubview(self.searchView)
        self.applyTheme()
    }

    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        self.clear()
    }

    // MARK: - Public API
    func handleKeyCommands(sender: UIKeyCommand) {}

    // MARK: - Private methods

    private func searchQuery(_ query: String) {
        self.suggestClient.query(query as String) { (result, error) in
            guard let result = result else {
                self.searchView.clear()
                return
            }
            let navigations = result.navigations.compactMap { (dict) -> SearchResult? in
                guard
                    let title = dict["title"] as? String,
                    let desc = dict["q"] as? String,
                    let urlString = dict["url"] as? String,
                    let url = URL(string: urlString),
                    let imageURL = dict["image"] as? String,
                    let impressionURL = dict["impression"] as? String else {
                    return nil
                }
                let fixedDesc = desc.replaceFirstOccurrence(of: "!", with: "")
                return SearchResult(type: .navigation, query: query, title: title, url: url, description: fixedDesc, imageURL: imageURL, impressionURL: impressionURL)
            }
            let suggestions = result.suggestions.compactMap { (query) -> SearchResult? in
                guard let url = self.profile.searchEngines.defaultEngine.searchURLForQuery(query) else {
                    return nil
                }
                return SearchResult(type: .suggestion, query: query, title: query, url: url)
            }
            var results = [[SearchResult]]()
            if !navigations.isEmpty {
                results.append(navigations)
            }
            if !suggestions.isEmpty {
                results.append(suggestions)
            }
            self.cache[query] = results
            self.searchView.results = results
        }
    }

    private func clear() {
        self.lastQuery = ""
        self.cache.removeAll()
        self.searchView.clear()
    }
}

// MARK: - Themeable
extension SearchResultsViewController: Themeable {
    func applyTheme() {
        self.view.backgroundColor = UIColor.clear
    }
}

// MARK: - Private API
extension SearchResultsViewController: BrowserCoreClient {
    func reportSelection(query: String, url: URL, completion: String?, isForgetMode: Bool) {}
}

extension SearchResultsViewController: SearchResultViewDelegate {

    func didSelect(result: SearchResult) {
        self.useCases.openLink.openLink(urlString: result.url.absoluteString, query: result.query)
    }

    func didLongPress(result: SearchResult) {
    }

    func didShow(result: SearchResult) {
        self.suggestClient.requestImpression(urlString: result.impressionURL)
    }

}
