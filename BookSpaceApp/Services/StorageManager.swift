import Foundation

class StorageManager {
    static let shared = StorageManager()
    
    private let booksKey = "savedBooks"
    private let statusKey = "bookStatuses"
    
    func saveBook(_ book: Book, status: ReadingStatus) {
        var books = getMyBooks()
        books.removeAll { $0.id == book.id }
        books.append(book)
        
        if let encoded = try? JSONEncoder().encode(books) {
            UserDefaults.standard.set(encoded, forKey: booksKey)
        }
        
        updateBookStatus(book.id, status: status)
    }
    
    func removeBook(_ bookId: String) {
        var books = getMyBooks()
        books.removeAll { $0.id == bookId }
        
        if let encoded = try? JSONEncoder().encode(books) {
            UserDefaults.standard.set(encoded, forKey: booksKey)
        }
        
        var statuses = getAllStatuses()
        statuses.removeValue(forKey: bookId)
        UserDefaults.standard.set(statuses, forKey: statusKey)
    }
    
    func getMyBooks() -> [Book] {
        guard let data = UserDefaults.standard.data(forKey: booksKey),
              let books = try? JSONDecoder().decode([Book].self, from: data) else {
            return []
        }
        return books
    }
    
    func getBookStatus(_ bookId: String) -> ReadingStatus? {
        let statuses = getAllStatuses()
        guard let statusString = statuses[bookId] else { return nil }
        return ReadingStatus(rawValue: statusString)
    }
    
    func updateBookStatus(_ bookId: String, status: ReadingStatus) {
        var statuses = getAllStatuses()
        statuses[bookId] = status.rawValue
        UserDefaults.standard.set(statuses, forKey: statusKey)
    }
    
    private func getAllStatuses() -> [String: String] {
        return UserDefaults.standard.dictionary(forKey: statusKey) as? [String: String] ?? [:]
    }
}
