//
//  WeiXinURLViewController.swift
//  OZner
//
//  Created by test on 16/1/1.
//  Copyright © 2016年 sunlinlin. All rights reserved.
//

import UIKit
import MBProgressHUD

class WeiXinURLViewController: UIViewController,UIWebViewDelegate {

    override init(nibName nibNameOrNil: String?, bundle nibBundleOrNil: Bundle?){
        
        super.init(nibName: nibNameOrNil, bundle: nibBundleOrNil)
        
    }
    fileprivate var URLString:String?
    fileprivate var tmpTitle:String?
    convenience  init(Url:String,Title:String) {
        
        var nibNameOrNil = String?("WeiXinURLViewController")
        if Bundle.main.path(forResource: nibNameOrNil, ofType: "xib") == nil
        {
            nibNameOrNil = nil
        }
        self.init(nibName: nibNameOrNil, bundle: nil)
        self.URLString=Url
        self.tmpTitle=Title
    }
    required init(coder aDecoder: NSCoder) {
        
        fatalError("init(coder:) has not been implemented")
        
    }
    @IBAction func BackClick(_ sender: AnyObject) {
        self.dismiss(animated: true, completion: nil)
    }
    @IBOutlet var titleOfURL: UILabel!
    @IBOutlet var webView: UIWebView!
    
    var button:UIButton!
    
    override func viewDidLoad() {
        super.viewDidLoad()

        titleOfURL.text=tmpTitle!
        
        //重新加载按钮
        button=UIButton(frame: CGRect(x: 0, y: HEIGHT_SCREEN/2-40, width: WIDTH_SCREEN, height: 40))
        button.addTarget(self, action: #selector(loadAgain), for: .touchUpInside)
        button.setTitleColor(UIColor.gray, for: UIControlState())
        button.setTitle("加载失败,点击继续加载！", for: UIControlState())
        button.isHidden=true
        webView.addSubview(button)
        
        webView.delegate=self
        webView.scalesPageToFit = true
        webView.loadRequest(URLRequest(url: URL(string: URLString!)!))
        
        // Do any additional setup after loading the view.
    }

    
    //继续加载
    func loadAgain(_ button:UIButton)
    {
        webView.loadRequest(URLRequest(url: URL(string: URLString!)!))
        
    }
    func webViewDidStartLoad(_ webView: UIWebView) {
        button.isHidden=true
        MBProgressHUD.showAdded(to: self.view, animated: true)
        self.perform(#selector(hideMbProgressHUD), with: nil, afterDelay: 3);
    }
    func hideMbProgressHUD()
    {
        MBProgressHUD.hide(for: self.view, animated: true)
    }
    func webViewDidFinishLoad(_ webView: UIWebView) {
        MBProgressHUD.hide(for: self.view, animated: true)
        button.isHidden=true
    }
    func webView(_ webView: UIWebView, didFailLoadWithError error: Error) {
        MBProgressHUD.hide(for: self.view, animated: true)
        button.isHidden=false
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
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
