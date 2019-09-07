import Prelude
import UIKit

extension CGSize {
    public enum lens {
        public static let width = Lens<CGSize, CGFloat>(
            view: { view in view.width },
            set: { view, set in .init(width: view, height: set.height) }
        )
        
        public static let height = Lens<CGSize, CGFloat>(
            view: { view in view.height },
            set: { view, set in .init(width: set.width, height: view) }
        )
    }
}
