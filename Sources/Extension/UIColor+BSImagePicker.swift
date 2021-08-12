// The MIT License (MIT)
//
// Copyright (c) 2020 Shashank Mishra
//
// Permission is hereby granted, free of charge, to any person obtaining a copy
// of this software and associated documentation files (the "Software"), to deal
// in the Software without restriction, including without limitation the rights
// to use, copy, modify, merge, publish, distribute, sublicense, and/or sell
// copies of the Software, and to permit persons to whom the Software is
// furnished to do so, subject to the following conditions:
//
// The above copyright notice and this permission notice shall be included in all
// copies or substantial portions of the Software.
//
// THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR
// IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY,
// FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE
// AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER
// LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM,
// OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN THE
// SOFTWARE.

import UIKit

extension UIColor {
  
  static var systemBackgroundColor: UIColor {
    if #available(iOS 13.0, *) {
      return systemBackground
    } else {
      // Same old color used for iOS 12 and earlier
      return .white
    }
  }
  
  static var systemShadowColor: UIColor {
    if #available(iOS 13.0, *) {
      return tertiarySystemBackground
    } else {
      // Same old color used for iOS 12 and earlier
      return .black
    }
  }
  
  static var systemPrimaryTextColor: UIColor {
    if #available(iOS 13.0, *) {
      return label
    } else {
      // Same old color used for iOS 12 and earlier
      return .black
    }
  }
  
  static var systemSecondaryTextColor: UIColor {
    if #available(iOS 13.0, *) {
      return secondaryLabel
    } else {
      // Same old color used for iOS 12 and earlier
      return .black
    }
  }
  
  static var systemStrokeColor: UIColor {
    if #available(iOS 13.0, *) {
      return UIColor { (traitCollection: UITraitCollection) -> UIColor in
        if traitCollection.userInterfaceStyle == .dark {
          return white
        }
        else {
          return black
        }}
    } else {
      // Same old color used for iOS 12 and earlier
      return .black
    }
  }
  
  static var systemOverlayColor: UIColor {
    if #available(iOS 13.0, *) {
      return secondarySystemBackground
    } else {
      // Same old color used for iOS 12 and earlier
      return .lightGray
    }
  }
  
  public convenience init?(hex: String) {
    let red, green, blue: CGFloat
    
    if hex.hasPrefix("#") {
      let start = hex.index(hex.startIndex, offsetBy: 1)
      let hexColor = String(hex[start...])
      
      if hexColor.count == 6 {
        let scanner = Scanner(string: hexColor)
        var hexNumber: UInt64 = 0
        
        if scanner.scanHexInt64(&hexNumber) {
          red = CGFloat((hexNumber & 0xff0000) >> 16) / 255
          green = CGFloat((hexNumber & 0x00ff00) >> 8) / 255
          blue = CGFloat((hexNumber & 0x0000ff) >> 0) / 255
          
          self.init(red: red, green: green, blue: blue, alpha: 1.0)
          return
        }
      }
    }
    return nil
  }
  
  func image(_ size: CGSize = CGSize(width: 1, height: 1)) -> UIImage {
         return UIGraphicsImageRenderer(size: size).image { rendererContext in
             self.setFill()
             rendererContext.fill(CGRect(x: 0, y: 0, width: size.width, height: size.height))
         }
     }
}
