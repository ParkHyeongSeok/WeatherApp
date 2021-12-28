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

extension CLLocationManager: HasDelegate {
    public typealias Delegate = CLLocationManagerDelegate
}

// Delegate Proxy Class
public class RxCLLocationManagerDelegateProxy: DelegateProxy<CLLocationManager, CLLocationManagerDelegate>, DelegateProxyType, CLLocationManagerDelegate {
    
    public init(locationManager: CLLocationManager) {
        super.init(parentObject: locationManager, delegateProxy: RxCLLocationManagerDelegateProxy.self)
    }
    
    
    public static func registerKnownImplementations() {
        self.register { RxCLLocationManagerDelegateProxy(locationManager: $0) }
    }
}

extension Reactive where Base: CLLocationManager {
    var delegate: DelegateProxy<CLLocationManager, CLLocationManagerDelegate> {
        return RxCLLocationManagerDelegateProxy.proxy(for: base)
    }
    
    // 이 메소드가 호출되면 Observable을 통해서 파라미터 목록이 방출
    public var didUpdateLocation: Observable<[CLLocation]> {
        // GPS로부터 새로운 위치 정보가 전달되면 CLLocation이 전달된다.
        let selector = #selector(CLLocationManagerDelegate.locationManager(_:didUpdateLocations:))
        return delegate.methodInvoked(selector)
            .map { parameters in
                return parameters[1] as! [CLLocation]
            }
    }
    
    // 허가 상태가 변경하는 시점마다 현재 상태를 방출
    public var didChangeAuthorizationStatus: Observable<CLAuthorizationStatus> {
        let sel: Selector
        if #available(iOS 14.0, *) {
            sel = #selector(CLLocationManagerDelegate.locationManagerDidChangeAuthorization(_:))
            // 파라미터 목록에서 CLAuthorizationStatus 목록을 뽑아낸뒤 리턴
            return delegate.methodInvoked(sel)
                .map { paramters in
                    return (paramters[0] as! CLLocationManager).authorizationStatus
                }
        } else {
            sel = #selector(CLLocationManagerDelegate.locationManager(_:didChangeAuthorization:))
            // 파라미터 목록에서 CLAuthorizationStatus 목록을 뽑아낸뒤 리턴
            return delegate.methodInvoked(sel)
                .map { paramters in
                    return CLAuthorizationStatus(rawValue: paramters[1] as! Int32) ?? .notDetermined
                }
        }
        
    }
}
