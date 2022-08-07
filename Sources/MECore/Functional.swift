//
//  Functional.swift
//  
//
//  Created by Pablo Ezequiel Romero Giovannoni on 17/10/2021.
//

import Foundation

// `|>` pipe-forward operator (with)

func with<A, B>(_ a: A, _ f: (A) -> B) -> B {
  return f(a)
}

precedencegroup ForwardApplication {
  associativity: left
}

infix operator |>: ForwardApplication

func |> <A, B>(_ a: A, f: (A) -> B) -> B {
  return with(a, f)
}

// `>>>` forward compose or right arrow operator (pipe)

func pipe<A, B, C>(_ f: @escaping (A) -> B, _ g: @escaping (B) -> C) -> (A) -> C {
  return { a in
    return g(f(a))
  }
}

precedencegroup ForwardComposition {
  associativity: left
  higherThan: ForwardApplication
}

infix operator >>>: ForwardComposition

func >>> <A, B, C>(_ f: @escaping (A) -> B, _ g: @escaping (B) -> C) -> (A) -> C {
  return pipe(f, g)
}
