//
//  OutputRecorder.swift
//  InfiniteImageScrollTests
//
//  Created by Swain Molster on 9/16/19.
//  Copyright © 2019 Swain Molster. All rights reserved.
//

import Foundation

/**
 An object that can be used to record outputs, e.g. from a view model.
 
 Supports recording from multiple threads. Example usage:
 ```
 func testCorrectMessagesDisplayedInOrder() {
     // e.g. an output of type `OutputFunction<String>`
     viewModel.outputs.displayMessage
     
     let outputRecorder = OutputRecorder<String>()
     viewModel.outputs.displayMessage = outputRecorder.record
     
     viewModel.inputs.somethingThatLeadsToDisplaying("First")
     viewModel.inputs.somethingThatLeadsToDisplaying("Second")
     
     XCTAssert(outputRecorder.recordedValues == ["First", "Second"]
 }
 ```
 */
final class OutputRecorder<Value> {
    
    /// Private queue.
    private let queue = DispatchQueue(label: "output-recorder", qos: .userInteractive)
    
    private var receivedValues: [Value] = []
    
    /// Currently recorded values.
    var recordedValues: [Value] {
        return queue.sync {
            return self.receivedValues
        }
    }
    
    /// Records the provided `value`.
    func record(_ value: Value) -> Void {
        queue.async {
            self.receivedValues.append(value)
        }
    }
    
}
