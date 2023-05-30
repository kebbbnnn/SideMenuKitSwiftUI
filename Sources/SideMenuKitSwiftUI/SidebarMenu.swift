/*
 * FILE:	SidebarMenu.swift
 * DESCRIPTION:	SideMenuKitSwiftUI: Custom Side Menu with Icon on Sidebar
 * DATE:	Tue, May 24 2022
 * UPDATED:	Mon, Jun 13 2022
 * AUTHOR:	Kouichi ABE (WALL) / 阿部康一
 * E-MAIL:	kouichi@MagickWorX.COM
 * URL:		https://www.MagickWorX.COM/
 * COPYRIGHT:	(c) 2022 阿部康一／Kouichi ABE (WALL)
 * LICENSE:	The 2-Clause BSD License (See LICENSE.txt)
 * REFERENCES:  https://medium.com/@maxnatchanon/swiftui-how-to-get-content-offset-from-scrollview-5ce1f84603ec
 */

import SwiftUI

public struct SMKSidebarMenu<Menu,Content, BottomView>: View where Menu: Hashable, Content: View, BottomView: View
{
  @State private var showsSidebar: Bool = false
  @State private var selected: Menu

  private let configuration: SMKSideMenuConfiguration
  private let menuItems: [SMKSideMenuItem<Menu>]
  private let mainContent: (Menu) -> Content
  private let bottomView: () -> BottomView

  public init(configuration: SMKSideMenuConfiguration = .sidebar, menuItems: [SMKSideMenuItem<Menu>], startItem: Menu, @ViewBuilder content: @escaping (Menu) -> Content, bottomView: @escaping () -> BottomView) {
    self._selected = State(initialValue: startItem)
    self.configuration = configuration
    self.menuItems = menuItems
    self.mainContent = content
    self.bottomView = bottomView
  }

  public var body: some View {
    SMKSidebarMenuStack(sidebarWidth: configuration.sidebarWidth, showsSidebar: $showsSidebar) {
        SidebarMenuView<Menu, BottomView>(items: menuItems, selected: $selected, showsSidebar: $showsSidebar, bottomView: self.bottomView)
        .background(configuration.backgroundColor)
    } content: {
      mainContent(selected)
    }
    .edgesIgnoringSafeArea(.all)
  }
}

// MARK: - Preview
struct SidebarMenu_Previews: PreviewProvider
{
  enum Menu: Int, Hashable
  {
    case fine
    case cloudy
    case rainy
    case snow
    case bolt
    case wind
    case tornado
  }

  static private let items: [SMKSideMenuItem<Menu>] = [
    (title: "晴れ", icon: "sun.max.fill",  tag: Menu.fine,    color: Color.orange),
    (title: "曇り", icon: "cloud.fill",    tag: Menu.cloudy,  color: Color.gray),
    (title: "雨",   icon: "umbrella.fill", tag: Menu.rainy,   color: Color.blue),
    (title: "雪",   icon: "snowflake",     tag: Menu.snow,    color: Color.cyan),
    (title: "雷",   icon: "bolt.fill",     tag: Menu.bolt,    color: Color.yellow),
    (title: "風",   icon: "wind",          tag: Menu.wind,    color: Color.green),
    (title: "竜巻", icon: "tornado",       tag: Menu.tornado, color: Color.indigo)
  ].map({ SMKSideMenuItem<Menu>(title: $0.title, icon: $0.icon, tag: $0.tag, color: $0.color) })

  static var previews: some View {
    SMKSidebarMenu<Menu,ContentView, BottomView>(menuItems: items, startItem: .fine) {
      (menu) -> ContentView in
      ContentView(selected: menu, items: items)
    } bottomView: {
        BottomView()
    }
  }
    
  struct BottomView: View {
      var body: some View {
          ZStack {
              Text("TEST")
          }
      }
  }

  struct ContentView: View
  {
    private let menu: Menu
    private let item: SMKSideMenuItem<Menu>

    init(selected menu: Menu, items: [SMKSideMenuItem<Menu>]) {
      self.menu = menu
      self.item = items.filter({ $0.tag == menu })[0]
    }

    @ViewBuilder
    var body: some View {
      VStack {
        Spacer()
        item.icon.resizable()
          .aspectRatio(contentMode: .fit)
          .foregroundColor(.white)
          .frame(width: 192, height: 192)
        Spacer()
      }
      .navigationTitle("\(item.title)")
      .frame(maxWidth: .infinity, alignment: .center)
      .background(item.color)
    }
  }
}
