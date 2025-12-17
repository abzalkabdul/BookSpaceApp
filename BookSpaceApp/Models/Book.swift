struct Book: Codable {
    let id: String
    let title: String
    let authors: [String]?
    let description: String?
    let imageURL: String?
    
    init(from bookItem: BookItem) {
            self.id = bookItem.id
            self.title = bookItem.volumeInfo.title
            self.authors = bookItem.volumeInfo.authors ?? []
            self.description = bookItem.volumeInfo.description
            self.imageURL = bookItem.volumeInfo.imageLinks?.thumbnail
        }
}
