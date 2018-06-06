/// This file is generated by Weaver 0.9.9
/// DO NOT EDIT!
import WeaverDI
// MARK: - WSReviewViewController
final class WSReviewViewControllerDependencyContainer: DependencyContainer {
    let movieID: UInt
    init(parent: DependencyContainer, movieID: UInt) {
        self.movieID = movieID
        super.init(parent)
    }
    override func registerDependencies(in store: DependencyStore) {
    }
}
@objc protocol WSReviewViewControllerDependencyResolver {
    var movieID: UInt { get }
    var reviewManager: ReviewManaging { get }
}
extension WSReviewViewControllerDependencyContainer: WSReviewViewControllerDependencyResolver {
    var reviewManager: ReviewManaging {
        return resolve(ReviewManaging.self, name: "reviewManager")
    }
}
extension WSReviewViewController {
    static func makeWSReviewViewController(injecting parentDependencies: DependencyContainer, movieID: UInt) -> WSReviewViewController {
        let dependencies = WSReviewViewControllerDependencyContainer(parent: parentDependencies, movieID: movieID)
        return WSReviewViewController(injecting: dependencies)
    }
}
protocol WSReviewViewControllerObjCDependencyInjectable {
    init(injecting dependencies: WSReviewViewControllerDependencyResolver)
}