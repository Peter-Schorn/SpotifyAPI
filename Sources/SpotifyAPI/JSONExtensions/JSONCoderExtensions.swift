import Foundation


public extension JSONDecoder {
    
    convenience init(
        keyDecodingStrategy: KeyDecodingStrategy?,
        dateDecodingStrategy: DateDecodingStrategy? = nil,
        dataDecodingStrategy: DataDecodingStrategy? = nil,
        nonConformingFloatDecodingStrategy: NonConformingFloatDecodingStrategy? = nil,
        userInfo: [CodingUserInfoKey: Any]? = nil
    ) {
        self.init()
        if let keyDecodingStrategy = keyDecodingStrategy {
            self.keyDecodingStrategy = keyDecodingStrategy
        }
        if let dateDecodingStrategy = dateDecodingStrategy {
            self.dateDecodingStrategy = dateDecodingStrategy
        }
        if let dataDecodingStrategy = dataDecodingStrategy {
            self.dataDecodingStrategy = dataDecodingStrategy
        }
        if let nonConformingFloatDecodingStrategy = nonConformingFloatDecodingStrategy {
            self.nonConformingFloatDecodingStrategy = nonConformingFloatDecodingStrategy
        }
        if let userInfo = userInfo {
            self.userInfo = userInfo
        }
       
    }
    
}

public extension JSONEncoder {
    
    convenience init(
        keyEncodingStrategy: KeyEncodingStrategy?,
        outputFormatting: OutputFormatting? = nil,
        dateEncodingStrategy: DateEncodingStrategy? = nil,
        dataEncodingStrategy: DataEncodingStrategy? = nil,
        nonConformingFloatEncodingStrategy: NonConformingFloatEncodingStrategy? = nil,
        userInfo: [CodingUserInfoKey: Any]? = nil
    ) {
        self.init()
        if let keyEncodingStrategy = keyEncodingStrategy {
            self.keyEncodingStrategy = keyEncodingStrategy
        }
        if let outputFormatting = outputFormatting {
            self.outputFormatting = outputFormatting
        }
        if let dateEncodingStrategy = dateEncodingStrategy {
            self.dateEncodingStrategy = dateEncodingStrategy
        }
        if let dataEncodingStrategy = dataEncodingStrategy {
            self.dataEncodingStrategy = dataEncodingStrategy
        }
        if let nonConformingFloatEncodingStrategy = nonConformingFloatEncodingStrategy {
            self.nonConformingFloatEncodingStrategy = nonConformingFloatEncodingStrategy
        }
        if let userInfo = userInfo {
            self.userInfo = userInfo
        }
       
    }
    
}
