
import ReactiveSwift
import Result

extension SignalProtocol where Value: EventProtocol, Error == NoError {
    
    public func errors() -> Signal<Value.Error, NoError> {
        return self.signal.map { $0.event.error }.skipNil()
    }
}

extension SignalProducerProtocol where Value: EventProtocol, Error == NoError {
    
    public func errors() -> SignalProducer<Value.Error, NoError> {
        return self.producer.lift { $0.errors() }
    }
}
