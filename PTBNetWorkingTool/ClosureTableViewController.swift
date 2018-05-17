import UIKit
import Alamofire

class ClosureTableViewController: UITableViewController {
    
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view, typically from a nib.
        
        PTBNetWorkingTool.setBaseUrl(baseUrl: "http://www.huxiamai.com/Public/api/")
        PTBNetWorkingTool.setBaseParameters(parameters: ["CLIENT_SIGN" : "wshoppingApp2016"])
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    func dataRequest() {
        PTBNetWorkingTool.request(to: "PublicManage/smsVerifyCode", parameters: ["sellerNo" : "17606501821"], delegate: nil) { (isSuccess, urlString, request, response, result, error) in
            
            if isSuccess {
                if let _ = result {
                    print("请求到的数据为：", result!)
                }
            } else {
                if let _ = error {
                    print("请求出错，", error!)
                }
            }
        }
    }
    
    func downloadRequest() {
        PTBNetWorkingTool.download(from: "http://oerrev9h1.bkt.clouddn.com//Lable/20161224/585e15a843bcd.xml", addBaseSetting: false, delegate: nil, progressHandler: { progress in
            
            print("下载进度：" + progress.localizedDescription)
        }) { (isSuccess, request, response, destinationUrl, result, error) in
            
            if isSuccess {
                if let _ = result {
                    print("下载的文件位于：\(destinationUrl)，文件为：", result!)
                }
            } else {
                if let _ = error {
                    print("下载出错，", error!)
                }
            }
        }
    }
    
    
    func uploadRequest() {
        PTBNetWorkingTool.upload(multipartFormData: { (multipartFormData) in
            multipartFormData.append(UIImagePNGRepresentation(UIImage(named: "messi")!)!, withName: "avatar_file", fileName: "avatar_file.jpeg", mimeType: "image/jpeg")
        }, to: "FileManage/Upload", delegate: nil,  progressHandler: { progress in
            
            print("上传进度：" + progress.localizedDescription)
        }, completionHandler: { (isSuccess, fileUrl, request, response, result, error) in
            
            if isSuccess {
                if let _ = result {
                    print("上传成功：", result!)
                }
            } else {
                if let _ = error {
                    print("上传失败，", error!)
                }
            }
        })
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
    
}

