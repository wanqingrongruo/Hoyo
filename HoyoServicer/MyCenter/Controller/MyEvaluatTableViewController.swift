//
//  MyEvaluatTableViewController.swift
//  HoyoServicer
//
//  Created by 赵兵 on 16/4/8.
//  Copyright © 2016年 com.ozner.net. All rights reserved.
//

import UIKit
import SDWebImage
import MBProgressHUD
class MyEvaluatTableViewController: UITableViewController {
    //var tableView:UITableView?
    var evaluateTop :Evaluation = Evaluation()
    var scorelists : [ScoreDetail] = [ScoreDetail]()
    override func viewDidLoad() {
        super.viewDidLoad()
        self.title="我的评价"
        tableView.separatorStyle=UITableViewCellSeparatorStyle.none
        tableView!.register(UINib(nibName: "MyEvaluatCell", bundle: Bundle.main), forCellReuseIdentifier: "MyEvaluatCell")
        tableView!.register(UINib(nibName: "MyEvaluatHeadCell", bundle: Bundle.main), forCellReuseIdentifier: "MyEvaluatHeadCell")
        tableView!.separatorStyle=UITableViewCellSeparatorStyle.none
        MBProgressHUD.showAdded(to: self.view, animated: true)
        User.GetMyScoreDetails({[weak self]  (evaluation,scorelists) in
            MBProgressHUD.hide(for: self!.view, animated: true)
            if let strongSelf = self{
                
                strongSelf.evaluateTop = evaluation
                strongSelf.scorelists = scorelists
                
                //ll
                self?.tableView.reloadData()
            }
        }) { (error) in
            
            MBProgressHUD.hide(for: self.view, animated: true)
            
        }
    }
    
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    override init(nibName nibNameOrNil: String?, bundle nibBundleOrNil: Bundle?){
        super.init(nibName: nibNameOrNil, bundle: nibBundleOrNil)
    }
    convenience  init() {
        
        var nibNameOrNil = String?("MyEvaluatTableViewController")
        if Bundle.main.path(forResource: nibNameOrNil, ofType: "xib") == nil
        {
            nibNameOrNil = nil
        }
        self.init(nibName: nibNameOrNil, bundle: nil)
        
    }
    required init(coder aDecoder: NSCoder) {
        
        fatalError("init(coder:) has not been implemented")
        
    }
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        navigationController?.setNavigationBarHidden(false, animated: animated)
        self.tabBarController?.tabBar.isHidden=true
        navigationItem.leftBarButtonItem = UIBarButtonItem.createBarButtonItem("back", target: self, action: #selector(MyEvaluatTableViewController.disMissBtn))
    }
    
    func disMissBtn(){
        _ = navigationController?.popViewController(animated: true)
    }
    
    // MARK: - Table view data source
    
    override func numberOfSections(in tableView: UITableView) -> Int {
        // #warning Incomplete implementation, return the number of sections
        return 1
    }
    
    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        // #warning Incomplete implementation, return the number of rows
        return scorelists.count + 1
    }
    
    override func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return indexPath.row==0 ? 164:135
    }
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: indexPath.row==0 ? "MyEvaluatHeadCell":"MyEvaluatCell", for: indexPath)
        cell.selectionStyle=UITableViewCellSelectionStyle.none
        
        if indexPath.row == 0{
            let cell = (cell as!  MyEvaluatHeadCell )
            
            if User.currentUser?.headimageurl != nil
            {
                var tmpUrl = User.currentUser?.headimageurl
                
               
                if let _ = tmpUrl {
                    if (tmpUrl!.contains("http"))==false {
                        
                        if let _ =  (NetworkManager.defaultManager?.website) {
                             tmpUrl!=(NetworkManager.defaultManager?.website)!+tmpUrl!
                        }
                       
                    }
                }
                if (tmpUrl!.contains("http"))==false {
                    tmpUrl!=(NetworkManager.defaultManager?.website)!+tmpUrl!
                }
                
                cell.headImageView.sd_setImage(with: URL(string: tmpUrl!))
                //e(data: (User.currentUser?.headimageurl)!)
                
            }
            
            
            cell.alreadyDidCount.text = (self.evaluateTop.number) == nil ? "0" :(self.evaluateTop.number)
            cell.alreadyGetLists.text = (self.evaluateTop.score) == nil ? "0" : (self.evaluateTop.score)
            let sumCount = (cell.alreadyGetLists.text! as NSString).doubleValue
            
            let count = (cell.alreadyDidCount.text! as NSString).doubleValue
            var score :Double =  0.0
            if count != 0 {
                
                
                print()
                score = ceil(sumCount/(count))
                print(score)
            }
            self.commentStars(cell.score1, score2: cell.score2, score3: cell.score3, score4: cell.score4, score5: cell.score5,score: count == 0 ?  0 : score)
            
            cell.evaluateTitle.text = "当前累计综合评分为"+"\(score)"+"星"
            
        }else
        {
            if  (indexPath.row - 1) <  scorelists.count {
                //print(indexPath.row)
                
                let cell = cell as! MyEvaluatCell
                // cell.remark.text = self.scorelists[indexPath.row-1 ].remark
                cell.orderid.text = self.scorelists[indexPath.row-1].orderId
                
                if let headImage = self.scorelists[indexPath.row-1].headimageurl {
                      cell.headImage.sd_setImage(with: URL(string: (headImage as String)), placeholderImage: UIImage(named: "DefaultHeadImg"))//
                }else{
                    cell.headImage.image = UIImage(named: "DefaultHeadImg")
                }
                
                cell.orderid.text = self.scorelists[indexPath.row-1].orderId
                
                if let cTime = self.scorelists[indexPath.row-1].createTime {
                    
                    let  timeStamp  =  DateTool.dateFromServiceTimeStamp(cTime)
                    
                    if let timeS = timeStamp, let remark = self.scorelists[indexPath.row-1].remark {
                        
                         cell.remark.text = DateTool.stringFromDate(timeS, dateFormat: "yyyy-MM-dd") + " " + remark
                    }
                }
                
                if let score = self.scorelists[indexPath.row-1].score {
                   self.commentStars(cell.score1, score2: cell.score2, score3: cell.score3, score4: cell.score4, score5: cell.score5, score:  ( score as NSString).doubleValue)
                    
                }
  
            }
        }
        
        return cell
    }
    
    func  commentStars(_ score1 :UIImageView,score2 :UIImageView,score3 :UIImageView,score4 :UIImageView,score5 :UIImageView,score :Double)
    {
        let tmpImage = UIImage(named: "starsedOfHome")
        switch score {
        case 1.0:
            score1.image = tmpImage
            
        case 2.0:
            score1.image = tmpImage
            score2.image = tmpImage
            
        case 3.0:
            
            score1.image = tmpImage
            score2.image = tmpImage
            score3.image = tmpImage
            
        case 4.0:
            score1.image = tmpImage
            score2.image = tmpImage
            score3.image = tmpImage
            score4.image = tmpImage
            
        case 5.0:
            score1.image = tmpImage
            score2.image = tmpImage
            score3.image = tmpImage
            score4.image = tmpImage
            score5.image = tmpImage
            
        default:
            break
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
