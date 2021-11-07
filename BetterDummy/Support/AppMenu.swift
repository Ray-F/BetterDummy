//
//  menuHandler.swift
//  BetterDummy
//
//  Created by @waydabber
//

import AppKit
import os.log

class AppMenu {
  let appMenu = NSMenu()
  var statusBarItem: NSStatusItem!
  let manageMenu = NSMenu()
  let manageSubmenu = NSMenuItem(title: "Manage dummies", action: nil, keyEquivalent: "")
  let startAtLoginMenuItem = NSMenuItem(title: "Start at login", action: #selector(app.handleStartAtLogin(_:)), keyEquivalent: "")
  let automaticallyCheckForUpdatesMenuItem = NSMenuItem(title: "Automatically check for updates", action: #selector(app.handleSimpleCheckMenu(_:)), keyEquivalent: "")
  let enable16KMenuItem = NSMenuItem(title: "Enable up to 16K resolutions", action: #selector(app.handleEnable16K(_:)), keyEquivalent: "")
  let reconnectAfterSleepMenuItem = NSMenuItem(title: "Disconnect and reconnect on sleep", action: #selector(app.handleSimpleCheckMenu(_:)), keyEquivalent: "")
  let useTempSleepMenuItem = NSMenuItem(title: "Use mirrored dummy sleep workaround", action: #selector(app.handleSimpleCheckMenu(_:)), keyEquivalent: "")

  @available(macOS, deprecated: 10.10)
  func setupMenu() {
    let newMenu = NSMenu()
    let newSubmenu = NSMenuItem(title: "Create new dummy", action: nil, keyEquivalent: "")
    newSubmenu.submenu = newMenu
    self.manageSubmenu.submenu = self.manageMenu
    self.manageSubmenu.isHidden = true
    let settingsMenu = NSMenu()
    settingsMenu.addItem(self.startAtLoginMenuItem)
    settingsMenu.addItem(self.automaticallyCheckForUpdatesMenuItem)
    settingsMenu.addItem(NSMenuItem.separator())
    settingsMenu.addItem(self.enable16KMenuItem)
    settingsMenu.addItem(NSMenuItem.separator())
    settingsMenu.addItem(self.useTempSleepMenuItem)
    settingsMenu.addItem(self.reconnectAfterSleepMenuItem)
    settingsMenu.addItem(NSMenuItem.separator())
    settingsMenu.addItem(NSMenuItem(title: "Reset BetterDummy", action: #selector(app.handleReset(_:)), keyEquivalent: ""))
    let settingsSubmenu = NSMenuItem(title: "Settings", action: nil, keyEquivalent: "")
    settingsSubmenu.submenu = settingsMenu
    self.appMenu.addItem(newSubmenu)
    self.appMenu.addItem(self.manageSubmenu)
    self.appMenu.addItem(NSMenuItem.separator())
    self.appMenu.addItem(settingsSubmenu)
    let updateItem = NSMenuItem(title: "Check for updates...", action: #selector(app.updaterController.checkForUpdates(_:)), keyEquivalent: "")
    updateItem.target = app.updaterController
    self.appMenu.addItem(updateItem)
    self.appMenu.addItem(NSMenuItem(title: "About BetterDummy (RF)", action: #selector(app.handleAbout(_:)), keyEquivalent: ""))
    self.appMenu.addItem(NSMenuItem(title: "Support the project...", action: #selector(app.handleDonate(_:)), keyEquivalent: ""))
    self.addCreateAllMenuItem()
    self.appMenu.addItem(NSMenuItem.separator())
    self.appMenu.addItem(NSMenuItem(title: "Quit BetterDummy", action: #selector(NSApplication.terminate(_:)), keyEquivalent: "q"))
    self.populateNewMenu(newMenu)
    self.statusBarItem = NSStatusBar.system.statusItem(withLength: CGFloat(NSStatusItem.variableLength))
    if let button = self.statusBarItem.button {
      button.image = NSImage(named: "status")
    }
    self.statusBarItem.menu = self.appMenu
  }

  func populateNewMenu(_ newMenu: NSMenu) {
    for key in DummyManager.dummyDefinitions.keys.sorted() {
      if let dummyDefinition = DummyManager.dummyDefinitions[key] {
        let item = NSMenuItem(title: "\(dummyDefinition.description)", action: #selector(app.handleCreateDummy(_:)), keyEquivalent: "")
        item.tag = key
        newMenu.addItem(item)
        if dummyDefinition.addSeparatorAfter {
          newMenu.addItem(NSMenuItem.separator())
        }
      }
    }
    os_log("New dummy menu populated.", type: .info)
  }

  func emptyManageMenu() {
    var items: [NSMenuItem] = []
    for i in 0 ..< self.manageMenu.items.count {
      items.append(self.manageMenu.items[i])
    }
    for item in items {
      self.manageMenu.removeItem(item)
    }
  }

  func repopulateManageMenu() {
    self.emptyManageMenu()
    var first = true
    for key in DummyManager.dummies.keys.sorted(by: <) {
      if let dummy = DummyManager.dummies[key] {
        if !first {
          self.manageMenu.addItem(NSMenuItem.separator())
        }
        self.addDummyToManageMenu(dummy)
        first = false
      }
    }
  }
  
  func addCreateAllMenuItem() {
    let allHeaderItem = NSMenuItem()
    let attrsHeader: [NSAttributedString.Key: Any] = [.foregroundColor: NSColor.headerTextColor, .font: NSFont.boldSystemFont(ofSize: 13)]
    allHeaderItem.attributedTitle = NSAttributedString(string: "Manage all dummies", attributes: attrsHeader)
    
    let disconnect = NSMenuItem(title: "Disconnect all dummies", action: #selector(app.handleDisconnectAllDummy(_:)), keyEquivalent: "")
    let connect = NSMenuItem(title: "Connect all dummies", action: #selector(app.handleConnectAllDummy(_:)), keyEquivalent: "")
    
    self.appMenu.addItem(NSMenuItem.separator())
    self.appMenu.addItem(disconnect)
    self.appMenu.addItem(connect)
  }

  func getResolutionSubmenuItem(_ dummy: Dummy) -> NSMenuItem {
    let resolutionMenu = NSMenu()
    // TODO: Implement resolution submenu
    _ = dummy.getResolutionList()
    resolutionMenu.addItem(NSMenuItem(title: "Under construction", action: nil, keyEquivalent: ""))
    let resolutionSubmenu = NSMenuItem(title: "Set Resolution", action: nil, keyEquivalent: "")
    resolutionSubmenu.submenu = resolutionMenu
    return resolutionSubmenu
  }

  func getAssociateSubmenuItem(_ dummy: Dummy) -> NSMenuItem {
    let associateMenu = NSMenu()
    for display in DisplayManager.getAllDisplays() where !display.isDummy {
      var displayItem: NSMenuItem
      displayItem = NSMenuItem(title: display.name, action: #selector(app.handleAssociate(_:)), keyEquivalent: "")
      displayItem.tag = dummy.number // TODO: We need to devise a tag that signifies both the dummy and the display in question (like dummy.number*256+display.number)
      associateMenu.addItem(displayItem)
    }
    let associateSubmenu = NSMenuItem(title: "Associate Display", action: nil, keyEquivalent: "")
    associateSubmenu.submenu = associateMenu
    return associateSubmenu
  }

  func addDummyToManageMenu(_ dummy: Dummy) {
    let dummyHeaderItem = NSMenuItem()
    let attrsHeader: [NSAttributedString.Key: Any] = [.foregroundColor: NSColor.headerTextColor, .font: NSFont.boldSystemFont(ofSize: 13)]
    dummyHeaderItem.attributedTitle = NSAttributedString(string: "\(dummy.getMenuItemTitle())", attributes: attrsHeader)
    self.manageMenu.addItem(dummyHeaderItem)
    if dummy.isConnected {
      var connectItem: NSMenuItem
      connectItem = NSMenuItem(title: "Disconnect dummy", action: #selector(app.handleDisconnectDummy(_:)), keyEquivalent: "")
      self.manageMenu.addItem(connectItem)
      connectItem.tag = dummy.number
      // self.manageMenu.addItem(self.getResolutionSubmenuItem(dummy))
      self.manageMenu.addItem(self.getAssociateSubmenuItem(dummy))
    } else {
      var disconnectItem: NSMenuItem
      disconnectItem = NSMenuItem(title: "Connect dummy", action: #selector(app.handleConnectDummy(_:)), keyEquivalent: "")
      self.manageMenu.addItem(disconnectItem)
      disconnectItem.tag = dummy.number
    }
    let deleteItem = NSMenuItem(title: "Discard dummy", action: #selector(app.handleDiscardDummy(_:)), keyEquivalent: "")
    deleteItem.tag = dummy.number
    self.manageMenu.addItem(deleteItem)
    self.manageSubmenu.isHidden = false
  }
}
