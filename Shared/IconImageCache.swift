//
//  IconImageCache.swift
//  NetNewsWire-iOS
//
//  Created by Brent Simmons on 5/2/21.
//  Copyright © 2021 Ranchero Software. All rights reserved.
//

import Foundation
import Account
import Articles

class IconImageCache {

	static var shared = IconImageCache()

	private var smartFeedIconImageCache = [ItemIdentifier: IconImage]()
	private var webFeedIconImageCache = [ItemIdentifier: IconImage]()
	private var faviconImageCache = [ItemIdentifier: IconImage]()
	private var smallIconImageCache = [ItemIdentifier: IconImage]()
	private var authorIconImageCache = [Author: IconImage]()

	func imageFor(_ itemID: ItemIdentifier) -> IconImage? {
		if let smartFeed = SmartFeedsController.shared.find(by: itemID) {
			return imageForFeed(smartFeed)
		}
		if let feed = AccountManager.shared.existingFeed(with: itemID) {
			return imageForFeed(feed)
		}
		return nil
	}

	func imageForFeed(_ feed: FeedProtocol) -> IconImage? {
		guard let itemID = feed.itemID else {
			return nil
		}
		
		if let smartFeed = feed as? PseudoFeed {
			return imageForSmartFeed(smartFeed, itemID)
		}
		if let webFeed = feed as? Feed, let iconImage = imageForWebFeed(webFeed, itemID) {
			return iconImage
		}
		if let smallIconProvider = feed as? SmallIconProvider {
			return imageForSmallIconProvider(smallIconProvider, itemID)
		}

		return nil
	}

	func imageForArticle(_ article: Article) -> IconImage? {
		if let iconImage = imageForAuthors(article.authors) {
			return iconImage
		}
		guard let feed = article.feed else {
			return nil
		}
		return imageForFeed(feed)
	}

	func emptyCache() {
		smartFeedIconImageCache = [ItemIdentifier: IconImage]()
		webFeedIconImageCache = [ItemIdentifier: IconImage]()
		faviconImageCache = [ItemIdentifier: IconImage]()
		smallIconImageCache = [ItemIdentifier: IconImage]()
		authorIconImageCache = [Author: IconImage]()
	}
}

private extension IconImageCache {
	
	func imageForSmartFeed(_ smartFeed: PseudoFeed, _ itemID: ItemIdentifier) -> IconImage? {
		if let iconImage = smartFeedIconImageCache[itemID] {
			return iconImage
		}
		if let iconImage = smartFeed.smallIcon {
			smartFeedIconImageCache[itemID] = iconImage
			return iconImage
		}
		return nil
	}

	func imageForWebFeed(_ webFeed: Feed, _ itemID: ItemIdentifier) -> IconImage? {
		if let iconImage = webFeedIconImageCache[itemID] {
			return iconImage
		}
		if let iconImage = appDelegate.webFeedIconDownloader.icon(for: webFeed) {
			webFeedIconImageCache[itemID] = iconImage
			return iconImage
		}
		if let faviconImage = faviconImageCache[itemID] {
			return faviconImage
		}
		if let faviconImage = appDelegate.faviconDownloader.faviconAsIcon(for: webFeed) {
			faviconImageCache[itemID] = faviconImage
			return faviconImage
		}
		return nil
	}

	func imageForSmallIconProvider(_ provider: SmallIconProvider, _ itemID: ItemIdentifier) -> IconImage? {
		if let iconImage = smallIconImageCache[itemID] {
			return iconImage
		}
		if let iconImage = provider.smallIcon {
			smallIconImageCache[itemID] = iconImage
			return iconImage
		}
		return nil
	}

	func imageForAuthors(_ authors: Set<Author>?) -> IconImage? {
		guard let authors = authors, authors.count == 1, let author = authors.first else {
			return nil
		}
		return imageForAuthor(author)
	}

	func imageForAuthor(_ author: Author) -> IconImage? {
		if let iconImage = authorIconImageCache[author] {
			return iconImage
		}
		if let iconImage = appDelegate.authorAvatarDownloader.image(for: author) {
			authorIconImageCache[author] = iconImage
			return iconImage
		}
		return nil
	}
}
