//
//  QQViewController.swift
//  考勤
//
//  Created by Foxconn 38 on 2017/11/24.
//  Copyright © 2017年 Foxconn 38. All rights reserved.
//

import UIKit

class QQViewController: UIViewController ,UISearchBarDelegate{


    @IBOutlet weak var myTextField: UITextField!
    override func viewDidLoad() {
        super.viewDidLoad()
        webService2()
    // Do any additional setup after loading the view.
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
   
    var checkName:[String]=[]//為表格數據的巡檢人建立數據模型
    var checkPlace:[String]=[]//為表格數據巡檢日期建立數據模型
    var checkReason:[String]=[]//為表格數據巡檢狀態建立數據模型
    var checkRemark:[String]=[]//為表格數據巡檢類型建立數據模型
    var elementValue=""
    var elementData:[GDataXMLElement]=[]
    var elementNumber1=""
    var elementNumber2=""
    var normalArray:[String]=[]
    var abnormalArray:[String]=[]
    var normalAreaArray:[String]=[]
    var normalNumberArray:[String]=[]
    var abnormalAreaArray:[String]=[]
    var abnormalNumberArray:[String]=[]
    var matchAbnormalArray:[String]=[]
    func webService2(){
        let soapmsg="<?xml version=\"1.0\" encoding=\"utf-8\"?>"+"<soap:Envelope xmlns:xsi=\"http://www.w3.org/2001/XMLSchema-instance\" xmlns:xsd=\"http://www.w3.org/2001/XMLSchema\" xmlns:soap=\"http://schemas.xmlsoap.org/soap/envelope/\">"+"<soap:Body>"+"<getCountGroupByArea xmlns=\"http://tempuri.org/\">"+"<date>2017/11/23</date>"+"</getCountGroupByArea>"+"</soap:Body>"+"</soap:Envelope>"
        let urlString="http://106.14.5.95:8090/AttendService1.asmx?"
        let url=URL(string:urlString)
        var request=URLRequest(url:url!)
        let msgLength=String(soapmsg.count)
        request.addValue("text/xml;charest=utf-8", forHTTPHeaderField: "Content-Type")//請求類型
        request.addValue(msgLength, forHTTPHeaderField: "Content-Length")//請求長度，加入請求頭中
        request.addValue("http://tempuri.org/getCountGroupByArea", forHTTPHeaderField: "SOAPAction")//這三處主要是為了設計請求頭，這個根據webservice的接口要求形式決定。
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
                let root=a.rootElement()
                let elementF=root?.elements(forName: "soap:Body")[0] as! GDataXMLElement
                let elementS=elementF.elements(forName: "getCountGroupByAreaResponse")[0] as! GDataXMLElement
                let isWorry=elementS.elements(forName: "getCountGroupByAreaResult")[0] as! GDataXMLElement
                if isWorry.stringValue()==""{
                    self.errMessage(parm:"查詢失敗", parm1:"編號不存在")
                }else{
                    for xmlData in elementS.elements(forName: "getCountGroupByAreaResult"){
                        self.elementData=(xmlData as AnyObject).elements(forName: "string") as! [GDataXMLElement]
                    }
                    self.elementNumber1=self.elementData[0].stringValue()
                    self.elementNumber2=self.elementData[1].stringValue()
                    let normalArray=self.elementNumber1.components(separatedBy: "&")
                    for i in 0..<normalArray.count{
                        let normalArrayAll=normalArray[i].components(separatedBy: ":")
                        self.normalAreaArray.append(normalArrayAll[0])
                        self.normalNumberArray.append(normalArrayAll[1])
                    }
                    let abnormalArray=self.elementNumber2.components(separatedBy: "&")
                    for i in 0..<abnormalArray.count{
                        let abnoramlArrayAll=abnormalArray[i].components(separatedBy: ":")
                        self.abnormalAreaArray.append(abnoramlArrayAll[0])
                        self.abnormalNumberArray.append(abnoramlArrayAll[1])
                    }
                    for i in 0..<self.normalAreaArray.count{
                        if self.abnormalAreaArray.contains(self.normalAreaArray[i]){
                            self.matchAbnormalArray.append(self.abnormalNumberArray[self.abnormalAreaArray.index(of:self.normalAreaArray[i])!])
                        }else{
                            self.matchAbnormalArray.append("0")
                        }
                    }
                    print(self.normalAreaArray)
                    print(self.normalNumberArray)
                    print(self.abnormalAreaArray)
                    print(self.matchAbnormalArray)
                }
            }
        }
        task.resume()
    }
    //    func webService(){
