//
//  Network.swift
//  Desert Code Camp
//
//  Created by David Barkman on 9/8/19.
//  Copyright © 2019 Dbarkman LLC. All rights reserved.
//

import Foundation

class Network {
    
    static func callAPI(request: URLRequest, callAPIClosure: @escaping (JSON, HTTPURLResponse) -> Void) {
        let task = URLSession.shared.dataTask(with: request) { data, response, error in
            if error == nil {
                if let data = data, let dataString = String(data: data, encoding: .utf8) {
                    let json = JSON(parseJSON: dataString)
                    if let response = response as? HTTPURLResponse {
                        callAPIClosure(json, response)
                    }
                } else {
                    print("Client Error")
                }
            }
        }
        task.resume()
    }
}
