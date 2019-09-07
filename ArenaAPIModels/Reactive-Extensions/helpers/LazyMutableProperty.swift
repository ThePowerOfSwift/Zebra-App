
import ReactiveSwift

public func lazyMutableProperty<T>(_ host: AnyObject, key: UnsafeRawPointer, setter: @escaping (T) -> Void, getter: @escaping () -> T) -> MutableProperty<T> {
    return lazyAssociatedProperty(host, key: key) {
        let property = MutableProperty<T>(getter())
        property.producer.skip(first: 1).startWithValues { value in
            setter(value)
        }
        return property
    }
}
