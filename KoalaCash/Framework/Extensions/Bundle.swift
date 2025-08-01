//
//  Bundle.swift
//  KoalaCash
//
//  Created by Jesus Cedillo on 01/08/25.
//

import Foundation

extension Bundle {
  func string(for key: String) -> String {
    guard let v = infoDictionary?[key] as? String else {
      fatalError("Missing \(key) in Info.plist")
    }
    return v
  }
}
