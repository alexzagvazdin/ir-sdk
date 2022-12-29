//
//  HomeViewController.swift
//  IRSDKSample
//
//  Created by Marcin Hatalski on 23/12/2022.
//

import Combine
import IRSDK
import UIKit

class HomeViewController: UIViewController {
    
    private lazy var tableView: UITableView = {
        let tableView = UITableView()
        tableView.rowHeight = UITableView.automaticDimension
        tableView.register(TaskCell.self, forCellReuseIdentifier: "TaskCell")
        tableView.dataSource = self
        tableView.delegate = self
        tableView.separatorInset = .zero
        return tableView
    }()
    
    var cancellables = Set<AnyCancellable>()
    
    private var tasks = [Task]() {
        didSet { tableView.reloadData() }
    }

    override func viewDidLoad() {
        super.viewDidLoad()
        
        view.backgroundColor = .systemBackground
        setupNavigationBar()
        setupTableView()
        loadTasks()
    }
    
    private func setupNavigationBar() {
        navigationItem.rightBarButtonItem = UIBarButtonItem(
            image: UIImage(
                systemName: "ellipsis",
                withConfiguration: UIImage.SymbolConfiguration(weight: .bold)
            ),
            style: .plain,
            target: self,
            action: #selector(moreButtonTapped)
        )
        navigationController?.navigationBar.prefersLargeTitles = true
        title = "Home"
    }
    
    @objc private func moreButtonTapped() {
        let alert = UIAlertController(title: nil, message: nil, preferredStyle: .actionSheet)
        alert.addAction(UIAlertAction(title: "Log Out", style: .destructive) { [weak self] _ in self?.logOut() })
        alert.addAction(UIAlertAction(title: "Cancel", style: .cancel))
        present(alert, animated: true)
    }
    
    private func logOut() {
        IRSDK.deauthenticate()
        (UIApplication.shared.delegate as? AppDelegate)?.navigateToLogin()
    }
    
    private func setupTableView() {
        view.addSubview(tableView)
        tableView.translatesAutoresizingMaskIntoConstraints = false
        NSLayoutConstraint.activate([
            tableView.topAnchor.constraint(equalTo: view.topAnchor),
            tableView.bottomAnchor.constraint(equalTo: view.bottomAnchor),
            tableView.leadingAnchor.constraint(equalTo: view.leadingAnchor),
            tableView.trailingAnchor.constraint(equalTo: view.trailingAnchor)
        ])
    }
    
    private func loadTasks() {
        TaskRepository.shared.$tasks
            .sink { [weak self] tasks in self?.tasks = tasks }
            .store(in: &cancellables)
    }
}

extension HomeViewController: UITableViewDataSource, UITableViewDelegate {
 
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        tasks.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "TaskCell", for: indexPath) as! TaskCell
        
        let task = tasks[indexPath.item]
        cell.title = "Task \(task.id)"
        cell.subtitle = task.description
        cell.isCompleted = task.isCompleted
        return cell
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        let photoGridsViewController = TaskViewController(task: tasks[indexPath.item])
        navigationController?.pushViewController(photoGridsViewController, animated: true)
        tableView.deselectRow(at: indexPath, animated: true)
    }
}

