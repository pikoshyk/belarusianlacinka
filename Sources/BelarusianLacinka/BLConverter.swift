//
//  Converter.swift
//  lacinkaconverter
//
//  Created by Logout on 21.11.22.
//

import Foundation

public class BLConverter: Any {

    internal var rules: [BLRule] = []

    public init()
    {
        guard let rulesUrl = Bundle.module.url(forResource: "rules", withExtension: "xml") else {
            return
        }
                
        self.rules = BLRulesParser(xmlRulesUrl: rulesUrl).parse()
    }

    public func convert(text: String, direction: BLDirection, version: BLVersion, orthograpy: BLOrthography) -> String
    {
        var newText = text
        for rule in self.rules {
            newText = rule.apply(text: newText, direction: direction, version: version, orthograpy: orthograpy)
        }
        return newText
    }
}
