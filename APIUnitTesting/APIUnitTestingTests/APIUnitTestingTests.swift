//
//  APIUnitTestingTests.swift
//  APIUnitTestingTests
//
//  Created by rajnikanthole on 20/07/24.
//

import XCTest
@testable import APIUnitTesting

class MockNetworkingService: NetworkingLayer {
    func fetchData(url: URL, completion: @escaping (Data?, Error?) -> Void) {
        // Fetch Mockfrom UnitTestData.json file
        
        guard let pathString = Bundle(for: type(of: self)).path(forResource: "UnitTestData", ofType: "json") else {
            fatalError("UnitTestData.json not found")
        }
        
        do {
            let data = try Data(contentsOf: URL(fileURLWithPath: pathString), options: .mappedIfSafe)
            
            completion(data, nil)
            
        } catch {
            completion(nil, error)
        }
    }
}

final class APIUnitTestingTests: XCTestCase {
    
    var apiClient: SongsAPIClient!
    
    func testFetchData() throws {
        let expectation = self.expectation(description: "Fetch songs data")
        apiClient.fetchData { result in
            switch result {
            case .success(let movie):
                XCTAssertEqual(movie.title, "Songs")
                XCTAssertEqual(movie.genre, "Good")
            case .failure(let error):
                XCTFail("Error: \(error.localizedDescription)")
            }
            expectation.fulfill()
        }
        wait(for: [expectation], timeout: 5.0)
    }
    
    override func setUpWithError() throws {
        let mockNetworkingService = MockNetworkingService()
        apiClient = SongsAPIClient(networkingService: mockNetworkingService)
    }
    
    override func tearDownWithError() throws {
        apiClient = nil
        super.tearDown()
    }
    
    func testPerformanceExample() throws {
        // This is an example of a performance test case.
        self.measure {
            // Put the code you want to measure the time of here.
        }
    }
    
}
