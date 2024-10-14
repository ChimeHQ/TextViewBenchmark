import XCTest
import OSLog

extension XCTOSSignpostMetric {
	static let loadStorageMetric = XCTOSSignpostMetric(
		subsystem: "com.chimehq.TextViewBenchmark",
		category: "TextViewController",
		name: "\(OSSignposter.loadStorageName)"
	)

	static let installStorageMetric = XCTOSSignpostMetric(
		subsystem: "com.chimehq.TextViewBenchmark",
		category: "TextViewController",
		name: "\(OSSignposter.installStorageName)"
	)

	static let moveToEndOfDocumentMetric = XCTOSSignpostMetric(
		subsystem: "com.chimehq.TextViewBenchmark",
		category: "TextViewController",
		name: "\(OSSignposter.moveToEndOfDocumentName)"
	)
}

final class TextViewBenchmarkUITests: XCTestCase {
	private let app = XCUIApplication()
	private let bundle = Bundle(for: TextViewBenchmarkUITests.self)

    override func setUpWithError() throws {
        continueAfterFailure = true
    }

    override func tearDownWithError() throws {
        // Put teardown code here. This method is called after the invocation of each test method in the class.
    }

    func testLaunchPerformance() throws {
		let url = try XCTUnwrap(bundle.url(forResource: "empty", withExtension: "txt"))

		app.launchArguments = ["-testFileURL", url.path(percentEncoded: false)]

        measure(metrics: [XCTApplicationLaunchMetric()]) {
			app.launch()
        }
    }

	/// Some random Ruby file I found in the mime-types gem.
	///
	/// Has 230 lines, which seems fairly standard as far as small files go.
	func testLaunchWithNormalFile() throws {
		let url = try XCTUnwrap(bundle.url(forResource: "types", withExtension: "rb"))

		app.launchArguments = ["-testFileURL", url.path(percentEncoded: false)]

		let metrics: [XCTMetric] = [
			XCTApplicationLaunchMetric(),
			XCTOSSignpostMetric.loadStorageMetric,
			XCTOSSignpostMetric.installStorageMetric,
			XCTMemoryMetric(),
		]

		measure(metrics: metrics) {
			app.launch()
		}
	}

	func testScrollToBottomWithNormalFile() throws {
		let url = try XCTUnwrap(bundle.url(forResource: "types", withExtension: "rb"))

		app.launchArguments = ["-testFileURL", url.path(percentEncoded: false)]

		let metrics: [XCTMetric] = [
			XCTOSSignpostMetric.moveToEndOfDocumentMetric,
			XCTMemoryMetric(),
		]

		let options = XCTMeasureOptions()

		options.invocationOptions = [.manuallyStart, .manuallyStop]

		measure(metrics: metrics, options: options) {
			app.launch()

			startMeasuring()

			let textView = app.windows.scrollViews.textViews.element

			textView.typeKey(.downArrow, modifierFlags: [.command])

			stopMeasuring()
		}
	}

	func testScrollToBottomWithOneMillionSingleAsciiCharacterLinesFile() throws {
		let url = Self.oneMillionSingleAsciiCharacterLinesFileURL

		app.launchArguments = ["-testFileURL", url.path(percentEncoded: false)]

		let metrics: [XCTMetric] = [
			XCTOSSignpostMetric.loadStorageMetric,
			XCTOSSignpostMetric.installStorageMetric,
			XCTOSSignpostMetric.moveToEndOfDocumentMetric,
			XCTMemoryMetric(),
		]

		let options = XCTMeasureOptions()

		options.invocationOptions = [.manuallyStart, .manuallyStop]

		measure(metrics: metrics, options: options) {
			app.launch()

			startMeasuring()

			let textView = app.windows.scrollViews.textViews.element

			textView.typeKey(.downArrow, modifierFlags: [.command])

			stopMeasuring()
		}
	}

	func testScrollToEndWithOneMillionSingleAsciiCharacterLineFile() throws {
		let url = Self.oneMillionSingleAsciiCharacterLineFileURL

		app.launchArguments = ["-testFileURL", url.path(percentEncoded: false)]

		let metrics: [XCTMetric] = [
			XCTOSSignpostMetric.loadStorageMetric,
			XCTOSSignpostMetric.installStorageMetric,
			XCTOSSignpostMetric.moveToEndOfDocumentMetric,
			XCTMemoryMetric(),
		]

		let options = XCTMeasureOptions()

		options.invocationOptions = [.manuallyStart, .manuallyStop]

		measure(metrics: metrics, options: options) {
			app.launch()

			startMeasuring()

			let textView = app.windows.scrollViews.textViews.element

			textView.typeKey(.rightArrow, modifierFlags: [.command])

			stopMeasuring()
		}
	}
}

extension TextViewBenchmarkUITests {
	private static func generateTestDocument(at url: URL, generator: (FileHandle) throws -> Void) throws {
		let path = url.path(percentEncoded: false)

		if FileManager.default.fileExists(atPath: path) {
			return
		}

		FileManager.default.createFile(atPath: path, contents: Data(), attributes: nil)

		let fileHandle = FileHandle(forWritingAtPath: path)!

		fileHandle.seekToEndOfFile()

		try generator(fileHandle)

		try fileHandle.close()
	}

	static let oneMillionSingleAsciiCharacterLinesFileURL: URL = {
		let path = NSTemporaryDirectory() + "one_million_single_ascii_character_lines.txt"
		let url = URL(fileURLWithPath: path, isDirectory: false)

		try! generateTestDocument(at: url) { handle in
			let data = Data(String(repeating: "a\n", count: 1000).utf8)

			for _ in 0..<1000 {
				try handle.write(contentsOf: data)
			}
		}

		return url
	}()

	static let oneMillionSingleAsciiCharacterLineFileURL: URL = {
		let path = NSTemporaryDirectory() + "one_million_single_ascii_character_line.txt"
		let url = URL(fileURLWithPath: path, isDirectory: false)

		try! generateTestDocument(at: url) { handle in
			let data = Data(String(repeating: "a", count: 1000).utf8)

			for _ in 0..<1000 {
				try handle.write(contentsOf: data)
			}
		}

		return url
	}()
}
