open func httpBody(for parameters: [String: String], encoding: String.Encoding = .utf8) -> Data? {
    let combine: (String, String) -> String = { key, value in
        return key + value
    }
    return nil
}
