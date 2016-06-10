/*:
 > # IMPORTANT: To use `ReactiveCocoa.playground`, please:
 
 1. Retrieve the project dependencies using one of the following terminal commands from the ReactiveCocoa project root directory:
    - `script/bootstrap`
    **OR**, if you have [Carthage](https://github.com/Carthage/Carthage) installed
    - `carthage checkout`
 1. Open `ReactiveCocoa.xcworkspace`
 1. Build `Result-Mac` scheme 
 1. Build `ReactiveCocoa-Mac` scheme
 1. Finally open the `ReactiveCocoa.playground`
 1. Choose `View > Show Debug Area`
 */

import Result
import ReactiveCocoa
import Foundation


/*:
 ## Action
 */
 
 /*:
 ### `Random generator Action`
 */
scopedExample("Random") {
    struct Config {
        let max: UInt32
        let count: UInt32
    }
    let action = Action<Config, UInt32, NoError> { (config) in
        return SignalProducer<UInt32, NoError>({ (observer, _) in
            for _ in 1...config.count {
                observer.sendNext(arc4random_uniform(config.max))
            }
            observer.sendCompleted()
        })
            .logEvents(identifier: "random(\(config.max),\(config.count))",
                fileName: "\"Action page\"")
            .replayLazily(Int(config.count))
        
    }
    var producer = action.apply(Config(max: 10, count:10))
    
    let subscriber1 = Observer<UInt32, ActionError<NoError>>(next: { print("Subscriber 1 received \($0)") })
    let subscriber2 = Observer<UInt32, ActionError<NoError>>(next: { print("Subscriber 2 received \($0)") })

    print("Subscriber 1 subscribes to producer")
    producer.start(subscriber1)

    print("Subscriber 2 subscribes to producer")
    // Notice, how the producer will start the work again
    producer.start(subscriber2)
    print("Subscriber 2 subscribes to producer again")
    producer.start(subscriber2)

    producer = action.apply(Config(max: 100, count:10))
    print("Subscriber 1 subscribes to producer")
    producer.start(subscriber1)
    
    print("Subscriber 2 subscribes to producer")
    producer.start(subscriber2)
}
