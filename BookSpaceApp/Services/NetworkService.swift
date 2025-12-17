import Foundation
import Alamofire

enum NetworkError: Error {
    case invalidURL
    case noData
    case decodingError
    case networkFailure(Error)
    case serverError(Int)
    case unknown
    
    var description: String {
        switch self {
        case .invalidURL: return "Invalid URL"
        case .noData: return "No data found"
        case .decodingError: return "Failed to decode data"
        case .serverError(let code): return "Server error \(code)"
        case .networkFailure(let error): return "Network error: \(error.localizedDescription)"
        case .unknown: return "Something went wrong"
        }
    }
}


protocol NetworkServiceDelegate: AnyObject {
    func didFetchBooks(_ books: [Book])
    func didFetchBookDetails(_ book: Book)
    func didFailWithError(_ error: NetworkError)
}

class NetworkService {
    
    static let shared = NetworkService()
    
    // Delegate
    weak var delegate: NetworkServiceDelegate?
    
    private let apiKey = "AIzaSyArqdCEVY9tqN_EfEyhei3RCHyl6z0cRHM"
    private let baseURL = "https://www.googleapis.com/books/v1/volumes"
    
    
    // MARK: - 1. Поиск книг
    func searchBooks(query: String) {
        let parameters: Parameters = [
            "q": query,
            "key": apiKey,
            "maxResults": 40
        ]
        
        AF.request(baseURL, parameters: parameters)
            .validate(statusCode: 200..<300)
            .responseDecodable(of: GoogleBooksResponse.self) { response in
                self.handleBooksResponse(response)
            }
    }
    
    // MARK: - 2. Популярные книги
    func fetchPopularBooks() {
        let parameters: Parameters = [
            "q": "subject:fiction",
            "orderBy": "relevance",
            "key": apiKey,
            "maxResults": 40
        ]
        
        AF.request(baseURL, parameters: parameters)
            .validate(statusCode: 200..<300)
            .responseDecodable(of: GoogleBooksResponse.self) { response in
                self.handleBooksResponse(response)
            }
    }
    
    // MARK: - 3. Детали книги по ID
    func fetchBookDetails(id: String) {
        let url = "\(baseURL)/\(id)"
        let parameters: Parameters = ["key": apiKey]
        
        AF.request(url, parameters: parameters)
            .validate(statusCode: 200..<300)
            .responseDecodable(of: BookItem.self) { response in
                switch response.result {
                case .success(let bookItem):
                    let book = Book(from: bookItem)
                    print("Successfully loaded book: \(book.title)")
                    
                    DispatchQueue.main.async {
                        self.delegate?.didFetchBookDetails(book)
                    }
                    
                case .failure(let error):
                    print("Error: \(error)")
                    let networkError = self.mapError(response: response)
                    
                    DispatchQueue.main.async {
                        self.delegate?.didFailWithError(networkError)
                    }
                }
            }
    }
    
    
    // MARK: Общий обработчик ответов
    private func handleBooksResponse(_ response: AFDataResponse<GoogleBooksResponse>) {
        switch response.result {
        case .success(let googleResponse):
            let books = (googleResponse.items ?? []).map { Book(from: $0) }
            print("Successfully loaded \(books.count) books")
            
            DispatchQueue.main.async {
                self.delegate?.didFetchBooks(books)
            }
            
        case .failure(let error):
            print("Error: \(error)")
            let networkError = self.mapError(response: response)
            
            DispatchQueue.main.async { [weak self] in
                self?.delegate?.didFailWithError(networkError)
            }
        }
    }
    
    /// Преобразование ошибок Alamofire в NetworkError
    private func mapError<T>(response: AFDataResponse<T>) -> NetworkError {
        if let statusCode = response.response?.statusCode {
            return .serverError(statusCode)
        } else if response.data == nil {
            return .noData
        } else if response.error?.isResponseSerializationError == true {
            return .decodingError
        } else if let error = response.error {
            return .networkFailure(error)
        } else {
            return .unknown
        }
    }
}
