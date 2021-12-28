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
import RxSwift
import RxCocoa
import CoreLocation
import NSObject_Rx

class OpenWeatherMapApi: NSObject, WeatherApiType {
    
    // 현재 날씨 방출, 주로 UI Binding에 이용하기 때문에 BehaviorRelay
    private let summaryRelay = BehaviorRelay<WeatherDataType?>(value: nil)
    // 예보 목록
    private let forcaseRelay = BehaviorRelay<[WeatherDataType]>(value: [])
    
    private let urlSession = URLSession.shared
    
    func fetch(location: CLLocation) -> Observable<(WeatherDataType?, [WeatherDataType])> {
        let summary = self.fetchSummary(location: location)
        let forecase = self.fetchForecast(location: location)
        Observable.zip(summary, forecase)
            .subscribe(onNext: { [weak self] result in
                self?.summaryRelay.accept(result.0)
                self?.forcaseRelay.accept(result.1)
            })
            .disposed(by: rx.disposeBag)
        return Observable.combineLatest(summary.asObservable(), forecase.asObservable())
    }
    
    // 현재 날씨
    private func fetchSummary(location: CLLocation) -> Observable<WeatherDataType?> {
        let request = composeUrlRequest(endpoint: summaryEndpoint, from: location)
        // request를 전달하면 data 형식의 responce를 방출하는 Observable 리턴
        return request
            .flatMap { self.urlSession.rx.data(request: $0) }
            .map { data -> WeatherSummary in
                return try JSONDecoder().decode(WeatherSummary.self, from: data)
            }
            .map { WeatherData(summary: $0) }
            .catchAndReturn(nil)
    }
    
    private func fetchForecast(location: CLLocation) -> Observable<[WeatherDataType]> {
        let request = composeUrlRequest(endpoint: forecastEndpoint, from: location)
        return request
            .flatMap { self.urlSession.rx.data(request: $0) }
            .map { data -> [WeatherData] in
                let forecase = try JSONDecoder().decode(Forecast.self, from: data)
                return forecase.list.map(WeatherData.init)
            }
            .catchAndReturn([])
    }
}

