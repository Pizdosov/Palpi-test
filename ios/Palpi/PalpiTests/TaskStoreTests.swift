import XCTest
@testable import Palpi

final class TaskStoreTests: XCTestCase {
    private var defaults: UserDefaults!
    private var store: TaskStore!
    private let suiteName = "palpi.tests"

    override func setUp() {
        super.setUp()
        defaults = UserDefaults(suiteName: suiteName)
        defaults.removePersistentDomain(forName: suiteName)
        store = TaskStore(defaults: defaults)
    }

    override func tearDown() {
        defaults.removePersistentDomain(forName: suiteName)
        defaults = nil
        store = nil
        super.tearDown()
    }

    func testAddIgnoresBlankTitle() {
        XCTAssertNil(store.add("   "))
        XCTAssertTrue(store.tasks.isEmpty)
    }

    func testAddToggleAndDelete() {
        let task = store.add("Купить молоко")
        XCTAssertEqual(store.tasks.count, 1)
        XCTAssertEqual(store.tasks.first?.title, "Купить молоко")
        XCTAssertEqual(store.remainingCount, 1)

        store.toggle(task!)
        XCTAssertTrue(store.tasks[0].isDone)
        XCTAssertEqual(store.remainingCount, 0)

        store.delete(task!)
        XCTAssertTrue(store.tasks.isEmpty)
    }

    func testNewestTaskAppearsFirst() {
        _ = store.add("Первая")
        _ = store.add("Вторая")
        XCTAssertEqual(store.tasks.map(\.title), ["Вторая", "Первая"])
    }

    func testPersistsAcrossRelaunch() {
        _ = store.add("Позвонить маме")
        let reloaded = TaskStore(defaults: defaults)
        XCTAssertEqual(reloaded.tasks.first?.title, "Позвонить маме")
        XCTAssertEqual(reloaded.tasks.count, 1)
    }
}
