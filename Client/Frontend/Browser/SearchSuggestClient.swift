/* This Source Code Form is subject to the terms of the Mozilla Public
 * License, v. 2.0. If a copy of the MPL was not distributed with this
 * file, You can obtain one at http://mozilla.org/MPL/2.0/. */

import Foundation
import Shared
import SwiftyJSON

let SearchSuggestClientErrorDomain = "org.mozilla.firefox.SearchSuggestClient"
let SearchSuggestClientErrorInvalidEngine = 0
let SearchSuggestClientErrorInvalidResponse = 1

/*
 * Clients of SearchSuggestionClient should retain the object during the
 * lifetime of the search suggestion query, as requests are canceled during destruction.
 *
 * Query callbacks that must run even if they are cancelled should wrap their contents in `withExtendendLifetime`.
 */
class SearchSuggestClient {
    fileprivate let searchEngine: OpenSearchEngine
    fileprivate let userAgent: String
    fileprivate var task: URLSessionTask?

    lazy fileprivate var urlSession: URLSession = makeURLSession(userAgent: self.userAgent, configuration: URLSessionConfiguration.ephemeral)

    init(searchEngine: OpenSearchEngine, userAgent: String) {
        self.searchEngine = searchEngine
        self.userAgent = userAgent
    }

    func requestImpression(urlString: String?) {
        guard let urlString = urlString, let url = URL(string: urlString) else {
            return
        }
        self.urlSession.dataTask(with: url).resume()
    }

    func query(_ query: String, callback: @escaping (_ response: (suggestions: [String], navigations: [[String: Any]])?, _ error: NSError?) -> Void) {
        let url = searchEngine.suggestURLForQuery(query)
        if url == nil {
            let error = NSError(domain: SearchSuggestClientErrorDomain, code: SearchSuggestClientErrorInvalidEngine, userInfo: nil)
            callback(nil, error)
            return
        }

        task = urlSession.dataTask(with: url!) { (data, response, error) in
            if let error = error {
                callback(nil, error as NSError?)
                return
            }

            guard let data = data, let _ = validatedHTTPResponse(response, statusCode: 200..<300) else {
                let error = NSError(domain: SearchSuggestClientErrorDomain, code: SearchSuggestClientErrorInvalidResponse, userInfo: nil)
                callback(nil, error as NSError?)
                return
            }

            let json = JSON(data)
            let dict = json.dictionaryObject
            let array = dict?["results"] as? [[String: Any]]
            let mappedQueries = array?.compactMap({ (dict) -> String? in
                guard let type = dict["type"] as? String, let query = dict["q"] as? String else {
                    return nil
                }
                if type == "QUERY" && !query.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty {
                    return query
                }
                return nil
            }) ?? []
            let mappedNavigations = array?.compactMap({ (dict) -> [String: Any]? in
                guard let type = dict["type"] as? String else {
                    return nil
                }
                if type == "NAVIGATION" {
                    return dict
                }
                return nil
            }) ?? []
            callback((mappedQueries, mappedNavigations), nil)
        }
        task?.resume()
    }

    /*func query(_ query: String, callback: @escaping (_ response: [String]?, _ error: NSError?) -> Void) {
        let url = searchEngine.suggestURLForQuery(query)
        if url == nil {
            let error = NSError(domain: SearchSuggestClientErrorDomain, code: SearchSuggestClientErrorInvalidEngine, userInfo: nil)
            callback(nil, error)
            return
        }

        task = urlSession.dataTask(with: url!) { (data, response, error) in
            if let error = error {
                callback(nil, error as NSError?)
                return
            }

            guard let data = data, let _ = validatedHTTPResponse(response, statusCode: 200..<300) else {
                let error = NSError(domain: SearchSuggestClientErrorDomain, code: SearchSuggestClientErrorInvalidResponse, userInfo: nil)
                callback(nil, error as NSError?)
                return
            }

            let json = JSON(data)
            let array = json.arrayObject

            // The response will be of the following format:
            //    ["foobar",["foobar","foobar2000 mac","foobar skins",...]]
            // That is, an array of at least two elements: the search term and an array of suggestions.

            if array?.count ?? 0 < 2 {
                let error = NSError(domain: SearchSuggestClientErrorDomain, code: SearchSuggestClientErrorInvalidResponse, userInfo: nil)
                callback(nil, error)
                return
            }

            guard let suggestions = array?[1] as? [String] else {
                let error = NSError(domain: SearchSuggestClientErrorDomain, code: SearchSuggestClientErrorInvalidResponse, userInfo: nil)
                callback(nil, error)
                return
            }

            callback(suggestions, nil)
        }
        task?.resume()
    }*/

    func cancelPendingRequest() {
        task?.cancel()
    }
}
