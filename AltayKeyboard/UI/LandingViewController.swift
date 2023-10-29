//
//  KeySetFactory.swift
//  ibepo
//  Komikeyboard
//
//  Created by Steve Gigou on 2020-05-04.
//  Edited by Aleksei Ivanov on 2020-10-17
//  Copyright © 2020 Novesoft. All rights reserved.
//  Copyright © 2020 majbyr.com. All rights reserved.
//

import UIKit

class LandingViewController: UITableViewController {

  enum Sections: Int, CaseIterable {
    case tools, help, links, contact
  }

  // MARK: Life cycle

  override func viewDidLoad() {
    super.viewDidLoad()
    tableView.tableHeaderView = Bundle.main.loadNibNamed("LandingHeaderView", owner: nil, options: nil)?.first as? UIView
    let backButton = UIBarButtonItem()
    backButton.title = ""
    self.navigationController?.navigationBar.topItem?.backBarButtonItem = backButton
  }

  override func viewWillAppear(_ animated: Bool) {
    super.viewWillAppear(true)
    navigationController?.setNavigationBarHidden(true, animated: animated)
  }

  override func viewWillDisappear(_ animated: Bool) {
    super.viewWillDisappear(animated)
    navigationController?.setNavigationBarHidden(false, animated: animated)
  }

  // MARK: Table view data source

  override func numberOfSections(in tableView: UITableView) -> Int {
    return Sections.allCases.count
  }

  override func tableView(_ tableView: UITableView, titleForHeaderInSection section: Int) -> String? {
    switch section {
    case Sections.tools.rawValue: return "Настройка"
    case Sections.help.rawValue: return "Помощь"
    case Sections.links.rawValue: return "Полезные ссылки"
    case Sections.contact.rawValue: return "Контакты"
    default: return ""
    }
  }

  override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
    switch section {
    case Sections.tools.rawValue: return 1
    case Sections.help.rawValue: return 1
    case Sections.links.rawValue: return 2
    case Sections.contact.rawValue: return 1
    default: return 0
    }
  }

  override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
    let cell = tableView.dequeueReusableCell(withIdentifier: "basicCell", for: indexPath)
    switch indexPath.section {
    case Sections.tools.rawValue:
        configure(cell, title: "Тест клавиатуры", imageName: "gear", systemName: "keyboard")
    case Sections.help.rawValue:
      switch indexPath.row {
      case 0: configure(cell, title: "Установка", imageName: "settings")
      case 1: configure(cell, title: "Documentation", imageName: "book-open")
      default: break
      }
    case Sections.links.rawValue:
      switch indexPath.row {
      case 0: configure(cell, title: "Алтай Википедия", imageName: "globe")
      case 1: configure(cell, title: "Алтай Википедия - Јайым энциклопедия", imageName: "vk")
      default: break
      }
    case Sections.contact.rawValue:
        configure(cell, title: "Разработчик Күжүгет А.А.", imageName: "vk")
    default:
      break
    }
    return cell
  }

    private func configure(_ cell: UITableViewCell, title: String, imageName: String, systemName: String? = nil) {
        cell.textLabel?.text = title
        if let name = systemName {
            cell.imageView?.image = UIImage(systemName: name)
        } else {
            cell.imageView?.image = UIImage(named: imageName)
        }
        cell.imageView?.tintColor = .systemBlue
    }

  // MARK: User interaction

  override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
    switch indexPath.section {
    case Sections.tools.rawValue: open(segue: "editor")
    case Sections.help.rawValue:
      switch indexPath.row {
      case 0: open(segue: "install")
      case 1: open(url: "https://vk.com/altay_wikipedia")
      default: break
      }
    case Sections.links.rawValue:
      switch indexPath.row {
      case 0: open(url: "https://alt.wikipedia.org/")
      case 1: open(url: "https://vk.com/altay_wikipedia")
      default: break
      }
    case Sections.contact.rawValue: open(url: "https://vk.com/kuzhuget")
    default: break
    }
  }

    private func open(url destination: String) {
        guard let url = URL(string: destination) else { return }
        if UIApplication.shared.canOpenURL(url) {
            UIApplication.shared.open(url, options: [:])
        }
    }

    private func open(segue identifier: String) {
        performSegue(withIdentifier: identifier, sender: self)
    }

}
