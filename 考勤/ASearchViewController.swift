//
//  ASearchViewController.swift
//  考勤
//
//  Created by Foxconn 38 on 2017/11/21.
//  Copyright © 2017年 Foxconn 38. All rights reserved.
//

import UIKit
import Charts
class ASearchViewController: UIViewController,ChartViewDelegate,XMLParserDelegate,UITableViewDelegate ,UITableViewDataSource,UITextFieldDelegate{
    
    @IBOutlet weak var aTableView: UITableView!
    @IBOutlet weak var putView: UIView!
    @IBOutlet weak var mySegmentedControl: UISegmentedControl!
    @IBOutlet weak var myTextField: UITextField!
    @IBOutlet weak var myButton: UIButton!
    
    var myBarChartView:BarChartView!
    var myLineChartView:LineChartView!
    override func viewDidLoad() {
    super.viewDidLoad()
        aTableView.dataSource=self
        aTableView.delegate=self
        createBar()
        createLine()
        myTextField.delegate=self
//        myBarChartView.delegate=self
//        myLineChartView.delegate=self
        self.view.addSubview(myBarChartView)
    myButton.addTarget(self,action:#selector(touchBegin),for:UIControlEvents.touchUpInside)
   
        
    }
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return 100.0
    }
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return nameValue.count
        
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let Cell=aTableView.dequeueReusableCell(withIdentifier: "cell", for: indexPath) as! aTableViewCell
        Cell.nameTextField.text=nameValue[indexPath.row]
        Cell.placeTextField.text=placeValue[indexPath.row]
        Cell.reasonTextField.text=reasonValue[indexPath.row]
        Cell.remarkTextField.text=remarkValue[indexPath.row]
        return Cell
    }
    
    @IBAction func viewClick(_ sender:AnyObject){//点击屏幕外面键盘收起，必须把视图的class改为UIController
        myTextField.resignFirstResponder()
    }
    
    
    func createBar(){
        
        myBarChartView=BarChartView(frame: CGRect(x:0,y:0,width:putView.frame.width,height:putView.frame.height))
        myBarChartView.center=putView.center
        myBarChartView.delegate=self
        //self.view.addSubview(myBarChartView)
    }
    func createLine(){
        myLineChartView=LineChartView(frame: CGRect(x:0,y:0,width:putView.frame.width,height:putView.frame.height))
        myLineChartView.center=putView.center
        myLineChartView.delegate=self
        //self.view.addSubview(myLineChartView)
    }
    var checkPlace=""
    var checkAbnormal=""
    func chartValueSelected(_ chartView: ChartViewBase, entry: ChartDataEntry, highlight: Highlight) {
        checkPlace=normalAreaArray[Int(entry.x)]
        checkAbnormal=String(Int(matchAbnormalArray[Int(entry.x)]))
        DispatchQueue.main.async {
            self.performSegue(withIdentifier: "towork", sender: self)
        }
    }
    
    
    func setChart1(dataPoints:[String],values:[Double]){
        myBarChartView.noDataText="無數據"
        myBarChartView.chartDescription?.text=""
        //myBarChartView.rightAxis.drawGridLinesEnabled = false
        myBarChartView.rightAxis.enabled=false
        myBarChartView.xAxis.labelPosition = .bottom
        myBarChartView.xAxis.valueFormatter=IndexAxisValueFormatter(values:normalAreaArray)
        myBarChartView.xAxis.granularity=1.0
        myBarChartView.xAxis.labelTextColor = .red
        //myBarChartView.leftAxis.labelFont = .systemFont(ofSize: 20)
        myBarChartView.leftAxis.axisMaximum=40
        myBarChartView.leftAxis.axisMinimum=0
        myBarChartView.animate(xAxisDuration:0, yAxisDuration: 1, easingOption: .easeInQuad)
        var dataEntries:[BarChartDataEntry]=[]
        for i in 0..<dataPoints.count{
            let dataEntry=BarChartDataEntry(x:Double(i),y:values[i])
            dataEntries.append(dataEntry)
        }
        let chartDataSet=BarChartDataSet(values:dataEntries,label:"考勤人數")
        chartDataSet.valueFont=UIFont.systemFont(ofSize: 13)
        let chartData=BarChartData(dataSet:chartDataSet)
        myBarChartView.xAxis.axisMinimum=chartData.xMin-1
        myBarChartView.xAxis.axisMaximum=chartData.xMax+1
        myBarChartView.data=chartData

        chartDataSet.colors=[UIColor(red:136.0/255.0,green:99.0/255.0,blue:168.0/255.0,alpha:1.0),UIColor(red:246.0/255.0,green:198.0/255.0,blue:103.0/255.0,alpha:1.0),UIColor(red:113.0/255.0,green:199.0/255.0,blue:212.0/255.0,alpha:1.0),UIColor(red:108.0/255.0,green:187.0/255.0,blue:92.0/255.0,alpha:1.0)]
        
    }
    
    func setChart2(dataPoints:[String],values:[Double]){
        myLineChartView.noDataText="無數據"
        myLineChartView.chartDescription?.text=""
        myLineChartView.xAxis.valueFormatter=IndexAxisValueFormatter(values:normalAreaArray)
        myLineChartView.xAxis.granularity=1.0
        myLineChartView.leftAxis.axisMaximum=40
        myLineChartView.leftAxis.axisMinimum=0
        myLineChartView.animate(xAxisDuration:0, yAxisDuration: 1, easingOption: .easeInQuad)

        var dataEntries: [ChartDataEntry] = []
        for i in 0..<dataPoints.count {
            let dataEntry = ChartDataEntry(x: Double(i), y: values[i])
            dataEntries.append(dataEntry)
        }
        let lineChartDataSet=LineChartDataSet(values:dataEntries,label:"異常考勤人數")
        lineChartDataSet.colors=[.cyan]
        lineChartDataSet.valueFont=UIFont.systemFont(ofSize: 13)
        myLineChartView.legend.form = .circle
        let lineChartData = LineChartData(dataSet: lineChartDataSet)
        myLineChartView.data = lineChartData
        myLineChartView.xAxis.labelPosition = .bottom
        myLineChartView.rightAxis.enabled = false
    }
    
    var strDate=""
    func alert(){
        let myDataPicker = UIDatePicker(frame: CGRect(x:0, y:40, width:320, height:200))
        myDataPicker.datePickerMode=UIDatePickerMode.date
        myDataPicker.locale = NSLocale(localeIdentifier: "zh_CN") as Locale
        let alertController = UIAlertController(title: "请选择日期\n\n\n\n\n\n\n\n\n\n\n", message: nil, preferredStyle:  .actionSheet)
        let cancleAction = UIAlertAction(title: "取消", style: .cancel, handler: nil)
        let doneAction = UIAlertAction(title: "确定", style: .default) { (action: UIAlertAction) in
        let  dateFormatter = DateFormatter()
        dateFormatter.dateFormat = "yyyy-MM-dd"
        self.strDate = dateFormatter.string(from: myDataPicker.date)
        self.checkDate = self.strDate
        self.myTextField.text=self.checkDate
        self.webService1()
        self.webService2()
        
        }
        alertController.view.addSubview(myDataPicker)
        alertController.addAction(doneAction)
        alertController.addAction(cancleAction)
        self.present(alertController, animated: true, completion: nil)
        
        
    }

    @objc func touchBegin(){
        alert()
        
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
    }
    
    var isTouch=false
    @IBAction func selectChart(_ sender: Any) {
        if isTouch{
            self.view.addSubview(myBarChartView)
               myLineChartView.removeFromSuperview()
            isTouch=false
        }else{
            self.view.addSubview(myLineChartView)
            myBarChartView.removeFromSuperview()
            isTouch=true
        }
    }
    
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        self.checkDate=myTextField.text!
        DispatchQueue.global().async {
                        self.webService1()
                        self.webService2()
                    }
        textField.resignFirstResponder()
        return true
    }
    
    var elementData:[GDataXMLElement]=[]
    var elementValue=""
    var checkDate=""
    func webService1(){
        let soapmsg="<?xml version=\"1.0\" encoding=\"utf-8\"?>"+"<soap:Envelope xmlns:xsi=\"http://www.w3.org/2001/XMLSchema-instance\" xmlns:xsd=\"http://www.w3.org/2001/XMLSchema\" xmlns:soap=\"http://schemas.xmlsoap.org/soap/envelope/\">"+"<soap:Body>"+"<findAbnor xmlns=\"http://tempuri.org/\">"+"<date>\(checkDate)</date>"+"</findAbnor>"+"</soap:Body>"+"</soap:Envelope>"
        let urlString="http://106.14.5.95:8090/AttendService1.asmx?"
        let url=URL(string:urlString)
        var request=URLRequest(url:url!)
        let msgLength=String(soapmsg.count)
        request.addValue("text/xml;charest=utf-8", forHTTPHeaderField: "Content-Type")//請求類型
        request.addValue(msgLength, forHTTPHeaderField: "Content-Length")//請求長度，加入請求頭中
        request.addValue("http://tempuri.org/findAbnor", forHTTPHeaderField: "SOAPAction")//這三處主要是為了設計請求頭，這個根據webservice的接口要求形式決定。
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
                let elementS=elementF.elements(forName: "findAbnorResponse")[0] as! GDataXMLElement
                //因為編號錯誤的話返回的數據是沒有string節點的，所以判斷是否為空就看看"findInfoByNameNoResponse"的元素值是否為空
                //let isWorry=elementS.elements(forName: "findAbnorResult")[0] as! GDataXMLElement
                if elementS.stringValue()==""{
                    self.errMessage(parm:"查詢失敗", parm1:"編號不存在")
                }else{
                    for xmlData in elementF.elements(forName: "findAbnorResponse"){
                        self.elementData=(xmlData as AnyObject).elements(forName: "findAbnorResult") as! [GDataXMLElement]
                    }
                    print(self.elementData[0].stringValue())
                    self.elementValue=self.elementData[0].stringValue()
                    self.checkJsonAnalysis(param: self.elementValue)
//                    DispatchQueue.global().async {
//
//                    }
                    DispatchQueue.main.async {
                       self.aTableView.reloadData()
                   }
                    //self.elementValue.removeAll()
                }
            
            }
        }
        task.resume()
    }
    
    var elementNumber1=""
    var elementNumber2=""
    var normalArray:[String]=[]
    var abnormalArray:[String]=[]
    var normalAreaArray:[String]=[]
    var normalNumberArray:[Double]=[]
    var abnormalAreaArray:[String]=[]
    var abnormalNumberArray:[String]=[]
    var matchAbnormalArray:[Double]=[]
    
    func webService2(){
        let soapmsg="<?xml version=\"1.0\" encoding=\"utf-8\"?>"+"<soap:Envelope xmlns:xsi=\"http://www.w3.org/2001/XMLSchema-instance\" xmlns:xsd=\"http://www.w3.org/2001/XMLSchema\" xmlns:soap=\"http://schemas.xmlsoap.org/soap/envelope/\">"+"<soap:Body>"+"<getCountGroupByArea xmlns=\"http://tempuri.org/\">"+"<date>\(checkDate)</date>"+"</getCountGroupByArea>"+"</soap:Body>"+"</soap:Envelope>"
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
            if data == nil{
                self.errMessage(parm: "查询失败", parm1: "网络出错或系统出错")
            }else{
            //print(String(data:data!,encoding:.utf8) as Any)
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
                    self.normalAreaArray.removeAll()
                    self.normalNumberArray.removeAll()
                    let normalArray=self.elementNumber1.components(separatedBy: "&")
                    for i in 0..<normalArray.count{
                        let normalArrayAll=normalArray[i].components(separatedBy: ":")
                        
                        self.normalAreaArray.append(normalArrayAll[0])
                        self.normalNumberArray.append(Double(normalArrayAll[1])!)
                    }
                    self.matchAbnormalArray.removeAll()
                    let abnormalArray=self.elementNumber2.components(separatedBy: "&")
                    for i in 0..<abnormalArray.count{
                        let abnoramlArrayAll=abnormalArray[i].components(separatedBy: ":")
                        self.abnormalAreaArray.append(abnoramlArrayAll[0])
                        self.abnormalNumberArray.append(abnoramlArrayAll[1])
                    }
                    for i in 0..<self.normalAreaArray.count{
                        if self.abnormalAreaArray.contains(self.normalAreaArray[i]){
                            self.matchAbnormalArray.append(Double(self.abnormalNumberArray[self.abnormalAreaArray.index(of:self.normalAreaArray[i])!])!)
                        }else{
                            self.matchAbnormalArray.append(Double("0")!)
                        }
                    }
                    
                    DispatchQueue.main.async {
                        self.setChart1(dataPoints:self.normalAreaArray,values:self.normalNumberArray)
                        self.setChart2(dataPoints:self.normalAreaArray,values:self.matchAbnormalArray)
                    }
//                    print(self.normalAreaArray)
//                    print(self.normalNumberArray)
//                    print(self.abnormalAreaArray)
//                    print(self.matchAbnormalArray)
                }
            }
        }
     }
        task.resume()
    }
    
    
    var nameValue:[String]=[]
    var placeValue:[String]=[]
    var reasonValue:[String]=[]
    var remarkValue:[String]=[]
    func checkJsonAnalysis(param:String){
        self.nameValue.removeAll()
        self.placeValue.removeAll()
        self.reasonValue.removeAll()
        self.remarkValue.removeAll()
        let jsonData=param.data(using:.utf8, allowLossyConversion: false)
        let json=try? JSON(data:jsonData!)
        for i in 0..<json!.count{
            nameValue.append(String(describing:json![i]["AOAD_NAME"]))
            placeValue.append(String(describing:json![i]["AOAD_AREA"]))
            reasonValue.append(String(describing:json![i]["AOAD_BSTATE"]))
            remarkValue.append(String(describing:json![i]["AOAD_MEMOHR"]))
            
        }
    }
    
    override func prepare(for segue:UIStoryboardSegue,sender:Any?){
        if segue.identifier=="towork"{
            let destinationController=segue.destination as! workViewController
                destinationController.date=self.checkDate
                destinationController.place=self.checkPlace
                destinationController.abnormal=self.checkAbnormal
                destinationController.webService1()
                //destinationController.placeLabel.text=self.checkPlace
        }
    }
    
    func errMessage(parm:String,parm1:String){
        let errMessage=UIAlertController(title:parm,message:parm1,preferredStyle:.alert)
        errMessage.addAction(UIAlertAction(title:"OK",style:.default,handler:nil))
        present(errMessage,animated: true,completion: nil)
    }
    
}
