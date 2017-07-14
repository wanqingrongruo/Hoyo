//
//  RNExpressShowViewController.swift
//  HoyoServicer
//
//  Created by roni on 2017/6/23.
//  Copyright © 2017年 com.ozner.net. All rights reserved.
//

import UIKit
import MBProgressHUD

class RNExpressShowViewController: UIViewController{
    
     var URLString:String?
     var tmpTitle:String?
    
    var webView: UIWebView!
    
    var button:UIButton!

    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
        
        self.title = tmpTitle
        
         navigationItem.leftBarButtonItem = UIBarButtonItem.createBarButtonItem("back", target: self, action: #selector(disMissBtn))
        
        //重新加载按钮
        button=UIButton(frame: CGRect(x: 0, y: HEIGHT_SCREEN/2-40, width: WIDTH_SCREEN, height: 40))
        button.addTarget(self, action: #selector(loadAgain), for: .touchUpInside)
        button.setTitleColor(UIColor.gray, for: UIControlState())
        button.setTitle("加载失败,点击继续加载！", for: UIControlState())
        button.isHidden=true
      
        
        webView = UIWebView(frame: CGRect(x: 0, y: 0, width: WIDTH_SCREEN, height: HEIGHT_SCREEN-64))
        view.addSubview(webView)
        webView.delegate=self
        webView.scalesPageToFit = true
        webView.loadRequest(URLRequest(url: URL(string: URLString!)!))
        
        webView.addSubview(button)
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    

    func disMissBtn(){
        _ = self.navigationController?.popViewController(animated: true)
    }
    
    //继续加载
    func loadAgain(_ button:UIButton)
    {
        webView.loadRequest(URLRequest(url: URL(string: URLString!)!))
        
    }
}


extension RNExpressShowViewController: UIWebViewDelegate {
    
   
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
    
}
