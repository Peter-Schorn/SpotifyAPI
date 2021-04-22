import XCTest
import SpotifyWebAPIMainTests
import SpotifyAPITestUtilities

var tests = [XCTestCaseEntry]()
tests += SpotifyWebAPIMainTests.__allTests()

_ = SpotifyTestObserver()

XCTMain(tests)
