//
//  TaskRepository.swift
//  IRSDKSample
//
//  Created by Marcin Hatalski on 23/12/2022.
//

import Foundation

class TaskRepository {
    
    static let shared = TaskRepository()
    
    @Published private(set) var tasks = [Task]()
    
    private init() { seed() }
    
    private func seed() {
        tasks.append(contentsOf: [
            Task(id: 1, description: "Take photos of coolers ❄️", sceneType: "test-cooler", isCompleted: false),
            Task(id: 2, description: "Take photos of shelves ☀️", sceneType: "test-shelf", isCompleted: false)
        ])
    }
    
    func completeTask(with id: Int) {
        guard let index = tasks.firstIndex(where: { $0.id == id }) else { return }
        tasks[index] = tasks[index].completed
    }
}
