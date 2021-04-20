import Foundation
import XCTest
import SpotifyWebAPI

public class XCTestObserver: NSObject, XCTestObservation {
    
    public func testBundleWillStart(_ testBundle: Bundle) {
//        print("\n\ntestBundleWillStart: \(testBundle)\n\n")
    }
    
    public func testBundleDidFinish(_ testBundle: Bundle) {
//        print("\n\ntestBundleDidFinish: \(testBundle)\n\n")
        
        if let logFile = SpotifyAPITestCase.logFile {
            let failingTestsString = self.makeFailingTestsString()
            try? failingTestsString.append(to: logFile)
        }

    }
    
    func makeFailingTestsString() -> String {
        
        let tests = SpotifyAPITestCase.failingTests
            .compactMap { test -> (testCase: String, testMethod: String)? in
                // each string in `failingTests` has the format
                // "<test-case>.<test-method>", so we split the string
                // on the period
                let tests = test.split(separator: ".").map(String.init)
                if tests.count != 2 { return nil }
                return (testCase: tests[0], testMethod: tests[1])
            }
            .sorted { lhs, rhs in
                lhs.testCase < rhs.testCase
            }
        
    
        let failingTestsFilter = tests
            .map { test in
                "\(test.testCase)/\(test.testMethod)"
            }
            .joined(separator: "|")
        
        let reTestCommand = """
            to re-run failing tests:
            
            swift test --filter "\(failingTestsFilter)"
            """
    
        var testsListString = ""

        var currentTestCase: String? = nil
        for test in tests {
            if test.testCase != currentTestCase {
                print("\n\(test.testCase)", to: &testsListString)
                currentTestCase = test.testCase
            }
            print("    - \(test.testMethod)", to: &testsListString)
        }

        
        let finalMessage = """

            --------- FAILING TESTS ---------

            \(testsListString)
            
            \(reTestCommand)
            """
        
        return finalMessage
    }
    
    public override init() {
        super.init()
        XCTestObservationCenter.shared.addTestObserver(self)
    }
}

/// The base class for **all** test cases in this package.
/// Overides `record(_:)` to record issues.
open class SpotifyAPITestCase: XCTestCase {
    
    public static var failingTests: [String] = []

    /// The file that issues will be logged to during tests.
    public static let logFile: URL? = {
        if let folder = SpotifyDecodingError.dataDumpfolder {
            let dateString = DateFormatter
                .millisecondsTime.string(from: Date())
            return folder.appendingPathComponent(
                "test log \(dateString).txt",
                isDirectory: false
            )
        }
        return nil
    }()
    
    #if canImport(ObjectiveC)
    
//    open override func record(_ issue: XCTIssue) {
//
//        super.record(issue)
//
//        let context = issue.sourceCodeContext
//
//        let symbolNames = context.callStack
//            .compactMap { frame -> String? in
//                guard let name = frame.symbolInfo?.symbolName,
//                      !name.starts(with: "@objc") else {
//                    return nil
//                }
//                return name
//            }
//            .joined(separator: "\n")
//
//        let filePath = context.location?.fileURL.path ?? ""
//        let line = (context.location?.lineNumber)
//            .flatMap(String.init) ?? ""
//        let locationString = "\(filePath):\(line)"
//
//        let testName = self.name
//
//        let message = """
//            ------------------------------------------------
//            \(locationString)
//            \(testName)
//            \(issue.compactDescription)
//            callstack:
//            \(symbolNames)
//            ------------------------------------------------
//            """
//
//        if let logFile = Self.logFile {
//            try? message.append(to: logFile)
//        }
//
//        if !Self.failingTests.contains(testName) {
//            Self.failingTests.append(testName)
//        }
//
//    }
    
    #else
    
    override open func recordFailure(
        withDescription description: String,
        inFile filePath: String,
        atLine lineNumber: Int,
        expected: Bool
    ) {
        
        super.recordFailure(
            withDescription: description,
            inFile: filePath,
            atLine: lineNumber,
            expected: expected
        )
        
        let testName = self.name

        let message = """
            ------------------------------------------------
            \(filePath):\(lineNumber)
            \(testName)
            \(description)
            ------------------------------------------------
            """

        if let logFile = Self.logFile {
            try? message.append(to: logFile)
        }

        if !Self.failingTests.contains(testName) {
            Self.failingTests.append(testName)
        }

    }
    
    #endif

}
