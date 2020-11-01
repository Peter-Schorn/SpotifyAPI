import Foundation

extension Array where Element == URLQueryItem {
    
    mutating func sortByNameThenValue() {
        self = self.sortedByNameThenValue()
    }
    
    func sortedByNameThenValue() -> Self {
        return self.sorted { lhs, rhs in
            if lhs.name != rhs.name {
                return lhs.name < rhs.name
            }
            return (lhs.value ?? "") < (rhs.value ?? "")
        }
    }

}
