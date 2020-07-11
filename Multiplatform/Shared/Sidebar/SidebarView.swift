//
//  SidebarView.swift
//  NetNewsWire
//
//  Created by Maurice Parker on 6/29/20.
//  Copyright © 2020 Ranchero Software. All rights reserved.
//

import SwiftUI
import Account

struct SidebarView: View {
	
	// I had to comment out SceneStorage because it blows up if used on macOS
	//	@SceneStorage("expandedContainers") private var expandedContainerData = Data()
	@StateObject private var expandedContainers = SidebarExpandedContainers()
	@EnvironmentObject private var sidebarModel: SidebarModel
	@State var navigate = false

	@ViewBuilder
	var body: some View {
		#if os(macOS)
		ZStack {
			NavigationLink(destination: TimelineContainerView(feeds: sidebarModel.selectedFeeds), isActive: $navigate) {
				EmptyView()
			}.hidden()
			List(selection: $sidebarModel.selectedFeedIdentifiers) {
				rows
			}
		}
		.onChange(of: sidebarModel.selectedFeedIdentifiers) { value in
			navigate = !sidebarModel.selectedFeedIdentifiers.isEmpty
		}
		#else
		List {
			rows
		}
		#endif
//		.onAppear {
//			expandedContainers.data = expandedContainerData
//		}
//		.onReceive(expandedContainers.objectDidChange) {
//			expandedContainerData = expandedContainers.data
//		}
	}
	
	var rows: some View {
		ForEach(sidebarModel.sidebarItems) { sidebarItem in
			if let containerID = sidebarItem.containerID {
				DisclosureGroup(isExpanded: $expandedContainers[containerID]) {
					ForEach(sidebarItem.children) { sidebarItem in
						if let containerID = sidebarItem.containerID {
							DisclosureGroup(isExpanded: $expandedContainers[containerID]) {
								ForEach(sidebarItem.children) { sidebarItem in
									buildSidebarItemNavigation(sidebarItem)
								}
							} label: {
								buildSidebarItemNavigation(sidebarItem)
							}
						} else {
							buildSidebarItemNavigation(sidebarItem)
						}
					}
				} label: {
					SidebarItemView(sidebarItem: sidebarItem)
				}
			}
		}
	}
	
	func buildSidebarItemNavigation(_ sidebarItem: SidebarItem) -> some View {
		#if os(macOS)
		return SidebarItemView(sidebarItem: sidebarItem).tag(sidebarItem.feed!.feedID!)
		#else
		return ZStack {
			SidebarItemView(sidebarItem: sidebarItem)
			NavigationLink(destination: TimelineContainerView(feeds: sidebarModel.selectedFeeds),
						   tag: sidebarItem.feed!.feedID!,
						   selection: $sidebarModel.selectedFeedIdentifier) {
				EmptyView()
			}.buttonStyle(PlainButtonStyle())
		}
		#endif
	}
	
}