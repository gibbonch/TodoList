import Foundation
import Network

protocol NetworkClientProtocol {
    
    func fetchData<T: Decodable>(from url: String,
                                 type: T.Type,
                                 completion: @escaping (Result<T, any Error>) -> Void)
}

final class NetworkClient: NetworkClientProtocol {
    
    private let session: URLSession
    
    init(session: URLSession = .shared) {
        self.session = session
    }
    
    func fetchData<T: Decodable>(from url: String,
                                 type: T.Type,
                                 completion: @escaping (Result<T, any Error>) -> Void) {
        
        guard let url = URL(string: url) else {
            completion(.failure(NetworkError.invalidURL))
            return
        }
        
        let request = URLRequest(url: url)
        
        session.dataTask(with: request) { data, response, error in
            if let error = error {
                completion(.failure(NetworkError.urlRequestError(error)))
                return
            }
            
            guard let httpResponse = response as? HTTPURLResponse else {
                completion(.failure(NetworkError.urlSessionError))
                return
            }
            
            guard (200..<300).contains(httpResponse.statusCode) else {
                completion(.failure(NetworkError.httpStatusCode(httpResponse.statusCode)))
                return
            }
            
            guard let data = data else {
                completion(.failure(NetworkError.urlSessionError))
                return
            }
            
            do {
                let decoded = try JSONDecoder().decode(T.self, from: data)
                completion(.success(decoded))
            } catch {
                completion(.failure(NetworkError.decodingError))
            }
        }.resume()
    }
}
