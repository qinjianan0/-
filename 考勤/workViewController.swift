//
//  workViewController.swift
//  考勤
//
//  Created by Foxconn 38 on 2017/11/22.
//  Copyright © 2017年 Foxconn 38. All rights reserved.
//

import UIKit

class workViewController: UIViewController ,XMLParserDelegate,UITableViewDataSource,UITableViewDelegate{
    
    @IBOutlet weak var workTextField: UITextField!
    @IBOutlet weak var abnormalTextField: UITextField!
    @IBOutlet weak var placeLabel: UILabel!
    @IBOutlet weak var tableView: UITableView!
    override func viewDidLoad() {
        tableView.dataSource=self
        tableView.delegate=self
        super.viewDidLoad()
        workTextField.textColor = .red
        abnormalTextField.textColor = .red
        
        //placeLabel.text=place1
        //webService1()
        //webService2()
        
    }
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return 100.0
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return nameValue.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let Cell=tableView.dequeueReusableCell(withIdentifier: "cell", for: indexPath) as! workTableViewCell
        Cell.nameTextField.text=nameValue[indexPath.row]
        Cell.placeTextField.text=placeValue[indexPath.row]
        Cell.workTextField.text=workValue[indexPath.row]
        Cell.freeTextField.text=freeValue[indexPath.row]
        Cell.remarkTextField.text=remarkValue[indexPath.row]
        return Cell
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
    }
    
    var date=""
    var place=""
    var abnormal=""
    var elementData:[GDataXMLElement]=[]
    var elementValue=""
    func webService1(){
        let soapmsg="<?xml version=\"1.0\" encoding=\"utf-8\"?>"+"<soap:Envelope xmlns:xsi=\"http://www.w3.org/2001/XMLSchema-instance\" xmlns:xsd=\"http://www.w3.org/2001/XMLSchema\" xmlns:soap=\"http://schemas.xmlsoap.org/soap/envelope/\">"+"<soap:Body>"+"<findArea xmlns=\"http://tempuri.org/\">"+"<date>\(date)</date>"+"<area>\(place)</area>"+"</findArea>"+"</soap:Body>"+"</soap:Envelope>"
        let urlString="http://106.14.5.95:8090/AttendService1.asmx?"
        let url=URL(string:urlString)
        var request=URLRequest(url:url!)
        let msgLength=String(soapmsg.count)
        request.addValue("text/xml;charest=utf-8", forHTTPHeaderField: "Content-Type")//請求類型
        request.addValue(msgLength, forHTTPHeaderField: "Content-Length")//請求長度，加入請求頭中
        request.addValue("http://tempuri.org/findArea", forHTTPHeaderField: "SOAPAction")//這三處主要是為了設計請求頭，這個根據webservice的接口要求形式決定。
        request.addValue("application/x-www-form-urlencoded;charset=utf-8",forHTTPHeaderField: "Content-Type")
        request.httpMethod="POST"
        request.httpBody=soapmsg.data(using:.utf8)
        request.timeoutInterval=15//設置請求超時時間
        let session=URLSession.shared
        let task=session.dataTask(with:request){(data,response,error)-> Void in
            print(String(data:data!,encoding:.utf8) as Any)
            if let err=error{
                DispatchQueue.main.async {
                    self.errMessage(parm: "請求失敗", parm1: err.localizedDescription)
                }
            }else{
                let a=try! GDataXMLDocument(data:data!,options:0)
                let root=a.rootElement()//建立根節點，節點要一層一層往下找必須被作為節點不能作為節點數組
                let elementF=root?.elements(forName: "soap:Body")[0] as! GDataXMLElement
                let elementS=elementF.elements(forName: "findAreaResponse")[0] as! GDataXMLElement
                if elementS.stringValue()==""{
                    self.errMessage(parm:"查詢失敗", parm1:"編號不存在")
                }else{
                    for xmlData in elementF.elements(forName: "findAreaResponse"){
                        self.elementData=(xmlData as AnyObject).elements(forName: "findAreaResult") as! [GDataXMLElement]
                    }
                    print(self.elementData[0].stringValue())
                    self.elementValue=self.elementData[0].stringValue()
                    self.checkJsonAnalysis(param: self.elementValue)
                    DispatchQueue.main.async {
                        self.placeLabel.text=self.place
                        self.tableView.reloadData()
                        self.workTextField.text=String(self.nameValue.count)
                        self.abnormalTextField.text=self.abnormal
                    }
                    self.elementValue.removeAll()
                    
                }
                
            }
        }
        task.resume()
    }
    
    var checkDate1=""
    var place1=""
    var abnormal1=""
    func webService2(){
        let soapmsg="<?xml version=\"1.0\" encoding=\"utf-8\"?>"+"<soap:Envelope xmlns:xsi=\"http://www.w3.org/2001/XMLSchema-instance\" xmlns:xsd=\"http://www.w3.org/2001/XMLSchema\" xmlns:soap=\"http://schemas.xmlsoap.org/soap/envelope/\">"+"<soap:Body>"+"<findCHArea xmlns=\"http://tempuri.org/\">"+"<date>\(checkDate1)</date>"+"<area>\(place1)</area>"+"</findCHArea>"+"</soap:Body>"+"</soap:Envelope>"
        let urlString="http://106.14.5.95:8090/AttendService1.asmx?"
        let url=URL(string:urlString)
        var request=URLRequest(url:url!)
        let msgLength=String(soapmsg.count)
        request.addValue("text/xml;charest=utf-8", forHTTPHeaderField: "Content-Type")//請求類型
        request.addValue(msgLength, forHTTPHeaderField: "Content-Length")//請求長度，加入請求頭中
        request.addValue("http://tempuri.org/findCHArea", forHTTPHeaderField: "SOAPAction")//這三處主要是為了設計請求頭，這個根據webservice的接口要求形式決定。
        request.addValue("application/x-www-form-urlencoded;charset=utf-8",forHTTPHeaderField: "Content-Type")
        request.httpMethod="POST"
        request.httpBody=soapmsg.data(using:.utf8)
        request.timeoutInterval=15//設置請求超時時間
        let session=URLSession.shared
        let task=session.dataTask(with:request){(data,response,error)-> Void in
            print(String(data:data!,encoding:.utf8) as Any)
            if let err=error{
                DispatchQueue.main.async {
                    self.errMessage(parm: "請求失敗", parm1: err.localizedDescription)
                }
            }else{
                let a=try! GDataXMLDocument(data:data!,options:0)
                let root=a.rootElement()//建立根節點，節點要一層一層往下找必須被作為節點不能作為節點數組
                let elementF=root?.elements(forName: "soap:Body")[0] as! GDataXMLElement
                let elementS=elementF.elements(forName: "findCHAreaResponse")[0] as! GDataXMLElement
                if elementS.stringValue()==""{
                    self.errMessage(parm:"查詢失敗", parm1:"編號不存在")
                }else{
                    for xmlData in elementF.elements(forName: "findCHAreaResponse"){
                        self.elementData=(xmlData as AnyObject).elements(forName: "findCHAreaResult") as! [GDataXMLElement]
                    }
                    print(self.elementData[0].stringValue())
                    self.elementValue=self.elementData[0].stringValue()
                    self.checkJsonAnalysis(param: self.elementValue)
                    DispatchQueue.main.async {
                        self.placeLabel.text=self.place1
                        self.tableView.reloadData()
                        self.workTextField.text=String(self.nameValue.count)
                        self.abnormalTextField.text=self.abnormal1
                    }
                    self.elementValue.removeAll()
                    
                }
                
            }
        }
        task.resume()
    }
    
        var nameValue:[String]=[]
        var placeValue:[String]=[]
        var workValue:[String]=[]
        var freeValue:[String]=[]
        var remarkValue:[String]=[]
        func checkJsonAnalysis(param:String){
            self.nameValue.removeAll()
            self.placeValue.removeAll()
            self.workValue.removeAll()
            self.freeValue.removeAll()
            self.remarkValue.removeAll()
            let jsonData=param.data(using:.utf8, allowLossyConversion: false)
                let json=try? JSON(data:jsonData!)
                for i in 0..<json!.count{
                    nameValue.append(String(describing:json![i]["AOAD_NAME"]))
                    placeValue.append(String(describing:json![i]["AOAD_AREA"]))
                    workValue.append(String(describing:json![i]["AOAD_BSTATE"]))
                    freeValue.append(String(describing:json![i]["AOAD_ESTATE"]))
                    remarkValue.append(String(describing:json![i]["AOAD_MEMOHR"]))
                    
            }
    }
    
    func errMessage(parm:String,parm1:String){
        let errMessage=UIAlertController(title:parm,message:parm1,preferredStyle:.alert)
        errMessage.addAction(UIAlertAction(title:"OK",style:.default,handler:nil))
        present(errMessage,animated: true,completion: nil)
    }
    
    @IBAction func unwind(_ sender: UIButton){
        dismiss(animated: true, completion: nil)
    }
    
}





