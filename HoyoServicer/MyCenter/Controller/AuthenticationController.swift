//
//  AuthenticationController.swift
//  HoyoServicer
//
//  Created by 赵兵 on 16/3/30.
//  Copyright © 2016年 com.ozner.net. All rights reserved.
//

import UIKit
import ALCameraViewController
import MBProgressHUD


class AuthenticationController: UIViewController {
    
    var dissCallBack:(()->Void)?//对注册进来用的
    @IBOutlet weak var leftButton: UIButton!
    @IBOutlet weak var rightButton: UIButton!
    @IBOutlet weak var centerViewContainer: UIView!
    @IBOutlet weak var firstViewContainer: UIView!
    @IBOutlet weak var verifierStateLabel: UILabel!
    @IBOutlet weak var verifyButton: UIButton!
    @IBAction func verifyClick(_ sender: AnyObject) {
        
        
        if ((secondViewContainer?.isHidden)!)==false {//第二个页面的点击事件处理
            
            if secondViewContainer?.nameTextField.text==""||secondViewContainer?.ID2TextField.text=="" {
                let alert=SCLAlertView()
                alert.showTitle("", subTitle: "姓名和身份证号不能为空！", duration: 2, completeText: "", style: SCLAlertViewStyle.notice, colorStyle: nil, colorTextButton: nil, circleIconImage: nil)
                return
            }
            
            let frontData=UIImageJPEGRepresentation((secondViewContainer?.imageButton1.imageView?.image)!, 0.001)! as Data
            let backData=UIImageJPEGRepresentation((secondViewContainer?.imageButton2.imageView?.image)!, 0.001)! as Data
            MBProgressHUD.showAdded(to: self.view, animated: true)
            User.UploadRealnameAuthinfo((secondViewContainer?.nameTextField.text)!, cardid: (secondViewContainer?.ID2TextField.text)!, frontImg: frontData, backImg: backData, success: {
                [weak self] in
                MBProgressHUD.hide(for: self!.view, animated: true)
                self!.verifierStateLabel.text="正在审核中。。。"
                self!.secondViewContainer?.isHidden=true
                self!.verifyButton.setTitle("身份验证", for: UIControlState())
                self!.verifyButton.backgroundColor=UIColor.gray
                self!.verifyButton.isEnabled=false
                if self!.dissCallBack != nil {
                    self!.leftButton.isHidden = true
                }
                }, failure: { [weak self](error) in
                    MBProgressHUD.hide(for: self!.view, animated: true)
                    let alert=SCLAlertView()
                    alert.addButton("确定", action: { })
                    alert.showNotice("", subTitle: "上传失败，请检查网络后重试")
                    self!.verifyButton.backgroundColor=UIColor(red: 252/255, green: 134/255, blue: 62/255, alpha: 1)
                    self!.verifyButton.isEnabled=false
                })
            
        }else//第一个页面的点击事件处理
        {
            secondViewContainer?.isHidden=false
            verifyButton.setTitle("提交", for: UIControlState())
            verifyButton.backgroundColor=UIColor.gray
            verifyButton.isEnabled=false
            leftButton.isHidden=false
            
        }
        
    }
    var secondViewContainer:AuthDetailView?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        secondViewContainer=Bundle.main.loadNibNamed("AuthDetailView", owner: nil, options: nil)?.last as? AuthDetailView
        centerViewContainer.addSubview(secondViewContainer!)
        secondViewContainer?.snp.makeConstraints({ (make) in
            make.edges.equalTo(centerViewContainer).inset(UIEdgeInsetsMake(0, 0, 0, 0))
        })
        secondViewContainer?.isHidden=true
        leftButton.addTarget(self, action: #selector(barButtonClick), for: .touchUpInside)
        rightButton.addTarget(self, action: #selector(barButtonClick), for: .touchUpInside)
        secondViewContainer?.imageButton1.addTarget(self, action: #selector(cameraClick), for: .touchUpInside)
        secondViewContainer?.imageButton2.addTarget(self, action: #selector(cameraClick), for: .touchUpInside)
        
        
        leftButton.isHidden = !(dissCallBack == nil)
        rightButton.isHidden = (dissCallBack == nil)
        initFrontData=UIImageJPEGRepresentation((secondViewContainer?.imageButton1.imageView?.image)!, 0.001)! as Data
        initBackData=UIImageJPEGRepresentation((secondViewContainer?.imageButton2.imageView?.image)!, 0.001)! as Data
        //获取认证信息
        verifyButton.isEnabled=false
        verifyButton.backgroundColor=UIColor.gray
        MBProgressHUD.showAdded(to: self.view, animated: true)
        User.GetCurrentRealNameInfo({
            
            [weak self] checkState in
            MBProgressHUD.hide(for: self!.view, animated: true)
            switch checkState
            {
            case "0" :
                self!.verifierStateLabel.text="请上传身份证进行审核。。。"
                self!.verifyButton.isEnabled=true
                self!.verifyButton.backgroundColor=UIColor(red: 252/255, green: 134/255, blue: 62/255, alpha: 1)
                break
            case "1" :
                self!.verifierStateLabel.text="您的信息正在等待审核。。。"
            case "2" :
                self!.verifierStateLabel.text="您的信息已经审核通过。"
            case "3" :
                self!.verifierStateLabel.text="您的身份信息已被拒绝。"
                self!.verifyButton.isEnabled=true
                self!.verifyButton.backgroundColor=UIColor(red: 252/255, green: 134/255, blue: 62/255, alpha: 1)
            default :
                self!.verifierStateLabel.text="获取数据失败，请检查网络后重试！"
                break
            }
        }) { [weak self](error) in
            print(error)
            self!.verifierStateLabel.text="获取数据失败，请检查网络后重试！"
            MBProgressHUD.hide(for: self!.view, animated: true)
        }
        // Do any additional setup after loading the view.
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        navigationController?.setNavigationBarHidden(false, animated: animated)
        // navigationController?.navigationBar.translucent = false
    }
    
    func barButtonClick(_ button:UIButton)
    {
        if secondViewContainer?.isHidden==false&&button.tag==1 {
            secondViewContainer?.isHidden = !(secondViewContainer?.isHidden)!
            verifyButton.setTitle("身份验证", for: UIControlState())
            if dissCallBack != nil {
                leftButton.isHidden = ((secondViewContainer?.isHidden)!)
            }
        }
        else{
            self.dismiss(animated: dissCallBack==nil, completion: dissCallBack)
        }
        
        
    }
    func cameraClick(_ button:UIButton) {
        let alert = SCLAlertView()
        alert.addButton("相册") {
            [weak self] in
            let libraryViewController = CameraViewController.imagePickerViewController(croppingEnabled: true) { [weak self] image, asset in
                if image != nil
                {
                    button.setImage(image, for: .normal)
                    self!.checkCommitButtonIsEnable()
                }
                
                self!.dismiss(animated: true, completion: nil)
            }
            
            self!.present(libraryViewController, animated: true, completion: nil)
        }
        alert.addButton("拍摄") {
            [weak self] in
            let cameraViewController = CameraViewController(croppingEnabled: true, allowsLibraryAccess: true) { [weak self] image, asset in
                if image != nil
                {
                    button.setImage(image, for: .normal)
                    self!.checkCommitButtonIsEnable()
                }
                
                self!.dismiss(animated: true, completion: nil)
            }
            self!.present(cameraViewController, animated: true, completion: nil)
        }
        alert.addButton("取消", action: {})
        alert.showInfo("", subTitle: "请选择")
        //
    }
    var initFrontData:Data?
    var initBackData:Data?
    
    fileprivate func checkCommitButtonIsEnable()
    {
        let frontData=UIImageJPEGRepresentation((secondViewContainer?.imageButton1.imageView?.image)!, 0.001)! as Data
        let backData=UIImageJPEGRepresentation((secondViewContainer?.imageButton2.imageView?.image)!, 0.001)! as Data
        if !(initFrontData==frontData||initBackData==backData) {
            verifyButton.isEnabled=true
            verifyButton.backgroundColor=UIColor(red: 252/255, green: 134/255, blue: 62/255, alpha: 1)
        }
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
    }
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    override init(nibName nibNameOrNil: String?, bundle nibBundleOrNil: Bundle?){
        super.init(nibName: nibNameOrNil, bundle: nibBundleOrNil)
    }
    //dissCall不等于nil，是从注册跳过来的，否则，从个人中心过来的
    convenience  init(dissCall:(()->Void)?) {
        
        var nibNameOrNil = String?("AuthenticationController")
        if Bundle.main.path(forResource: nibNameOrNil, ofType: "xib") == nil
        {
            nibNameOrNil = nil
        }
        self.init(nibName: nibNameOrNil, bundle: nil)
        dissCallBack=dissCall
        
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
