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

import UIKit
import CoreLocation
import RxSwift
import RxCocoa
import NSObject_Rx

class CoreLocationProvider: LocationProviderType {
    
    private let locationManager = CLLocationManager()
    
    // 위치 정보
    private let location = BehaviorRelay<CLLocation>(value: CLLocation.gangnamStation)
    
    // 주소 정보
    private let address = BehaviorRelay<String>(value: "강남역")
    
    // 허가 상태
    private let authorized = BehaviorRelay<Bool>(value: false)
    
    private let disposeBag = DisposeBag()
    
    init() {
        // locationManager 초기화
        // GPS 정확도 설정
        locationManager.desiredAccuracy = kCLLocationAccuracyThreeKilometers
        
        // 권한 요청 및 위치 정보 요청
        locationManager.requestWhenInUseAuthorization()
        locationManager.startUpdatingLocation()
        
        // Delegate Proxy를 통해 만든 메서드. 위치 정보가 업데이트 될 때마다 위치를 방출
        locationManager.rx.didUpdateLocation
            .throttle(.seconds(5), scheduler: MainScheduler.instance)
            .map { $0.last ?? CLLocation.gangnamStation }
            .bind(to: location)
            .disposed(by: disposeBag)
        
        // 위치 정보를 받아 reverseGeocode로 주소를 생성
        location
            .flatMap { location in
                return Observable<String>.create { observer in
                    let geocoder = CLGeocoder()
                    geocoder.reverseGeocodeLocation(location) { placemarks, error in
                        if let place = placemarks?.first {
                            // 정상적으로 장소가 반환되면 우리나라 주소에서 구, 동에 해당하는 데이터를 뽑은 다음 새로운 데이터로 방출
                            if let gu = place.locality,
                               let dong = place.subLocality {
                                observer.onNext("\(gu) \(dong)")
                            } else {
                                observer.onNext(place.name ?? "알 수 없음")
                            }
                        } else {
                            observer.onNext("알 수 없음")
                        }
                        observer.onCompleted()
                    }
                    
                    return Disposables.create()
                }
            }
            .bind(to: address)
            .disposed(by: disposeBag)
        
        // 새로운 허가 상태
        locationManager.rx.didChangeAuthorizationStatus
            .map { $0 == .authorizedAlways || $0 == .authorizedWhenInUse }
            .bind(to: authorized)
            .disposed(by: disposeBag)
    }
    
    func currentLocation() -> Observable<CLLocation> {
        return location.asObservable()
    }
    
    func currentAddress() -> Observable<String> {
        return address.asObservable()
    }
}
