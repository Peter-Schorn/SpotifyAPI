import Foundation

extension Sequence where Element == URLQueryItem {
    
    func sortedByNameThenValue() -> [URLQueryItem] {
        return self.sorted { lhs, rhs in
            if lhs.name != rhs.name {
                return lhs.name < rhs.name
            }
            return (lhs.value ?? "") < (rhs.value ?? "")
        }
    }

}

extension Array where Element == URLQueryItem {
    
    mutating func sortByNameThenValue() {
        self = self.sortedByNameThenValue()
    }
    
}
