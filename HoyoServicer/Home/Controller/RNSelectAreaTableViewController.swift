//
//  RNSelectAreaTableViewController.swift
//  HoyoServicer
//
//  Created by 婉卿容若 on 2017/3/15.
//  Copyright © 2017年 com.ozner.net. All rights reserved.
//

import UIKit

protocol RNSelectAreaTableViewControllerDelegate {
    func reloadInstallInfoUI(_ loaction: String) // 更新 UI
}

class RNSelectAreaTableViewController: UITableViewController {
    
    var index:Int // 索引,表达跳转多少次, index = 2 后 popToViewController
    var dataSource:[String] // 数据源
    var selectedStr: String // 选择的地区 (通过这个判定选择了地区数组的哪个城市)
    var location: String // 回调的数据
    
    var delegate: RNSelectAreaTableViewControllerDelegate?

    override func viewDidLoad() {
        super.viewDidLoad()

        self.title = "地区"
        navigationItem.leftBarButtonItem = UIBarButtonItem.createBarButtonItem("back", target: self, action: #selector(disMissBtn))
        view.backgroundColor = UIColor.white
        
        tableView.rowHeight = 44
        tableView.register(UITableViewCell.self, forCellReuseIdentifier: "reuseIdentifier")
        // tableView.tableFooterView = UIView()
        
    }
    
    init(index: Int, data: [String], location: String, selected: String) {
        self.index = index
        self.dataSource = data
        self.selectedStr = selected
        self.location = location
        
        super.init(nibName: nil, bundle: nil)
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }


    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }

    // MARK: - Table view data source

    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        // #warning Incomplete implementation, return the number of rows
        return dataSource.count
    }

    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "reuseIdentifier", for: indexPath)

        // Configure the cell...
        if indexPath.row < dataSource.count {
            cell.textLabel?.text = dataSource[indexPath.row]
        }
       

        return cell
    }
    
    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        
        guard indexPath.row < dataSource.count else {
            return
        }
        
        let city = dataSource[indexPath.row]
        var loca = location + city
        
        switch index {
        case 0:
            
            loca += " "
            // 第二层
            let jsonPath = Bundle.main.path(forResource: "china_cities_three_level", ofType: "json")
            let jsonData = (try! Data(contentsOf: URL(fileURLWithPath: jsonPath!))) as Data
            let tmpObject: AnyObject?
            do{
                tmpObject = try! JSONSerialization.jsonObject(with: jsonData, options: JSONSerialization.ReadingOptions.mutableContainers) as AnyObject?
            }
            let adressArray = tmpObject as! NSMutableArray
            
            var provinceArr = [String]()
            for item in adressArray {
                let str = (item as AnyObject)["name"] as! String
                
                if str == city {
                    
                    let arr = (item as AnyObject)["cities"] as! NSMutableArray
                    
                    for item02 in arr {
                        
                        let str02 = (item02 as AnyObject)["name"] as! String
                        provinceArr.append(str02)
                    }
                    
                }
            }
            let selectAreaVC = RNSelectAreaTableViewController(index: 1, data: provinceArr, location: loca, selected: city)
            selectAreaVC.delegate = delegate
            navigationController?.pushViewController(selectAreaVC, animated: true)

            break
        case 1:
            
            loca += " "
            // TO DO: 更好的封装
            // 第三层
            let jsonPath = Bundle.main.path(forResource: "china_cities_three_level", ofType: "json")
            let jsonData = (try! Data(contentsOf: URL(fileURLWithPath: jsonPath!))) as Data
            let tmpObject: AnyObject?
            do{
                tmpObject = try! JSONSerialization.jsonObject(with: jsonData, options: JSONSerialization.ReadingOptions.mutableContainers) as AnyObject?
            }
            let adressArray = tmpObject as! NSMutableArray
            
            var provinceArr = [String]()
            for item in adressArray {
                
                let arr = (item as AnyObject)["cities"] as! NSMutableArray
                
                for item02 in arr {
                    
                    let str02 = (item02 as AnyObject)["name"] as! String
                    
                    if str02 == city {
                        
                        let arr02 = (item02 as AnyObject)["area"] as! [String]
                        
                        for item03 in arr02 {
                            provinceArr.append(item03)
                        }
                    }
                }
                
                
            }
            let selectAreaVC = RNSelectAreaTableViewController(index: 2, data: provinceArr, location: loca, selected: city)
            selectAreaVC.delegate = delegate
            navigationController?.pushViewController(selectAreaVC, animated: true)

            break
        case 2:
            
            guard let step = self.navigationController?.viewControllers.count else {
                
                let alertView = SCLAlertView()
                alertView.addButton("确定", action: {})
                alertView.showError("提示", subTitle: "导航栈错误")
                return
            }
            
            guard step >= 4 else {
                
                let alertView = SCLAlertView()
                alertView.addButton("确定", action: {})
                alertView.showError("提示", subTitle: "导航栈错误")
                return
            }
            
            guard let vc = navigationController?.viewControllers[step-4] else {
                let alertView = SCLAlertView()
                alertView.addButton("确定", action: {})
                alertView.showError("提示", subTitle: "导航栈错误")
                return
            }
            
             self.delegate?.reloadInstallInfoUI(loca)
            
            _ = self.navigationController?.popToViewController(vc, animated: true)
        default:
            break
        }
    }

   
}

// MARK: - event response

extension RNSelectAreaTableViewController {
    
    // 返回按钮事件
    func disMissBtn(){
        
        _ =  self.navigationController?.popViewController(animated: true)
        
    }
}

