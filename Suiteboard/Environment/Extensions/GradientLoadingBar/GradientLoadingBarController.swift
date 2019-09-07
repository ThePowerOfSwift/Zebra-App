import Foundation
import UIKit

/// Typealias for controller to match pod name.
public typealias GradientLoadingBar = GradientLoadingBarController

/// The `GradientLoadingBarController` mediates between the `GradientLoadingBarViewModel` and the corresponding `GradientView`.
open class GradientLoadingBarController {
    // MARK: - Public properties
    
    /// The height of the gradient bar.
    ///  - Note: Has to be public to allow overwriting `setupConstraints()`
    public let height: Double
    
    /// Flag whether the top layout constraint should respect `safeAreaLayoutGuide`.
    ///  - Note: Has to be public to allow overwriting `setupConstraints()`
    public let isRelativeToSafeArea: Bool
    
    /// View containing the gradient layer.
    public let gradientView: GradientView
    
    /// Singleton instance.
    public static var shared = GradientLoadingBar()
    
    // MARK: - Private properties
    
    /// View model containing logic for the gradient view.
    private let viewModel: GradientLoadingBarViewModel
    
    /// The dispose bag for the observables.
    private var disposeBag = DisposeBag()
    
    // MARK: - Initializers
    
    /// Creates a new gradient loading bar instance.
    ///
    /// Parameters:
    ///  - height:               Height of the gradient bar.
    ///  - durations:            Configuration with durations for each animation.
    ///  - gradientColorList:    Colors used for the gradient.
    ///  - isRelativeToSafeArea: Flag whether the top layout constraint should respect `safeAreaLayoutGuide`.
    ///  - superview:            Optional custom view containing the gradient bar.
    ///
    /// Returns: Instance with gradient bar
    public init(height: Double = 2.5,
                durations: Durations = .default,
                gradientColorList: [UIColor] = [UIColor.red, UIColor.white],
                isRelativeToSafeArea: Bool = true,
                onView superview: UIView? = nil) {
        self.height = height
        self.isRelativeToSafeArea = isRelativeToSafeArea
        
        gradientView = GradientView(progressAnimationDuration: durations.progress,
                                    gradientColorList: gradientColorList)
        
        viewModel = GradientLoadingBarViewModel(superview: superview,
                                                durations: durations)
        
        setupGradientView()
        bindViewModelToView()
    }
    
    deinit {
        if gradientView.superview != nil {
            gradientView.removeFromSuperview()
        }
    }
    
    // MARK: - Private methods
    
    private func setupGradientView() {
        gradientView.isHidden = true
        gradientView.clipsToBounds = true
    }
    
    private func bindViewModelToView() {
        viewModel.animatedVisibilityUpdate.subscribeDistinct { [weak self] newAnimatedVisibilityUpdate, _ in
            self?.gradientView.animate(isHidden: newAnimatedVisibilityUpdate.isHidden,
                                       duration: newAnimatedVisibilityUpdate.duration)
            }.add(to: &disposeBag)
        
        viewModel.superview.subscribeDistinct { [weak self] newSuperview, _ in
            self?.addGradientView(to: newSuperview)
            }.add(to: &disposeBag)
    }
    
    private func addGradientView(to superview: UIView?) {
        guard gradientView.superview == nil else {
            // The viewmodel informed us eventhough we already have a valid superview.
            return
        }
        
        guard let superview = superview else {
            // We've received an invalid superview.
            return
        }
        
        gradientView.translatesAutoresizingMaskIntoConstraints = false
        superview.addSubview(gradientView)
        
        setupConstraints(superview: superview)
    }
    
    // MARK: - Public methods
    
    /// Apply layout contraints for gradient loading view.
    open func setupConstraints(superview: UIView) {
        let superViewTopAnchor: NSLayoutYAxisAnchor
        if #available(iOS 11.0, *), isRelativeToSafeArea {
            superViewTopAnchor = superview.safeAreaLayoutGuide.topAnchor
        } else {
            superViewTopAnchor = superview.topAnchor
        }
        
        NSLayoutConstraint.activate([
            gradientView.topAnchor.constraint(equalTo: superViewTopAnchor),
            gradientView.heightAnchor.constraint(equalToConstant: CGFloat(height)),
            
            gradientView.leadingAnchor.constraint(equalTo: superview.leadingAnchor),
            gradientView.trailingAnchor.constraint(equalTo: superview.trailingAnchor)
            ])
    }
    
    /// Fades in the gradient loading bar.
    public func show() {
        viewModel.show()
    }
    
    /// Fades out the gradient loading bar.
    public func hide() {
        viewModel.hide()
    }
    
    /// Toggle visiblity of gradient loading bar.
    public func toggle() {
        viewModel.toggle()
    }
}