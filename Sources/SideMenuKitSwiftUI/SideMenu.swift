/*
 * FILE:	SideMenu.swift
 * DESCRIPTION:	SideMenuKitSwiftUI: Primitive Container for SideMenu
 * DATE:	Fri, May 27 2022
 * UPDATED:	Mon, Nov 21 2022
 * AUTHOR:	Kouichi ABE (WALL) / 阿部康一
 * E-MAIL:	kouichi@MagickWorX.COM
 * URL:		https://www.MagickWorX.COM/
 * COPYRIGHT:	(c) 2022 阿部康一／Kouichi ABE (WALL)
 * LICENSE:	The 2-Clause BSD License (See LICENSE.txt)
 */

import SwiftUI

public struct SMKSideMenu<Menu,Content, BottomView>: View where Menu: Hashable, Content: View, BottomView: View
{
  @State private var showsSidebar: Bool = false
  @State private var selected: Menu

  private let configuration: SMKSideMenuConfiguration
  private let menuItems: [SMKSideMenuItem<Menu>]
  private let mainContent: (Menu) -> Content
  private let bottomView: () -> BottomView

  public init(configuration: SMKSideMenuConfiguration, menuItems: [SMKSideMenuItem<Menu>], startItem: Menu, @ViewBuilder content: @escaping (Menu) -> Content, bottomView: @escaping () -> BottomView) {
    self._selected = State(initialValue: startItem)
    self.configuration = configuration
    self.menuItems = menuItems
    self.mainContent = content
    self.bottomView = bottomView
  }

  private var _navigationPath: Any?
  @available(iOS 16.0, *)
  private var navigationPath: Binding<NavigationPath> {
    get {
      return _navigationPath as! Binding<NavigationPath>
    }
    set {
      _navigationPath = newValue
    }
  }

  @available(iOS 16.0, *)
  public init(navigationPath: Binding<NavigationPath>, configuration: SMKSideMenuConfiguration, menuItems: [SMKSideMenuItem<Menu>], startItem: Menu, @ViewBuilder content: @escaping (Menu) -> Content, bottomView: @escaping () -> BottomView) {
    self._selected = State(initialValue: startItem)
    self.configuration = configuration
    self.menuItems = menuItems
    self.mainContent = content
    self.bottomView = bottomView
    self.navigationPath = navigationPath // XXX: Assign Last
  }

  public var body: some View {
    Group {
      if configuration.menuStyle == .sidebar {
        if #available(iOS 16.0, *) {
          SMKSidebarMenuStack(navigationPath: navigationPath, sidebarWidth: configuration.sidebarWidth, showsSidebar: $showsSidebar) {
              SidebarMenuView<Menu, BottomView>(items: menuItems, selected: $selected, showsSidebar: $showsSidebar, bottomView: self.bottomView)
              .background(configuration.backgroundColor)
          } content: {
            mainContent(selected)
          }
        }
        else {
          SMKSidebarMenuStack(sidebarWidth: configuration.sidebarWidth, showsSidebar: $showsSidebar) {
              SidebarMenuView<Menu, BottomView>(items: menuItems, selected: $selected, showsSidebar: $showsSidebar, bottomView: self.bottomView)
            .background(configuration.backgroundColor)
          } content: {
            mainContent(selected)
          }
        }
      }
      else {
        if #available(iOS 16.0, *) {
          SMKSlideMenuStack(navigationPath: navigationPath, sidebarWidth: configuration.sidebarWidth, showsSidebar: $showsSidebar) {
            SlideMenuView<Menu, BottomView>(items: menuItems, selected: $selected, showsSidebar: $showsSidebar, configuration: configuration, bottomView: self.bottomView)
              .background(configuration.backgroundColor)
          } content: {
            mainContent(selected)
          }
        }
        else {
          SMKSlideMenuStack(sidebarWidth: configuration.sidebarWidth, showsSidebar: $showsSidebar) {
            SlideMenuView<Menu, BottomView>(items: menuItems, selected: $selected, showsSidebar: $showsSidebar, configuration: configuration, bottomView: self.bottomView)
              .background(configuration.backgroundColor)
          } content: {
            mainContent(selected)
          }
        }
      }
    }
    .edgesIgnoringSafeArea(.all)
  }
}

// MARK: - Preview
struct SideMenu_Previews: PreviewProvider
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

#if true
  static private let configuration: SMKSideMenuConfiguration = .slide
#else
  static private let configuration: SMKSideMenuConfiguration = .sidebar
#endif

  static var previews: some View {
    SMKSideMenu<Menu,ContentView, BottomView>(configuration: configuration, menuItems: items, startItem: .fine) {
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
    @State private var showsAlert: Bool = false
    @State private var message: String = ""

    private let menu: Menu
    private let item: SMKSideMenuItem<Menu>

    init(selected menu: Menu, items: [SMKSideMenuItem<Menu>]) {
      self.menu = menu
      self.item = items.filter({ $0.tag == menu })[0]
    }

    @ViewBuilder
    var body: some View {
      VStack {
        item.icon.resizable()
          .aspectRatio(contentMode: .fit)
          .foregroundColor(.white)
          .frame(width: 192, height: 192)
          .gesture(tap)
        Text("明日の天気は「\(item.title)」でしょう").font(.title)
        Spacer()
      }
      .navigationTitle("天気予報：\(item.title)")
      .frame(maxWidth: .infinity, alignment: .center)
      .background(item.color)
      .alert(message, isPresented: $showsAlert) {
        Button("OK") {}
      }
    }

    private var tap: some Gesture {
      TapGesture()
        .onEnded { _ in
          self.message = {
            switch self.menu {
              case .fine:    return "熱中症に注意"
              case .cloudy:  return "曇天に舞う"
              case .rainy:   return "傘を忘れずに"
              case .snow:    return "雪だるまを作ろう！"
              case .bolt:    return "ピカチュウ！"
              case .wind:    return "電車の遅延と運休に注意"
              case .tornado: return "コロッケを買いに行くのだ！"
            }
          }()
          self.showsAlert.toggle()
        }
    }
  }
}
