//
//  FinancialViewController.swift
//  HoyoServicer
//
//  Created by 杨龙洲 on 3/4/16.
//  Copyright © 2016年 com.ozner.net. All rights reserved.
//

import UIKit

class FinancialViewController: UIViewController,UITableViewDataSource,UITableViewDelegate{
    //返回
    @IBAction func back() {
        _ = self.navigationController?.popViewController(animated: true)
    }
    
    var tableView :UITableView?
    lazy var seg : UISegmentedControl = {
        
        let segCon = UISegmentedControl (frame: CGRect(x: 20, y: 10, width: WIDTH_SCREEN-20*2, height: 35))
        segCon.insertSegment(withTitle: "明细", at: 0, animated: true)
        segCon.insertSegment(withTitle: "收入", at: 1, animated: true)
        segCon.insertSegment(withTitle: "支出", at: 2, animated: true)
        return segCon
    }()
    
    var backControl :UIControl!
    
    @IBOutlet weak var backView: UIView!
    @IBOutlet weak var selectTimeView: UIDatePicker!
    //    lazy  var selectTimeView :UIDatePicker = {
    //
    //        let  picker = UIDatePicker()
    //      picker.datePickerMode = UIDatePickerMode.Date
    //
    //
    //
    //        return  picker
    //
    //    }()
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        selectTimeView.isHidden = true
    }
    //选择时间
    @IBOutlet weak var selectTimeBtn: UIButton!
    //选择查看时间
    @IBAction func selectTime() {
        
        
        
        self.selectTimeView.backgroundColor = UIColor.white
        
        
        self.backControl.frame = self.view.bounds
        self.view.bringSubview(toFront: backControl)
        self.view.bringSubview(toFront: backView)
        self.view.bringSubview(toFront: selectTimeView)
        selectTimeView.isHidden = false
        selectTimeView.addTarget(self, action: #selector(FinancialViewController.select as (FinancialViewController) -> () -> ()), for: .valueChanged)
        
        
    }
    
    
    func select(){
        
        let select = selectTimeView.date
        let dataFormatter = DateFormatter()
        self.selectTimeView.datePickerMode = .date
        dataFormatter.dateFormat="yyyy-MM-dd"
        let mon = dataFormatter.string(from: select)
        var arr = NSArray()
        arr = mon.components(separatedBy: "-") as NSArray
        //   print(arr[1])
        selectTimeBtn.titleLabel?.text = (arr[1] as! String)+"月"
        
    }

    
    override func viewDidLoad() {
        
        super.viewDidLoad()
        
        addBackControl()
        initTableView()
        seg.tintColor = COLORRGBA(58, g: 58, b: 58, a: 1)
        seg.addTarget(self, action: #selector(FinancialViewController.segChange(_:)), for: .valueChanged)
        
        seg.selectedSegmentIndex = 0
 
        
        self.segChange(seg)
        
        
        
    }
    func  initTableView(){
        
        tableView = UITableView(frame: CGRect(x: 0, y: 128, width: WIDTH_SCREEN, height: HEIGHT_SCREEN-HEIGHT_NavBar))
        
        tableView!.delegate = self
        tableView!.dataSource = self
        tableView!.estimatedRowHeight = 400
        
        tableView!.rowHeight = UITableViewAutomaticDimension
        tableView!.register(UINib(nibName: "DetailfFinancialViewCell", bundle: Bundle.main), forCellReuseIdentifier: "DetailfFinancialViewCell")
        self.view.addSubview(tableView!)
        
        
    }
    
    func numberOfSections(in tableView: UITableView) -> Int {
        // #warning Incomplete implementation, return the number of sections
        return 1
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        // #warning Incomplete implementation, return the number of rows
        return 5
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "DetailfFinancialViewCell") as! DetailfFinancialViewCell
        
        cell.selectionStyle = .none
        return cell
    }
    
    func tableView(_ tableView: UITableView, viewForHeaderInSection section: Int) -> UIView? {
        
        let view = UIView(frame: CGRect(x: 0, y: 0, width: WIDTH_SCREEN, height: 60))
        view.addSubview(seg)
        tableView.addSubview(view)
        view.backgroundColor = UIColor.white
        return view
        
    }
    func tableView(_ tableView: UITableView, heightForHeaderInSection section: Int) -> CGFloat {
        return 60
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        
        
    }
    
    //添加选择时间的时候的背景效果
    func addBackControl() {
        
        if backControl == nil {
            let frame = CGRect.zero
            backControl = UIControl(frame: frame)
            backControl.backgroundColor = UIColor.black
            backControl.alpha = 0.5
            
            backControl.addTarget(self, action: #selector(FinancialViewController.clickBackControl), for: .touchUpInside);
            
            
            self.view.addSubview(self.backControl)
            self.view.sendSubview(toBack: self.backControl)
            
        }
    }
    
    func clickBackControl(){
        
        backControl.frame = CGRect.zero
        
        selectTimeView.isHidden = true
    }
    
    override func  awakeFromNib() {
        
    }
    func segChange(_ segCon : UISegmentedControl)
    {
        
        self.tableView?.reloadData()
        
        
        
        //        if (segCon.selectedSegmentIndex == 0) {
        //            //[self.view addSubview:self.one.tableView];
        //            self.seg_Detail.tableView.hidden = false
        //
        //            self.seg_Detail.tableView.snp_makeConstraints(closure: { [weak self] make in
        //              if let  strongSelf = self{
        //                make.edges.equalTo((strongSelf.view)!).inset(UIEdgeInsetsMake(180, 0, 0, 0))
        //                }
        //                //make.edges.equalTo(srtrongself.view).inset(UIEdgeInsetsMake(60, 0, 0, 0))
        //            })
        //
        //                    self.seg_Income.tableView.hidden = true
        //            self.seg_Expend.tableView.hidden = true
        //
        //
        //        }
        //        else if (segCon.selectedSegmentIndex == 1){
        //
        //            //        [self.view addSubview:self.two.tableView];
        //                      self.seg_Income.tableView.hidden = false
        //            self.seg_Income.tableView.frame = CGRectMake(0, 180, WIDTH_SCREEN, HEIGHT_SCREEN - 180)
        //            self.seg_Detail.tableView.hidden = true
        //            self.seg_Expend.tableView.hidden = true
        //
        //        }
        //        else if (segCon.selectedSegmentIndex == 2){
        //            //        [self.view addSubview:self.three.tableView];
        //
        //            self.seg_Expend.tableView.hidden = false
        //            self.seg_Expend.tableView.frame = CGRectMake(0, 180, WIDTH_SCREEN  , HEIGHT_SCREEN - 180)
        //            self.seg_Detail.tableView.hidden = true
        //            self.seg_Income.tableView.hidden = true
        //            
        //        }
        
        
    }
    func disappear() {
        
        backControl.frame = CGRect.zero
        self.selectTimeView.removeFromSuperview()
    }
}
