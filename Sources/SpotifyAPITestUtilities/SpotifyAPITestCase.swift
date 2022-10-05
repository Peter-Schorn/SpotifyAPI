import Foundation
import XCTest
@testable import SpotifyWebAPI
import RegularExpressions

#if canImport(FoundationNetworking)
import FoundationNetworking
#endif

public class SpotifyTestObserver: NSObject, XCTestObservation {
    
    public static var isRegisteredAsObserver = false

    public func testBundleWillStart(_ testBundle: Bundle) {
//        print("\n\ntestBundleWillStart: \(testBundle)\n\n")
    }
    
    public func testBundleDidFinish(_ testBundle: Bundle) {
//        print("\n\ntestBundleDidFinish: \(testBundle)\n\n")
        
        DistributedLock.releaseAllLocks()

        if let failingTestsString = self.makeFailingTestsString() {
            if let logFile = SpotifyAPITestCase.logFile {
                try? failingTestsString.append(to: logFile)
            }
            
            print(failingTestsString)
        }

    }
    
    func makeFailingTestsString() -> String? {
        
        if SpotifyAPITestCase.failingTests.isEmpty {
            return nil
        }

        #if canImport(ObjectiveC)
        
        let tests = SpotifyAPITestCase.failingTests
            .compactMap { test -> (testCase: String, testMethod: String)? in
                // each string in `failingTests` has the format
                // "-[<test-case> <test-method>]"
                guard
                    let match = try! test.regexMatch(#"-\[(\w+) (\w+)\]"#),
                    match.groups.count >= 2,
                    let testCase = match.groups[0]?.match,
                    let testMethod = match.groups[1]?.match
                else {
                    return nil
                }

                return (testCase: testCase, testMethod: testMethod)
            }

        #else
        
        let tests = SpotifyAPITestCase.failingTests
            .compactMap { test -> (testCase: String, testMethod: String)? in
                // each string in `failingTests` has the format
                // "<test-case>.<test-method>", so we split the string
                // on the period
                let tests = test.split(separator: ".").map(String.init)
                if tests.count != 2 { return nil }
                return (testCase: tests[0], testMethod: tests[1])
            }
        
        #endif
        
        let sortedTests = tests.sorted { lhs, rhs in
            lhs.testCase < rhs.testCase
        }
    
        let failingTestsFilter = sortedTests
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
        for test in sortedTests {
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
    
    /// Only executes once per process.
    func globalSetup() {
        XCTestObservationCenter.shared.addTestObserver(self)
        Self.isRegisteredAsObserver = true
        SpotifyAPILogHandler.bootstrap()
    }

    public override init() {
        super.init()
        self.globalSetup()
    }
}

/// The base class for **all** test cases in this package. Overrides
/// `record(_:)` to record issues and `setUp()` to install a test observer.
open class SpotifyAPITestCase: XCTestCase {
    
    public static var failingTests: [String] = []

    /// The file that issues will be logged to during tests.
    public static let logFile: URL? = {
        if let folder = SpotifyDecodingError.dataDumpFolder {
            let dateString = DateFormatter
                .millisecondsTime.string(from: Date())
            return folder.appendingPathComponent(
                "test log \(dateString).txt",
                isDirectory: false
            )
        }
        return nil
    }()
    
    public static func selectNetworkAdaptor() {
        if Bool.random() {
            print(
                "URLSession._defaultNetworkAdaptor = " +
                "URLSession.__defaultNetworkAdaptor"
            )
            URLSession._defaultNetworkAdaptor = URLSession.__defaultNetworkAdaptor
        }
        else {
            print(
                "URLSession._defaultNetworkAdaptor = NetworkAdaptorManager" +
                ".shared.networkAdaptor(request:)"
            )
            URLSession._defaultNetworkAdaptor = NetworkAdaptorManager
                    .shared.networkAdaptor(request:)
        }
    }

    open override class func setUp() {
        if !SpotifyTestObserver.isRegisteredAsObserver {
            _ = SpotifyTestObserver()
        }
        
        Self.selectNetworkAdaptor()

    }
    
    #if canImport(ObjectiveC)
    
    open override func record(_ issue: XCTIssue) {

        super.record(issue)

        let context = issue.sourceCodeContext

        let symbolNames = context.callStack
            .compactMap { frame -> String? in
                guard let name = frame.symbolInfo?.symbolName,
                      !name.starts(with: "@objc") else {
                    return nil
                }
                return name
            }
            .joined(separator: "\n")

        let filePath = context.location?.fileURL.path ?? ""
        let line = (context.location?.lineNumber)
            .flatMap(String.init) ?? ""
        let locationString = "\(filePath):\(line)"

        let testName = self.name

        let message = """
            ------------------------------------------------
            \(locationString)
            \(testName)
            \(issue.compactDescription)
            call-stack:
            \(symbolNames)
            ------------------------------------------------
            """

        if let logFile = Self.logFile {
            try? message.append(to: logFile)
        }

        if !Self.failingTests.contains(testName) {
            Self.failingTests.append(testName)
        }

    }
    
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
