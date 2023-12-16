@testable import MapleBacon
import XCTest

final class UIImageDataConvertibleTests: XCTestCase {
  // original image data
  func testJPG() {
    let data = self.data(filename: "maplebacon.jpeg")!
    let imageType = ImageType.fromData(data)
    XCTAssertNotNil(imageType)
    XCTAssertEqual(imageType, .jpg)
  }

  func testPNG() {
    let data = self.data(filename: "maplebacon.png")!
    let imageType = ImageType.fromData(data)
    XCTAssertNotNil(imageType)
    XCTAssertEqual(imageType, .png)
  }
  
  func testTIFF() {
    let data = self.data(filename: "maplebacon.tiff")!
    let imageType = ImageType.fromData(data)
    XCTAssertNil(imageType)
  }
}

extension XCTestCase {
  func data(filename: String) -> Data? {
    let data = try? Data(contentsOf: url(for: filename))
    
    return data
  }
  
  func url(for filename: String) -> URL {
    let bundle = Bundle(for: type(of: self))
    
    let url = bundle.url(forResource: "Images/\(filename)", withExtension: "")
    
    if let isFileURL = url?.isFileURL {
      XCTAssert(isFileURL)
    } else {
      XCTFail("\(filename) does not exist")
    }
    
    return url!
  }
}

private enum ImageType: String {
  case png = "public.png"
  case jpg = "public.jpeg"

  static func fromData(_ data: Data) -> Self? {
    func matchesPrefix(_ prefixes: [UInt8?]) -> Bool {
      guard data.count >= prefixes.count else {
        return false
      }
      return zip(prefixes.indices, prefixes).allSatisfy { index, `prefix` in
        guard index < data.count else {
          return false
        }
        return data[index] == `prefix`
      }
    }

    if matchesPrefix([0xFF, 0xD8, 0xFF]) {
      return .jpg
    }
    if matchesPrefix([0x89, 0x50, 0x4E, 0x47, 0x0D, 0x0A, 0x1A, 0x0A]) {
      return .png
    }

    return nil
  }
}
