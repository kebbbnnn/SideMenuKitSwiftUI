/*
 * FILE:	SidebarMenuView.swift
 * DESCRIPTION:	SideMenuKitSwiftUI: Manage the Menus on Sidebar
 * DATE:	Tue, May 24 2022
 * UPDATED:	Mon, Jun 13 2022
 * AUTHOR:	Kouichi ABE (WALL) / 阿部康一
 * E-MAIL:	kouichi@MagickWorX.COM
 * URL:		https://www.MagickWorX.COM/
 * COPYRIGHT:	(c) 2022 阿部康一／Kouichi ABE (WALL)
 * LICENSE:	The 2-Clause BSD License (See LICENSE.txt)
 */

import SwiftUI

struct SidebarMenuView<Menu, BottomView>: View where Menu: Hashable, BottomView: View
{
  private let items: [SMKSideMenuItem<Menu>]

  @Binding private var selected: Menu
  @Binding private var showsSidebar: Bool
    
  private let bottomView: () -> BottomView

  init(items: [SMKSideMenuItem<Menu>], selected: Binding<Menu>, showsSidebar: Binding<Bool>, bottomView: @escaping () -> BottomView) {
    self.items = items
    self._selected = selected
    self._showsSidebar = showsSidebar
    self.bottomView = bottomView
  }

  @ViewBuilder
  var body: some View {
      GeometryReader { geo in
          ScrollView(showsIndicators: false) {
              VStack {
                  ForEach(items) { item in
                      SidebarMenuItem(item, selected: $selected, showsSidebar: $showsSidebar)
                  }
                  
                  Spacer()
                  
                  self.bottomView()
              }
              .frame(height: geo.size.height - 70)
          }
          .padding(.top, 70.0)
          .edgesIgnoringSafeArea(.all)
      }
  }
}
