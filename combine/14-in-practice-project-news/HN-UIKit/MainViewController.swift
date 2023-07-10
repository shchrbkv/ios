//
//  ViewController.swift
//  HN-UIKit
//
//  Created by Alex Scherbakov on 4/24/23.
//

import Combine
import UIKit

class MainViewController: UITableViewController {

    let api = API()
    var subscriptions = [AnyCancellable]()
    var news = [Story]() {
        didSet {
            tableView.reloadData()
        }
    }

    override func viewDidLoad() {
        super.viewDidLoad()
        title = "Hacker Newz"

        tableView.register(UITableViewCell.self, forCellReuseIdentifier: "StoryCell")

        api.stories()
            .receive(on: DispatchQueue.main)
            .catch { _ in Empty() }
            .assign(to: \.news, on: self)
            .store(in: &subscriptions)
    }

    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        news.count
    }

    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "StoryCell", for: indexPath)
        let id = indexPath.row

        var content = cell.defaultContentConfiguration()
        content.text = news[id].title
        content.textProperties.color = .tintColor
        content.textProperties.font = .boldSystemFont(ofSize: 17)
        content.secondaryText = news[id].by
        cell.contentConfiguration = content

        return cell
    }
}
