//
//  Constants.swift
//  ImageFeed
//
//  Created by Сёма Шибаев on 14.06.2025.
//

import Foundation
enum Constants {
    static let accessKey = "uA54EbvlEgmjVeNGZzP00cUW0u26DtzW_RXIrkRSf4g"
    static let secretKey = "vBU2cmTlxSR7lwaSkWZzFcwMumDM1wXr_-7niYMXyf8"
    static let redirectURI = "urn:ietf:wg:oauth:2.0:oob"
    static let accessScope = "public+read_user+write_likes"
    static let defaultBaseURL = URL(string: "https://api.unsplash.com") ?? URL(string: "https://unsplash.com")!
}
