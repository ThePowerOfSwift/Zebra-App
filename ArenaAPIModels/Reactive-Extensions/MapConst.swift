
import ReactiveSwift

public extension SignalProtocol {
    
    func mapConst <U> (_ value: U) -> Signal<U, Error> {
        return self.signal.map { _ in value }
    }
}

public extension SignalProducerProtocol {
    func mapConst <U> (_ value: U) -> SignalProducer<U, Error> {
        return self.producer.lift { $0.mapConst(value) }
    }
}
