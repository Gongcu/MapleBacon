//
//  Copyright © 2017 Jan Gorman. All rights reserved.
//

import XCTest
import Nimble
import MapleBacon

final class MapleBaconTests: XCTestCase {

  private class DummyTransformer: ImageTransformer, CallCounting {

    let identifier = "com.schnaub.DummyTransformer"

    var callCount = 0

    func transform(image: UIImage) -> UIImage? {
      callCount += 1
      return image
    }

  }

  private let url = URL(string: "https://www.apple.com/mapleBacon.png")!
  private let helper = TestHelper()
  
  override func setUp() {
    super.setUp()
    MockURLProtocol.requestHandler = { request in
      return (HTTPURLResponse(), self.helper.imageResponseData())
    }
  }

  override func tearDown() {
    super.tearDown()
    Cache.default.clearMemory()
    Cache.default.clearDisk()
  }
  
  func testIntegration() {
    let configuration = MockURLProtocol.mockedURLSessionConfiguration()
    let downloader = Downloader(sessionConfiguration: configuration)
    let mapleBacon = MapleBacon(cache: .default, downloader: downloader)

    waitUntil { done in
      mapleBacon.image(with: self.url, progress: nil) { image in
        expect(image).toNot(beNil())
        done()
      }
    }
  }

  func testTransformerIntegration() {
    let configuration = MockURLProtocol.mockedURLSessionConfiguration()
    let downloader = Downloader(sessionConfiguration: configuration)
    let mapleBacon = MapleBacon(cache: .default, downloader: downloader)

    let transformer = DummyTransformer()
    waitUntil { done in
      mapleBacon.image(with: self.url, transformer: transformer, progress: nil) { image in
        expect(image).toNot(beNil())
        expect(transformer.callCount) == 1
        done()
      }
    }
  }

  func testTransformerResultIsCached() {
    let configuration = MockURLProtocol.mockedURLSessionConfiguration()
    let downloader = Downloader(sessionConfiguration: configuration)
    let mapleBacon = MapleBacon(cache: .default, downloader: downloader)

    let transformer = DummyTransformer()
    waitUntil { done in
      mapleBacon.image(with: self.url, transformer: transformer, progress: nil) { _ in
        expect(transformer.callCount) == 1
        
        MapleBacon.shared.image(with: self.url, transformer: transformer, progress: nil) { image in
          expect(image).toNot(beNil())
          expect(transformer.callCount) == 1
          done()
        }
      }
    }
  }

}
