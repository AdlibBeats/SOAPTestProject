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

protocol NetworkServiceProtocol {
    var token: String { get set }
}

protocol SOAPTestServiceProtocol: NetworkServiceProtocol {
    func fetchToken() -> Observable<String>
    func fetchOptimalFaresOffers(with outboundDate: Date?) -> Observable<[OptimalFaresOffer]>
}

final class SOAPTestService {
    var token = ""
    
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
    
    func makeURLRequest(with url: URL, _ body: String) -> URLRequest {
        URLRequest(url: url).with {
            $0.httpMethod = "POST"
            $0.addValue("text/xml; charset=utf-8", forHTTPHeaderField: "Content-Type")
            $0.addValue("\(body.count)", forHTTPHeaderField: "Content-Length")
            $0.httpBody = body.data(
                using: String.Encoding.utf8,
                allowLossyConversion: false
            )
        }
    }
}

extension SOAPTestService: SOAPTestServiceProtocol {
    func fetchToken() -> Observable<String> {
        Observable.create { [weak self] subscriber in
            let message = Config.Messages.startSession
            let body = message.makeBody()
            guard
                let url = URL(string: "\(Config.baseUrl.rawValue)\(Config.travelshop.rawValue)"),
                let urlRequest = self?.makeURLRequest(with: url, body) else {
                    subscriber.onError(URLError.invalid)
                return Disposables.create()
            }
            
            return URLSession.shared.rx.response(request: urlRequest)
                .subscribe(
                    onNext: { response, data in
                        guard let dataString = String(
                            data: data,
                            encoding: String.Encoding(rawValue: String.Encoding.utf8.rawValue)
                        ) else {
                            return subscriber.onNext("")
                        }
                        
                        let xml = SWXMLHash.parse(dataString)
                        
                        do {
                            return subscriber.onNext(try xml["env:Envelope"]["env:Body"]["ns1:\(message.makeTile())Output"]["ns1:session_token"].value())
                        } catch {
                            subscriber.onError(error)
                        }
                    }, onError: { error in subscriber.onError(error) }
                )
        }
    }
    
    func fetchOptimalFaresOffers(with outboundDate: Date?) -> Observable<[OptimalFaresOffer]> {
        Observable.create { [weak self] subscriber in
            
            let message = Config.Messages.getOptimalFares(
                token: self?.token ?? "",
                outboundDate: { (date: Date?) -> String in
                    guard let date = date else { return "" }
                    return DateFormatter().with { $0.dateFormat = "dd.MM.yyyy" }.string(from: date)
                }(outboundDate)
            )
            let body = message.makeBody()
            guard
                let url = URL(string: "\(Config.baseUrl.rawValue)\(Config.travelshop.rawValue)"),
                let urlRequest = self?.makeURLRequest(with: url, body) else {
                    subscriber.onError(URLError.invalid)
                return Disposables.create()
            }
            
            return URLSession.shared.rx.response(request: urlRequest)
                .subscribe(
                    onNext: { response, data in
                        guard let dataString = String(
                            data: data,
                            encoding: String.Encoding(rawValue: String.Encoding.utf8.rawValue)
                        ) else {
                            return subscriber.onNext([])
                        }
                        
                        let xml = SWXMLHash.parse(dataString)
                        
                        do {
                            let result: [OptimalFaresOffer] = try xml["env:Envelope"]["env:Body"]["ns1:GetOptimalFaresOutput"]["ns1:offers"]["ns1:GetOptimalFaresOffer"].value()
                            return subscriber.onNext(result)
                        } catch {
                            subscriber.onError(error)
                        }
                    }, onError: { error in subscriber.onError(error) }
                )
        }
    }
}
