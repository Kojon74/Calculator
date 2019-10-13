//
//  ViewController.swift
//  Calculator
//
//  Created by Ken Johnson on 2019-04-30.
//  Copyright © 2019 Ken Johnson. All rights reserved.

//  Fix constraints on iPhone 7
//  Either do everything progrematically or not (need to add constraint between scroll view and one of buttons)
//  Scroll if too many numbers and don't fit on one label or make numbers smaller so text fits
//  Background colour stripes (easier to click answer or console label)
//  Trigenometry functions
//  Add () and square and square root
//  If you press an operator first, takes answer as first number
//  Learn about constraints
//  Learn what wrapped and unwrapped means when converting variables between different types
//  Make / look better
//  If number is too small, it shows 0.0
//  Find a way to work horizontal scrolling but not vertical scrolling on UItextView
//  Figure out why

import UIKit

class ViewController: UIViewController, UITextViewDelegate {
    var count = 0
    var runningNumber = ""
    var currentNumber = ""
    var operationType = "Empty"
    var result = 0.0
    var numDeleted = 0
    var numEquations = 0
    var isFirstNumber = true
    var lastAnswer = 0.0
    var isPow = false
    var powCount = 0
    
    let font:UIFont? = UIFont.systemFont(ofSize: 28)
    let fontSuper:UIFont? = UIFont.systemFont(ofSize: 14)
    
    var attString = NSMutableAttributedString()
    
    var numberArray = [Double]()
    var operationArray1 = [String]()
    var operationArray = [String]()
    var operationArray2 = [String]()
    var plusMinusArray = [Double]()
    
    var tagArray: [String] = ["0","1","2","3","4","5","6","7","8","9","+","–","*","/","=",".","-","DEL","CLR","ANS","(",")","POW","ROT"]
    var consoleLbl  = [UITextView] ()
    var answerLbl  = [UITextView] ()
    
    var currentConsoleLbl = UITextView()
    var currentAnswerLbl = UITextView()
    
    var originalScrollHeight = 0
    
    @IBOutlet weak var buttonDelete: UIButton!
    @IBOutlet weak var buttonEquals: UIButton!
    
