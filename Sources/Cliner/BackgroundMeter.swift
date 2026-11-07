import ClinerCore
import Foundation

enum BackgroundMeter {
    static func sizes(for paths: [String], limit: Int = 3) -> AsyncStream<(String, Int64?)> {
        AsyncStream { continuation in
            let task = Task.detached {
                await withTaskGroup(of: (String, Int64?).self) { group in
                    var index = 0
                    func enqueue() {
                        guard !Task.isCancelled, index < paths.count else { return }
                        let path = paths[index]
                        index += 1
                        group.addTask {
                            (path, DirectorySizer().allocatedSize(at: path))
                        }
                    }
                    for _ in 0..<min(limit, paths.count) {
                        enqueue()
                    }
                    for await result in group {
                        if Task.isCancelled {
                            group.cancelAll()
                            break
                        }
                        continuation.yield(result)
                        enqueue()
                    }
                }
                continuation.finish()
            }
            continuation.onTermination = { _ in
                task.cancel()
            }
        }
    }
}
