//
//  FindElement.swift
//  hank.dump_hierarchyUITests
//
//  Created by Automation on 2024/4/17.
//
     
import XCTest
     
class FindElement {
    func find_element_by_xpath(bundle_id: String, app: XCUIApplication, xpath: String) -> XCUIElement? {
        let elements = xpath.split(separator: "/")
        let app = XCUIApplication(bundleIdentifier:String(bundle_id))
        var currentElement = app.children(matching: .any).element(boundBy: 0)
        for element in elements {
            if let bracketIndex = element.firstIndex(of: "[") {
                let type = String(element.prefix(upTo: bracketIndex))
                var index = Int(element[bracketIndex...].trimmingCharacters(in: CharacterSet(charactersIn: "[]")))
                switch type {
                case "Window":
                    if index == 0 {
                        print("pass")
                    } else {
                        currentElement = currentElement.windows.element(boundBy:index!)
                    }
                case "Other":
                    print(index!)
                    currentElement = currentElement.otherElements.element(boundBy:index!)
                case "NavigationBar":
                    currentElement = currentElement.navigationBars.element(boundBy:index!)
                case "StaticText":
                    currentElement = currentElement.staticTexts.element(boundBy:index!)
                case "Image":
                    currentElement = currentElement.images.element(boundBy:index!)
                default:
                    break
                }
            }
        }
        if !currentElement.exists {
            print("Element not found")
            return nil
        }
        return currentElement
    }
}
