//
//  LARules.swift
//  lacinkaconverter
//
//  Created by Logout on 21.11.22.
//

import Foundation

public enum BLDirection: String {
    case toLacin = "forth"
    case toCyrillic = "back"
}

public enum BLVersion: String {
    case traditional = "traditional"
    case geographic = "geographic"
}

public enum BLOrthography: String {
    case academic = "academic"
    case classic = "classic"
}

struct BLRuleRenderer {
    var name: String
    var search: [BLDirection: String]
    var replace: [BLDirection: String]
    var defaultSearch: String?
    var defaultReplace: String?
    
    func search(direction: BLDirection) -> String? {
        return self.search[direction] ?? self.defaultSearch
    }
    
    func replace(direction: BLDirection) -> String? {
        return self.replace[direction] ?? self.defaultReplace
    }
    
    func apply(pairSearch: String, pairReplace: String, text: String, direction: BLDirection) -> String {
        
        guard let (search, replace) = self.renderSearchReplace(from: pairSearch, to: pairReplace, direction: direction) else {
            return text
        }

        var newText = text
        if self.name == "ReplaceByPattern" {
            newText = text.replacingOccurrences(of: search, with: replace, options: .regularExpression)
        } else if self.name == "SimpleReplace" {
            newText = text.replacingOccurrences(of: search, with: replace)
        }
        
        return newText
    }
    
    func renderSearchReplace(from: String, to: String, direction: BLDirection) -> (String, String)? {
        guard let search = self.search(direction: direction), let replace = self.replace(direction: direction) else {
            return nil
        }
        let ruleSearch = search.replacingOccurrences(of: "[[pair]]", with:  from)
        let ruleReplace = replace.replacingOccurrences(of: "[[pair]]", with:  to)
        return (ruleSearch, ruleReplace)
    }
}

struct BLRulePair {
    var cyrillic: String
    var latin: String
    var versions: [BLVersion]
    var orthographies: [BLOrthography]
    var directions: [BLDirection]
    
    func text(direction: BLDirection, version: BLVersion, orthograpy: BLOrthography) -> (String, String)? {
        if (self.directions.count > 0 && self.directions.contains(direction) == false) ||
            (self.versions.count > 0 && self.versions.contains(version) == false) ||
            (self.orthographies.count > 0 && self.orthographies.contains(orthograpy) == false) {
            return nil
        }

        let textFrom = direction == .toLacin ? self.cyrillic : self.latin
        let textTo = direction == .toLacin ? self.latin : self.cyrillic
        return (textFrom, textTo)
    }
}

struct BLRule {
    var sort: Int
    var name: String
    var renderer: BLRuleRenderer
    var directions: [BLDirection]
    var versions: [BLVersion]
    var orthographies: [BLOrthography]
    var pairs: [BLRulePair]
    
    func apply(text: String, direction: BLDirection, version: BLVersion, orthograpy: BLOrthography) -> String
    {

        if (self.directions.count > 0 && self.directions.contains(direction) == false) ||
            (self.versions.count > 0 && self.versions.contains(version) == false) ||
            (self.orthographies.count > 0 && self.orthographies.contains(orthograpy) == false) {
            return text
        }
        
        var newText = text
        if self.pairs.count > 0 {
            for pair in self.pairs {
                guard let (pairSearch, pairReplace) = pair.text(direction: direction, version: version, orthograpy: orthograpy) else {
                    continue
                }
                
                newText = self.renderer.apply(pairSearch: pairSearch, pairReplace: pairReplace, text: newText, direction: direction)
            }
        } else {
            newText = self.renderer.apply(pairSearch: "", pairReplace: "", text: newText, direction: direction)
        }

        return newText
    }
}
