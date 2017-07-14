//
//  UserInfoViewController.swift
//  HoyoServicer
//
//  Created by 赵兵 on 16/4/8.
//  Copyright © 2016年 com.ozner.net. All rights reserved.
//

import UIKit
import ALCameraViewController
import MBProgressHUD


class UserInfoViewController: UIViewController,SelectIDTableViewControllerDelegate{
    
    
    
    //    lazy var setSexController: SetSexViewController = {
    //
    //        let setSexController = SetSexViewController (nibName: "SetSexViewController", bundle: nil)
    //
    //        return setSexController
    //    }()
    //    lazy var editNameCon: EditNameViewController = {
    //
    //        let editNameCon = EditNameViewController (nibName: "EditNameViewController", bundle: nil)
    //
    //        return editNameCon
    //    }()
    //    lazy var adressControll :SelectAdressTableViewController = {
    //        let jsonPath = NSBundle.mainBundle().pathForResource("china_citys", ofType: "json")
    //        let jsonData = NSData(contentsOfFile: jsonPath!)! as NSData
    //        let tmpObject: AnyObject?
    //        do{
    //            tmpObject = try? NSJSONSerialization.JSONObjectWithData(jsonData, options: NSJSONReadingOptions.MutableContainers)
    //        }
    //        let adressDic = tmpObject as! NSMutableArray
    //        let adressControll = SelectAdressTableViewController(adressData: adressDic, firstSelectRow: -1)
    //        adressControll.delegate = self
    //        return adressControll
    //
    //    }()
    
    var isUpdatePhoto = true // 默认 true - 未更新头像
    
    // 说实话我不理解这个界面为什么这么写, view+label+button.....为了用xib, 无所不用其极啊....我想加个放大头像的新功能都要重改整个界面...我还是不加新功能了...这个锅我不背... ronizheng
    
    @IBAction func toDetailController(_ sender: UIButton) {
        switch sender.tag {
        case 1:
            let alert = SCLAlertView()
            alert.addButton("相册") {
                [weak self] in
                
                let libraryViewController = CameraViewController.imagePickerViewController(croppingEnabled: true) { [weak self] image, asset in
                    if let  strongSelf = self{
                        
                        if image != nil {
                            
                            strongSelf.headImg.image = image
                            
                            strongSelf.isUpdatePhoto =  false
                        }
                        
                        //User.currentUser?.headimageurl=UIImageJPEGRepresentation(image!, 0.001)! as NSData
                    }
                    
                    self!.dismiss(animated: true, completion: nil)
                }
                
                self!.present(libraryViewController, animated: true, completion: nil)
            }
            alert.addButton("拍摄") {
                [weak self] in
                let cameraViewController = CameraViewController(croppingEnabled: true, allowsLibraryAccess: true) { [weak self] image, asset in
                    if let  strongSelf = self{
                        
                        if image != nil {
                            strongSelf.headImg.image = image
                        }
                    }
                    self!.dismiss(animated: true, completion: nil)
                }
                self!.present(cameraViewController, animated: true, completion: nil)
            }
            alert.addButton("取消", action: {})
            alert.showInfo("提示", subTitle: "请选择以下方式更新个人头像")
            
            break
        case 2:
//             let editNameController=EditNameViewController(callback: { (nameOfCallBack) in
//                 self.name.text=nameOfCallBack
//             })
//             self.navigationController?.pushViewController(editNameController, animated: true)
            break
        case 3:
            
            //            setSexController.tmpSex = self.sex.text
            let setSexController = SetSexViewController (callback: { (nameOfCallBack) in
                self.sex.text = nameOfCallBack
            })
            
            self.navigationController?.pushViewController(setSexController, animated: true)
            
            break
        case 4:
            
            
            let jsonPath = Bundle.main.path(forResource: "china_citys", ofType: "json")
            let jsonData = (try! Data(contentsOf: URL(fileURLWithPath: jsonPath!))) as Data
            let tmpObject: AnyObject?
            do{
                tmpObject = try! JSONSerialization.jsonObject(with: jsonData, options: JSONSerialization.ReadingOptions.mutableContainers) as AnyObject?
            }
            let adressDic = tmpObject as! NSMutableArray
            let adressControll = SelectAdressTableViewController(adressData: adressDic, firstSelectRow: -1)
            adressControll.delegate = self
            self.navigationController?.pushViewController(adressControll, animated: true)
            
            break
        default: break
            
        }
        
    }
    
    @IBOutlet weak var headImg: UIImageView!
    @IBOutlet weak var name: UILabel!
    @IBOutlet weak var phone: UILabel!
    @IBOutlet weak var sex: UILabel!
    @IBOutlet weak var address: UILabel!
    
    //    var headImageData: NSData?
    //    let queue = NSOperationQueue()
    //    var isHeadImageDataDownloaded = false
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.title="个人信息"
        
