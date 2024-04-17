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

//    func find_element_by_xpath(bundle_id: String, app: XCUIApplication, xpath: String) -> XCUIElement? {
//        let elements = xpath.split(separator: "/")
//        let app = XCUIApplication(bundleIdentifier:String(bundle_id))
//        var currentElement = app.children(matching: .any).element(boundBy: 0)
//        print(elements)
//        for element in elements {
//            if let bracketIndex = element.firstIndex(of: "[") {
//                let type = String(element.prefix(upTo: bracketIndex))
//                let index = Int(element[bracketIndex...].trimmingCharacters(in: CharacterSet(charactersIn: "[]")))
//                print(index)
//                let otherElements = currentElement.children(matching: .any).count
//                print(otherElements)
//                let elementTypes: [String: (XCUIElement, Int) -> XCUIElement] = [
//                           "Other": { $0.otherElements.element(boundBy: $1) },
//                           "NavigationBar": { $0.navigationBars.element(boundBy: $1) },
//                           "StaticText": { $0.staticTexts.element(boundBy: $1) },
//                           "Image": { $0.images.element(boundBy: $1) },
//                           "Button": { $0.buttons.element(boundBy: $1) },
//                           "Cell": { $0.cells.element(boundBy: $1) },
//                           "TextField": { $0.textFields.element(boundBy: $1) },
//                           "SecureTextField": { $0.secureTextFields.element(boundBy: $1) },
//                           "Switch": { $0.switches.element(boundBy: $1) },
//                           "Slider": { $0.sliders.element(boundBy: $1) },
//                           "Stepper": { $0.steppers.element(boundBy: $1) },
//                           "PageIndicator": { $0.pageIndicators.element(boundBy: $1) },
//                           "StatusBar": { $0.statusBars.element(boundBy: $1) },
//                           "Table": { $0.tables.element(boundBy: $1) },
//                           "CollectionView": { $0.collectionViews.element(boundBy: $1) },
//                           "ScrollView": { $0.scrollViews.element(boundBy: $1) },
//                           "WebView": { $0.webViews.element(boundBy: $1) },
//                           "Map": { $0.maps.element(boundBy: $1) },
//                           "SegmentedControl": { $0.segmentedControls.element(boundBy: $1) },
//                           "Picker": { $0.pickers.element(boundBy: $1) },
//                           "PickerWheel": { $0.pickerWheels.element(boundBy: $1) },
//                           "ActivityIndicator": { $0.activityIndicators.element(boundBy: $1) },
//                           "ProgressIndicator": { $0.progressIndicators.element(boundBy: $1) },
//                           "SearchField": { $0.searchFields.element(boundBy: $1) },
//                           "TextView": { $0.textViews.element(boundBy: $1) },
//                           "DatePicker": { $0.datePickers.element(boundBy: $1) },
//                           "Menu": { $0.menus.element(boundBy: $1) },
//                           "MenuItem": { $0.menuItems.element(boundBy: $1) },
//                           "Toolbar": { $0.toolbars.element(boundBy: $1) },
//                           "Tab": { $0.tabs.element(boundBy: $1) },
//                           "TabGroup": { $0.tabGroups.element(boundBy: $1) },
//                           "Key": { $0.keys.element(boundBy: $1) },
//                           "Keyboard": { $0.keyboards.element(boundBy: $1) },
//                           "Link": { $0.links.element(boundBy: $1) },
//                           "RatingIndicator": { $0.ratingIndicators.element(boundBy: $1) },
//                           "ValueIndicator": { $0.valueIndicators.element(boundBy: $1) },
//                           "SplitGroup": { $0.splitGroups.element(boundBy: $1) },
//                           "Splitter": { $0.splitters.element(boundBy: $1) },
//                           "RelevanceIndicator": { $0.relevanceIndicators.element(boundBy: $1) },
//                           "Timeline": { $0.timelines.element(boundBy: $1) },
//                           "TouchBar": { $0.touchBars.element(boundBy: $1) },
//                           "LayoutArea": { $0.layoutAreas.element(boundBy: $1) },
//                           "LayoutItem": { $0.layoutItems.element(boundBy: $1) },
//                           "LevelIndicator": { $0.levelIndicators.element(boundBy: $1) },
//                           "Matte": { $0.mattes.element(boundBy: $1) },
//                           "DockItem": { $0.dockItems.element(boundBy: $1) },
//                           "Ruler": { $0.rulers.element(boundBy: $1) },
//                           "RulerMarker": { $0.rulerMarkers.element(boundBy: $1) },
//                           "Grid": { $0.grids.element(boundBy: $1) },
//                           // Add more types here...
//                       ]	
//
//                if let index = index, let elementFunction = elementTypes[type] {
//                    currentElement = elementFunction(currentElement, index)
//                }
//            }
//        }
//        if !currentElement.exists {
//            print("Element not found")
//            return nil
//        }
//        return currentElement
//    }
//}
    func find_element_by_xpath(bundle_id: String, app: XCUIApplication, xpath: String) -> XCUIElement? {
        let path = xpath.split(separator: "/")
        let app = XCUIApplication(bundleIdentifier:String(bundle_id))
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
        if !element.exists {
            print("Element not found")
            return nil
        }
        return element
    }
}
