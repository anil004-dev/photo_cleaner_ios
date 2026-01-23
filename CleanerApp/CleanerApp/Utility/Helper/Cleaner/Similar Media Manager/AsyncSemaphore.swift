//
//  AsyncSemaphore.swift
//  CleanerApp
//
//  Created by iMac on 09/12/25.
//

actor AsyncSemaphore {
    private var permits: Int
    private var waiters: [CheckedContinuation<Void, Never>] = []

    init(value: Int) {
        self.permits = value
    }

    func wait() async {
        if permits > 0 {
            permits -= 1
            return
        }

        await withCheckedContinuation { cont in
            waiters.append(cont)
        }
    }

    func signal() {
        if waiters.isEmpty {
            permits += 1
        } else {
            let cont = waiters.removeFirst()
            cont.resume()
        }
    }
}
