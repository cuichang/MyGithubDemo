//
//  MyGithubDemoTests.swift
//  MyGithubDemoTests
//

import XCTest
@testable import MyGithubDemo

final class HomeViewModelTests: XCTestCase {

    var sut: HomeViewModel!
    var mockNetworkService: MockNetworkService!

    override func setUp() {
        super.setUp()
        mockNetworkService = MockNetworkService()
        sut = HomeViewModel(networkService: mockNetworkService)
    }

    override func tearDown() {
        sut = nil
        mockNetworkService = nil
        super.tearDown()
    }

    func testLoadTrendingRepos_Success() {
        // Given
        let expectedRepos = [
            Repository.mock(id: 1, name: "Repo1"),
            Repository.mock(id: 2, name: "Repo2")
        ]
        mockNetworkService.mockResult = .success(expectedRepos)

        let expectation = XCTestExpectation(description: "Load repos")

        sut.repositories.bind { repos in
            if repos.count == 2 {
                expectation.fulfill()
            }
        }

        // When
        sut.loadTrendingRepos()

        // Then
        wait(for: [expectation], timeout: 1.0)
        XCTAssertEqual(sut.repositories.value.count, 2)
        XCTAssertFalse(sut.isLoading.value)
    }

    func testRepositoryAtIndex_ValidIndex_ReturnsRepository() {
        // Given
        let repo = Repository.mock(id: 1, name: "TestRepo")
        sut.repositories.value = [repo]

        // When
        let result = sut.repository(at: 0)

        // Then
        XCTAssertNotNil(result)
        XCTAssertEqual(result?.name, "TestRepo")
    }

    func testRepositoryAtIndex_InvalidIndex_ReturnsNil() {
        // Given
        sut.repositories.value = []

        // When
        let result = sut.repository(at: 0)

        // Then
        XCTAssertNil(result)
    }
}

// MARK: - Mock Network Service

class MockNetworkService: NetworkServiceProtocol {

    var mockResult: Result<[Repository], NetworkError>?

    func request<T: Decodable>(_ endpoint: Endpoint, completion: @escaping (Result<T, NetworkError>) -> Void) {
        if let result = mockResult as? Result<T, NetworkError> {
            completion(result)
        }
    }

    func request(_ endpoint: Endpoint, completion: @escaping (Result<Data?, NetworkError>) -> Void) {
        completion(.success(nil))
    }
}

// MARK: - Repository Mock

extension Repository {
    static func mock(id: Int, name: String) -> Repository {
        Repository(
            id: id,
            name: name,
            fullName: "owner/\(name)",
            owner: Owner(
                id: 1,
                login: "owner",
                avatarUrl: "https://example.com/avatar.png",
                htmlUrl: "https://github.com/owner"
            ),
            description: "Test repository",
            htmlUrl: "https://github.com/owner/\(name)",
            stargazersCount: 100,
            watchersCount: 50,
            forksCount: 20,
            openIssuesCount: 5,
            language: "Swift",
            isPrivate: false,
            isFork: false,
            createdAt: "2024-01-01T00:00:00Z",
            updatedAt: "2024-01-01T00:00:00Z"
        )
    }
}
