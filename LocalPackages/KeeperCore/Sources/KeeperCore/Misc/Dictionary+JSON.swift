import Foundation

public extension Dictionary {
    func asJsonString(options: JSONSerialization.WritingOptions = []) -> String? {
        guard JSONSerialization.isValidJSONObject(self),
              let data = try? JSONSerialization.data(withJSONObject: self, options: options),
              let string = String(data: data, encoding: .utf8)
        else {
            return nil
        }
        return string
    }
}
