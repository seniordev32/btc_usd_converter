//
//  APIManager.swift
//  BTC_USD
//
//  Created by Moon on 1/27/21.
//  Copyright © 2021 Eric. All rights reserved.
//

import Foundation
import Alamofire

class APIManager: NSObject {
    let COINGECKO_API_URL = "https://api.coingecko.com/api/v3"
    let SIMPLE_PRICE_PATH = "/simple/price"
    let BTC_USD_QUERY = "?ids=bitcoin&vs_currencies=usd"
    
    var latestRatio: Float {
        get {
            let value = UserDefaults.standard.float(forKey: "ratio")
            return value == 0 ? 1 : value
        }
        set {
            UserDefaults.standard.set(newValue, forKey: "ratio")
        }
    }
    
    static let shared: APIManager = {
        let instance = APIManager()
        return instance
    }()
    
    func getPriceRatio(completion: @escaping (_ ratio: Float) -> ()) {
        AF.request(COINGECKO_API_URL + SIMPLE_PRICE_PATH + BTC_USD_QUERY).responseJSON { (response) in
            if let data = response.data,
                let jsonBody = try? JSONSerialization.jsonObject(with: data, options: .allowFragments) as? [String: Any] {
                let ratio = (jsonBody["bitcoin"] as! [String: Any])["usd"] as! Float
                self.latestRatio = ratio
                completion(ratio)
            }
            
        }
    }
}
