//
//  URLProtocolMock.swift
//  TidepoolServiceKitTests
//
//  Created by Rick Pasetto on 9/15/21.
//  Copyright © 2021 LoopKit Authors. All rights reserved.
//

import Foundation
import XCTest

class URLProtocolMock: URLProtocol {
    static var handlers: [Handler] = []

    override class func canInit(with request: URLRequest) -> Bool { true }

    override class func canonicalRequest(for request: URLRequest) -> URLRequest { request }

    override func startLoading() {
        guard !Self.handlers.isEmpty else {
            XCTFail("Unexpected request")
            return
        }

        Self.handlers.removeFirst().handle(self)
    }

    override func stopLoading() {}

    struct Handler {
        var validator: Validator
        var error: Error?
        var success: Success?

        init(validator: Validator, error: Error) {
            self.validator = validator
            self.error = error
            self.success = nil
        }

        init(validator: Validator, success: Success) {
            self.validator = validator
            self.error = nil
            self.success = success
        }

        func handle(_ urlProtocol: URLProtocol) {
            guard let client = urlProtocol.client else {
                return
            }

            validator.validate(request: urlProtocol.request)

            if let error = error {
                client.urlProtocol(urlProtocol, didFailWithError: error)
            } else if let success = success, let url = urlProtocol.request.url, let urlResponse = success.response(for: url) {
                client.urlProtocol(urlProtocol, didReceive: urlResponse, cacheStoragePolicy: .notAllowed)
                if let body = success.body {
                    client.urlProtocol(urlProtocol, didLoad: body)
                }
            }

            client.urlProtocolDidFinishLoading(urlProtocol)
        }
    }

    struct Validator {
        var url: URL
        var method: String
        var headers: [String: String]?
        var body: Data?

        init(url: String, method: String, headers: [String: String]? = nil, body: Data? = nil) {
            self.url = URL(string: url)!
            self.method = method
            self.headers = headers
            self.body = body
        }

        init<E>(url: String, method: String, headers: [String: String]? = nil, body: E) where E: Encodable {
            self.init(url: url, method: method, headers: headers, body: try? JSONEncoder.tidepool.encode(body))
        }

        func validate(request: URLRequest) {
            XCTAssertEqual(request.url, url)
            XCTAssertEqual(request.httpMethod, method)
            if let headers = headers {
                XCTAssertNotNil(request.allHTTPHeaderFields)
                if let allHTTPHeaderFields = request.allHTTPHeaderFields {
                    for (key, value) in headers {
                        XCTAssertEqual(allHTTPHeaderFields[key], value)
                    }
                }
            }
            if let body = body {
                if let httpBodyStream = request.httpBodyStream {
                    XCTAssertEqual(Data(from: httpBodyStream), body)
                } else {
                    XCTAssertEqual(request.httpBody, body)
                }
            }
        }
    }

    struct Success {
        var statusCode: Int
        var headers: [String: String]?
        var body: Data?

        init(statusCode: Int, headers: [String: String]? = nil, body: Data? = nil) {
            self.statusCode = statusCode
            self.headers = headers
            self.body = body
        }

        init<E>(statusCode: Int, headers: [String: String]? = nil, body: E) where E: Encodable {
            self.init(statusCode: statusCode, headers: headers, body: try? JSONEncoder.tidepool.encode(body))
        }

        mutating func set<E>(body: E) where E: Encodable {
            self.body = try? JSONEncoder.tidepool.encode(body)
        }

        func response(for url: URL) -> URLResponse? {
            return HTTPURLResponse(url: url, statusCode: statusCode, httpVersion: "HTTP/1.1", headerFields: headers)
        }
    }
}

fileprivate extension Data {
    private static let bufferSize = 2048

    init?(from inputStream: InputStream) {
        self.init()

        inputStream.open()
        let buffer = UnsafeMutablePointer<UInt8>.allocate(capacity: Self.bufferSize)
        while inputStream.hasBytesAvailable {
            let bytesRead = inputStream.read(buffer, maxLength: Self.bufferSize)
            guard bytesRead >= 0 else {
                return nil
            }
            self.append(buffer, count: bytesRead)
        }
        buffer.deallocate()
        inputStream.close()
    }
}
