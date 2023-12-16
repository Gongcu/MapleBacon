//
//  Copyright © 2020 Schnaub. All rights reserved.
//

import UIKit

public protocol DataConvertible {
  associatedtype Result

  static func convert(from data: Data) -> Result?

  func toData() -> Data?
}

extension UIImage: DataConvertible {

  public static func convert(from data: Data) -> UIImage? {
    UIImage(data: data, scale: UIScreen.main.scale)
  }

  public func toData() -> Data? {
    cgImage?.dataProvider?.data as? Data
  }
}
