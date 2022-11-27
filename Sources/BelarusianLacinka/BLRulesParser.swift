//
//  LAParser.swift
//  lacinkaconverter
//
//  Created by Logout on 21.11.22.
//

/**
 * Class Rule
 * The rule collects its patterns and replacements, considering the specified
 * version and orthography, and invokes the appropriate renderer.
 * You can implement you own renderer.
 * See Michaskruzelka\Lacinka\Renderers\RendererInterface.
 * It is a \SimpleXMLElement and it must be structured as follows:
 *
 *      <rule name="[rule_name]">
 *          <sort>[number]</sort>
 *          <renderer>
 *              <name>[Some implementation of RendererInterface]</name>
 *              <search>[Search Pattern, can include <back> or <forth> inheriting nodes]</search>
 *              <replace>[Replacement, can include <back> or <forth> inheriting nodes]</replace>
 *          </renderer>
 *          <directions>
 *              <back>[true|false]</back>
 *              <forth>[true|false]</forth>
 *          </directions>
 *          <versions>
 *              <[version]>[true|false]</[version]>
 *              ...
 *          </versions>
 *          <orthographies>
 *              <[orthography]>[true|false]</[orthography]>
 *              ...
 *          </orthographies>
 *          <pairs>
 *              <pair>
 *                  <cyrillic>[letter|word|etc]</cyrillic>
 *                  <latin>[letter|word|etc]</latin>
 *                  <versions>...</versions>
 *                  <orthographies>...</orthographies>
 *                  <directions>...</directions>
 *              </pair>
 *              ...
 *          </pairs>
 *      </rule>
 *
 * @package Michaskruzelka\Lacinka
 * @author Mikhail Marchanka <michaskruzelka@gmail.com>
 */

import Foundation

class BLRulesParser: NSObject {

    fileprivate let xmlRulesUrl: URL
    
    fileprivate var rules: [BLRule] = []
    fileprivate var currentRule: BLRule?
    fileprivate var currentPair: BLRulePair?
    fileprivate var elementsOrder: [String] = []

    init(xmlRulesUrl: URL) {
        self.xmlRulesUrl = xmlRulesUrl
        super.init()
    }
    
    func parse() -> [BLRule] {
        guard let xmlResponseData = try? Data(contentsOf: self.xmlRulesUrl) else {
            fatalError("Failed to load \(self.xmlRulesUrl)")
        }
        
        let parser = XMLParser(data: xmlResponseData)
        parser.delegate = self
        parser.parse()
        self.rules.sort { rule1, rule2 in
            return rule1.sort < rule2.sort
        }
        return self.rules
    }
}

extension BLRulesParser: XMLParserDelegate {

    func parser(_ parser: XMLParser, didStartElement elementName: String, namespaceURI: String?, qualifiedName qName: String?, attributes attributeDict: [String : String] = [:]) {
        
        //The current parsed tag is presented as `elementName` in this function
        if elementName == "rules" {
            self.rules = []
        } else if elementName == "rule" {
            self.currentRule = BLRule(sort: -1, name: attributeDict["name"] ?? "", renderer: BLRuleRenderer(name: "", search: [:], replace: [:]), directions: [], versions: [], orthographies: [], pairs: [])
            self.currentPair = nil
        } else if elementName == "pairs" {
            self.currentRule?.pairs = []
            self.currentPair = nil
        } else if elementName == "pair" {
            self.currentPair = BLRulePair(cyrillic: "", latin: "", versions: [], orthographies: [], directions: [])
        }
        self.elementsOrder.append(elementName)
    }

