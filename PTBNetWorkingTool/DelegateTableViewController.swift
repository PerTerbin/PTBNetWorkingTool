//
//  DelegateTableViewController.swift
//  PTBNetWorkingTool
//
//  Created by PerTerbin on 2017/5/16.
//  Copyright © 2017年 PerTerbin. All rights reserved.
//

import UIKit
import Alamofire

class DelegateTableViewController: UITableViewController, PTBDataRequestDelegate, PTBDownloadRequestDelegate, PTBUploadRequestDelegate {
    
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view, typically from a nib.
        
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    func dataRequest() {
        PTBNetWorkingTool.request(to: "PublicManage/smsVerifyCode", parameters: ["sellerNo" : "17606501821"], delegate: self)
    }
    
    func downloadRequest() {
        PTBNetWorkingTool.download(from: "http://oerrev9h1.bkt.clouddn.com//Lable/20161224/585e15a843bcd.xml", addBaseSetting: false, delegate: self)
    }
    
    func uploadRequest() {
        PTBNetWorkingTool.upload(multipartFormData: { (multipartFormData) in
            multipartFormData.append(UIImagePNGRepresentation(UIImage(named: "messi")!)!, withName: "avatar_file", fileName: "avatar_file.jpeg", mimeType: "image/jpeg")
        },to: "FileManage/Upload", delegate: self)
    }
    
    // MARK: - UITableViewDelegate
    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        tableView.deselectRow(at: indexPath, animated: true)
        
        switch indexPath.row {
        case 0:
            PTBNetWorkingTool.setResponseType(type: .none)
        case 1:
            PTBNetWorkingTool.setResponseType(type: .data)
        case 2:
            PTBNetWorkingTool.setResponseType(type: .json)
        case 3:
            PTBNetWorkingTool.setResponseType(type: .string)
        case 4:
            PTBNetWorkingTool.setResponseType(type: .any)
        default:
            break;
        }
        
        switch indexPath.section {
        case 0:
            self.dataRequest()
        case 1:
            self.downloadRequest()
        case 2:
            self.uploadRequest()
        default:
            break
        }
    }
    
    // MARK: - PTBDataRequestDelegate
    func dataRequestSuccess(urlString: String?, request: URLRequest?, response: HTTPURLResponse?, result: Any?) {
        if let _ = result {
            print("请求到的数据为：", result!)
        }
    }
    
    func dataRequestFailure(urlString: String?, request: URLRequest?, response: HTTPURLResponse?, error: Any?) {
        if let _ = error {
            print("请求出错，", error!)
        }
    }
    
    // MARK: - PTBDownloadRequestDelegate
    func downloadRequestSuccess(urlString: String?, request: URLRequest?, response: HTTPURLResponse?, destinationUrl: URL?, result: Any?) {
        if let _ = result {
            print("下载的文件位于：\(destinationUrl)，文件为：", result!)
        }
    }
    
    func downloadRequestFailure(urlString: String?, request: URLRequest?, response: HTTPURLResponse?, destinationUrl: URL?, error: Any?) {
        if let _ = error {
            print("下载出错，", error!)
        }
    }
    
    func downloadProgress(urlString: String?, request: URLRequest?, progress: Progress) {
        print("下载进度：" + progress.localizedDescription)
    }
    
    // MARK: - PTBUploadRequestDelegate
    func uploadRequestSuccess(fileUrl: URL?, request: URLRequest?, response: HTTPURLResponse?, result: Any?) {
        if let _ = result {
            print("上传成功，", result!)
        }
    }
    
    func uploadRequestFailure(fileUrl: URL?, request: URLRequest?, response: HTTPURLResponse?, error: Any?) {
        if let _ = error {
            print("上传失败，", error!)
        }
    }
    
    func uploadProgress(fileUrl: URL?, request: URLRequest?, progress: Progress) {
        print("上传进度：" + progress.localizedDescription)
    }
    
}

