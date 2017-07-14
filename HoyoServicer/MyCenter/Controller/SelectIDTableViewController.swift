//
//  SelectIDTableViewController.swift
//  HoyoServicer
//
//  Created by 赵兵 on 16/4/10.
//  Copyright © 2016年 com.ozner.net. All rights reserved.
//

import UIKit
import MBProgressHUD
import IQKeyboardManager

protocol SelectIDTableViewControllerDelegate {
    func selectButtonChange(_ index:Int)
    func ToSelectAdressController()
    func SelectAdressFinished(_ adress:String)
}
class SelectIDTableViewController: UIViewController,SelectIDTableViewControllerDelegate,UITextFieldDelegate ,UITableViewDelegate,UITableViewDataSource{
    
    var tableView: UITableView = UITableView()
    
    
    //1 首席合伙人,2一般合伙人,3联系工程师
    fileprivate var whitchCell = 1{
        didSet{
            if whitchCell==oldValue {
                return
            }
            self.tableView.reloadData()
        }
    }
    var chiefOfSelectIDCell:ChiefOfSelectIDCell?
    var generalOfSelectIDCell:GeneralOfSelectIDCell?
    override func viewDidLoad() {
        super.viewDidLoad()
        self.title="选择身份"
        self.automaticallyAdjustsScrollViewInsets=false
        tableView = UITableView(frame: CGRect(x: 0, y: 0, width: UIScreen.main.bounds.width, height: UIScreen.main.bounds.height - 64))
        tableView.backgroundColor = UIColor.white
        tableView.estimatedRowHeight = 600
        tableView.rowHeight = UITableViewAutomaticDimension
        view.addSubview(tableView)
        tableView.delegate = self
        tableView.dataSource = self
        tableView.separatorStyle=UITableViewCellSeparatorStyle.none
        chiefOfSelectIDCell=Bundle.main.loadNibNamed("ChiefOfSelectIDCell", owner: self, options: nil)?.last as? ChiefOfSelectIDCell
        chiefOfSelectIDCell?.delegate=self
        generalOfSelectIDCell=Bundle.main.loadNibNamed("GeneralOfSelectIDCell", owner: self, options: nil)?.last as? GeneralOfSelectIDCell
        chiefOfSelectIDCell?.webSiteNameTextField.delegate=self
        chiefOfSelectIDCell?.detailAdressTextField.delegate=self
        generalOfSelectIDCell?.delegate=self
        generalOfSelectIDCell?.inputNumberTextField.delegate=self
        generalOfSelectIDCell?.commitbutton.addTarget(self, action: #selector(commitClick), for: .touchUpInside)
        chiefOfSelectIDCell?.commitbutton.addTarget(self, action: #selector(commitClick), for: .touchUpInside)
        chiefOfSelectIDCell?.selectionStyle=UITableViewCellSelectionStyle.none
        generalOfSelectIDCell?.selectionStyle=UITableViewCellSelectionStyle.none
        
        // 移除
        chiefOfSelectIDCell?.regularView.removeFromSuperview()
        generalOfSelectIDCell?.regularView.removeFromSuperview()
    }
    func commitClick(_ button:UIButton) {
        
        let tmpStr:String?
        if button.tag==1 {
            tmpStr="partner"
        }
        else
        {
            tmpStr=generalOfSelectIDCell?.selectIndex==22 ? "n-partner" : "engineer"
        }
        if let str = tmpStr {
            //            weak var weakSelf = self
            switch (str) {
            case "partner":
                //创建团队
                createTeam()
                break
            case "n-partner":
                //加入团队 一般合伙人
                //PartnerCommand
                joinEngineerTeam()
                break
            case "engineer":
                //联席工程师
                joinHoldTeam()
                break
            default:
                break
            }
        }
        
    }
    /**
     SelectIDTableViewControllerDelegate回掉方法
     */
    func selectButtonChange(_ index: Int) {
        whitchCell=index==21 ?1:index
    }
    //选择地址
    func ToSelectAdressController(){
        let jsonPath = Bundle.main.path(forResource: "china_citys", ofType: "json")
        let jsonData = (try! Data(contentsOf: URL(fileURLWithPath: jsonPath!))) as Data
        let tmpObject: AnyObject?
        do{
            tmpObject = try! JSONSerialization.jsonObject(with: jsonData, options: JSONSerialization.ReadingOptions.mutableContainers) as AnyObject?
        }
        let adressDic = tmpObject as! NSMutableArray
        let adressControll = SelectAdressTableViewController(adressData: adressDic, firstSelectRow: -1)
        adressControll.delegate=self
        self.navigationController?.pushViewController(adressControll, animated: true)
        
    }
    func SelectAdressFinished(_ adress:String)
    {
        chiefOfSelectIDCell?.cityLabel.text=adress
        
    }
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        textField.resignFirstResponder()
        return true
    }
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        navigationController?.setNavigationBarHidden(false, animated: animated)
        navigationController?.navigationBar.isTranslucent = false
        self.tabBarController?.tabBar.isHidden=true
        //重写返回按钮
        navigationItem.leftBarButtonItem = UIBarButtonItem.createBarButtonItem("back", target: self , action:#selector(SelectIDTableViewController.backBtnAction) )
        IQKeyboardManager.shared().isEnabled = true
        IQKeyboardManager.shared().isEnableAutoToolbar = true
        IQKeyboardManager.shared().shouldShowTextFieldPlaceholder = true
        IQKeyboardManager.shared().shouldResignOnTouchOutside = true
        IQKeyboardReturnKeyHandler.init().lastTextFieldReturnKeyType = UIReturnKeyType.done
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        IQKeyboardManager.shared().isEnabled = false
        IQKeyboardManager.shared().isEnableAutoToolbar = false
        IQKeyboardManager.shared().shouldShowTextFieldPlaceholder = false
        IQKeyboardManager.shared().shouldResignOnTouchOutside = false
    }
    func backBtnAction(){
        _ = navigationController?.popViewController(animated: true)
    }
    
    // MARK: - Table view data source
    
     func numberOfSections(in tableView: UITableView) -> Int {
        // #warning Incomplete implementation, return the number of sections
        return 1
    }
         func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        // #warning Incomplete implementation, return the number of rows
        return 1
    }
    
//     func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
//        let tmpHeight:CGFloat = whitchCell==1 ? 650:560
//        
//        return max(tmpHeight, (HEIGHT_SCREEN-HEIGHT_NavBar))
//    }
    
