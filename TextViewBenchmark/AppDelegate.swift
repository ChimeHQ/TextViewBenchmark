import Cocoa

@main
final class AppDelegate: NSObject, NSApplicationDelegate {
	let window: NSWindow
	let controller: TextViewController

	override init() {
		self.controller = TextViewController.withManualTextKitTwoConfiguration()
		self.window = NSWindow(contentViewController: controller)
	}

	func applicationDidFinishLaunching(_ aNotification: Notification) {
		window.makeKeyAndOrderFront(self)

		try! controller.loadData()
	}

	func applicationSupportsSecureRestorableState(_ app: NSApplication) -> Bool {
		return true
	}
}

extension AppDelegate {
}
