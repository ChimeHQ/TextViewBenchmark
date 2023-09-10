import Cocoa

@main
final class AppDelegate: NSObject, NSApplicationDelegate {
	let window: NSWindow
	let controller: TextViewController

	override init() {
		self.controller = TextViewController.withFullTextKit2ObjectNetworkConfiguration()
		self.window = NSWindow(contentViewController: controller)
	}

	func applicationDidFinishLaunching(_ aNotification: Notification) {
		window.makeKeyAndOrderFront(self)

		guard let path = UserDefaults.standard.string(forKey: "testFileURL") else {
			return
		}

		let url = URL(filePath: path, directoryHint: .notDirectory)

		try! controller.loadData(at: url)
	}

	func applicationSupportsSecureRestorableState(_ app: NSApplication) -> Bool {
		return true
	}
}
