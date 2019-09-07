import ReactiveSwift
import Result
import UIKit

private enum Associations {
    fileprivate static var isEnabled = 0
}

public extension Rac where Object: UIBarItem {
    var isEnabled: Signal<Bool, NoError> {
        nonmutating set {
            let prop: MutableProperty<Bool> = lazyMutableProperty(
                object,
                key: &Associations.isEnabled,
                setter: { [weak object] in object?.isEnabled = $0 },
                getter: { [weak object] in object?.isEnabled ?? true })
            
            prop <~ newValue.observe(on: UIScheduler())
        }
        
        get {
            return .empty
        }
    }
}