    func parser(_ parser: XMLParser, foundCharacters string: String) {
        let valueStr = string.trimmingCharacters(in: .whitespacesAndNewlines)
        let lastElement = self.elementsOrder.last ?? ""
        if lastElement == "sort" {
            if self.elementsOrder.reversed()[1] == "rule" {
                self.currentRule?.sort = Int(valueStr) ?? -1
            }
        } else if lastElement == "cyrillic" {
            if self.elementsOrder.reversed()[1] == "pair" {
                self.currentPair?.cyrillic = valueStr
            }
        } else if lastElement == "latin" {
            if self.elementsOrder.reversed()[1] == "pair" {
                self.currentPair?.latin = valueStr
            }
        } else if self.elementsOrder.count > 1 && self.elementsOrder.reversed()[1] == "directions" {
            for direction in [BLDirection.toCyrillic, BLDirection.toLacin] {
                if direction.rawValue == lastElement {
                    if self.elementsOrder.count > 2 && self.elementsOrder.reversed()[2] == "rule" {
                        if valueStr.lowercased() == "true" {
                            self.currentRule?.directions.append(direction)
                        }
                    } else if self.elementsOrder.count > 2 && self.elementsOrder.reversed()[2] == "pair" {
                        if valueStr.lowercased() == "true" {
                            self.currentPair?.directions .append(direction)
                        }
                    }
                }
            }
        } else if self.elementsOrder.count > 1 && self.elementsOrder.reversed()[1] == "versions" {
            for version in [BLVersion.geographic, BLVersion.traditional] {
                if version.rawValue == lastElement && valueStr.lowercased() == "true" {
                    if self.elementsOrder.count > 2 && self.elementsOrder.reversed()[2] == "rule" {
                        self.currentRule?.versions.append(version)
                    } else if self.elementsOrder.count > 2 && self.elementsOrder.reversed()[2] == "pair" {
                        self.currentPair?.versions.append(version)
                    }
                }
            }
        } else if self.elementsOrder.count > 1 && self.elementsOrder.reversed()[1] == "orthographies" {
            for orthography in [BLOrthography.academic, BLOrthography.academic] {
                if orthography.rawValue == lastElement && valueStr.lowercased() == "true" {
                    if self.elementsOrder.count > 2 && self.elementsOrder.reversed()[2] == "rule" {
                        self.currentRule?.orthographies.append(orthography)
                    } else if self.elementsOrder.count > 2 && self.elementsOrder.reversed()[2] == "pair" {
                        self.currentPair?.orthographies.append(orthography)
                    }
                }
            }
        } else if self.elementsOrder.count > 1 && self.elementsOrder.reversed()[1] == "renderer" {
            if lastElement == "name" {
                self.currentRule?.renderer.name = valueStr
            } else if lastElement == "search" {
                if self.currentRule?.renderer.search.count == 0 {
                    var text = ""
                    if let rule = self.currentRule {
                        text = rule.renderer.defaultSearch ?? ""
                    }
                    self.currentRule?.renderer.defaultSearch = text + valueStr
                }
            } else if lastElement == "replace" {
                if self.currentRule?.renderer.replace.count == 0 {
                    var text = ""
                    if let rule = self.currentRule {
                        text = rule.renderer.defaultReplace ?? ""
                    }
                    self.currentRule?.renderer.defaultReplace = text + valueStr
                }
            }
        } else if self.elementsOrder.count > 2 && self.elementsOrder.reversed()[2] == "renderer" {
            if self.elementsOrder.count > 1 && self.elementsOrder.reversed()[1] == "search" {
                for direction in [BLDirection.toCyrillic, BLDirection.toLacin] {
                    if direction.rawValue == lastElement {
                        var text = ""
                        if let rule = self.currentRule {
                            text = rule.renderer.search[direction] ?? ""
                        }
                        self.currentRule?.renderer.search[direction] = text + valueStr
                    }
                }
            } else if self.elementsOrder.count > 1 && self.elementsOrder.reversed()[1] == "replace" {
                for direction in [BLDirection.toCyrillic, BLDirection.toLacin] {
                    if direction.rawValue == lastElement {
                        var text = ""
                        if let rule = self.currentRule {
                            text = rule.renderer.replace[direction] ?? ""
                        }
                        self.currentRule?.renderer.replace[direction] = text + valueStr
                    }
                }
            }
        }

    }

    func parser(_ parser: XMLParser, didEndElement elementName: String, namespaceURI: String?, qualifiedName qName: String?) {
        for i in (0..<self.elementsOrder.count).reversed() {
            let currentElement = self.elementsOrder[i]
            self.elementsOrder.remove(at: i)
            if currentElement == elementName {
                break
            }
        }
        switch elementName {
        case "rule":
            if let currentRule = self.currentRule {
                self.rules.append(currentRule)
            }
            self.currentRule = nil
        case "pair":
            if let currentPair = self.currentPair {
                self.currentRule?.pairs.append(currentPair)
            }
            self.currentPair = nil
        default: break
        }
    }

    func parserDidEndDocument(_ parser: XMLParser) {
    }
}
