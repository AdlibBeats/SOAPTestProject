//
//  SOAPTestModel.swift
//  SOAPTestProject
//
//  Created by Andrew on 19.09.2020.
//  Copyright © 2020 Andrew. All rights reserved.
//

import Foundation

struct SOAPTestModel: Identifiable {
    let id = UUID()
    let ak: String
    let departureDate: String
    let departureTime: String
    let arrivalDate: String
    let arrivalTime: String
    let flightNumber: String
    let totalPrice: String
    let durationTime: String
    let departureAirportCode: String
    let arrivalAirportCode: String
}

extension SOAPTestModel: Equatable {
    static func == (lhs: SOAPTestModel, rhs: SOAPTestModel) -> Bool {
        lhs.id == rhs.id
    }
}
