//
//  RNSelectProvinceTableViewController.swift
//  HoyoServicer
//
//  Created by 婉卿容若 on 2016/11/7.
//  Copyright © 2016年 com.ozner.net. All rights reserved.
//

import UIKit

typealias ProvinceCallBack = ([String: String]) -> ()

class RNSelectProvinceTableViewController: UITableViewController {
    
  
    
    internal var backClosure: ProvinceCallBack
    internal var serviceAreas: [RNServiceAreasModel]  // 服务区域
    
//    private lazy var dataSource = {
//        return [String]()
//    }()
    
    fileprivate lazy var paramDic = {
        return [String: String]()
    }()

    init(style: UITableViewStyle, closure: @escaping ProvinceCallBack, serviceAreas: [RNServiceAreasModel]) {
        
        
        
        self.backClosure = closure
        
        self.serviceAreas = serviceAreas
        
        super.init(style: style)
    }
    
    
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    override func viewDidLoad() {
        super.viewDidLoad()

        navigationItem.title = "选择服务区域"
        
        navigationItem.leftBarButtonItem = UIBarButtonItem.createBarButtonItem("back", target: self, action: #selector(disMissBtn))
       
        self.automaticallyAdjustsScrollViewInsets=false
        tableView.tableFooterView = UIView(frame: CGRect.zero)
        
        tableView.register(UITableViewCell.self, forCellReuseIdentifier: "reuseIdentifier")
        

    }
    
    func disMissBtn() {
       _ =  navigationController?.popViewController(animated: true)
    }


    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }

    // MARK: - Table view data source

    override func numberOfSections(in tableView: UITableView) -> Int {
        // #warning Incomplete implementation, return the number of sections
        return 1
    }

    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        
        tableViewDisplayWithMsg("您当前没有服务区域", ifNecessagryForRowCount: serviceAreas.count)
        return serviceAreas.count
    }

    
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "reuseIdentifier", for: indexPath)

        let model = serviceAreas[indexPath.row]
        
        var str = ""
        if let p = model.province{
            
            str = str + p
        }
        
        if let c = model.city{
            str = str + c
        }
        
        if let cou = model.country{
            str = str + cou
        }
        
        cell.textLabel?.text = str

        return cell
    }
    
    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        
        let model = serviceAreas[indexPath.row]
        
        
        if let p = model.province{
            
            paramDic["SearchProvince"] = p
        }
        
        if let c = model.city{
            paramDic["SearchCity"] = c
        }
        
        if let cou = model.country{
           paramDic["SearchArea"] = cou
        }
        
        self.backClosure(paramDic)
        
        _ = self.navigationController?.popViewController(animated: true)

    }
    
    func tableViewDisplayWithMsg(_ message: String, ifNecessagryForRowCount: Int ) -> Void {
        if  ifNecessagryForRowCount == 0{
            //没有数据时显示
            
            let messageLabel = UILabel()
            messageLabel.text = message
            messageLabel.font = UIFont.systemFont(ofSize: 15)
            messageLabel.textColor = UIColor.black
            messageLabel.textAlignment = NSTextAlignment.center
            messageLabel.sizeToFit()
            
            tableView.backgroundView = messageLabel
            
            
        }else{
            tableView.backgroundView = nil
            
       }
    }

    

    /*
    // Override to support conditional editing of the table view.
    override func tableView(tableView: UITableView, canEditRowAtIndexPath indexPath: NSIndexPath) -> Bool {
        // Return false if you do not want the specified item to be editable.
        return true
    }
    */

    /*
    // Override to support editing the table view.
    override func tableView(tableView: UITableView, commitEditingStyle editingStyle: UITableViewCellEditingStyle, forRowAtIndexPath indexPath: NSIndexPath) {
        if editingStyle == .Delete {
            // Delete the row from the data source
            tableView.deleteRowsAtIndexPaths([indexPath], withRowAnimation: .Fade)
        } else if editingStyle == .Insert {
            // Create a new instance of the appropriate class, insert it into the array, and add a new row to the table view
        }    
    }
    */

    /*
    // Override to support rearranging the table view.
    override func tableView(tableView: UITableView, moveRowAtIndexPath fromIndexPath: NSIndexPath, toIndexPath: NSIndexPath) {

    }
    */

    /*
    // Override to support conditional rearranging of the table view.
    override func tableView(tableView: UITableView, canMoveRowAtIndexPath indexPath: NSIndexPath) -> Bool {
        // Return false if you do not want the item to be re-orderable.
        return true
    }
    */

    /*
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
        // Get the new view controller using segue.destinationViewController.
        // Pass the selected object to the new view controller.
    }
    */

}
