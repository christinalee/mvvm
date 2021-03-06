//
//  TagCreationHelper.swift
//  yaroll
//
//  Created by Christina on 5/31/16.
//  Copyright © 2016 Math Camp. All rights reserved.
//

import Foundation
import UIKit

struct TagCreationHelper {
  typealias My = TagCreationHelper
  
  static func getCurrentMillis() -> Int64 {
    return  Int64(Date().timeIntervalSince1970 * 1000)
  }
  
  static func makeNewTag(_ text: String, location: TagViewLocation?) -> UserTagInfo {
    let tagId = String(getCurrentMillis())
    let imgUrl = "dog-pink" //hardcoding asset for demo, but this should be a server sent profile photo url
    let attributedText = My.getAttributedString(text, fontSize: 12.0)
    
    if let location = location {
      switch(location){
      case .customLocation(let point):
        let location = TagViewLocation.customLocation(point: point)
        return UserTagInfo(id: tagId, text: attributedText, location: location, imgUrl: imgUrl, centerOnTooth: true)
      case .default:
        let location = TagViewLocation.default
        return UserTagInfo(id: tagId, text: attributedText, location: location, imgUrl: imgUrl, centerOnTooth: false)
      }
    }
    
    return UserTagInfo(id: tagId, text: attributedText, location: location, imgUrl: imgUrl, centerOnTooth: false)
  }
  
  // This function is here purely for example. Server tags should, unsurprisingly, always come from the server and are never created client side.
  static func makeNewServerTag(_ text: String, location: CGPoint, userId: String) -> PhotoTypes.Tag {
    let attributedText = getAttributedString(text, fontSize: 12.0)
    let canEdit = userId == TagOwner.Own
    let currentMillis = My.getCurrentMillis()
    
    return PhotoTypes.Tag(tagId: String(currentMillis), location: location, text: attributedText, canEdit: canEdit, createdAt: Double(currentMillis), createdBy: userId)
  }
  
  fileprivate static func getAttributedString(_ nonEmptyText: String, fontSize: CGFloat) -> NSAttributedString {
    let regularFont = UIFont(name: "AvenirNext-Medium", size: fontSize)
    let boldFont = UIFont(name: "AvenirNext-DemiBold", size: fontSize)
    
    let markedUpText = nonEmptyText.characters.split {$0 == " "}.map { String($0) }.map({ (word) -> String in
      if word.characters.first == "@" { return "*" + word + "*" }
      return word
    }).joined(separator: " ")
    return My.processAttributedString(markedUpText, normalFont: regularFont!, boldFont: boldFont!)
  }
  
  fileprivate static func processAttributedString(_ inputString: String, normalFont: UIFont, boldFont: UIFont) -> NSMutableAttributedString {
    let processedText = NSMutableAttributedString()
    if inputString.characters.count == 0 { return processedText }
    
    // Find all * pairs
    var isBold = false
    let slices = inputString.characters.split { $0 == "*" }.map { String($0) }
    
    // if first character of input string is * then start out bold
    let charArray: Array<Character> = Array(inputString.characters)
    let firstChar: Character = charArray[0]
    if firstChar == "*" {
      isBold = true
    }
    
    for index in 0 ..< slices.count {
      let sliceString = NSMutableAttributedString(string: slices[index])
      sliceString.addAttribute(NSFontAttributeName, value: isBold ? boldFont : normalFont, range: NSMakeRange(0, sliceString.length))
      processedText.append(sliceString)
      isBold = !isBold
    }
    
    let paragraphStyle = NSMutableParagraphStyle()
    paragraphStyle.alignment = NSTextAlignment.left
    processedText.addAttribute(NSParagraphStyleAttributeName, value: paragraphStyle, range: NSMakeRange(0,processedText.length))
    
    return processedText
  }
}
