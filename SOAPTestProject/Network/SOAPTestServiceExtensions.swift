//
//  SOAPTestServiceExtensions.swift
//  SOAPTestProject
//
//  Created by Andrew on 19.09.2020.
//  Copyright © 2020 Andrew. All rights reserved.
//

import Foundation

protocol SOAPTestServiceMessagesProtocol {
    func makeBody() -> String
    func makeTile() -> String
}

extension SOAPTestService.Config.Messages: SOAPTestServiceMessagesProtocol {
    func makeTile() -> String {
        switch self {
        case .startSession: return "StartSession"
        case .getOptimalFares: return "GetOptimalFares"
        }
    }
    
    func makeBody() -> String {
        switch self {
        case .startSession: return """
            <?xml version="1.0" encoding="UTF-8"?>
            <v:Envelope xmlns:v="http://www.w3.org/2003/05/soap-envelope" xmlns:c="http://www.w3.org/2003/05/soap-encoding" xmlns:d="http://www.w3.org/2001/XMLSchema" xmlns:i="http://www.w3.org/2001/XMLSchema-instance">
            <v:Header />
            <v:Body>
            <StartSessionInput xmlns="http://www.tais.ru/" id="o0" c:root="1">
            <login i:type="d:string">[partner]||SOAPTEST</login>
            <password i:type="d:string">[partner]||SOAPTEST</password>
            <disable_hash i:type="d:string">Y</disable_hash>
            <hash i:type="d:string"></hash>
            </StartSessionInput>
            </v:Body>
            </v:Envelope>
            """
        case .getOptimalFares(let token, let outboundDate): return """
            <?xml version="1.0" encoding="UTF-8"?>
            <v:Envelope xmlns:v="http://www.w3.org/2003/05/soap-envelope" xmlns:c="http://www.w3.org/2003/05/soap-encoding" xmlns:d="http://www.w3.org/2001/XMLSchema" xmlns:i="http://www.w3.org/2001/XMLSchema-instance">
            <v:Header />
            <v:Body>
            <GetOptimalFaresInput xmlns="http://www.tais.ru/" id="o0" c:root="1">
            <session_token i:type="d:string">\(token)</session_token>
            <owrt i:type="d:string">OW</owrt>
            <departure_point i:type="d:string">MOW</departure_point>
            <arrival_point i:type="d:string">LED</arrival_point>
            <outbound_date i:type="d:string">\(outboundDate)</outbound_date>
            <return_date i:type="d:string" />
            <adult_count i:type="d:int">1</adult_count>
            <child_count i:type="d:int">0</child_count>
            <infant_count i:type="d:int">0</infant_count>
            <class i:type="d:string">E</class>
            <hash i:type="d:string"></hash>
            </GetOptimalFaresInput>
            </v:Body>
            </v:Envelope>
            """
        }
    }
}