     func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        
        if whitchCell != 1 {
            generalOfSelectIDCell?.selectIndex=whitchCell==2 ? 22:23
        }
        
        return whitchCell==1 ? chiefOfSelectIDCell!:generalOfSelectIDCell!
    }
    
    //MARK: - 团队操作
    /**创建团队(首席合伙人)*/
    fileprivate func createTeam() {
        //创建网点：已成功
        weak var weakSelf = self
        if chiefOfSelectIDCell?.webSiteNameTextField.text == "" {
            let alertView=SCLAlertView()
            alertView.addButton("确定", action: {})
            alertView.showError("温馨提示", subTitle: "请输入网点名称")
            return
        }
        if chiefOfSelectIDCell?.cityLabel.text == "省         市" {
            let alertView=SCLAlertView()
            alertView.addButton("确定", action: {})
            alertView.showError("温馨提示", subTitle: "请选择所在省市")
            return
        }
        if chiefOfSelectIDCell?.detailAdressTextField.text == "" {
            let alertView=SCLAlertView()
            alertView.addButton("确定", action: {})
            alertView.showError("温馨提示", subTitle: "请输入详细信息")
            return
        }
        let str = (chiefOfSelectIDCell?.cityLabel.text)! as NSString
        let strNer = str.components(separatedBy: " ")
        let province = strNer.first
        let city = strNer.last
        print("\(province)" + "\(city)")
        let dict = ["scope":"partner","name":(chiefOfSelectIDCell?.webSiteNameTextField.text)!,"province":province!,"city":city!,"country":"  ","address":(chiefOfSelectIDCell?.detailAdressTextField.text)!]
        MBProgressHUD.showAdded(to: view.superview, animated: true)
        User.UpgradeAuthority(dict as NSDictionary, success: {
            MBProgressHUD.hide(for: weakSelf?.view.superview, animated: true)
            let alertView=SCLAlertView()
            alertView.addButton("确定", action: {})
            alertView.showSuccess("温馨提示", subTitle: "申请成功!")
            _ = weakSelf?.navigationController?.popViewController(animated: true)
            }, failure: { (error:NSError) in
                MBProgressHUD.hide(for: weakSelf?.view.superview, animated: true)
                let alertView=SCLAlertView()
                alertView.addButton("确定", action: {})
                alertView.showError("温馨提示", subTitle: "提交申请失败请重试")
        })
        
    }
    /**加入团队(一般合伙人)*/
    fileprivate func joinEngineerTeam(){
        weak var weakSelf = self
        if generalOfSelectIDCell?.inputNumberTextField.text == "" {
            let alertView=SCLAlertView()
            alertView.addButton("确定", action: {})
            alertView.showError("温馨提示", subTitle: "请输入团队号")
            return
        }
        let params: NSDictionary = ["groupnumber":Int((generalOfSelectIDCell?.inputNumberTextField.text)!)!,"commandaction":"join","scope":"n-partner"]
        MBProgressHUD.showAdded(to: view.superview, animated: true)
        User.PartnerCommand(params, success: {
            let alertView=SCLAlertView()
            alertView.addButton("确定", action: {})
            alertView.showSuccess("温馨提示", subTitle: "申请成功!")
            _ = weakSelf?.navigationController?.popViewController(animated: true)
            }, failure: { (error:NSError) in
                MBProgressHUD.hide(for: weakSelf!.view.superview, animated: true)
                if error.code == -10033 {
                    let alertView=SCLAlertView()
                    alertView.addButton("确定", action: {})
                    alertView.showError("温馨提示", subTitle: "当前组不存在请重试")
                } else {
                    let alertView=SCLAlertView()
                    alertView.addButton("确定", action: {})
                    alertView.showError("温馨提示", subTitle: "提交申请失败请重试")
                }
        })
        
    }
    /**加入团队(联席工程师)*/
    fileprivate func joinHoldTeam() {
        
        weak var weakSelf = self
        if generalOfSelectIDCell?.inputNumberTextField.text == "" {
            let alertView=SCLAlertView()
            alertView.addButton("确定", action: {})
            alertView.showError("温馨提示", subTitle: "请输入团队号")
            return
        }
        
        let params: NSDictionary = ["groupnumber":Int((generalOfSelectIDCell?.inputNumberTextField.text)!)!,"commandaction":"join","scope":"l-engineer"]
        MBProgressHUD.showAdded(to: view.superview, animated: true)
        User.PartnerCommand(params, success: {
            MBProgressHUD.hide(for: weakSelf!.view.superview, animated: true)
            let alertView=SCLAlertView()
            alertView.addButton("确定", action: {})
            alertView.showSuccess("温馨提示", subTitle: "申请成功!")
            _ = weakSelf?.navigationController?.popViewController(animated: true)
            }, failure: { (error:NSError) in
                MBProgressHUD.hide(for: weakSelf!.view.superview, animated: true)
                if error.code == -10033 {
                    let alertView=SCLAlertView()
                    alertView.addButton("确定", action: {})
                    alertView.showError("温馨提示", subTitle: "当前组不存在请重试")
                } else {
                    let alertView=SCLAlertView()
                    alertView.addButton("确定", action: {})
                    alertView.showError("温馨提示", subTitle: "提交申请失败请重试")
                    
                }
        })
    }
    
}
