/// This file is generated by Weaver 0.11.2
/// DO NOT EDIT!
// MARK: - FooTest15
protocol FooTest15DependencyResolver {
    var dict: Dictionary<AnyHashable, Any> { get }
    var dict1: Dictionary<AnyHashable, Any> { get }
    var dict2: Dictionary<AnyHashable?, Any?>? { get }
    var array: Array<Any> { get }
    var array1: Array<Any> { get }
    var array2: Array<Any?>? { get }
}
final class FooTest15DependencyContainer: FooTest15DependencyResolver {
    let dict: Dictionary<AnyHashable, Any>
    let dict1: Dictionary<AnyHashable, Any>
    let dict2: Dictionary<AnyHashable?, Any?>?
    let array: Array<Any>
    let array1: Array<Any>
    let array2: Array<Any?>?
    init(dict: Dictionary<AnyHashable, Any>, dict1: Dictionary<AnyHashable, Any>, dict2: Dictionary<AnyHashable?, Any?>?, array: Array<Any>, array1: Array<Any>, array2: Array<Any?>?) {
        self.dict = dict
        self.dict1 = dict1
        self.dict2 = dict2
        self.array = array
        self.array1 = array1
        self.array2 = array2
    }
}
