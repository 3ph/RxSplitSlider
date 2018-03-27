//  RxSplitSlider.swift
//  RxSplitSlider
//
//  Created by Tomas Friml on 25/03/2018.
//
//  MIT License
//
//  Copyright (c) 2018 Tomas Friml
//
//  Permission is hereby granted, free of charge, to any person obtaining a copy
//  of this software and associated documentation files (the "Software"), to deal
//  in the Software without restriction, including without limitation the rights
//  to use, copy, modify, merge, publish, distribute, sublicense, and/or sell
//  copies of the Software, and to permit persons to whom the Software is
//  furnished to do so, subject to the following conditions:
//
//  The above copyright notice and this permission notice shall be included in all
//  copies or substantial portions of the Software.
//
//  THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR
//  IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY,
//  FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE
//  AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER
//  LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM,
//  OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN THE
//  SOFTWARE.
//

import RxCocoa
import RxSwift
import SplitSlider

public typealias SplitSliderValueAndPortionType = (value: Float, portion: SplitSliderPortion)

extension Reactive where Base: SplitSlider {

    public var portionSelected: Observable<SplitSliderPortion?> {
        return RxSplitSliderDelegateProxy.proxy(for: base)._portionSelected.asObservable()
    }
    
    public var portionValueChanged: Observable<SplitSliderValueAndPortionType> {
        return RxSplitSliderDelegateProxy.proxy(for: base)._portionValueChanged.asObservable()
    }
}

extension SplitSlider: HasDelegate {
    public typealias Delegate = SplitSliderDelegate
}

public class RxSplitSliderDelegateProxy:
    DelegateProxy<SplitSlider, SplitSliderDelegate>, DelegateProxyType {
    

    public init(parentObject: SplitSlider) {
        self._slider = parentObject
        super.init(parentObject: parentObject, delegateProxy: RxSplitSliderDelegateProxy.self)
    }
    
    public static func registerKnownImplementations() {
        self.register { RxSplitSliderDelegateProxy(parentObject: $0) }
    }
    
    public static func currentDelegate(for object: SplitSlider) -> SplitSliderDelegate? {
        return object.delegate
    }
    
    public static func setCurrentDelegate(_ delegate: SplitSliderDelegate?, to object: SplitSlider) {
        object.delegate = delegate
    }
    
    // MARK: - Private
    fileprivate weak var _slider: SplitSlider?
    fileprivate let _portionSelected = PublishSubject<SplitSliderPortion?>()
    fileprivate let _portionValueChanged = PublishSubject<SplitSliderValueAndPortionType>()
}

extension RxSplitSliderDelegateProxy: SplitSliderDelegate {
    public func slider(_ slider: SplitSlider, didSelect portion: SplitSliderPortion?) {
        _portionSelected.onNext(portion)
    }
    
    public func slider(_ slider: SplitSlider, didUpdate value: CGFloat, for portion: SplitSliderPortion) {
        _portionValueChanged.onNext((value: Float(value), portion: portion))
    }
}