    lazy var scrollView: UIScrollView = {
        let view = UIScrollView()
        view.contentSize.height = CGFloat(getScrollViewHeight())
        view.translatesAutoresizingMaskIntoConstraints = false
        view.backgroundColor = UIColor(white: 0.1, alpha: 1)
        return view
    }()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        view.addSubview(scrollView)
        setupScrollView()
        scrollView.scrollToBottom()
    }
    
    func getScrollViewHeight() -> Double {
        let screenHeight = Double(UIScreen.main.bounds.height)
        let topHeight = Double(buttonDelete.center.y) - 47
        let bottomHeight = Double(buttonEquals.center.y) + 45
        let window = UIApplication.shared.windows[0]
        let bottomPadding = window.safeAreaInsets.bottom
        let height = screenHeight - (bottomHeight - topHeight + Double(bottomPadding))
        return height
    }

    func setupScrollView() {
        scrollView.topAnchor.constraint(equalTo: view.topAnchor).isActive = true
        scrollView.bottomAnchor.constraint(equalTo: buttonDelete.bottomAnchor, constant: -72).isActive = true
        scrollView.leadingAnchor.constraint(equalTo: view.leadingAnchor).isActive = true
        scrollView.trailingAnchor.constraint(equalTo: view.trailingAnchor).isActive = true
        scrollView.bounces = false
        originalScrollHeight = Int(scrollView.contentSize.height)
    }
    
    func scrollViewDidScroll(_ scrollView: UIScrollView) {
        let origin: CGPoint = scrollView.contentOffset
        scrollView.contentOffset = CGPoint(x: origin.x, y: 0.0)
    }
    
    @IBAction func pushButton(sender: UIButton) {
        //print(currentConsoleLbl.frame.minY)
        var lastChar = ""
        var useless = 0
        
        if isFirstNumber {
            currentConsoleLbl = UITextView()
            
            if Int(scrollView.contentSize.height)-50 < (numEquations+1)*100 {
                currentConsoleLbl.frame = CGRect(x: 0, y: currentAnswerLbl.frame.origin.y+50, width:self.view.frame.size.width, height:50)
            } else {
                currentConsoleLbl.frame = CGRect(x: 0, y: buttonDelete.frame.origin.y-72, width:self.view.frame.size.width, height:50)
            }
            
            currentConsoleLbl.font = font
            currentConsoleLbl.textColor = UIColor.white
            currentConsoleLbl.backgroundColor = UIColor(white: 0.1, alpha: 1)
            currentConsoleLbl.isScrollEnabled = false
            //currentConsoleLbl.translatesAutoresizingMaskIntoConstraints = false
            scrollView.addSubview(currentConsoleLbl)
            NSLayoutConstraint.activate([
                currentConsoleLbl.heightAnchor.constraint(equalToConstant: 50),
                currentConsoleLbl.leadingAnchor.constraint(equalTo: view.leadingAnchor),
                currentConsoleLbl.trailingAnchor.constraint(equalTo: view.trailingAnchor)
                ])
            isFirstNumber = false
            
        }
        
        let originConsole: CGPoint = currentConsoleLbl.contentOffset
        currentConsoleLbl.contentOffset = CGPoint(x: originConsole.x, y: 0.0)
        
        currentAnswerLbl = UITextView()
        
        switch tagArray[sender.tag] {
        case "0","1","2","3","4","5","6","7","8","9":
            runningNumber += "\(sender.tag)"
            currentNumber += "\(sender.tag)"
            currentConsoleLbl.insertText("\(sender.tag)")
            if isPow == true {
                currentConsoleLbl.font = fontSuper
                attString = NSMutableAttributedString(string: "\(runningNumber)", attributes: [.font:font!])
                attString.setAttributes([.font:fontSuper!,.baselineOffset:14], range: NSRange(location:runningNumber.count-powCount, length:powCount))
                currentConsoleLbl.attributedText = attString
                currentConsoleLbl.textColor = UIColor.white
                powCount += 1
            }
        case "+":
            operationType = "+"
        case "–":
            operationType = "–"
        case "*":
            operationType = "·"
        case "/":
            operationType = "/"
        case "=":
            numEquations += 1
            currentConsoleLbl.font = font
            if Int(scrollView.contentSize.height)-50 < (numEquations)*100 {
                scrollView.contentSize = CGSize(width:self.view.frame.size.width, height:scrollView.contentSize.height + 100)
            }
            currentAnswerLbl.frame = CGRect(x:0, y:currentConsoleLbl.frame.origin.y+50, width:self.view.frame.size.width, height:50)
            //currentAnswerLbl.translatesAutoresizingMaskIntoConstraints = false
            scrollView.addSubview(currentAnswerLbl)
            NSLayoutConstraint.activate([
                currentAnswerLbl.heightAnchor.constraint(equalToConstant: 50),
                currentAnswerLbl.leadingAnchor.constraint(equalTo: view.leadingAnchor),
                currentAnswerLbl.trailingAnchor.constraint(equalTo: view.trailingAnchor)
                ])
            currentAnswerLbl.font = font
            currentAnswerLbl.textColor = UIColor.white
            currentAnswerLbl.textAlignment = NSTextAlignment.right
            currentAnswerLbl.backgroundColor = UIColor(white: 0.2, alpha: 1)
            
            switch runningNumber.last! {
            case "+","-","*","/":
                currentAnswerLbl.text = "ERROR: Invalid Operations"
            default:
                numberArray.append(Double(currentNumber)!)
                calculate()
                if result.truncatingRemainder(dividingBy: 1) != 0 {
                    currentAnswerLbl.text = String(round(1000*result)/1000)
                } else {
                    currentAnswerLbl.text = String(Int(result))
                }
                lastAnswer = result
                
            }
            operationType = "="
            runningNumber += operationType
            currentConsoleLbl.text = runningNumber
            currentConsoleLbl.isEditable = false
            currentAnswerLbl.isEditable = false
            consoleLbl.append(currentConsoleLbl)
            answerLbl.append(currentAnswerLbl)
            if originalScrollHeight-50 > numEquations*100 {
                shiftUp(upBy: 100)
            }
            clear(clearConsole: false)
            isFirstNumber = true
            scrollView.scrollToBottom()
        case ".":
            runningNumber += "."
            currentNumber += "."
            currentConsoleLbl.text = runningNumber
        case "-":
            runningNumber += "-"
            currentNumber += "-"
            currentConsoleLbl.text = runningNumber
        case "DEL":
            if runningNumber == "" {
                break
            }
            lastChar = String((runningNumber.popLast() ?? nil)!)
            currentNumber = String(currentNumber.dropLast())
            currentConsoleLbl.text = runningNumber
            switch lastChar {
            case "+","–","·","/":
                count -= 1
                if numberArray[count].truncatingRemainder(dividingBy: 1) == 0 {
                    currentNumber = String(Int(numberArray[count]))
                } else {
                    currentNumber = String(numberArray[count])
                }
                operationArray = operationArray.dropLast()
                if numDeleted != 0 {
                    numberArray = numberArray.dropLast()
                }
            default:
                useless += 1
            }
            if runningNumber == "" {
                numberArray = numberArray.dropLast()
            }
            numDeleted += 1
        case "CLR":
            clear(clearConsole: true)
        case "ANS":
            if numEquations == 0 {
                clear(clearConsole: true)
                currentAnswerLbl.text = "ERROR: No Previous Answer"
            }
            if lastAnswer.truncatingRemainder(dividingBy: 1) != 0 {
                runningNumber += String(round(1000*lastAnswer)/1000)
            } else {
                runningNumber += String(Int(lastAnswer))
            }
            currentNumber += String(lastAnswer)
            currentConsoleLbl.text = runningNumber
        case "(":
            runningNumber += "("
            currentConsoleLbl.text = runningNumber
        case ")":
            runningNumber += ")"
            currentConsoleLbl.text = runningNumber
        case "POW":
            if isPow == false {
                currentConsoleLbl.font = fontSuper
                attString = NSMutableAttributedString(string: "\(runningNumber)", attributes: [.font:font!])
                attString.setAttributes([.font:fontSuper!,.baselineOffset:14], range: NSRange(location:runningNumber.count,length:powCount))
                currentConsoleLbl.attributedText = attString
                currentConsoleLbl.textColor = UIColor.white
                isPow = true
                powCount = 1
            } else {
                currentConsoleLbl.font = font
                isPow = false
            }
        case "ROT":
            print()
        default:
            currentAnswerLbl.text = "ERROR"
        }
        if operationType == "+" || operationType == "–" || operationType == "·" || operationType == "/" {
            runningNumber += operationType
            if isPow == true {
                currentConsoleLbl.font = fontSuper
                attString = NSMutableAttributedString(string: "\(runningNumber)", attributes: [.font:font!])
                attString.setAttributes([.font:fontSuper!,.baselineOffset:14], range: NSRange(location:runningNumber.count-powCount,length:powCount))
                currentConsoleLbl.attributedText = attString
                currentConsoleLbl.textColor = UIColor.white
                powCount += 1
                print("Through")
            } else {
                currentConsoleLbl.text = runningNumber
            }
            if currentNumber == "" {
                numEquations += 1
                if Int(scrollView.contentSize.height)-50 < (numEquations)*100 {
                    scrollView.contentSize = CGSize(width:self.view.frame.size.width, height:scrollView.contentSize.height + 100)
                }
                currentAnswerLbl.frame = CGRect(x:0, y:currentConsoleLbl.frame.origin.y+50, width:self.view.frame.size.width, height:50)
                //currentAnswerLbl.translatesAutoresizingMaskIntoConstraints = false
                scrollView.addSubview(currentAnswerLbl)
                NSLayoutConstraint.activate([
                    currentAnswerLbl.heightAnchor.constraint(equalToConstant: 50),
                    currentAnswerLbl.leadingAnchor.constraint(equalTo: view.leadingAnchor),
                    currentAnswerLbl.trailingAnchor.constraint(equalTo: view.trailingAnchor)
                    ])
                currentAnswerLbl.font = font
                currentAnswerLbl.textColor = UIColor.white
                currentAnswerLbl.textAlignment = NSTextAlignment.right
                currentAnswerLbl.backgroundColor = UIColor(white: 0.2, alpha: 1)
                currentAnswerLbl.text = "ERROR: Invalid Operations"
                consoleLbl.append(currentConsoleLbl)
                answerLbl.append(currentAnswerLbl)
                if originalScrollHeight-50 > numEquations*100 {
                    shiftUp(upBy: 100)
                }
                clear(clearConsole: false)
                isFirstNumber = true
                scrollView.scrollToBottom()
            } else {
                currentAnswerLbl.font = font
                numberArray.append(Double(currentNumber)!)
                operationArray.append(operationType)
                currentNumber = ""
                operationType = ""
                count += 1
            }
        }
        
    }

    func textViewDidScroll(_ textView: UITextView) {
        let origin: CGPoint = textView.contentOffset
        textView.contentOffset = CGPoint(x: origin.x, y: 0.0)
    }
    
    func clear(clearConsole: Bool) {
        runningNumber = ""
        currentNumber = ""
        operationType = "Empty"
        numberArray = [Double]()
        operationArray = [String]()
        operationArray2 = [String]()
        plusMinusArray = [Double]()
        if clearConsole {
            currentConsoleLbl.text = runningNumber
        }
        count = 0
        result = 0
        numDeleted = 0
        isPow = false
        powCount = 0
    }
    
    func calculate() {
        var a = 0
        while a < operationArray.count {
            if operationArray[a] == "+" || operationArray[a] == "–" {
                plusMinusArray.append(numberArray[a])
                if operationArray[a] == "+" {
                    operationArray2.append("+")
                } else if operationArray[a] == "–" {
                    operationArray2.append("–")
                }
            } else if operationArray[a] == "·" {
                numberArray[a+1] = numberArray[a]*numberArray[a+1]
            } else if operationArray[a] == "/" {
                numberArray[a+1] = numberArray[a]/numberArray[a+1]
            }
            a += 1
        }
        plusMinusArray.append(numberArray[a])
        a = 0
        while a < operationArray2.count {
            if operationArray2[a] == "+" {
                plusMinusArray[a+1] += Double(plusMinusArray[a])
            } else if operationArray2[a] == "–" {
                plusMinusArray[a+1] = Double(plusMinusArray[a]) - Double(plusMinusArray[a+1])
            }
            a += 1
        }
        result = plusMinusArray[a]
    }
    
    func shiftUp(upBy: CGFloat) {
        var a = 0
        while a < consoleLbl.count{
            consoleLbl[a].frame.origin = CGPoint(x:0, y:consoleLbl[a].frame.origin.y - upBy)
            answerLbl[a].frame.origin = CGPoint(x:0, y:answerLbl[a].frame.origin.y - upBy)
            a += 1
        }
    }
}

extension UIScrollView {
    func scrollToBottom() {
        let bottomOffset = CGPoint(x: 0, y: contentSize.height - bounds.size.height + contentInset.bottom)
        setContentOffset(bottomOffset, animated: false)
    }
}
