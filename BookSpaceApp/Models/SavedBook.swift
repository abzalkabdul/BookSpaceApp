import Foundation

struct SavedBook: Codable {
    let id: String
    let title: String
    let authors: [String]?
    let description: String?
    let imageURL: String?
    let status: ReadingStatus
    let dateAdded: Date

    init(book: Book, status: ReadingStatus) {
        self.id = book.id
        self.title = book.title
        self.authors = book.authors
        self.description = book.description
        self.imageURL = book.imageURL
        self.status = status
        self.dateAdded = Date()
    }
}
