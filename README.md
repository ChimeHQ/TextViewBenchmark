# TextViewBenchmark
A suite of performance tests for macOS text views

Every year, I check in on TextKit 2 to see how things are going. It was introduced in macOS 12, and I found it basically unusable. With macOS 12 it was better, but still rough. So far, on macOS 14, it seems like it might be ok. However, I was having some performance problems. So I finally went head and factored that out into a dedicated project. Pretty focused on `NSTextView` right now, but I'm into making it more general if that's helpful to anyone.

## Usage

The tests automated using XCTest's ui performance testing system, backed by custom `OSSignpost`. I find this really wonderful for both repeatibility and Instruments usage.

If you want to set up your own view for testing, you can do something like this:

```swift
static func withScrollableTextView() -> TextViewController {
    let scrollView = NSTextView.scrollableTextView()
    let textView = scrollView.documentView as! NSTextView

    return TextViewController(textView: textView, scrollView: scrollView)
}
```

## Results

I'm using macOS 14 beta, so that may be a factor. But, what I can say is TextKit 1 is extremely fast and TextKit 2... continues to have some room for improvement.

## Contributing and Collaboration

I'd love to hear from you! Get in touch via an issue or pull request.

I prefer collaboration, and would love to find ways to work together if you have a similar project.

I prefer indentation with tabs for improved accessibility. But, I'd rather you use the system you want and make a PR than hesitate because of whitespace.

By participating in this project you agree to abide by the [Contributor Code of Conduct](CODE_OF_CONDUCT.md).
