
import Foundation

enum SearchScope: String {
    case Both
    case Title
    case Content
    
    static var titles: [String] {
        get {
            return [SearchScope.Both.rawValue, SearchScope.Title.rawValue, SearchScope.Content.rawValue]
        }
    }
    
    static var scopes: [SearchScope] {
        get {
            return [SearchScope.Both, SearchScope.Title, SearchScope.Content]
        }
    }
}