//        let soapmsg="<?xml version=\"1.0\" encoding=\"utf-8\"?>"+"<soap:Envelope xmlns:xsi=\"http://www.w3.org/2001/XMLSchema-instance\" xmlns:xsd=\"http://www.w3.org/2001/XMLSchema\" xmlns:soap=\"http://schemas.xmlsoap.org/soap/envelope/\">"+"<soap:Body>"+"<getCountGroupByArea xmlns=\"http://tempuri.org/\">"+"<date>2017/11/24</date>"+"</getCountGroupByArea>"+"</soap:Body>"+"</soap:Envelope>"
//        let urlString="http://106.14.5.95:8090/AttendService1.asmx?"
//        let url=URL(string:urlString)
//        var request=URLRequest(url:url!)
//        let msgLength=String(soapmsg.count)
//        request.addValue("text/xml;charest=utf-8", forHTTPHeaderField: "Content-Type")//請求類型
//        request.addValue(msgLength, forHTTPHeaderField: "Content-Length")//請求長度，加入請求頭中
//        request.addValue("http://tempuri.org/getCountGroupByArea", forHTTPHeaderField: "SOAPAction")//這三處主要是為了設計請求頭，這個根據webservice的接口要求形式決定。
//        request.httpMethod="POST"
//        request.httpBody=soapmsg.data(using:.utf8)
//        request.timeoutInterval=15//設置請求超時時間
//        let session=URLSession.shared
//        let task=session.dataTask(with:request){(data,response,error)-> Void in
//            print(String(data:data!,encoding:.utf8) as Any)
//            if let err=error{
//                DispatchQueue.main.async {
//                    self.errMessage(parm: "請求失敗", parm1: err.localizedDescription)
//                }
//            }else{
//                let a=try! GDataXMLDocument(data:data!,options:0)
//                let root=a.rootElement()//建立根節點，節點要一層一層往下找必須被作為節點不能作為節點數組
//                let elementF=root?.elements(forName: "soap:Body")[0] as! GDataXMLElement
//                let elementS=elementF.elements(forName: "getCountGroupByAreaResponse")[0] as! GDataXMLElement
//                //因為編號錯誤的話返回的數據是沒有string節點的，所以判斷是否為空就看看"findInfoByNameNoResponse"的元素值是否為空
//                //let isWorry=elementS.elements(forName: "findAbnorResult")[0] as! GDataXMLElement
//                if elementS.stringValue()==""{
//                    self.errMessage(parm:"查詢失敗", parm1:"編號不存在")
//                }else{
//                    for xmlData in elementF.elements(forName: "getCountGroupByAreaResponse"){
//                        self.elementData=(xmlData as AnyObject).elements(forName: "getCountGroupByAreaResult") as! [GDataXMLElement]
//                    }
//                    print(self.elementData[0].stringValue())
////                    self.elementValue=self.elementData[0].stringValue()
////
////                    self.checkJsonAnalysis(param: self.elementValue)
//                    }
//
//            }
////
//        }
//        task.resume()
//    }


//    var nameValue:[String]=[]
//    var placeValue:[String]=[]
//    var reasonValue:[String]=[]
//    var remarkValue:[String]=[]
//    func checkJsonAnalysis(param:String){
//            let jsonData=param.data(using:.utf8, allowLossyConversion: false)
//            let json=try? JSON(data:jsonData!)
//            for i in 0..<json!.count{
//                nameValue.append(String(describing:json![i]["AOAD_NAME"]))
//                placeValue.append(String(describing:json![i]["AOAD_AREA"]))
//
//        }
//
//
////            checkPlace.append(String(describing:json!["AOAD_AREA"]))
////            checkReason.append(String(describing: json!["AOAD_BSTATE"]))
////            checkRemark.append(String(describing:json!["AOAD_MEMOHR"]))//"01"通過掃描獲取，“02”不通過掃描
//
//        print("00000000000000000000000")
//        print(nameValue)
//        print("11111111111111111111111")
//        print(placeValue)
////        print("22222222222222222222222")
////        print(reasonValue)
////        print("33333333333333333333333")
////        print(remarkValue)
//    }
////
    func errMessage(parm:String,parm1:String){
        let errMessage=UIAlertController(title:parm,message:parm1,preferredStyle:.alert)
        errMessage.addAction(UIAlertAction(title:"OK",style:.default,handler:nil))
        present(errMessage,animated: true,completion: nil)
    }
    
}
