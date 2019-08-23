import PlaygroundSupport
import UIKit

public class Controller: NSObject, CalculatorViewDelegate, CalculatorViewDataSource {
    var displayText = "0"
    var num: String = String()
    var operationSign: String = String()
    var isDot = false
    
    typealias Operation = (Double, Double) -> Double
    
    public func calculatorView(_ calculatorView: CalculatorView, didPress key: CalculatorKey) {
        switch key {
        case .number(_):
            //Is First Number
            if operationSign.isEmpty && displayText == "0" {
                displayText = key.rawValue
                isDot = false
            } else {
                displayText += key.rawValue
            }
        case .dot:
            if !isDot {
                displayText += key.rawValue
                isDot = true
            }
        case .add, .subtract, .multiply, .divide:
            if let _ = Double(displayText) {
                num = displayText
            } else {
                num = displayText + "." + "0"
            }
            operationSign = key.rawValue
            displayText = ""
            isDot = false
        case .percent:
            num = ""
            operationSign = "%"
            displayText = ""
            displayText += key.rawValue
        case .toggleSign:
            if displayText != "0", let doubleDisplayText = Double(displayText) {
                var copyDisplayText = String(-1.0 * doubleDisplayText)
                
                if let _ = Int(displayText) {
                    copyDisplayText.removeLast()
                    copyDisplayText.removeLast()
                    displayText = copyDisplayText
                } else {
                    displayText = copyDisplayText
                }
            }
        case .clear:
            operationSign = ""
            displayText = "0"
            num = ""
        case .equal:
            if !num.isEmpty && !operationSign.isEmpty, let _ = Double(displayText) {
                //let _ = Double(displayText) vor chkarena mi qani nshan irar hetevic gri
                switch operationSign {
                case "+":
                    evaluate(op1: Double(num)!, op2: Double(displayText)!, operation: +)
                case "-":
                    evaluate(op1: Double(num)!, op2: Double(displayText)!, operation: -)
                case "×":
                    evaluate(op1: Double(num)!, op2: Double(displayText)!, operation: *)
                case "÷":
                    evaluate(op1: Double(num)!, op2: Double(displayText)!, operation: /)
                default:
                    fatalError()
                }
            } else if num.isEmpty && operationSign == "%" { //"%" qnarkum es gorcuxutyan deepq@
                displayText.removeFirst()
                num = String(Double(displayText)!/100.0)
                determineTheType()
            }
        default:
            break
        }
    }
    
    public func displayText(_ calculatorView: CalculatorView) -> String {
        return displayText
    }
    
    //MARK: -Private Func
    
    private func determineTheType() {
        if num.hasSuffix(".0") {
            displayText = num
            displayText.removeLast()
            displayText.removeLast()
        } else {
            displayText = num
        }
    }
    
    private func evaluate(op1: Double, op2: Double, operation: Operation) {
        guard let _ = Double(displayText) else {
            return
        }

        num = String(operation(op1,op2))
        determineTheType()
    }
}

// Internal Setup
let controller = Controller(), page = PlaygroundPage.current
setupCalculatorView(for: page, with: controller)
// To see the calculator view:
// 1. Run the Playground (⌘Cmd + ⇧Shift + ↩Return)
// 2. View Assistant Editors (⌘Cmd + ⌥Opt + ↩Return)
// 3. Select Live View in the Assistant Editor tabs
