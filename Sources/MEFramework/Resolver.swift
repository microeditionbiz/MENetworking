//
//  File.swift
//  
//
//  Created by Pablo Ezequiel Romero Giovannoni on 02/01/2022.
//

import UIKit

// TODO: check @functionBuilder

public final class Resolver {

    public enum Mode {
        case factory
        case allocation
    }

    public static let shared = Resolver()

    private var factories: [String: (Mode, Any)]
    private var allocations: [String: Any]

    private var queue: DispatchQueue

    init() {
        self.factories = [:]
        self.allocations = [:]
        self.queue = .init(label: "com.microedition.biz.Resolver.queue", attributes: .concurrent)
    }

    private static func key<T>(for type: T.Type) -> String {
        String(describing: type)
    }

    func register<T, Input>(mode: Mode, _ factory: @escaping (Resolver, Input) -> T) {
        queue.async(flags: .barrier) { [weak self] in
            self?.factories[Self.key(for: T.self)] = (mode, factory)
        }
    }

    func resolve<T, Input>(input: Input) -> T {
        queue.sync {
            let key = Self.key(for: T.self)
            guard let (mode, factory) = factories[key] as? (Mode, (Resolver, Input) -> Any) else {
                fatalError("No factory registered for key \(key)")
            }

            switch mode {
            case .factory:
                guard let value = factory(self, input) as? T else {
                    fatalError("Wrong return type in registered factory for key \(key)")
                }

                return value
            case .allocation:
                if let value = self.allocations[key] as? T {
                    return value
                }

                guard let value = factory(self, input) as? T else {
                    fatalError("Wrong return type in registered factory for key \(key)")
                }

                self.allocations[key] = value

                return value
            }
        }
    }

    func resetAllAllocations() {
        allocations.removeAll()
    }

    func removeAllocation<T>(for type: T.Type) {
        let key = Self.key(for: type)
        allocations.removeValue(forKey: key)
    }
}

//@propertyWrapper
//struct Inject<Value> {
//
//    init() {}
//
//    public var wrappedValue: Value {
//        Resolver.shared.resolve()
//    }
//
//}
//
//class PersonViewModel {
//    let fullName: String
//
//    init(firstName: String, sureName: String) {
//        self.fullName = [firstName, sureName].joined(separator: " ")
//    }
//}
//
//Resolver.shared.add(<#T##factory: () -> T##() -> T#>)
//
//class PersonView {
//    let viewModel: PersonViewModel
//
//    init(viewModel: PersonViewModel) {
//        self.viewModel = viewModel
//    }
//
//    func printFullName() {
//        print(viewModel.fullName)
//    }
//}
//
//let viewModel = PersonViewModel(firstName: "Pablo", sureName: "Romero")
//let personView = PersonView(viewModel: viewModel)
//personView.printFullName()
