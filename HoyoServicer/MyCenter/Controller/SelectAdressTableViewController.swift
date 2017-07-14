//
//  SelectAdressTableViewController.swift
//  HoyoServicer
//
//  Created by 赵兵 on 16/4/12.
//  Copyright © 2016年 com.ozner.net. All rights reserved.
//

import UIKit
// FIXME: comparison operators with optionals were removed from the Swift Standard Libary.
// Consider refactoring the code to use the non-optional operators.
fileprivate func < <T : Comparable>(lhs: T?, rhs: T?) -> Bool {
  switch (lhs, rhs) {
  case let (l?, r?):
    return l < r
  case (nil, _?):
    return true
  default:
    return false
  }
}


class SelectAdressTableViewController: UITableViewController {
    var delegate:SelectIDTableViewControllerDelegate?
    fileprivate var adressData:NSMutableArray?
    fileprivate var firstSelectRow:Int?//一级页面选择的行号
    //firstSelectRow 小于0一级选择页面 大于0二级选择页面
    init(adressData:NSMutableArray,firstSelectRow:Int) {
        super.init(nibName: nil, bundle: nil)
        self.firstSelectRow=firstSelectRow
        self.adressData = adressData
        self.title = firstSelectRow<0 ? "选择省市":"选择市区"
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    override func viewDidLoad() {
        super.viewDidLoad()
        
        self.automaticallyAdjustsScrollViewInsets=false
        tableView.tableFooterView = UIView()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        navigationController?.setNavigationBarHidden(false, animated: animated)
        navigationItem.leftBarButtonItem = UIBarButtonItem.createBarButtonItem("back", target: self, action: #selector(disMissBtn))
        // navigationController?.navigationBar.translucent = false
    }
    
    func disMissBtn() {
        _ = navigationController?.popViewController(animated: true)
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
        // #warning Incomplete implementation, return the number of rows
        
        return firstSelectRow!<0 ?(adressData?.count)!:(((adressData?.object(at: firstSelectRow!) as AnyObject).object(forKey: "cities") as AnyObject).count)!
    }

    
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = UITableViewCell()
        cell.textLabel?.text = firstSelectRow!<0 ?((adressData?.object(at: indexPath.row) as AnyObject).object(forKey: "name") as? String):(((adressData?.object(at: firstSelectRow!) as AnyObject).object(forKey: "cities") as AnyObject).object(at: indexPath.row) as! String)
        // Configure the cell...

        return cell
    }
    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        if  firstSelectRow<0 {
            //一级页面的选择事件
            let secondControll = SelectAdressTableViewController(adressData: adressData!, firstSelectRow: indexPath.row)
            secondControll.delegate=delegate
            self.navigationController?.pushViewController(secondControll, animated: true)
        }
        else{
            //二级页面的选择事件
            var tmpStr=(adressData?.object(at: firstSelectRow!) as AnyObject).object(forKey: "name") as! String
            
            tmpStr+="    "+((((adressData?.object(at: firstSelectRow!) as AnyObject).object(forKey: "cities") as AnyObject).object(at: indexPath.row)) as! String)
            
            
            delegate?.SelectAdressFinished(tmpStr)
            _ = self.navigationController?.popToViewController((self.navigationController?.viewControllers[(self.navigationController?.viewControllers.count)!-3])!, animated: true)
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
