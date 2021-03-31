#if canImport(Combine)
import Combine
#else
import OpenCombine
import OpenCombineDispatch
import OpenCombineFoundation
#endif
import Foundation

#if canImport(FoundationNetworking)
import FoundationNetworking
#endif

#if DEBUG
enum DebugHooks {
    
    static let receiveRateLimitedError = PassthroughSubject<RateLimitedError, Never>()

}
#endif
