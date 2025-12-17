import Foundation

nonisolated
struct GoogleBooksResponse: Codable {
    let kind: String?
    let totalItems: Int?
    let items: [BookItem]?
}

nonisolated
struct BookItem: Codable {
    let kind: String?
    let id: String
    let etag: String?
    let selfLink: String?
    let volumeInfo: VolumeInfo
    
    struct VolumeInfo: Codable {
        let title: String
        let authors: [String]?
        let description: String?
        let imageLinks: ImageLinks?
        let publishedDate: String?
        let pageCount: Int?
        
        struct ImageLinks: Codable {
            let thumbnail: String?
        }
    }

}
