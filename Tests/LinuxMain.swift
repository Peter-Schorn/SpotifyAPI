import XCTest
import SpotifyWebAPIMainTests
import SpotifyAPITestUtilities

var tests = [XCTestCaseEntry]()
tests += SpotifyWebAPIMainTests.__allTests()

_ = XCTestObserver()

XCTMain(tests)
