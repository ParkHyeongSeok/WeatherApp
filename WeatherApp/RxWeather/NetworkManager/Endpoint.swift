//
//  Mastering RxSwift
//  Copyright (c) KxCoding <help@kxcoding.com>
//
//  Permission is hereby granted, free of charge, to any person obtaining a copy
//  of this software and associated documentation files (the "Software"), to deal
//  in the Software without restriction, including without limitation the rights
//  to use, copy, modify, merge, publish, distribute, sublicense, and/or sell
//  copies of the Software, and to permit persons to whom the Software is
//  furnished to do so, subject to the following conditions:
//
//  The above copyright notice and this permission notice shall be included in
//  all copies or substantial portions of the Software.
//
//  THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR
//  IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY,
//  FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE
//  AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER
//  LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM,
//  OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN
//  THE SOFTWARE.
//


import Foundation
import CoreLocation
import RxSwift

// 현재 날씨 URL
let summaryEndpoint = "https://api.openweathermap.org/data/2.5/weather"
// 예보 날씨 URL
let forecastEndpoint = "https://api.openweathermap.org/data/2.5/forecast"

func composeUrlRequest(endpoint: String, from location: CLLocation) -> Observable<URLRequest> {
    // 좌표와 API Key를 통해 최종 URL이 형성
    let urlString = "\(endpoint)?lat=\(location.coordinate.latitude)&lon=\(location.coordinate.longitude)&appid=\(apiKey)&lang=kr&units=metric"
    return Observable.just(urlString)
        .compactMap { URL(string: $0) }
        .map { URLRequest(url: $0) }    
}

func compostURLRequestWithQuery(endpoint: String, with query: String) -> Observable<URLRequest> {
    // 쿼리와 API Key를 이용한 urlString
    let urlString = "\(endpoint)?q=\(query)&appid=\(apiKey)&lang=kr&units=metric"
    return Observable.just(urlString)
        .compactMap { URL(string: $0) }
        .map { URLRequest(url: $0) }
}
