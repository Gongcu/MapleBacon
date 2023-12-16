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
  
  // get image from remote and
  func testRemote() {
    guard let url = URL(string: "https://camo.githubusercontent.com/677de484983b3c6f437ebcfb978ef7310c799bbf822a00da1afddd311c3e2793/68747470733a2f2f7777772e64726f70626f782e636f6d2f732f6d6c717577396b366f677673706f782f4d61706c654261636f6e2e706e673f7261773d31") else {
      XCTFail()
      return
    }
    let fetchImageAndCacheExpectaion = XCTestExpectation()
    
    MapleBacon.shared.image(with: url) { result in
      guard (try? result.get()) != nil else {
        XCTFail()
        return
      }
      fetchImageAndCacheExpectaion.fulfill()
    }
    
    wait(for: [fetchImageAndCacheExpectaion], timeout: 5)
    
    XCTAssertEqual(try! MapleBacon.shared.isCached(with: url, imageTransformer: nil), true)
  }
  
  func testCache() {
    guard let url = URL(string: "https://camo.githubusercontent.com/677de484983b3c6f437ebcfb978ef7310c799bbf822a00da1afddd311c3e2793/68747470733a2f2f7777772e64726f70626f782e636f6d2f732f6d6c717577396b366f677673706f782f4d61706c654261636f6e2e706e673f7261773d31") else {
      XCTFail()
      return
    }
    
    let fetchImageAndCacheExpectaion = XCTestExpectation()
    MapleBacon.shared.fetchImageFromNetwork(with: url) { result in
      guard let image = try? result.get() else {
        XCTFail()
        return
      }
      MapleBacon.shared.cache.store(value: image, forKey: url.absoluteString) { error in
        XCTAssertNil(error) // <- data conversion error when fetching from remote
        fetchImageAndCacheExpectaion.fulfill()
      }
    }
    wait(for: [fetchImageAndCacheExpectaion], timeout: 5)
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
