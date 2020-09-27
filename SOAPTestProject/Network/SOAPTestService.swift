//
//  SOAPTestService.swift
//  SOAPTestProject
//
//  Created by Andrew on 18.09.2020.
//  Copyright © 2020 Andrew. All rights reserved.
//

import RxCocoa
import RxSwift
import SWXMLHash

enum NetworkServiceHTTPMethod: String {
    case get = "GET"
    case post = "POST"
    case put = "PUT"
    case delete = "DELETE"
}

protocol NetworkServiceProtocol: class {
    func setToken(_ token: String)
    func fetchUrl(from string: String) -> Observable<URL>
    func fetchURLRequest(from url: String, _ httpMethod: NetworkServiceHTTPMethod, _ body: String) -> Observable<URLRequest>
    func fetchResponse(from request: URLRequest) -> Observable<(response: HTTPURLResponse, data: Data)>
    func fetchStringResponse(from data: Data) -> Observable<String>
}

extension NetworkServiceProtocol {
    func fetchUrl(from string: String) -> Observable<URL> {
        Observable.create {
            guard let url = URL(string: string) else {
                $0.onError(RxCocoaURLError.unknown)
                return Disposables.create()
            }
            $0.onNext(url)
            return Disposables.create()
        }
    }
    
    func fetchURLRequest(from url: String, _ httpMethod: NetworkServiceHTTPMethod, _ body: String) -> Observable<URLRequest> {
        fetchUrl(from: url).map {
            URLRequest(url: $0).with {
                $0.httpMethod = httpMethod.rawValue
                $0.addValue("text/xml; charset=utf-8", forHTTPHeaderField: "Content-Type")
                $0.addValue("\(body.count)", forHTTPHeaderField: "Content-Length")
                $0.httpBody = body.data(
                    using: String.Encoding.utf8,
                    allowLossyConversion: false
                )
            }
        }
    }
    
    func fetchResponse(from request: URLRequest) -> Observable<(response: HTTPURLResponse, data: Data)> {
        URLSession.shared.rx.response(request: request)
    }
    
    func fetchStringResponse(from data: Data) -> Observable<String> {
        Observable.create {
            guard let result = String(
                data: data,
                encoding: String.Encoding(rawValue: String.Encoding.utf8.rawValue)
            ) else {
                $0.onError(RxCocoaError.unknown)
                return Disposables.create()
            }
            $0.onNext(result)
            return Disposables.create()
        }
    }
}

class NetworkService {
    fileprivate var token = ""
}

extension NetworkService: NetworkServiceProtocol {
    func setToken(_ token: String) {
        self.token = token
    }
}

protocol SOAPTestServiceProtocol: NetworkServiceProtocol {
    func fetchToken() -> Observable<String>
    func fetchOptimalFaresOffers(with outboundDate: Date?) -> Observable<[OptimalFaresOffer]>
}

final class SOAPTestService: NetworkService {
    enum URLError: Error {
        case invalid
    }
    
    enum Config: String {
        case baseUrl = "http://api.biletix.ru"
        case travelshop = "/bitrix/components/travelshop/ibe.soap/travelshop_booking.php?wsdl"
        
        enum Messages {
            case startSession
            case getOptimalFares(token: String, outboundDate: String)
        }
    }
}

extension SOAPTestService: SOAPTestServiceProtocol {
    func fetchToken() -> Observable<String> {
        fetchURLRequest(
            from: "\(Config.baseUrl.rawValue)\(Config.travelshop.rawValue)",
            .post,
            Config.Messages.startSession.makeBody()
        ).flatMapLatest(fetchResponse).map { $0.data }.flatMapLatest(fetchStringResponse).flatMapLatest { response in
            Observable.create {
                do {
                    $0.onNext(try SWXMLHash.parse(response)
                        .byKey("env:Envelope")
                        .byKey("env:Body")
                        .byKey("ns1:StartSessionOutput")
                        .byKey("ns1:session_token")
                        .value()
                    )
                    return Disposables.create()
                } catch {
                    $0.onError(XMLDeserializationError.nodeHasNoValue)
                }
                return Disposables.create()
            }
        }
    }
    
    func fetchOptimalFaresOffers(with outboundDate: Date?) -> Observable<[OptimalFaresOffer]> {
        fetchURLRequest(
            from: "\(Config.baseUrl.rawValue)\(Config.travelshop.rawValue)",
            .post,
            Config.Messages.getOptimalFares(
                token: token,
                outboundDate: { (date: Date?) -> String in
                    guard let date = date else { return "" }
                    return DateFormatter().with { $0.dateFormat = "dd.MM.yyyy" }.string(from: date)
                }(outboundDate)
            ).makeBody()
        ).flatMapLatest(fetchResponse).map { $0.data }.flatMapLatest(fetchStringResponse).flatMapLatest { response in
            Observable.create {
                do {
                    $0.onNext(try SWXMLHash.parse(response)
                        .byKey("env:Envelope")
                        .byKey("env:Body")
                        .byKey("ns1:GetOptimalFaresOutput")
                        .byKey("ns1:offers")
                        .byKey("ns1:GetOptimalFaresOffer")
                        .value()
                    )
                    return Disposables.create()
                } catch {
                    $0.onError(XMLDeserializationError.nodeHasNoValue)
                }
                return Disposables.create()
            }
        }
    }
}
