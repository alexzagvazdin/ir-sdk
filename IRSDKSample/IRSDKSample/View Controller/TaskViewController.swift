//
//  TaskViewController.swift
//  IRSDKSample
//
//  Created by Marcin Hatalski on 23/12/2022.
//

import UIKit
import IRSDK

class TaskViewController: UIViewController {
    
    private lazy var tableView: UITableView = {
        let tableView = UITableView()
        tableView.rowHeight = UITableView.automaticDimension
        tableView.register(PhotoGridCell.self, forCellReuseIdentifier: "PhotoGridCell")
        tableView.register(AddPhotoGridCell.self, forCellReuseIdentifier: "AddPhotoGridCell")
        tableView.delegate = self
        tableView.dataSource = self
        tableView.separatorInset = .zero
        return tableView
    }()
    
    private lazy var bottomPanel: UIView = {
        let view = UIView()
        view.backgroundColor = .systemBackground
        return view
    }()
    
    private lazy var bottomDivider: UIView = {
        let view = UIView()
        view.backgroundColor = .separator
        return view
    }()
    
    private lazy var finishButton: UIButton = {
        var attributeContainer = AttributeContainer()
        attributeContainer.font = .systemFont(ofSize: 16, weight: .bold)
        
        var configuration = UIButton.Configuration.filled()
        configuration.attributedTitle = AttributedString("Finish", attributes: attributeContainer)
        configuration.cornerStyle = .capsule
        configuration.buttonSize = .large

        let action = UIAction { [weak self] _ in self?.finish() }
        
        let button = UIButton(configuration: configuration, primaryAction: action)
        button.isEnabled = false
        return button
    }()
    
    private let task: Task
    
    private var photoGrids = [PhotoGrid]() {
        didSet { tableView.reloadData() }
    }
    
    private var currentIndex: Int {
        (photoGrids.max(by: { $0.index > $1.index })?.index ?? 0) + 1
    }
    
    init(task: Task) {
        self.task = task
        super.init(nibName: nil, bundle: nil)
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        view.backgroundColor = .systemBackground
        setupNavigationItem()
        setupSubviews()
    }
    
    private func setupNavigationItem() {
        let title = UILabel()
        title.text = "Task \(task.id)"
        title.font = .systemFont(ofSize: 16, weight: .medium)
        title.textColor = .label
        
        let subtitle = UILabel()
        subtitle.text = task.description
        subtitle.font = .systemFont(ofSize: 14, weight: .regular)
        subtitle.textColor = .secondaryLabel
        
        let stackView = UIStackView(arrangedSubviews: [title, subtitle])
        stackView.distribution = .equalCentering
        stackView.axis = .vertical
        stackView.alignment = .center
        
        navigationItem.titleView = stackView
        navigationItem.largeTitleDisplayMode = .never
    }
    
    private func setupSubviews() {
        view.addSubview(tableView)
        view.addSubview(bottomPanel)
        bottomPanel.addSubview(finishButton)
        
        tableView.translatesAutoresizingMaskIntoConstraints = false
        NSLayoutConstraint.activate([
            tableView.topAnchor.constraint(equalTo: view.topAnchor),
            tableView.bottomAnchor.constraint(equalTo: view.bottomAnchor),
            tableView.leadingAnchor.constraint(equalTo: view.leadingAnchor),
            tableView.trailingAnchor.constraint(equalTo: view.trailingAnchor)
        ])
        
        bottomPanel.translatesAutoresizingMaskIntoConstraints = false
        NSLayoutConstraint.activate([
            bottomPanel.bottomAnchor.constraint(equalTo: view.safeAreaLayoutGuide.bottomAnchor),
            bottomPanel.leadingAnchor.constraint(equalTo: view.leadingAnchor),
            bottomPanel.trailingAnchor.constraint(equalTo: view.trailingAnchor)
        ])
        
        finishButton.translatesAutoresizingMaskIntoConstraints = false
        NSLayoutConstraint.activate([
            finishButton.topAnchor.constraint(equalTo: bottomPanel.topAnchor, constant: 16),
            finishButton.bottomAnchor.constraint(equalTo: bottomPanel.bottomAnchor, constant: -16),
            finishButton.leadingAnchor.constraint(equalTo: bottomPanel.leadingAnchor, constant: 16),
            finishButton.trailingAnchor.constraint(equalTo: bottomPanel.trailingAnchor, constant: -16),
        ])
    }
    
    private func finish() {
        let dispatchGroup = DispatchGroup()
        photoGrids.forEach { photoGrid in
            dispatchGroup.enter()
            IRSDK.submitPhotoGrid(id: photoGrid.id) { result in
                switch result {
                case .success:
                    print("Successfully submitted photo grid.")
                case .failure(let error):
                    print("Failed to submit photo grid (\(error)).")
                }
                dispatchGroup.leave()
            }
        }
        dispatchGroup.notify(queue: .main) { [weak self] in
            guard let self = self else { return }
            TaskRepository.shared.completeTask(with: self.task.id)
            self.navigationController?.popViewController(animated: true)
        }
    }
}

extension TaskViewController: UITableViewDataSource, UITableViewDelegate {
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        photoGrids.count + 1
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        switch indexPath.item {
        case 0..<photoGrids.count:
            let cell = tableView.dequeueReusableCell(withIdentifier: "PhotoGridCell", for: indexPath) as! PhotoGridCell
            let photoGrid = photoGrids[indexPath.item]
            cell.photoGrid = photoGrid
            cell.didTapTrashButton = { [weak self] in self?.delete(photoGrid: photoGrid) }
            return cell
        default:
            let cell = tableView.dequeueReusableCell(withIdentifier: "AddPhotoGridCell", for: indexPath) as! AddPhotoGridCell
            cell.didTapCameraButton = { [weak self] in self?.showPhotoGrid() }
            return cell
        }
    }
    
    private func delete(photoGrid: PhotoGrid) {
        IRSDK.deletePhotoGrid(id: photoGrid.id) { [weak self] result in
            switch result {
            case .success:
                print("Successfully deleted photo grid.")
                self?.photoGrids.removeAll { $0.id == photoGrid.id }
            case .failure(let error):
                print("Failed to delete photo grid (\(error)).")
            }
        }
    }
    
    private func showPhotoGrid() {
        do {
            let metadata = ["task_id": task.id, "photo_grid_index": currentIndex]
            try IRSDK.showPhotoGrid(from: self, sceneType: task.sceneType, metadata: metadata, delegate: self)
        } catch {
            print("Failed to show photo grid (\(error).")
        }
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        tableView.deselectRow(at: indexPath, animated: true)
    }
}

extension TaskViewController: PhotoGridDelegate {
    
    func photoGridDidCreate(photoGridID: String) {
        photoGrids.append(PhotoGrid(id: photoGridID, index: currentIndex, createdAt: Date()))
    }

    func photoGridDidFinish() {
        finishButton.isEnabled = !photoGrids.isEmpty
    }
}

