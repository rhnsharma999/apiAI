//
//  ViewController.swift
//  api.ai
//
//  Created by Rohan Lokesh Sharma on 22/02/17.
//  Copyright © 2017 webarch. All rights reserved.
//

import UIKit
import ApiAI
import AVFoundation

class ViewController: UIViewController {
    
    
    var bottomConstraint:NSLayoutConstraint!
    
    
    
    var messages = [String]()
    var indicator = [Bool]()
    
     var myTableView:UITableView = {
        
        var view = UITableView()
        view.translatesAutoresizingMaskIntoConstraints = false
        view.separatorStyle = .none
        view.backgroundColor = .clear
        
        
        return view;
    }()
    
    var container:UIView = {
        
        let view = UIView()
        view.translatesAutoresizingMaskIntoConstraints = false;
        view.backgroundColor = .white
        return view;
        
    }()
    
    let speechSynt = AVSpeechSynthesizer()
    
    var textField:UITextField = {
        
        let view = UITextField()
        view.translatesAutoresizingMaskIntoConstraints = false;
        view.placeholder = "Enter chat"
        return view
    }()
    
    var button:UIButton = {
        let view = UIButton()
        view.translatesAutoresizingMaskIntoConstraints = false;
        view.backgroundColor = .black;
        view.setTitleColor(.white, for: .normal)
        view.setTitle("Send", for: .normal)
        return view;
        
    }()

    override func viewDidLoad() {
        
        
        myTableView.delegate = self
        myTableView.dataSource = self;
        myTableView.estimatedRowHeight = 100
        myTableView.rowHeight = UITableViewAutomaticDimension
        
        myTableView.register(CustomCell.self, forCellReuseIdentifier: "cell")
        myTableView.register(BotCell.self, forCellReuseIdentifier: "cell1")
        view.backgroundColor = .white;
        view.addSubview(container)
        view.addSubview(myTableView)
        setupConstraints()
        checkKeyboard()
        super.viewDidLoad()
        // Do any additional setup after loading the view, typically from a nib.
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    
    func speak(msg:String){
        let speechUtterance = AVSpeechUtterance(string: msg);
        speechSynt.speak(speechUtterance)
    }
    func changeColor(color:UIColor){
        view.backgroundColor = color
    }
    
    
    
    func didPressButton(){
        
        let req = ApiAI.shared().textRequest()
        if let text = textField.text{
            req?.query = text
            
            messages.append(text)
            indicator.append(true)
            print(indicator)
            myTableView.insertRows(at: [IndexPath(row: messages.count-1, section: 0)], with: .right)
            scrollToEnd()
        }
        
        
        
        req?.setMappedCompletionBlockSuccess({ (request, response) in
            let resp = response as! AIResponse
            
            if resp.result.action == "change.color"{
                
                if let parameters = resp.result.parameters as? [String:AIResponseParameter]{
                    
                    let color = parameters["color"]?.stringValue
                    if(color == "red"){
                        self.changeColor(color: .red)
                    }
                    else if color == "black"{
                        self.changeColor(color: .black)
                    }
                    else if color == "blue"{
                        self.changeColor(color: .blue)
                    }
                    
                }
                
                
                
                
                
            }
            if  let textResponse = resp.result.fulfillment.speech{
                
                self.messages.append(textResponse)
                self.indicator.append(false)
                self.myTableView.insertRows(at: [IndexPath(row: self.messages.count-1, section: 0)], with:.right)
                self.speak(msg: textResponse)}
            
            
        }, failure: { (req, error) in
            print(error?.localizedDescription)
        })
        
        
        ApiAI.shared().enqueue(req)
        
    }

    
    func setupConstraints(){
        
        
        container.leftAnchor.constraint(equalTo: view.leftAnchor).isActive = true;
        container.rightAnchor.constraint(equalTo: view.rightAnchor).isActive = true;
        container.heightAnchor.constraint(equalToConstant: 50).isActive = true;
        bottomConstraint = container.bottomAnchor.constraint(equalTo: view.bottomAnchor)
        bottomConstraint.isActive = true;
        
        container.addSubview(textField)
        container.addSubview(button)
        textField.leftAnchor.constraint(equalTo: container.leftAnchor,constant:10).isActive = true;
        textField.rightAnchor.constraint(equalTo: container.rightAnchor,constant:-50).isActive = true;
        textField.heightAnchor.constraint(equalTo:container.heightAnchor).isActive = true;
        textField.bottomAnchor.constraint(equalTo: container.bottomAnchor).isActive = true;
        
        
        button.leftAnchor.constraint(equalTo: textField.rightAnchor).isActive = true;
        button.rightAnchor.constraint(equalTo: container.rightAnchor).isActive = true;
        button.heightAnchor.constraint(equalToConstant: 50).isActive = true;
        button.bottomAnchor.constraint(equalTo: container.bottomAnchor).isActive = true;
        button.addTarget(self, action: #selector(didPressButton), for: .touchUpInside)
        
        
        
        myTableView.leftAnchor.constraint(equalTo: view.leftAnchor).isActive = true;
        myTableView.rightAnchor.constraint(equalTo: view.rightAnchor).isActive = true;
        myTableView.topAnchor.constraint(equalTo: topLayoutGuide.bottomAnchor).isActive = true;
        myTableView.bottomAnchor.constraint(equalTo: container.topAnchor).isActive = true;
        
 
    }

}


extension ViewController:UITableViewDelegate,UITableViewDataSource{
    
    func numberOfSections(in tableView: UITableView) -> Int {
        return 1;
    }
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return messages.count
        
    }
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        if indicator[indexPath.row]{
            let cell = tableView.dequeueReusableCell(withIdentifier: "cell") as! CustomCell
            
            
            cell.textView.text = messages[indexPath.row]
            
            cell.backgroundColor = .clear;
            cell.backgroundView?.backgroundColor = .clear
            
            return cell;
        }
        else{
            let cell = tableView.dequeueReusableCell(withIdentifier: "cell1") as! BotCell
            
            
            cell.textView.text = messages[indexPath.row]
            
            cell.backgroundColor = .clear;
            cell.backgroundView?.backgroundColor = .clear
            
            return cell;
        }
    }
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return UITableViewAutomaticDimension
    }
    
    
    
    
}


