//
//  RecentFetchResult.swift
//  Saikou Beta
//
//  Created by Inumaki on 27.02.23.
//

import Foundation

enum RecentFetchResult {
    case success(data: RecentResults)
    case failure(error: AnilistFetchError)
}
