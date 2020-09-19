//
//  SAOPTestResponse.swift
//  SOAPTestProject
//
//  Created by Andrew on 19.09.2020.
//  Copyright © 2020 Andrew. All rights reserved.
//

import SWXMLHash

private extension Int {
    var hours: Int { self / 3600 }
    var minutes: Int { (self % 3600) / 60 }
}

struct OptimalFaresOffer: XMLIndexerDeserializable {
    struct Product: XMLIndexerDeserializable {
        let passcat: String?
        let price: String?
        let fare: String?
        let taxes: String?
        let count: Int?
        let sumPrice: String?
        //<ns1:fares/>
        
        static func deserialize(_ node: XMLIndexer) throws -> Product {
            try Product(
                passcat: node["ns1:passcat"].value(),
                price: node["ns1:price"].value(),
                fare: node["ns1:fare"].value(),
                taxes: node["ns1:taxes"].value(),
                count: node["ns1:count"].value(),
                sumPrice: node["ns1:sum_price"].value()
            )
        }
    }
    
    struct OptimalFaresDirection: XMLIndexerDeserializable {
        struct OptimalFaresFlight: XMLIndexerDeserializable {
            struct AirSegment: XMLIndexerDeserializable {
                let ak: String?
                let oak: String?
                let flightNumber: String?
                let departureTime: Date?
                let arrivalTime: Date?
                let departureAirportCode: String?
                let arrivalAirportCode: String?
                let departureDate: Date?
                let arrivalDate: Date?
                let arrivalUTC: Date?
                let departureUTC: Date?
                let duration: Int?
                
                var durationTime: String {
                    guard let duration = duration else { return "" }
                    return "\(duration.hours):\(duration.minutes)"
                }
                
                let className: String?
                let rbd: String?
                let layoverTime: String?
                let direction: String?
                //<ns1:stops/>
                let bagType: String?
                let bagAllowance: String?
                let doctypeList: String?
                let fareCodes: String?
                
                static func deserialize(_ node: XMLIndexer) throws -> AirSegment {
                    try AirSegment(
                        ak: node["ns1:ak"].value(),
                        oak: node["ns1:oak"].value(),
                        flightNumber: node["ns1:flight_number"].value(),
                        departureTime: DateFormatter().with {
                            $0.dateFormat = "HH:mm"
                        }.date(from: node["ns1:departure_time"].value()),
                        arrivalTime: DateFormatter().with {
                            $0.dateFormat = "HH:mm"
                        }.date(from: node["ns1:arrival_time"].value()),
                        departureAirportCode: node["ns1:departure_airport_code"].value(),
                        arrivalAirportCode: node["ns1:arrival_airport_code"].value(),
                        departureDate: DateFormatter().with {
                            $0.dateFormat = "dd.MM.yyyy"
                        }.date(from: node["ns1:departure_date"].value()),
                        arrivalDate: DateFormatter().with {
                            $0.dateFormat = "dd.MM.yyyy"
                        }.date(from: node["ns1:arrival_date"].value()),
                        arrivalUTC: DateFormatter().with {
                            $0.dateFormat = "dd.MM.yyyy HH:mm:ss"
                        }.date(from: node["ns1:arrival_utc"].value()),
                        departureUTC: DateFormatter().with {
                            $0.dateFormat = "dd.MM.yyyy HH:mm:ss"
                        }.date(from: node["ns1:departure_utc"].value()),
                        duration: node["ns1:duration"].value(),
                        className: node["ns1:class"].value(),
                        rbd: node["ns1:rbd"].value(),
                        layoverTime: node["ns1:layover_time"].value(),
                        direction: node["ns1:direction"].value(),
                        bagType: node["ns1:bagtype"].value(),
                        bagAllowance: node["ns1:bagallowance"].value(),
                        doctypeList: node["ns1:doctype_list"].value(),
                        fareCodes: node["ns1:fare_codes"].value()
                    )
                }
            }
            
            let duration: Int?
            
            var durationTime: String {
                guard let duration = duration else { return "" }
                return "\(duration.hours):\(duration.minutes)"
            }
            
            let offerId: String?
            let seatCount: String?
            //<ns1:stops/>
            //<ns1:link/>
            let flightId: String?
            //<ns1:linked_flight_ids/>
            let segments: [AirSegment]?
            
            static func deserialize(_ node: XMLIndexer) throws -> OptimalFaresFlight {
                try OptimalFaresFlight(
                    duration: node["ns1:duration"].value(),
                    offerId: node["ns1:offer_id"].value(),
                    seatCount: node["ns1:seat_count"].value(),
                    flightId: node["ns1:flight_id"].value(),
                    segments: node["ns1:segments"]["ns1:AirSegment"].value()
                )
            }
        }
        let direction: String?
        let date: Date?
        let flights: [OptimalFaresFlight]?
        
        static func deserialize(_ node: XMLIndexer) throws -> OptimalFaresDirection {
            try OptimalFaresDirection(
                direction: node["ns1:direction"].value(),
                date: DateFormatter().with {
                    $0.dateFormat = "dd.MM.yyyy"
                }.date(from: node["ns1:date"].value()),
                flights: node["ns1:flights"]["ns1:GetOptimalFaresFlight"].value()
            )
        }
    }
    
    let ak: String?
    let charter: String?
    let block: String?
    let transitVisaRequired: String?
    let latinOnly: String?
    let products: [Product]?
    let totalPrice: String?
    let penalty: String?
    let multipnr: String?
    let timeLimit: Date?
    let link: String?
    let fareId: String?
    //<ns1:linked_fare_ids/>
    let directions: [OptimalFaresDirection]?
    
    static func deserialize(_ node: XMLIndexer) throws -> OptimalFaresOffer {
        try OptimalFaresOffer(
            ak: node["ns1:ak"].value(),
            charter: node["ns1:charter"].value(),
            block: node["ns1:block"].value(),
            transitVisaRequired: node["ns1:transit_visa_required"].value(),
            latinOnly: node["ns1:latin_only"].value(),
            products: node["ns1:products"]["ns1:Product"].value(),
            totalPrice: node["ns1:total_price"].value(),
            penalty: node["ns1:penalty"].value(),
            multipnr: node["ns1:multipnr"].value(),
            timeLimit: DateFormatter().with {
                $0.dateFormat = "dd.MM.yyyy HH:mm:ss"
            }.date(from: node["ns1:timelimit"].value()),
            link: node["ns1:link"].value(),
            fareId: node["ns1:fare_id"].value(),
            directions: node["ns1:directions"]["ns1:GetOptimalFaresDirection"].value()
        )
    }
}