class CustomCell:UITableViewCell{
 
   
    let bubbleView:UIView = {
        
        let view = UIView()
        view.translatesAutoresizingMaskIntoConstraints = false;
        view.backgroundColor = .blue;
        view.layer.cornerRadius = 5
        return view;
    }()
    
    let textView:UITextView = {
        let view = UITextView()
        view.translatesAutoresizingMaskIntoConstraints = false;
        view.backgroundColor = .clear;
        view.textColor = .white;
        view.isScrollEnabled = false
        view.font = UIFont.systemFont(ofSize: 15)
        
        return view;
        
    }()
    
    
    
    override init(style: UITableViewCellStyle, reuseIdentifier: String?){
        super.init(style:style,reuseIdentifier:reuseIdentifier)
        setupViews()
        
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    func setupViews(){
        
        addSubview(bubbleView)
        bubbleView.topAnchor.constraint(equalTo: topAnchor,constant:10).isActive = true;
        bubbleView.bottomAnchor.constraint(equalTo: bottomAnchor,constant:-10).isActive = true;
        
        
        
       /* if type == 0{
            
            textView.backgroundColor = .lightGray
            textView.textColor = .black
            bubbleView.leftAnchor.constraint(equalTo: leftAnchor,constant:10).isActive = true;
            bubbleView.rightAnchor.constraint(equalTo: rightAnchor,constant:-frame.width/2).isActive = true
        }
        else{
            
            */
            bubbleView.leftAnchor.constraint(equalTo: leftAnchor,constant:frame.width/2).isActive = true;
            bubbleView.rightAnchor.constraint(equalTo: rightAnchor,constant:-10).isActive = true;
      //  }
        
        bubbleView.addSubview(textView)
        textView.leftAnchor.constraint(equalTo: bubbleView.leftAnchor,constant:10).isActive = true;
        textView.rightAnchor.constraint(equalTo: bubbleView.rightAnchor,constant:-10).isActive = true;
        textView.topAnchor.constraint(equalTo: bubbleView.topAnchor,constant:10).isActive = true;
        textView.bottomAnchor.constraint(equalTo: bubbleView.bottomAnchor,constant:-10).isActive = true;
        
        
        
        
        
    }
}