        navigationItem.leftBarButtonItem = UIBarButtonItem.createBarButtonItem("back", target: self, action: #selector(disMissBtn))
        
        let province = (User.currentUser?.province)! as  String
        let city = (User.currentUser?.city)! as String
        self.address.text = province + " " + city
        
        
        if User.currentUser?.headimageurl != nil
        {
            var tmpUrl = User.currentUser?.headimageurl
            if (tmpUrl!.contains("http"))==false {
                tmpUrl!=(NetworkManager.defaultManager?.website)!+tmpUrl!
            }
            
            headImg.sd_setImage(with: URL(string: tmpUrl!))
            //e(data: (User.currentUser?.headimageurl)!)
            
            //            let op = NSBlockOperation {
            //
            //                 self.headImageData = NSData(contentsOfURL: NSURL(string: tmpUrl!)!)
            //            }
            //            queue.addOperation(op)
            //            op.completionBlock = {
            //                self.isHeadImageDataDownloaded = true
            //            }
            
        }
        
        //headImg.image=UIImage(data: (User.currentUser?.headimageurl)!
        
        phone.text=User.currentUser?.mobile
        name.text=User.currentUser?.name
        if User.currentUser?.sex == "2" || User.currentUser?.sex == ""
        {   sex.text = "保密"
        }
        if User.currentUser?.sex=="0" {
            sex.text="女"
        }else if User.currentUser?.sex=="1"
        {
            sex.text="男"
        }
        //
        
        
        
        
    }
    
    //------代理-----
    func SelectAdressFinished(_ adress:String)
    {
        
        
        self.address.text = adress
        
    }
    
    func selectButtonChange(_ index:Int)
    {
        
    }
    func ToSelectAdressController() {
        
    }
    
    
    //返回
    
    func disMissBtn() {
        
        var sexParam = "0"
        if self.sex.text == "女"
        {
            sexParam = "0"
        }
        if self.sex.text == "男"
        {
            sexParam = "1"
        }
        if self.sex.text == "保密"
        {
            sexParam = "2"
        }
        
        //  if isHeadImageDataDownloaded {
        
        let  adressDetail = self.address.text! as String
        let province =  adressDetail.components(separatedBy: " ").first! as String
        let city = adressDetail.components(separatedBy: " ").last! as String
        
        if isUpdatePhoto && name.text == User.currentUser?.name && User.currentUser?.sex == sexParam && ((User.currentUser?.province)! as String) == province && ((User.currentUser?.city)! as String) == city{
            _ = self.navigationController?.popViewController(animated: true)
        }
        else{
            
            var  imageData:Data = Data()
            if let image = headImg.image {
                imageData = UIImageJPEGRepresentation(image, 0.001)!
            }
            MBProgressHUD.showAdded(to: self.view, animated: true)
            let parames = ["headImage": imageData,"province": province,"city": city,"sex": sexParam] as [String : Any]
            User.UpdateUserInfo(parames as NSDictionary, success: {
                MBProgressHUD.hide(for: self.view, animated: true)
                _ = self.navigationController?.popViewController(animated: true)
            }) { (error) in
                MBProgressHUD.hide(for: self.view, animated: true)
                let alertView=SCLAlertView()
                alertView.addButton("重新试一下", action: {
                    [weak self] in
                    self?.doBack()
                })
                alertView.addButton("取消", action: {
                    _ = self.navigationController?.popViewController(animated: true)
                })
                alertView.showError("错误提示", subTitle: error.localizedDescription)
            }
            
        }
        
        //        }else{
        //
        //            let alertView=SCLAlertView()
        //            alertView.addButton("好的", action: {})
        //            alertView.showError("错误提示", subTitle: "网速有点差,请稍等一会儿")
        //        }
        
        
        
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        navigationController?.setNavigationBarHidden(false, animated: animated)
        self.tabBarController?.tabBar.isHidden=true
        
        
    }
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    
    
    
    
    override init(nibName nibNameOrNil: String?, bundle nibBundleOrNil: Bundle?){
        super.init(nibName: nibNameOrNil, bundle: nibBundleOrNil)
    }
    convenience  init() {
        
        var nibNameOrNil = String?("UserInfoViewController")
        if Bundle.main.path(forResource: nibNameOrNil, ofType: "xib") == nil
        {
            nibNameOrNil = nil
        }
        self.init(nibName: nibNameOrNil, bundle: nil)
        
    }
    required init(coder aDecoder: NSCoder) {
        
        fatalError("init(coder:) has not been implemented")
        
    }
    
    
    /*
     // MARK: - Navigation
     
     // In a storyboard-based application, you will often want to do a little preparation before navigation
     override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
     // Get the new view controller using segue.destinationViewController.
     // Pass the selected object to the new view controller.
     }
     */
    
}
