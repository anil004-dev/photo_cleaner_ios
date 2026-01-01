//
//  AsyncSemaphore.swift
//  CleanerApp
//
//  Created by iMac on 09/12/25.
//

actor AsyncSemaphore {
    private var permits: Int

    init(value: Int) {
        self.permits = value
    }

    func wait() async {
        while permits == 0 {
            await Task.yield()
        }
        permits -= 1
    }

    func signal() {
        permits += 1
    }
}
