//
//  TagViewModel.swift
//  yaroll
//
//  Created by Christina on 5/11/16.
//  Copyright © 2016 Math Camp. All rights reserved.
//

import Foundation
import RxSwift
import RxCocoa

struct TagViewModel {
  struct Drivers {
    let text: Driver<String?>
    let backgroundHidden: Driver<Bool>
    let tagTableHidden: Driver<Bool>
    let tagTableBridgeHidden: Driver<Bool>
    let displayTags: Driver<Dictionary<String, TagViewData>>
    let tagCreationContainerHidden: Driver<Bool>
    let placeholderHidden: Driver<Bool>
    let tagTableQuery: Driver<String>
  }
  
  typealias State = ConcreteTagModel.State
  let drivers: Drivers
  
  static func make(_ source: TagModel) -> TagViewModel {
    let model: Driver<State> = source.model
  
    let text: Driver<String?> = model.map{ (model: State) in
      switch(model.mode){
      case .tagging(let tagText, _):
        return tagText
      case .taggingAndMentioning(let tagText, _, _):
        return tagText
      case .none:
        return ""
      case .deletingTag:
        return nil
      }
    }.distinctUntilChanged { x, y in x == y }
    
    let backgroundHidden = model.map{ (model: State) -> Bool in
      !model.mode.shallowEquals(.deletingTag)
    }.distinctUntilChanged()
    
    let tagTableHidden = model.map{ (model: State) -> Bool in
      !model.mode.shallowEquals(.taggingAndMentioning(text: "", searchQuery: "", location: nil))
    }.distinctUntilChanged()
    
    let tagTableBridgeHidden = tagTableHidden
    
    let displayTags = model.map{ (state: State) in state.tags}.distinctUntilChanged { (lhs, rhs) -> Bool in
      if lhs.keys.count != rhs.keys.count {
        return false
      }
      
      return lhs.reduce(true, { (curr: Bool, keyVal: (String, TagViewData)) -> Bool in
        if !curr { return false } //if false, remain false
        
        if let rhsVal = rhs[keyVal.0] {
          if !rhsVal.state.deepEquals(keyVal.1.state) {
            return false
          }
        } else { return false }
        
        return true
      })
    }
    
    let tagCreationContainerHidden: Driver<Bool> = model.map{ (state: State) in
      switch(state.mode){
      case .tagging(_, _), .taggingAndMentioning(_, _, _):
        return false
      case .deletingTag, .none:
        return true
      }
    }.distinctUntilChanged()
    
    let placeholderHidden: Driver<Bool> = model.map{ (state: State) in
      switch(state.mode){
      case .tagging(let text, _):
        return text != ""
      case .taggingAndMentioning(let text, _, _):
        return text != ""
      case .none, .deletingTag:
        return false //todo: it is illogical that we set placeholder hidden in these cases because this view isn't on screen
      }
    }.distinctUntilChanged()
    
    let tagTableQuery: Driver<String> = model.map{ (state: State) in
      switch(state.mode){
      case .taggingAndMentioning(_, let searchQuery, _):
        return searchQuery
      case .tagging(_, _), .deletingTag, .none:
        return ""
      }
    }.distinctUntilChanged()
    
    return TagViewModel(
      drivers: Drivers(
        text: text,
        backgroundHidden: backgroundHidden,
        tagTableHidden: tagTableHidden,
        tagTableBridgeHidden: tagTableBridgeHidden,
        displayTags: displayTags,
        tagCreationContainerHidden: tagCreationContainerHidden,
        placeholderHidden: placeholderHidden ,
        tagTableQuery: tagTableQuery
      )
    )
  }
}
