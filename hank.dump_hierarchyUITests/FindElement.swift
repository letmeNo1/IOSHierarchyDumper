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
                let index = Int(element[bracketIndex...].trimmingCharacters(in: CharacterSet(charactersIn: "[]")))
                let elementTypes: [String: (XCUIElement, Int) -> XCUIElement] = [
                           "Other": { $0.otherElements.element(boundBy: $1) },
                           "NavigationBar": { $0.navigationBars.element(boundBy: $1) },
                           "StaticText": { $0.staticTexts.element(boundBy: $1) },
                           "Image": { $0.images.element(boundBy: $1) },
                           "Button": { $0.buttons.element(boundBy: $1) },
                           "Cell": { $0.cells.element(boundBy: $1) },
                           "TextField": { $0.textFields.element(boundBy: $1) },
                           "SecureTextField": { $0.secureTextFields.element(boundBy: $1) },
                           "Switch": { $0.switches.element(boundBy: $1) },
                           "Slider": { $0.sliders.element(boundBy: $1) },
                           "Stepper": { $0.steppers.element(boundBy: $1) },
                           "PageIndicator": { $0.pageIndicators.element(boundBy: $1) },
                           "StatusBar": { $0.statusBars.element(boundBy: $1) },
                           "Table": { $0.tables.element(boundBy: $1) },
                           "CollectionView": { $0.collectionViews.element(boundBy: $1) },
                           "ScrollView": { $0.scrollViews.element(boundBy: $1) },
                           "WebView": { $0.webViews.element(boundBy: $1) },
                           "Map": { $0.maps.element(boundBy: $1) },
                           "SegmentedControl": { $0.segmentedControls.element(boundBy: $1) },
                           "Picker": { $0.pickers.element(boundBy: $1) },
                           "PickerWheel": { $0.pickerWheels.element(boundBy: $1) },
                           "ActivityIndicator": { $0.activityIndicators.element(boundBy: $1) },
                           "ProgressIndicator": { $0.progressIndicators.element(boundBy: $1) },
                           "SearchField": { $0.searchFields.element(boundBy: $1) },
                           "TextView": { $0.textViews.element(boundBy: $1) },
                           "DatePicker": { $0.datePickers.element(boundBy: $1) },
                           "Menu": { $0.menus.element(boundBy: $1) },
                           "MenuItem": { $0.menuItems.element(boundBy: $1) },
                           "Toolbar": { $0.toolbars.element(boundBy: $1) },
                           "Tab": { $0.tabs.element(boundBy: $1) },
                           "TabGroup": { $0.tabGroups.element(boundBy: $1) },
                           "Key": { $0.keys.element(boundBy: $1) },
                           "Keyboard": { $0.keyboards.element(boundBy: $1) },
                           "Link": { $0.links.element(boundBy: $1) },
                           "RatingIndicator": { $0.ratingIndicators.element(boundBy: $1) },
                           "ValueIndicator": { $0.valueIndicators.element(boundBy: $1) },
                           "SplitGroup": { $0.splitGroups.element(boundBy: $1) },
                           "Splitter": { $0.splitters.element(boundBy: $1) },
                           "RelevanceIndicator": { $0.relevanceIndicators.element(boundBy: $1) },
                           "Timeline": { $0.timelines.element(boundBy: $1) },
                           "TouchBar": { $0.touchBars.element(boundBy: $1) },
                           "LayoutArea": { $0.layoutAreas.element(boundBy: $1) },
                           "LayoutItem": { $0.layoutItems.element(boundBy: $1) },
                           "LevelIndicator": { $0.levelIndicators.element(boundBy: $1) },
                           "Matte": { $0.mattes.element(boundBy: $1) },
                           "DockItem": { $0.dockItems.element(boundBy: $1) },
                           "Ruler": { $0.rulers.element(boundBy: $1) },
                           "RulerMarker": { $0.rulerMarkers.element(boundBy: $1) },
                           "Grid": { $0.grids.element(boundBy: $1) },
                           // Add more types here...
                       ]	

                if let index = index, let elementFunction = elementTypes[type] {
                    currentElement = elementFunction(currentElement, index)
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
