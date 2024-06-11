//
//  FindElement.swift
//  hank.dump_hierarchyUITests
//
//  Created by Automation on 2024/4/17.
//
     
import XCTest
     
class FindElement {
    var app: XCUIApplication

    init(app: XCUIApplication) {
            // 为属性赋初始值
        self.app = app
    }
    private func getVisibleElementsDescription(element: XCUIElement, indent: String = "") -> String {
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
    
    private func find_element_by_index(index: String) -> XCUIElement {
        return self.app.descendants(matching: .any).element(boundBy: Int(index)!)
    }
    
    
    
    private func find_element_by_predicate(condition: String) -> XCUIElement {
        var element: XCUIElement
        let predicate = NSPredicate(format: condition)
        element = self.app.descendants(matching: .any).element(matching: predicate).firstMatch
        return element
    }
    

    private func find_element_by_xpath(xpath: String) -> XCUIElement {
        let path = xpath.split(separator: "/")
        var element: XCUIElement = self.app
        for step in path {
            let components = step.components(separatedBy: "[")
            let type = components[0]
            let index = Int(components[1].dropLast())!
            
            switch type {
            case "Any":
                element = element.children(matching: .any).element(boundBy: index)
            case "Other":
                element = element.children(matching: .other).element(boundBy: index)
            case "Application":
                element = element.children(matching: .application).element(boundBy: index)
            case "Group":
                element = element.children(matching: .group).element(boundBy: index)
            case "Window":
                element = element.children(matching: .window).element(boundBy: index)
            case "Sheet":
                element = element.children(matching: .sheet).element(boundBy: index)
            case "Drawer":
                element = element.children(matching: .drawer).element(boundBy: index)
            case "Alert":
                element = element.children(matching: .alert).element(boundBy: index)
            case "Dialog":
                element = element.children(matching: .dialog).element(boundBy: index)
            case "Button":
                element = element.children(matching: .button).element(boundBy: index)
            case "RadioButton":
                element = element.children(matching: .radioButton).element(boundBy: index)
            case "RadioGroup":
                element = element.children(matching: .radioGroup).element(boundBy: index)
            case "CheckBox":
                element = element.children(matching: .checkBox).element(boundBy: index)
            case "DisclosureTriangle":
                element = element.children(matching: .disclosureTriangle).element(boundBy: index)
            case "PopUpButton":
                element = element.children(matching: .popUpButton).element(boundBy: index)
            case "ComboBox":
                element = element.children(matching: .comboBox).element(boundBy: index)
            case "MenuButton":
                element = element.children(matching: .menuButton).element(boundBy: index)
            case "ToolbarButton":
                element = element.children(matching: .toolbarButton).element(boundBy: index)
            case "Popover":
                element = element.children(matching: .popover).element(boundBy: index)
            case "Keyboard":
                element = element.children(matching: .keyboard).element(boundBy: index)
            case "NavigationBar":
                element = element.children(matching: .navigationBar).element(boundBy: index)
            case "TabBar":
                element = element.children(matching: .tabBar).element(boundBy: index)
            case "TabGroup":
                element = element.children(matching: .tabGroup).element(boundBy: index)
            case "Toolbar":
                element = element.children(matching: .toolbar).element(boundBy: index)
            case "StatusBar":
                element = element.children(matching: .statusBar).element(boundBy: index)
            case "Table":
                element = element.children(matching: .table).element(boundBy: index)
            case "TableRow":
                element = element.children(matching: .tableRow).element(boundBy: index)
            case "TableColumn":
                element = element.children(matching: .tableColumn).element(boundBy: index)
            case "Outline":
                element = element.children(matching: .outline).element(boundBy: index)
            case "OutlineRow":
                element = element.children(matching: .outlineRow).element(boundBy: index)
            case "Browser":
                element = element.children(matching: .browser).element(boundBy: index)
            case "CollectionView":
                element = element.children(matching: .collectionView).element(boundBy: index)
            case "Slider":
                element = element.children(matching: .slider).element(boundBy: index)
            case "PageIndicator":
                element = element.children(matching: .pageIndicator).element(boundBy: index)
            case "ProgressIndicator":
                element = element.children(matching: .progressIndicator).element(boundBy: index)
            case "ActivityIndicator":
                element = element.children(matching: .activityIndicator).element(boundBy: index)
            case "SegmentedControl":
                element = element.children(matching: .segmentedControl).element(boundBy: index)
            case "Picker":
                element = element.children(matching: .picker).element(boundBy: index)
            case "PickerWheel":
                element = element.children(matching: .pickerWheel).element(boundBy: index)
            case "Switch":
                element = element.children(matching: .switch).element(boundBy: index)
            case "Toggle":
                element = element.children(matching: .toggle).element(boundBy: index)
            case "Link":
                element = element.children(matching: .link).element(boundBy: index)
            case "Image":
                element = element.children(matching: .image).element(boundBy: index)
            case "Icon":
                element = element.children(matching: .icon).element(boundBy: index)
            case "SearchField":
                element = element.children(matching: .searchField).element(boundBy: index)
            case "ScrollView":
                element = element.children(matching: .scrollView).element(boundBy: index)
            case "ScrollBar":
                element = element.children(matching: .scrollBar).element(boundBy: index)
            case "StaticText":
                element = element.children(matching: .staticText).element(boundBy: index)
            case "TextField":
                element = element.children(matching: .textField).element(boundBy: index)
            case "SecureTextField":
                element = element.children(matching: .secureTextField).element(boundBy: index)
            case "DatePicker":
                element = element.children(matching: .datePicker).element(boundBy: index)
            case "TextView":
                element = element.children(matching: .textView).element(boundBy: index)
            case "Menu":
                element = element.children(matching: .menu).element(boundBy: index)
            case "MenuItem":
                element = element.children(matching: .menuItem).element(boundBy: index)
            case "MenuBar":
                element = element.children(matching: .menuBar).element(boundBy: index)
            case "MenuBarItem":
                element = element.children(matching: .menuBarItem).element(boundBy: index)
            case "Map":
                element = element.children(matching: .map).element(boundBy: index)
            case "WebView":
                element = element.children(matching: .webView).element(boundBy: index)
            case "IncrementArrow":
                element = element.children(matching: .incrementArrow).element(boundBy: index)
            case "DecrementArrow":
                element = element.children(matching: .decrementArrow).element(boundBy: index)
            case "Timeline":
                element = element.children(matching: .timeline).element(boundBy: index)
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
            case "ColorWell":
                element = element.children(matching: .colorWell).element(boundBy: index)
            case "HelpTag":
                element = element.children(matching: .helpTag).element(boundBy: index)
            case "Matte":
                element = element.children(matching: .matte).element(boundBy: index)
            case "DockItem":
                element = element.children(matching: .dockItem).element(boundBy: index)
            case "Ruler":
                element = element.children(matching: .ruler).element(boundBy: index)
            case "RulerMarker":
                element = element.children(matching: .rulerMarker).element(boundBy: index)
            case "Grid":
                element = element.children(matching: .grid).element(boundBy: index)
            case "LevelIndicator":
                element = element.children(matching: .levelIndicator).element(boundBy: index)
            case "Cell":
                element = element.children(matching: .cell).element(boundBy: index)
            case "LayoutArea":
                element = element.children(matching: .layoutArea).element(boundBy: index)
            case "LayoutItem":
                element = element.children(matching: .layoutItem).element(boundBy: index)
            case "Handle":
                element = element.children(matching: .handle).element(boundBy: index)
            case "Stepper":
                element = element.children(matching: .stepper).element(boundBy: index)
            case "Tab":
                element = element.children(matching: .tab).element(boundBy: index)
            case "TouchBar":
                element = element.children(matching: .touchBar).element(boundBy: index)
            case "StatusItem":
                element = element.children(matching: .statusItem).element(boundBy: index)
            default:
                break
            }
        }
        return element
    }
    func find_element_by_query(query_method:String, query_value:String) -> XCUIElement{
        var element:XCUIElement = XCUIApplication()
        if query_method == "xpath"{
            element = find_element_by_xpath(xpath: query_value)
        }
        if query_method == "index"{
            element = find_element_by_index(index: query_value)
        }
        if query_method == "predicate" {
            element = find_element_by_predicate(condition: query_value)
        }
        return element

    }
    
}
