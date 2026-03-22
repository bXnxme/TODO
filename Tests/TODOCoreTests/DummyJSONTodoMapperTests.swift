import XCTest
@testable import TODOCore

final class DummyJSONTodoMapperTests: XCTestCase {
    func testMapBuildsTaskItemsFromResponseData() throws {
        let expectedUUID = UUID(uuidString: "AAAAAAAA-BBBB-CCCC-DDDD-EEEEEEEEEEEE")!
        let expectedDate = Date(timeIntervalSince1970: 1_701_234_567)
        let mapper = DummyJSONTodoMapper(
            uuidFactory: { _ in expectedUUID },
            dateFactory: { expectedDate }
        )

        let data = """
        {
          "todos": [
            {
              "id": 1,
              "todo": "Buy milk",
              "completed": true,
              "userId": 77
            }
          ]
        }
        """.data(using: .utf8)!

        let items = try mapper.map(data: data)

        XCTAssertEqual(
            items,
            [
                TaskItem(
                    id: expectedUUID,
                    remoteID: 1,
                    title: "Buy milk",
                    details: "",
                    createdAt: expectedDate,
                    isCompleted: true
                )
            ]
        )
    }
}
