//
//  SOAPTestTableViewCell.swift
//  SOAPTestProject
//
//  Created by Andrew on 19.09.2020.
//  Copyright © 2020 Andrew. All rights reserved.
//

import Cartography

extension SOAPTestViewController {
    final class SOAPTestTableViewCell: UITableViewCell {
        private let akLabel = UILabel().then {
            $0.font = .systemFont(ofSize: 14)
            $0.textColor = .darkGray
            $0.textAlignment = .left
        }
        
        private let departureDateLabel = UILabel().then {
            $0.font = .systemFont(ofSize: 14)
            $0.textColor = .darkGray
            $0.textAlignment = .left
        }
        
        private let departureTimeLabel = UILabel().then {
            $0.font = .systemFont(ofSize: 14)
            $0.textColor = .darkGray
            $0.textAlignment = .left
        }
        
        private let arrivalDateLabel = UILabel().then {
            $0.font = .systemFont(ofSize: 14)
            $0.textColor = .darkGray
            $0.textAlignment = .left
        }
        
        private let arrivalTimeLabel = UILabel().then {
            $0.font = .systemFont(ofSize: 14)
            $0.textColor = .darkGray
            $0.textAlignment = .left
        }
        
        private let flightNumberLabel = UILabel().then {
            $0.font = .systemFont(ofSize: 14)
            $0.textColor = .darkGray
            $0.textAlignment = .left
        }
        
        private let totalPriceLabel = UILabel().then {
            $0.font = .systemFont(ofSize: 14)
            $0.textColor = .darkGray
            $0.textAlignment = .left
        }
        
        private let durationTimeLabel = UILabel().then {
            $0.font = .systemFont(ofSize: 14)
            $0.textColor = .darkGray
            $0.textAlignment = .left
        }
        
        private let departureAirportCodeLabel = UILabel().then {
            $0.font = .systemFont(ofSize: 14)
            $0.textColor = .darkGray
            $0.textAlignment = .left
        }
        
        private let arrivalAirportCodeLabel = UILabel().then {
            $0.font = .systemFont(ofSize: 14)
            $0.textColor = .darkGray
            $0.textAlignment = .left
        }
        
        override init(style: UITableViewCell.CellStyle, reuseIdentifier: String?) {
            super.init(style: style, reuseIdentifier: reuseIdentifier)
            
            backgroundColor = .white
            
            [
                akLabel,
                departureDateLabel,
                departureTimeLabel,
                arrivalDateLabel,
                arrivalTimeLabel,
                flightNumberLabel,
                totalPriceLabel,
                durationTimeLabel,
                departureAirportCodeLabel,
                arrivalAirportCodeLabel
            ].forEach(addSubview)
            
            constrain(self, akLabel) { view, akLabel in
                akLabel.top == view.top + 16
                akLabel.left == view.left + 16
            }
            
            constrain(
                akLabel,
                departureDateLabel,
                departureTimeLabel,
                arrivalDateLabel,
                arrivalTimeLabel,
                flightNumberLabel,
                totalPriceLabel,
                durationTimeLabel,
                departureAirportCodeLabel,
                arrivalAirportCodeLabel
            ) {
                akLabel,
                departureDateLabel,
                departureTimeLabel,
                arrivalDateLabel,
                arrivalTimeLabel,
                flightNumberLabel,
                totalPriceLabel,
                durationTimeLabel,
                departureAirportCodeLabel,
                arrivalAirportCodeLabel in
                
                departureDateLabel.top == akLabel.bottom + 16
                departureDateLabel.left == akLabel.left + 16
                
                departureTimeLabel.top == departureDateLabel.bottom + 16
                departureTimeLabel.left == akLabel.left + 16
                
                arrivalDateLabel.top == departureTimeLabel.bottom + 16
                arrivalDateLabel.left == akLabel.left + 16
                
                arrivalTimeLabel.top == arrivalDateLabel.bottom + 16
                arrivalTimeLabel.left == akLabel.left + 16
                
                flightNumberLabel.top == arrivalTimeLabel.bottom + 16
                flightNumberLabel.left == akLabel.left + 16
                
                totalPriceLabel.top == flightNumberLabel.bottom + 16
                totalPriceLabel.left == akLabel.left + 16
                
                durationTimeLabel.top == totalPriceLabel.bottom + 16
                durationTimeLabel.left == akLabel.left + 16
                
                departureAirportCodeLabel.top == durationTimeLabel.bottom + 16
                departureAirportCodeLabel.left == akLabel.left + 16
            }
            
            constrain(
                self,
                akLabel,
                departureAirportCodeLabel,
                arrivalAirportCodeLabel
            ) { view, akLabel, departureAirportCodeLabel, arrivalAirportCodeLabel in
                arrivalAirportCodeLabel.top == departureAirportCodeLabel.bottom + 16
                arrivalAirportCodeLabel.left == akLabel.left + 16
                arrivalAirportCodeLabel.bottom == view.bottom - 16
            }
        }
        
        required init?(coder: NSCoder) {
            fatalError("init(coder:) has not been implemented")
        }
        
        var model: SOAPTestModel? {
            willSet {
                akLabel.text = "AK: \(newValue?.ak ?? "-")"
                departureDateLabel.text = "Departure date: \(newValue?.departureDate ?? "-")"
                departureTimeLabel.text = "Departure time: \(newValue?.departureTime ?? "-")"
                arrivalDateLabel.text = "Arrival date: \(newValue?.arrivalDate ?? "-")"
                arrivalTimeLabel.text = "Arrival time: \(newValue?.arrivalTime ?? "-")"
                flightNumberLabel.text = "Flight number: \(newValue?.flightNumber ?? "-")"
                totalPriceLabel.text = "Total price: \(newValue?.totalPrice ?? " - ")"
                durationTimeLabel.text = "Duration time: \(newValue?.durationTime ?? "-")"
                departureAirportCodeLabel.text = "Departure airport code: \(newValue?.departureAirportCode ?? "-")"
                arrivalAirportCodeLabel.text = "Departure airport code: \(newValue?.arrivalAirportCode ?? "-")"
            }
        }
    }
}
