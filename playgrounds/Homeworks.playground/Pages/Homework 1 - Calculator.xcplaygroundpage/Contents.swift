import PlaygroundSupport
import UIKit

extension CalculatorKey {
    var function: ((Double, Double) -> Double)? {
        switch self {
        case .add: return { $0 + $1 }
        case .subtract: return { $0 - $1 }
        case .multiply: return { $0 * $1 }
        case .divide: return { $0 / $1 }
        default: return nil
        }
    }
}

public class Controller: NSObject, CalculatorViewDelegate, CalculatorViewDataSource {
    var displayText = "0"
    var isDot = false
    var isSecondValue = false
    var operation: CalculatorKey = .undefined
    var firstValue: Double?

    public func calculatorView(_ calculatorView: CalculatorView, didPress key: CalculatorKey) {
        switch key {
        case .number:
            if operation != .undefined && !isSecondValue {
                guard let _ = firstValue else { return }
                displayText = ""
                isSecondValue = true
            }
            
            if displayText == "0" {
                displayText = key.rawValue
                isDot = false
            } else {
                displayText += key.rawValue
            }
        case .dot:
            guard !isDot else { return }
            displayText += key.rawValue
            isDot = true
        case .add, .subtract, .multiply, .divide:
            guard let displayTextValue = Double(displayText) else {
                return // Do some error handling here
            }
            
            if firstValue != nil, operation != .undefined {
                firstValue = eval()
                operation = .undefined
                displayText = String(firstValue!).hasSuffix(".0") ? String(String(firstValue!).dropLast(2)) : String(firstValue!)
            }
            firstValue = displayTextValue
            operation = key
            isSecondValue = false
            isDot = false
        case .percent:
            guard let secondValue = Double(displayText) else { return }
            if firstValue != nil, operation != .undefined {
                firstValue = eval()
                firstValue = firstValue! / 100.0
                displayText = String(firstValue!)
                operation = .undefined
            } else if firstValue == nil {
                firstValue = secondValue / 100.0
                displayText = String(firstValue!)
                operation = .undefined
            }
        case .toggleSign:
            if displayText != "0", let doubleDisplayText = Double(displayText) {
                let copyDisplayText = String(-1.0 * doubleDisplayText)

                if let _ = Int(displayText) {
                    displayText = String(copyDisplayText.dropLast(2))
                } else {
                    displayText = copyDisplayText
                }
            }
        case .clear:
            isDot = false
            displayText = "0"
            operation = .undefined
            firstValue = nil
        case .equal:
            guard let _ = Double(displayText), operation != .undefined, firstValue != nil else { return }
            firstValue = eval()
            displayText = String(firstValue!).hasSuffix(".0") ? String(String(firstValue!).dropLast(2)) : String(firstValue!)
            operation = .undefined
        default:
            break
        }
    }
    
    public func displayText(_ calculatorView: CalculatorView) -> String {
        return displayText
    }
    
    //MARK: -Private Method
    
    private func eval() -> Double {
        guard let op2 = Double(displayText), let function = operation.function else {
            preconditionFailure("Couldn't get a numerical value from string.")
        }
        return function(firstValue!, op2)
    }
}

// Internal Setup
let controller = Controller(), page = PlaygroundPage.current
setupCalculatorView(for: page, with: controller)
// To see the calculator view:
// 1. Run the Playground (⌘Cmd + ⇧Shift + ↩Return)
// 2. View Assistant Editors (⌘Cmd + ⌥Opt + ↩Return)
// 3. Select Live View in the Assistant Editor tabs
