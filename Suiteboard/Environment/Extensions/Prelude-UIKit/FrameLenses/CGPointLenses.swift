import Prelude
import UIKit

extension CGPoint {
    public enum lens {
        public static let x = Lens<CGPoint, CGFloat>(
            view: { view in view.x },
            set: { view, set in .init(x: view, y: set.y) }
        )
        
        public static let y = Lens<CGPoint, CGFloat>(
            view: { view in view.x },
            set: { view, set in .init(x: view, y: set.y) }
        )
    }
}
