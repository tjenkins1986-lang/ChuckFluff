/// Lets `Int` (e.g. a photo index) be used directly with `.sheet(item:)`.
extension Int: Identifiable {
    public var id: Int { self }
}
