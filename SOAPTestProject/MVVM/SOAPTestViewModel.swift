//
//  SOAPTestViewModel.swift
//  SOAPTestProject
//
//  Created by Andrew on 19.09.2020.
//  Copyright © 2020 Andrew. All rights reserved.
//

import RxCocoa
import RxSwift

protocol SOAPTestViewModelProtocol {
    func transform(with input: SOAPTestViewModel.Input) -> SOAPTestViewModel.Output
}

final class SOAPTestViewModel {
    private var testService: SOAPTestServiceProtocol
    
    init(with testService: SOAPTestServiceProtocol) {
        self.testService = testService
    }
}

extension SOAPTestViewModel: SOAPTestViewModelProtocol {
    struct Input {
        
    }
    
    struct Output {
        let loading: Driver<Bool>
        let source: Driver<[SOAPTestModel]>
    }
    
    func transform(with input: Input) -> Output {
        let loadingRelay = BehaviorRelay<Bool>(value: true)
        
        return Output(
            loading: loadingRelay.asDriver().distinctUntilChanged(),
            source: testService.fetchToken()
                .do(onNext: { [weak self] in self?.testService.setToken($0) })
                .map { _ in DateFormatter().with { $0.dateFormat = "dd.MM.yyyy" }.date(from: "25.09.2020") }
                .flatMapLatest(testService.fetchOptimalFaresOffers)
                .map {
                    $0.filter { $0.ak == "S7" }.flatMap { offer in
                        (offer.directions ?? []).flatMap { $0.flights ?? [] }.flatMap { $0.segments ?? [] }.map {
                            SOAPTestModel(
                                ak: $0.ak ?? "",
                                departureDate: { (date: Date?) -> String in
                                    guard let date = date else { return "" }
                                    return DateFormatter().with { $0.dateFormat = "dd.MM.yyyy" }.string(from: date)
                                }($0.departureDate),
                                departureTime: { (date: Date?) -> String in
                                    guard let date = date else { return "" }
                                    return DateFormatter().with { $0.dateFormat = "HH:mm" }.string(from: date)
                                }($0.departureTime),
                                arrivalDate: { (date: Date?) -> String in
                                    guard let date = date else { return "" }
                                    return DateFormatter().with { $0.dateFormat = "dd.MM.yyyy" }.string(from: date)
                                }($0.arrivalDate),
                                arrivalTime: { (date: Date?) -> String in
                                    guard let date = date else { return "" }
                                    return DateFormatter().with { $0.dateFormat = "HH:mm" }.string(from: date)
                                }($0.arrivalTime),
                                flightNumber: $0.flightNumber ?? "",
                                totalPrice: offer.totalPrice ?? "",
                                durationTime: $0.durationTime,
                                departureAirportCode: $0.departureAirportCode ?? "",
                                arrivalAirportCode: $0.arrivalAirportCode ?? ""
                            )
                        }
                    }
                }
                .asDriver(onErrorDriveWith: .empty())
                .distinctUntilChanged()
                .do(onNext: { loadingRelay.accept($0.isEmpty) })
        )
    }
}
