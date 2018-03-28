// https://github.com/Quick/Quick

import Quick
import Nimble
import SplitSlider

class TableOfContentsSpec: QuickSpec {
    override func spec() {
        describe("Slider") {
            
            it("Adjust min") {
                let slider = SplitSlider()
                slider.min = 1
                slider.max = 10
                slider.left.value = 1
                
                slider.min = 2
                expect(slider.left.value) == 2
                
                slider.min = 11
                expect(slider.left.min) == 10
            }
            
            it("Adjust max") {
                let slider = SplitSlider()
                slider.min = 1
                slider.max = 10
                slider.left.value = 10
                
                slider.max = 9
                expect(slider.left.value) == 9
                
                slider.max = 0
                expect(slider.left.min) == 1
            }
        }
    }
}
