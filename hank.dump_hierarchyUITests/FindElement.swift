//
//  FindElement.swift
//  hank.dump_hierarchyUITests
//
//  Created by Automation on 2024/4/17.
//
     
import XCTest
     
class FindElement {
    func getVisibleElementsDescription(element: XCUIElement, indent: String = "") -> String {
        var description = ""
    

        if element.isHittable {
            description += "\(indent)\(element.debugDescription)\n"
        }

        for i in 0..<element.children(matching: .any).count {
            let child = element.children(matching: .any).element(boundBy: i)
            description += getVisibleElementsDescription(element: child, indent: indent + "  ")
        }

        return description
    }
    
    func find_element_by_index(bundle_id: String, app: XCUIApplication, index: String) -> XCUIElement {
        return app.descendants(matching: .any).element(boundBy: Int(index)!)
    }
    
    func find_element_first(app: XCUIApplication, message: String) -> XCUIElement {
        var element: XCUIElement
        let condition = String(message.split(separator: ":")[2]).trimmingCharacters(in: .whitespacesAndNewlines)
        if condition.contains("index"){
            let index = String(message.split(separator: ":")[3]).trimmingCharacters(in: .whitespacesAndNewlines)
            element = app.descendants(matching: .any).element(boundBy: Int(index)!)
        }else{
            let predicate = NSPredicate(format: condition)
            element = app.descendants(matching: .any).element(matching: predicate).firstMatch
        }
        return element
    }
    

    func find_element_by_xpath(app: XCUIApplication, xpath: String) -> XCUIElement {
        let path = xpath.split(separator: "/")
        var element: XCUIElement = app
        for step in path {
            let components = step.components(separatedBy: "[")
            let type = components[0]
            let index = Int(components[1].dropLast())!
            
            switch type {
            case "Window":
                element = element.children(matching: .window).element(boundBy: index)
            
            case "Other":
             
                element = element.children(matching: .other).element(boundBy: index)     
            case "Button":

                element = element.children(matching: .button).element(boundBy: index)
            case "StaticText":
                element = element.children(matching: .staticText).element(boundBy: index)
            case "TextField":
                element = element.children(matching: .textField).element(boundBy: index)
            case "SecureTextField":
                element = element.children(matching: .secureTextField).element(boundBy: index)
            case "Image":
                element = element.children(matching: .image).element(boundBy: index)
            case "Link":
                element = element.children(matching: .link).element(boundBy: index)
            case "SearchField":
                element = element.children(matching: .searchField).element(boundBy: index)
            case "Slider":
                element = element.children(matching: .slider).element(boundBy: index)
            case "Switch":
                element = element.children(matching: .switch).element(boundBy: index)
            case "Picker":
                element = element.children(matching: .picker).element(boundBy: index)
            case "DatePicker":
                element = element.children(matching: .datePicker).element(boundBy: index)
            case "Stepper":
                element = element.children(matching: .stepper).element(boundBy: index)
            case "WebView":
                element = element.children(matching: .webView).element(boundBy: index)
            case "NavigationBar":
                element = element.children(matching: .navigationBar).element(boundBy: index)
            case "Cell":
                element = element.children(matching: .cell).element(boundBy: index)
            case "StatusBar":
                element = element.children(matching: .statusBar).element(boundBy: index)
            case "Table":
                element = element.children(matching: .table).element(boundBy: index)
            case "CollectionView":
                element = element.children(matching: .collectionView).element(boundBy: index)
            case "ScrollView":
                element = element.children(matching: .scrollView).element(boundBy: index)
            case "Map":
                element = element.children(matching: .map).element(boundBy: index)
            case "SegmentedControl":
                element = element.children(matching: .segmentedControl).element(boundBy: index)
            case "PickerWheel":
                element = element.children(matching: .pickerWheel).element(boundBy: index)
            case "ActivityIndicator":
                element = element.children(matching: .activityIndicator).element(boundBy: index)
            case "ProgressIndicator":
                element = element.children(matching: .progressIndicator).element(boundBy: index)
            case "TextView":
                element = element.children(matching: .textView).element(boundBy: index)
            case "Menu":
                element = element.children(matching: .menu).element(boundBy: index)
            case "MenuItem":
                element = element.children(matching: .menuItem).element(boundBy: index)
            case "Toolbar":
                element = element.children(matching: .toolbar).element(boundBy: index)
            case "Tab":
                element = element.children(matching: .tab).element(boundBy: index)
            case "TabGroup":
                element = element.children(matching: .tabGroup).element(boundBy: index)
            case "Key":
                element = element.children(matching: .key).element(boundBy: index)
            case "Keyboard":
                element = element.children(matching: .keyboard).element(boundBy: index)
            case "RatingIndicator":
                element = element.children(matching: .ratingIndicator).element(boundBy: index)
            case "ValueIndicator":
                element = element.children(matching: .valueIndicator).element(boundBy: index)
            case "SplitGroup":
                element = element.children(matching: .splitGroup).element(boundBy: index)
            case "Splitter":
                element = element.children(matching: .splitter).element(boundBy: index)
            case "RelevanceIndicator":
                element = element.children(matching: .relevanceIndicator).element(boundBy: index)
            case "Timeline":
                element = element.children(matching: .timeline).element(boundBy: index)
            case "TouchBar":
                element = element.children(matching: .touchBar).element(boundBy: index)
            case "LayoutArea":
                element = element.children(matching: .layoutArea).element(boundBy: index)
            case "LayoutItem":
                element = element.children(matching: .layoutItem).element(boundBy: index)
            case "LevelIndicator":
                element = element.children(matching: .levelIndicator).element(boundBy: index)
            case "Matte":
                element = element.children(matching: .matte).element(boundBy: index)
            case "DockItem":
                element = element.children(matching: .dockItem).element(boundBy: index)
            case "Ruler":
                element = element.children(matching: .ruler).element(boundBy: index)
            case "RulerMarker":
                element = element.children(matching: .rulerMarker).element(boundBy: index)
            default:
                break
            }
        }
        return element
    }
}
