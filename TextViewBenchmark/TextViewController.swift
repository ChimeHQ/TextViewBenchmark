import AppKit
import OSLog

final class TK2EnforcedTextView: NSTextView {
	override var layoutManager: NSLayoutManager? {
		fatalError()
	}
}

final class TextViewController: NSViewController {
	let textView: NSTextView
	let scrollView: NSScrollView
	let logger = Logger(subsystem: Bundle.main.bundleIdentifier!, category: "TextViewController")
	let signposter: OSSignposter

	static func withScrollableTextView() -> TextViewController {
		let scrollView = TK2EnforcedTextView.scrollableTextView()
		let textView = scrollView.documentView as! NSTextView

		return TextViewController(textView: textView, scrollView: scrollView)
	}

	static func withTextKitOneView() -> TextViewController {
		let textView = NSTextView(usingTextLayoutManager: false)

		textView.isVerticallyResizable = true
		textView.isHorizontallyResizable = true
		textView.textContainer?.widthTracksTextView = true
		textView.layoutManager?.allowsNonContiguousLayout = true

		let max = CGFloat.greatestFiniteMagnitude
		let size = NSSize(width: max, height: max)

		textView.textContainer?.size = size
		textView.maxSize = size

		let scrollView = NSScrollView()

		scrollView.documentView = textView

		return TextViewController(textView: textView, scrollView: scrollView)
	}

	private static func withTextView(for textView: NSTextView) -> TextViewController {
		textView.isVerticallyResizable = true
		textView.isHorizontallyResizable = true
		textView.textContainer?.widthTracksTextView = true

		let max = CGFloat.greatestFiniteMagnitude
		let size = NSSize(width: max, height: max)

		textView.textContainer?.size = size
		textView.maxSize = size

		let scrollView = NSScrollView()

		scrollView.documentView = textView

		return TextViewController(textView: textView, scrollView: scrollView)
	}

	static func withManualTextKitTwoConfiguration() -> TextViewController {
		let textView = TK2EnforcedTextView(usingTextLayoutManager: true)

		return withTextView(for: textView)
	}


	static func withFullTextKit2ObjectNetworkConfiguration() -> TextViewController {
		let textContainer = NSTextContainer(size: CGSize(width: 0.0, height: 1.0e7))
		let textContentManager = NSTextContentStorage()
		let textLayoutManager = NSTextLayoutManager()
		textLayoutManager.textContainer = textContainer
		textContentManager.addTextLayoutManager(textLayoutManager)

		let textView = TK2EnforcedTextView(frame: .zero, textContainer: textContainer)

		return withTextView(for: textView)
	}

	init(textView: NSTextView, scrollView: NSScrollView) {
		self.signposter = OSSignposter(logger: logger)
		self.textView = textView
		self.scrollView = scrollView

		super.init(nibName: nil, bundle: nil)

		textView.delegate = self
	}

	@available(*, unavailable)
	required init?(coder: NSCoder) {
		fatalError("init(coder:) has not been implemented")
	}

	override func loadView() {
		scrollView.hasHorizontalScroller = true
		scrollView.hasVerticalScroller = true

		precondition(scrollView.documentView != nil)

		NSLayoutConstraint.activate([
			scrollView.widthAnchor.constraint(greaterThanOrEqualToConstant: 400.0),
			scrollView.heightAnchor.constraint(greaterThanOrEqualToConstant: 300.0),
		])

		self.view = scrollView

		let notes = NotificationCenter
			.default
			.notifications(named: NSTextView.willSwitchToNSLayoutManagerNotification, object: textView)

		Task {
			for await note in notes.map({ $0.name }) {
				print("note:", note)
			}
		}
	}

	func loadData(at url: URL) throws {
		let attrs: [NSAttributedString.Key : Any] = [
			.font: NSFont.monospacedSystemFont(ofSize: 12.0, weight: .regular),
			.foregroundColor: NSColor.textColor,
		]

		let options: [NSAttributedString.DocumentReadingOptionKey: Any] = [
			.defaultAttributes: attrs,
		]

		let storage = try signposter.withIntervalSignpost(OSSignposter.loadStorageName) {
			try NSTextStorage(url: url, options: options, documentAttributes: nil)
		}

		signposter.withIntervalSignpost(OSSignposter.installStorageName) {
			if textView.textLayoutManager != nil {
				textView.textStorage!.setAttributedString(storage)
			} else {
				textView.layoutManager!.replaceTextStorage(storage)
			}
		}
	}
}

extension TextViewController: NSTextViewDelegate {
	func textView(_ aTextView: NSTextView, doCommandBy commandSelector: Selector) -> Bool {
		switch commandSelector {
		case #selector(NSTextView.moveToEndOfDocument(_:)):
			signposter.withIntervalSignpost(OSSignposter.moveToEndOfDocumentName) {
				textView.moveToEndOfDocument(self)
			}
			return true
		default:
			return false
		}
	}
}
