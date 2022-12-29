//
//  Task.swift
//  IRSDKSample
//
//  Created by Marcin Hatalski on 23/12/2022.
//

struct Task {
    let id: Int
    let description: String
    let sceneType: String
    let isCompleted: Bool
}

extension Task {
    
    var completed: Task {
        get {
            Task(id: id, description: description, sceneType: sceneType, isCompleted: true)
        }
    }
}

