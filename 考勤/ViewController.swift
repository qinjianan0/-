//
//  ViewController.swift
//  考勤
//
//  Created by Foxconn 38 on 2017/11/21.
//  Copyright © 2017年 Foxconn 38. All rights reserved.
//

import UIKit

class ViewController: UIViewController,XMLParserDelegate,UITextFieldDelegate{

    @IBOutlet weak var nameTextField: UITextField!
    @IBOutlet weak var passwordTextField: UITextField!
    override func viewDidLoad() {
        super.viewDidLoad()
        let userDefaults=UserDefaults.standard
         passwordTextField.text=userDefaults.string(forKey:"password")
         nameTextField.text=userDefaults.string(forKey:"user")
        let imageView1 = UIImageView(image:UIImage(named:"user"))
        imageView1.frame = CGRect(x:0,y:0,width:25,height:25)
        nameTextField.leftView = imageView1
        nameTextField.leftViewMode = UITextFieldViewMode.always
   
      
        let imageView2 = UIImageView(image:UIImage(named:"password"))
        imageView2.frame = CGRect(x:0,y:0,width:25,height:25)
        passwordTextField.leftView = imageView2
        passwordTextField.leftViewMode = UITextFieldViewMode.always
        passwordTextField.delegate=self
        nameTextField.delegate=self
       
    }
    
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        passwordTextField.resignFirstResponder()
        nameTextField.resignFirstResponder()
        return true
    }
        
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
    }
    
    var name=""
    var password=""
    var elementData:[GDataXMLElement]=[]
    var elementValue:[String]=[]
    @IBAction func login(_ sender: UIButton) {
        name=nameTextField.text!
        password=passwordTextField.text!
        if name.isEmpty{
            promptMessage(param: "用戶名不能為空")
        }else if password.isEmpty{
            promptMessage(param: "密碼不能為空")
        }else{
            let soapmsg="<?xml version=\"1.0\" encoding=\"utf-8\"?>"+"<soap:Envelope xmlns:xsi=\"http://www.w3.org/2001/XMLSchema-instance\" xmlns:xsd=\"http://www.w3.org/2001/XMLSchema\" xmlns:soap=\"http://schemas.xmlsoap.org/soap/envelope/\">"+"<soap:Body>"+"<checkUserInfoStr xmlns=\"http://tempuri.org/\">"+"<userNo>\(name)</userNo>"+"<password>\(password)</password>"+"</checkUserInfoStr>"+"</soap:Body>"+"</soap:Envelope>"
            let urlString="http://106.14.5.95:8090/AttendService1.asmx"
            let url=URL(string:urlString)
            var request=URLRequest(url:url!)
            let msgLength=String(soapmsg.count)
            request.addValue("text/xml;charest=utf-8", forHTTPHeaderField: "Content-Type")//請求類型
            request.addValue(msgLength, forHTTPHeaderField: "Content-Length")//請求長度，加入請求頭中
            request.addValue("http://tempuri.org/checkUserInfoStr", forHTTPHeaderField: "SOAPAction")//這三處主要是為了設計請求頭，這個根據webservice的接口要求形式決定。
            request.httpMethod="POST"
            request.httpBody=soapmsg.data(using:.utf8)
            let session=URLSession.shared
            let task=session.dataTask(with: request){(data,respone,error)->Void in
                print(String(data:data!,encoding:.utf8) as Any)
                if let Error=error{
                    print(Error.localizedDescription)
                }else{
                    print("請求成功")
                    let a=try! GDataXMLDocument(data:data!,options:0)
                    let root=a.rootElement()
                    let elementF=root?.elements(forName: "soap:Body")[0] as! GDataXMLElement
                    for xmlData in elementF.elements(forName: "checkUserInfoStrResponse"){
                        self.elementData=(xmlData as AnyObject).elements(forName: "checkUserInfoStrResult") as! [GDataXMLElement]
                    }
                    self.elementValue=self.elementData[0].stringValue().components(separatedBy: "&")
                    if self.elementValue[0]=="2"{
                        print("登錄成功")
                        DispatchQueue.main.async {
                            let userDefaults=UserDefaults.standard
                            userDefaults.set(self.nameTextField.text,forKey:"user")
                            userDefaults.set(self.passwordTextField.text,forKey:"password")
                            userDefaults.synchronize()
                        }
                        self.user_name=self.elementValue[1]
                            self.setDic()
                        if (self.myDic["USER_NAME"]? .isEmpty)!{
                            self.errMessage(param: "日誌缺失")
                        }else{
                            self.jsonString=self.getJSONStringFromDictionary(dictionary: self.myDic as NSDictionary)
                            self.webService2()
                        }
                    }else if self.elementValue[0]=="1"{
                        print("登陸失敗")
                        DispatchQueue.main.async {
                            self.errMessage(param: "请确认用户名和密码")
                        }
                    }else if self.elementValue[0]=="0"{
                        DispatchQueue.main.async {
                            self.errMessage(param: "没有权限")
                        }
                    }
                }
            }
            task.resume()//啟動請求任務
        }
    }
    
        func errMessage(param:String){
            let errMessage=UIAlertController(title: "登錄失敗",message:param,preferredStyle:.alert)
            errMessage.addAction(UIAlertAction(title:"OK",style:.default,handler:nil))
            present(errMessage,animated: true,completion: nil)
        }
    
        func promptMessage(param:String){
            let errMessage=UIAlertController(title:"",message:param,preferredStyle:.alert)
            errMessage.addAction(UIAlertAction(title:"OK",style:.default,handler:nil))
            present(errMessage,animated: true,completion: nil)
            
        }
    
    var logTime=""
    var user_name=""
    var myDic:[String: String]=[:]  //建立个空字典
    func setDic(){

        //获取当前时间
        let now = Date()
        // 创建一个日期格式器
        let  dateFormatter = DateFormatter()
        dateFormatter.dateFormat = "yyyy/MM/dd HH:mm:ss"
        logTime = dateFormatter.string(from: now)
        //获取设备号
        myDic["DEVICE_ID"]=(UIDevice.current.identifierForVendor?.uuidString)!
        myDic["USER_NO"]=name
        myDic["USER_NAME"]=user_name
        myDic["LOG_TIME"]=logTime
        myDic["LOG_ITEM"]="考勤管理"
        myDic["MOD_USER"]=name
        myDic["MOD_DATE"]=logTime
        myDic["IS_SYNCH"]="N"

    }
    var jsonString=""
    
    func getJSONStringFromDictionary(dictionary:NSDictionary) -> String {
        if (!JSONSerialization.isValidJSONObject(dictionary)) {
            print("无法解析出JSONString")
            return ""
        }
        let data : NSData! = try? JSONSerialization.data(withJSONObject: dictionary, options: []) as NSData!
        let JSONString = NSString(data:data as Data,encoding: String.Encoding.utf8.rawValue)
        return JSONString! as String
    }
    
    var elementData1:[GDataXMLElement]=[]
    func webService2(){
        let soapmsg="<?xml version=\"1.0\" encoding=\"utf-8\"?>"+"<soap:Envelope xmlns:xsi=\"http://www.w3.org/2001/XMLSchema-instance\" xmlns:xsd=\"http://www.w3.org/2001/XMLSchema\" xmlns:soap=\"http://schemas.xmlsoap.org/soap/envelope/\">"+"<soap:Body>"+"<insertDataByJson xmlns=\"http://tempuri.org/\">"+"<jsonStr>\(jsonString)</jsonStr>"+"<collectionName>BSAppLog</collectionName>"+"</insertDataByJson>"+"</soap:Body>"+"</soap:Envelope>"
        let urlString="http://106.14.5.95:8090/Service2.asmx"
        let url=URL(string:urlString)
        var request=URLRequest(url:url!)
        let msgLength=String(soapmsg.count)
        request.addValue("text/xml;charest=utf-8", forHTTPHeaderField: "Content-Type")//請求類型
        request.addValue("application/x-www-form-urlencoded;charset=utf-8", forHTTPHeaderField: "Content-Type")
        request.addValue(msgLength, forHTTPHeaderField: "Content-Length")//請求長度，加入請求頭中
        request.addValue("http://tempuri.org/insertDataByJson", forHTTPHeaderField: "SOAPAction")//這三處主要是為了設計請求頭，這個根據webservice的接口要求形式決定。
        request.httpMethod="POST"
        request.httpBody=soapmsg.data(using:.utf8)
        request.timeoutInterval=15//設置請求超時時間
        let session=URLSession.shared
        let task=session.dataTask(with:request){(data,response,error)-> Void in
            print(String(data:data!,encoding:.utf8) as Any)
            if let Error=error{
                print(Error.localizedDescription)
            }else{
                let a=try! GDataXMLDocument(data:data!,options:0)
                let root=a.rootElement()
                let elementF=root?.elements(forName: "soap:Body")[0] as! GDataXMLElement
                for xmlData in elementF.elements(forName: "insertDataByJsonResponse"){
                    self.elementData1=(xmlData as AnyObject).elements(forName: "insertDataByJsonResult") as! [GDataXMLElement]
                }
                if self.elementData1[0].stringValue() == "true"{
                    DispatchQueue.main.async {
                    self.performSegue(withIdentifier: "show", sender: nil)
                    }
                }else{
                    DispatchQueue.main.async {
                    self.errMessage(param: "日誌缺失")
                    }
                }
           }
        }
        task.resume()
    }
}