    class BotCell : UITableViewCell {
        
        let bubbleView:UIView = {
            
            let view = UIView()
            view.translatesAutoresizingMaskIntoConstraints = false;
            view.backgroundColor = .lightGray;
            view.layer.cornerRadius = 5
            return view;
        }()
        
        let textView:UITextView = {
            let view = UITextView()
            view.translatesAutoresizingMaskIntoConstraints = false;
            view.backgroundColor = .clear;
            view.textColor = .white;
            view.isScrollEnabled = false
            view.font = UIFont.systemFont(ofSize: 15)
            
            return view;
            
        }()
        
        
        
        override init(style: UITableViewCellStyle, reuseIdentifier: String?){
            super.init(style:style,reuseIdentifier:reuseIdentifier)
            setupViews()
            
        }
        
        required init?(coder aDecoder: NSCoder) {
            fatalError("init(coder:) has not been implemented")
        }
        func setupViews(){
            
            addSubview(bubbleView)
            bubbleView.topAnchor.constraint(equalTo: topAnchor,constant:10).isActive = true;
            bubbleView.bottomAnchor.constraint(equalTo: bottomAnchor,constant:-10).isActive = true;
            
            
            
           
             textView.backgroundColor = .lightGray
             textView.textColor = .black
             bubbleView.leftAnchor.constraint(equalTo: leftAnchor,constant:10).isActive = true;
             bubbleView.rightAnchor.constraint(equalTo: rightAnchor,constant:-frame.width/2).isActive = true
            
 
            
            bubbleView.addSubview(textView)
            textView.leftAnchor.constraint(equalTo: bubbleView.leftAnchor,constant:10).isActive = true;
            textView.rightAnchor.constraint(equalTo: bubbleView.rightAnchor,constant:-10).isActive = true;
            textView.topAnchor.constraint(equalTo: bubbleView.topAnchor,constant:10).isActive = true;
            textView.bottomAnchor.constraint(equalTo: bubbleView.bottomAnchor,constant:-10).isActive = true;
 
    }
}

extension ViewController{
    
    
    func scrollToEnd(){
        if(messages.count > 0){
            
            myTableView.scrollToRow(at:IndexPath(row:messages.count-1,section:0), at: .bottom , animated: true)
        
        }
    }
    
    func checkKeyboard()
    {
        
        NotificationCenter.default.addObserver(self, selector: #selector(keyboardDidShow), name: NSNotification.Name.UIKeyboardWillShow, object: nil)
        
        NotificationCenter.default.addObserver(self, selector: #selector(keyboardHid), name: NSNotification.Name.UIKeyboardWillHide, object: nil)
    }
    
    func keyboardDidShow(notification:NSNotification)
    {
        print("didshow")
        
        
        let keyboardFrame = notification.userInfo?[UIKeyboardFrameEndUserInfoKey] as? CGRect
        let height = keyboardFrame?.height
        let duration = notification.userInfo?[UIKeyboardAnimationDurationUserInfoKey] as? Double
        
        if let keyHeight = height
        {
            bottomConstraint.constant = -keyHeight
        }
        
        if let dur = duration
        {
            UIView.animate(withDuration: dur, animations: {self.view.layoutIfNeeded()
                
                self.scrollToEnd()
                
            }, completion:nil)
        }
        
        
        
        
    }
    func keyboardHid(notification:NSNotification)
    {
        let duration = notification.userInfo?[UIKeyboardAnimationDurationUserInfoKey] as? Double
        
        bottomConstraint.constant = 0
        if let dur = duration
        {
            UIView.animate(withDuration: dur, animations: {
                
                self.view.layoutIfNeeded()
                
            })
        }
        
    }
}

