//
//  ViewController.swift
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

import SplitSlider
import RxSplitSlider
import RxSwift

class ViewController: UIViewController {

    @IBOutlet weak var splitSlider: SplitSlider!
    @IBOutlet weak var snapToStep: UISwitch!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        splitSlider.labelFont = UIFont.systemFont(ofSize: UIFont.smallSystemFontSize)
        splitSlider.left.step = 30
        
        splitSlider
            .rx
            .portionSelected
            .asDriver(onErrorJustReturn: nil)
            .drive(onNext: { [unowned self] portion in
                let portionString = portion == self.splitSlider.left ? "left" : "right"
                NSLog("Selected part: \(portion == nil ? "none" : portionString)")
            }).disposed(by: _disposeBag)
        
        splitSlider
            .rx
            .portionValueChanged
            .asDriver(onErrorJustReturn: (0, SplitSliderPortion()))
            .drive(onNext: { [unowned self] (value, portion) in
                let portionString = portion == self.splitSlider.left ? "left" : "right"
                NSLog("Current value: \(value) (portion: \(portionString))")
            }).disposed(by: _disposeBag)
        
    }
    @IBAction func snapToStepToggle(_ sender: Any) {
        if let toggle = sender as? UISwitch {
            splitSlider.snapToStep = toggle.isOn
        }
    }
    
    // MARK: - Private
    fileprivate let _disposeBag = DisposeBag()
}

