//
//  ViewController.swift
//  APIUnitTesting
//
//  Created by rajnikanthole on 20/07/24.
//

import UIKit


struct Songs: Codable {
    var title: String?
    var genre: String?
}

protocol NetworkingLayer {
    func fetchData(url: URL, completion: @escaping (Data?, Error?) -> Void)
}

class APINetworkingService: NetworkingLayer {
    func fetchData(url: URL, completion: @escaping (Data?, Error?) -> Void) {
        let task = URLSession.shared.dataTask(with: url) { data, response, error in
            if let error = error {
                completion(nil, error)
                return
            }
            
            guard let httpResponse = response as? HTTPURLResponse, (200...299).contains(httpResponse.statusCode) else {
                let error = NSError(domain: "", code: 0, userInfo: [NSLocalizedDescriptionKey: "Invalid response"])
                completion(nil, error)
                return
            }
            
            guard let data = data else {
                let error = NSError(domain: "", code: 0, userInfo: [NSLocalizedDescriptionKey: "No data"])
                completion(nil, error)
                return
            }
            completion(data, nil)
        }
        task.resume()
    }
    
    
}
class ViewController: UIViewController {
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        let apiNetworkingService = APINetworkingService()
        let  apiClient = SongsAPIClient(networkingService: apiNetworkingService)
        
        apiClient.fetchData { result in
            switch result {
            case .success(let songs):
                print("songs")
            case .failure(let error):
                print("error")
            }
        }
        // Do any additional setup after loading the view.
    }
    
}

class SongsAPIClient {
    private let networkingService: NetworkingLayer
    
    init(networkingService: NetworkingLayer) {
        self.networkingService = networkingService
    }
    func fetchData(completion: @escaping (Result<Songs, Error>) -> ()) {
        guard let url = URL(string: "https://mocki.io/v1/404c3427-efd4-4373-ab42-9fa2e4f82016") else {
            return
        }
        networkingService.fetchData(url: url) { data, error in
            if let error = error {
                completion(.failure(error))
                return
            }
            let decoder = JSONDecoder()
            do {
                let movie = try decoder.decode(Songs.self, from: data!)
                completion(.success(movie))
            } catch {
                completion(.failure(error))
            }
        }
    }
}
