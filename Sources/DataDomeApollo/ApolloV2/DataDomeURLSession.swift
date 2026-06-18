//
//  DataDomeURLSession+ApolloV2.swift
//  DataDomeApollo
//
//  Apollo iOS v2 support, built on the `ApolloURLSession` transport API.
//  Compiled only when the `ApolloV2` trait is enabled.
//

#if ApolloV2
import Foundation
import Apollo
import ApolloAPI
import CoreDataDome

/// A CoreDataDome `ApolloURLSession` for Apollo iOS v2.
///
/// DataDome detects a challenge from the response headers (`x-dd-b` / `x-sf-cc-x-dd-b`) —
/// **independent of the HTTP status code** — so a challenge can ride on a `2xx` response just as easily as a
/// `403`. The interceptor layers can't host this: a `GraphQLInterceptor` never sees the raw response, and an
/// `HTTPInterceptor` can neither read the body in `intercept` nor re-issue the request. The transport
/// (`ApolloURLSession`) is the one layer that sees the raw response for *every* request and can re-fetch
/// freely, so DataDome lives here — which also mirrors how DataDome intercepts at the network layer in its
/// other SDKs.
///
/// `chunks(for:)` hands **every** response to CoreDataDome's `validateResponse`, with a lazy body provider:
/// CoreDataDome runs its own header check and only reads the body when the response is actually a challenge,
/// so there is no detection logic duplicated here and non-challenge responses stream through untouched. On a
/// resolved challenge it re-fetches with the fresh cookie. Because this loop is *below* Apollo's request chain
/// it is **invisible to `MaxRetryInterceptor`** and to the integrator's own interceptors, so the retry is
/// genuinely **unbounded and user-driven** — it ends only when the user resolves the challenge (`.allowed`),
/// is blocked (`.blocked`), or dismisses it (`.error`).
public struct DataDomeURLSession: ApolloURLSession {

    /// The CoreDataDome SDK instance used to validate responses.
    private let dataDome: DataDome

    /// The underlying session that performs the actual network fetch.
    private let wrapped: any ApolloURLSession

    /// Creates a DataDome-validating session that wraps another `ApolloURLSession`.
    /// - Parameters:
    ///   - dataDome: The `DataDome` instance that validates intercepted responses.
    ///   - wrapped: The session that performs the actual network fetch. Defaults to
    ///     `URLSession(configuration: .default)`.
    public init(dataDome: DataDome, wrapping wrapped: any ApolloURLSession = URLSession(configuration: .default)) {
        self.dataDome = dataDome
        self.wrapped = wrapped
    }

    public func chunks(for request: URLRequest) async throws -> (any AsyncChunkSequence, URLResponse) {
        let dataDome = self.dataDome
        // Without a request URL CoreDataDome can neither validate nor present a response page; pass through.
        guard let requestURL = request.url else {
            return try await wrapped.chunks(for: request)
        }

        while true {
            let (chunks, response) = try await wrapped.chunks(for: request)
            guard let httpResponse = response as? HTTPURLResponse else {
                return (chunks, response)
            }

            let headers = httpResponse.allHeaderFields.reduce(into: [String: String]()) { result, pair in
                if let key = pair.key as? String, let value = pair.value as? String {
                    result[key] = value
                }
            }

            // Hand CoreDataDome a lazy body provider. It runs its own header check and only invokes the
            // provider when the response is a challenge that needs the body — so a non-challenge response is
            // never buffered, and there is no challenge-detection logic duplicated here.
            let collected = CollectedBody()
            let ddResponse = DataDomeResponse(statusCode: httpResponse.statusCode,
                                              headers: headers,
                                              bodyProvider: { try await collected.resolve { try await Self.buffer(chunks) } })

            switch await dataDome.validateResponse(ddResponse, requestURL: requestURL) {
            case .needRetry:
                // The user resolved the challenge and a fresh cookie is set; re-issue the request. This loops
                // for as long as the user keeps resolving challenges — deliberately not bounded.
                continue
            case .blocked:
                throw DataDomeError.blocked
            case .allowed, .error:
                break
            @unknown default:
                break
            }

            // Not a retry/block. If CoreDataDome read the body the original stream is consumed, so re-emit the
            // buffered copy; if it never touched the body (non-challenge), return the untouched stream so it
            // reaches the parser intact; if the body read itself failed, surface that error.
            switch await collected.result {
            case nil:
                return (chunks, response)
            case .success(let data)?:
                return (SingleChunkSequence(data: data ?? Data()), response)
            case .failure(let error)?:
                throw error
            }
        }
    }

    /// Reads an entire chunk stream into a single `Data`. Generic so the caller's existential
    /// `any AsyncChunkSequence` is opened to its concrete type for iteration.
    private static func buffer<S: AsyncChunkSequence>(_ chunks: S) async throws -> Data {
        var body = Data()
        for try await chunk in chunks {
            body.append(chunk)
        }
        return body
    }
}

/// Reads the response body at most once and caches the result (value or error). CoreDataDome may access
/// `DataDomeResponse.body` more than once while validating, but the underlying chunk stream is consume-once.
private actor CollectedBody {
    private var outcome: Result<Data?, any Error>?

    /// Runs `read` once, caching its outcome; subsequent calls return the cached value or rethrow.
    func resolve(_ read: @Sendable () async throws -> Data?) async throws -> Data? {
        if let outcome {
            return try outcome.get()
        }
        do {
            let data = try await read()
            outcome = .success(data)
            return data
        } catch {
            outcome = .failure(error)
            throw error
        }
    }

    /// The captured outcome, or `nil` if `resolve` was never called (CoreDataDome never read the body).
    var result: Result<Data?, any Error>? { outcome }
}

/// An ``AsyncChunkSequence`` that re-emits a single buffered `Data` value — used to hand a buffered
/// challenge response back to Apollo's request chain.
struct SingleChunkSequence: AsyncChunkSequence {
    let data: Data

    func makeAsyncIterator() -> AsyncIterator {
        AsyncIterator(data: data)
    }

    struct AsyncIterator: AsyncIteratorProtocol {
        var data: Data?

        mutating func next() async throws -> Data? {
            defer { data = nil }
            return data
        }
    }
}
#endif
