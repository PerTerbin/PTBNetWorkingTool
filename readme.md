**PTBNetWorkingTool**是基于Alamofire 4.3（https://github.com/Alamofire/Alamofire/）封装的网络工具，主要支持数据请求、上传请求和下载请求。

[TOC]

# 工具说明

开发者直接调用PTBNetWorkingTool进行网络请求，请求的结果可以通过**代理**和**闭包**获取。



## 网络请求类型

网络请求类型通过枚举**PTBHTTPMethod**获得，支持**9**种请求类型

```swift
public enum PTBHTTPMethod: String {
    case options = "OPTIONS"
    case get     = "GET"
    case head    = "HEAD"
    case post    = "POST"
    case put     = "PUT"
    case patch   = "PATCH"
    case delete  = "DELETE"
    case trace   = "TRACE"
    case connect = "CONNECT"
}
```



## 数据解析方式

请求得到的数据可以按**5**种方式序列化。

```swift
public enum PTBResponseType: String {
    case none   = "NONE"        // 直接返回HTTPResponse，未序列化
    case data   = "DATA"        // 序列化为Data
    case json   = "JSON"        // 序列化为JSON
    case string = "STRING"      // 序列化为String
    case any    = "ANY"         // 序列化为Any
}
```



## 工具初始化方法

一、设置基本请求头

```swift
func setHttpHeaders(httpHeaders: [String: String])
```

该方法可以设置基本的请求头，之后的请求如果没有传入新的请求头都会在请求头上加上该内容。

二、设置基本URL

```swift
func setBaseUrl(baseUrl: String)
```

该方法可以设置基本的url，之后的请求如果允许添加基本设置都会拼接上该*baseUrl*。

三、设置基本参数

```swift
func setBaseParameters(parameters: [String: Any])
```

该方法设置基本的参数，之后的请求如果允许添加基本设置都会拼接上该参数。

四、设置数据序列化方式

```swift
func setResponseType(type: PTBResponseType)
```

该方法设置数据的序列化方式，全局影响，如果没有设置默认是JSON类型。



## 请求方法说明

### 数据请求

数据请求可以根据**url**、**request**两种方式请求。



/// 通过地址进行数据请求
///
/// - Parameters:
///   - method:           		请求类型，默认POST
///   - urlString:          		请求地址
///   - parameters:       	 	请求的参数
///   - addBaseSetting:    	是否添加基本设置，默认添加
///   - httpHeaders:        	请求头，可选，为空则用初始设置的请求头
///   - delegate:           		请求完成后的代理，可选
///   - completionHandler:  	请求完成的回调，当代理为空时执行该回调

```swift
public static func request(method: PTBHTTPMethod = .post, to urlString: String, parameters: [String: Any]?, addBaseSetting: Bool = true, httpHeaders: [String: String]? = nil, delegate: PTBDataRequestDelegate?, completionHandler: PTBDataCompletionHandler? = nil)
```

**注：**通过该方法可以根据url发起数据请求，有7个参数。method是请求类型，如果不传则取默认值POST；urlString是本次请求的地址，parameters为本次请求的参数，真正发起的请求地址和参数不一样是urlString和parameters，它会受addBaseSetting影响；addBaseSetting代表本次请求是否要拼接初始化时设置的基本url和基本参数，不传取默认值YES；httpHeaders代表请求头，默认值为nil，如果为nil则使用初始化时设置的请求头，如果httpHeaders不为nil，则本次请求使用httpHeaders做请求头，不使用初始化时设置的值；delegate和completionHandler为请求完成后的回调，分别代表代理回调和闭包回调，delegate的优先级大于completionHandler，只有当delegate为nil时才会使用completionHandler回调。



/// 通过request进行数据请求
///
/// - Parameters:
///   - request:           		请求的Request对象
///   - delegate:           		请求完成后的代理，可选
///   - completionHandler:  	请求完成的回调，当代理为空时执行该回调

```swift
public static func request(with request: URLRequest, delegate: PTBDataRequestDelegate?, completionHandler: PTBDataCompletionHandler? = nil)
```

**注：**通过该方法可以根据request对象发起数据请求，有3个参数。request为请求的对象，request具体内容由使用者自己封装；delegate和completionHandler同上。



### 下载请求

下载请求可以根据**url**、**request**、**未下载完的数据**三种方式进行请求。



/// 通过地址进行下载请求
///
/// - Parameters:
///   - method:             		请求类型
///   - urlString:          		请求地址
///   - parameters:         	请求参数
///   - directory:          		缓存地址
///   - domain:             		缓存domain
///   - addBaseSetting:    	是否添加基本设置，默认添加
///   - httpHeaders:        	请求头，可选，为空则用初始设置的请求头
///   - delegate:           		下载完成的代理
///   - progressHandler:    	进度回调
///   - completionHandler:	下载完成后的回调，当代理为空时执行该回调

```swift
public static func download(method: PTBHTTPMethod = .get, from urlString: String, parameters: [String: Any]? = nil, httpHeaders: [String: String]? = nil, for directory: FileManager.SearchPathDirectory = .documentDirectory, in domain: FileManager.SearchPathDomainMask = .userDomainMask, addBaseSetting: Bool = true, delegate: PTBDownloadRequestDelegate?, progressHandler: PTBProgressHandler? = nil, completionHandler: PTBDownloadCompletionHandler? = nil) 
```

**注：**参数method、urlString、parameters、addBaseSetting、httpHeaders、delegate、completionHandler的意义同数据请求；directory和domain表示本次下载的文件存放的位置，皆有默认值；progressHandler为下载进度的回调闭包，只有当delegate为空时才会调用。



/// 通过Request进行下载请求
///
/// - Parameters:
///   - request:            		请求的Request对象
///   - directory:          		缓存地址
///   - domain:             		缓存domain
///   - delegate:           		下载完成的代理
///   - progressHandler:    	进度回调
///   - completionHandler:  	下载完成后的回调，当代理为空时执行该回调

```swift
public static func download(request: URLRequest, for directory: FileManager.SearchPathDirectory = .documentDirectory, in domain: FileManager.SearchPathDomainMask = .userDomainMask, delegate: PTBDownloadRequestDelegate?, progressHandler: PTBProgressHandler? = nil, completionHandler: PTBDownloadCompletionHandler? = nil)
```

**注：**request为请求的对象，其他参数意义同上。



/// 通过未下载完成的数据进行下载请求
///
/// - Parameters:
///   - resumeData:         	未下载完的数据
///   - directory:          		缓存地址
///   - domain:             		缓存domain
///   - delegate:           		下载完成的代理，可选
///   - progressHandler:    	进度回调
///   - completionHandler:  	下载完成后的回调，当代理为空时执行该回调

```swift
public static func download(resumingWith resumeData: Data, for directory: FileManager.SearchPathDirectory = .documentDirectory, in domain: FileManager.SearchPathDomainMask = .userDomainMask, delegate: PTBDownloadRequestDelegate?, progressHandler: PTBProgressHandler? = nil, completionHandler: PTBDownloadCompletionHandler? = nil)
```

**注：**该方法可以根据未下载完成的数据进行下载。resumeData为上次下载未完成的data数据。其他参数同上。



### 上传请求

上传请求可以上传**Data**、**File**、**InputStream**和**MultipartFormData**四种类型的数据，每种类型的数据都可以通过**url**、**request**两种方式请求。



**Data**

/// 根据data和url上传
///
/// - Parameters:
///   - data:               		上传的数据
///   - urlString:          		上传的地址
///   - method:             		请求类型
///   - addBaseSetting:     	是否添加基本设置，默认添加
///   - httpHeaders:        	请求头，可选，为空则用初始设置的请求头
///   - delegate:           		上传完成的代理，可选
///   - progressHandler:    	进度回调
///   - completionHandler:  	上传完成后的回调，当代理为空时执行该回调

```swift
static func upload(data: Data, to urlString: String, method: PTBHTTPMethod, addBaseSetting: Bool = true, httpHeaders: [String: String]? = nil, delegate: PTBUploadRequestDelegate?, progressHandler: PTBProgressHandler? = nil, completionHandler: PTBUploadCompletionHandler? = nil)
```

**注：**data为要上传的数据，其他参数意义如上。



/// 根据data和request上传
///
/// - Parameters:
///   - data:               		上传的数据
///   - request:            		上传的request
///   - method:             		请求类型
///   - delegate:           		上传完成的代理，可选
///   - progressHandler:    	进度回调
///   - completionHandler:  	上传完成后的回调，当代理为空时执行该回调

```swift
static func upload(data: Data, with request: URLRequest, method: PTBHTTPMethod, delegate: PTBUploadRequestDelegate?, progressHandler: PTBProgressHandler? = nil, completionHandler: PTBUploadCompletionHandler? = nil)
```

**注：**参数同上。



**File**

/// 根据本地文件地址和url上传
///
/// - Parameters:
///   - fileUrl:            		上传的文件地址
///   - urlString:          		上传的地址
///   - method:             		请求类型
///   - addBaseSetting:     	是否添加基本设置，默认添加
///   - httpHeaders:        	请求头，可选，为空则用初始设置的请求头
///   - delegate:           		上传完成的代理，可选
///   - progressHandler:    	进度回调
///   - completionHandler:  	上传完成后的回调，当代理为空时执行该回调

```swift
static func upload(fileUrl: URL, to urlString: String, method: PTBHTTPMethod, addBaseSetting: Bool = true, httpHeaders: [String: String]? = nil, delegate: PTBUploadRequestDelegate?, progressHandler: PTBProgressHandler? = nil, completionHandler: PTBUploadCompletionHandler? = nil)
```

**注：**fileUrl为文件的本地路径；其他参数同上。



/// 根据本地文件地址和request上传
///
/// - Parameters:
///   - fileUrl:            		上传的文件地址
///   - request:            		上传的request
///   - method:             		请求类型
///   - delegate:           		上传完成的代理，可选
///   - progressHandler:    	进度回调
///   - completionHandler:  	上传完成后的回调，当代理为空时执行该回调

```swift
static func upload(fileUrl: URL, with request: URLRequest, method: PTBHTTPMethod, delegate: PTBUploadRequestDelegate?, progressHandler: PTBProgressHandler? = nil, completionHandler: PTBUploadCompletionHandler? = nil)
```

**注：**通过request上传，参数同上。



**InputStream**

/// 根据stream和url上传
///
/// - Parameters:
///   - stream:             		上传的数据流
///   - urlString:          		上传的地址
///   - method:             		请求类型
///   - addBaseSetting:     	是否添加基本设置，默认添加
///   - httpHeaders:        	请求头，可选，为空则用初始设置的请求头
///   - delegate:           		上传完成的代理，可选
///   - progressHandler:    	进度回调
///   - completionHandler:  	上传完成后的回调，当代理为空时执行该回调

```swift
static func upload(stream: InputStream, to urlString: String, method: PTBHTTPMethod, addBaseSetting: Bool = true, httpHeaders: [String: String]? = nil, delegate: PTBUploadRequestDelegate?, progressHandler: PTBProgressHandler? = nil, completionHandler: PTBUploadCompletionHandler? = nil)
```

**注：**stream为上传的数据流，其他参数意义同上。



/// 根据stream和request上传
///
/// - Parameters:
///   - stream:             		上传的数据流
///   - request:            		上传的request
///   - method:             		请求类型
///   - delegate:           		上传完成的代理，可选
///   - progressHandler:    	进度回调
///   - completionHandler:  	上传完成后的回调，当代理为空时执行该回调

```swift
static func upload(stream: InputStream, with request: URLRequest, method: PTBHTTPMethod, delegate: PTBUploadRequestDelegate?, progressHandler: PTBProgressHandler? = nil, completionHandler: PTBUploadCompletionHandler? = nil)
```

**注：**通过request上传，参数同上。



**MultipartFormData**

/// 多表单数据和url上传
///
/// - Parameters:
///   - multipartFormData:          		拼接多表单数据的闭包
///   - encodingMemoryThreshold: 	编码内存的临界值
///   - url:                        				请求的url
///   - method:                     			请求类型
///   - addBaseSetting:            	 	是否添加基本设置，默认添加
///   - httpHeaders:                		请求头，可选，为空则用初始设置的请求头
///   - delegate:                   			上传完成的代理，可选
///   - progressHandler:            		进度回调
///   - completionHandler:         		上传完成后的回调，当代理为空时执行该回调

```swift
static func upload(multipartFormData: @escaping (MultipartFormData) -> Void, usingThreshold encodingMemoryThreshold: UInt64 = SessionManager.multipartFormDataEncodingMemoryThreshold, to urlString: String, method: PTBHTTPMethod = .post, addBaseSetting: Bool = true, httpHeaders: [String: String]? = nil, delegate: PTBUploadRequestDelegate?, progressHandler: PTBProgressHandler? = nil, completionHandler: PTBUploadCompletionHandler? = nil)
```

**注：**该方法可以通过多表单数据上传。multipartFormData为多表单数据拼接的闭包；encodingMemoryThreshold为编码内存的临界值，有默认值；其他参数意义同上。



/// 多表单数据和request上传
///
/// - Parameters:
///   - multipartFormData:          		拼接多表单数据的闭包
///   - encodingMemoryThreshold:    编码内存的临界值
///   - urlRequest:                 			请求的request
///   - delegate:                   			上传完成的代理，可选
///   - progressHandler:            		进度回调
///   - completionHandler:    		上传完成后的回调，当代理为空时执行该回调

```swift
static func upload(multipartFormData: @escaping (MultipartFormData) -> Void, usingThreshold encodingMemoryThreshold: UInt64 = SessionManager.multipartFormDataEncodingMemoryThreshold, with urlRequest: URLRequest, delegate: PTBUploadRequestDelegate?, progressHandler: PTBProgressHandler? = nil, completionHandler: PTBUploadCompletionHandler? = nil)
```

**注：**参数同上。



## 回调说明

### 数据请求

**代理**

```swift
public protocol PTBDataRequestDelegate {
    
    func dataRequestSuccess(urlString: String?, request: URLRequest?, response: HTTPURLResponse?, result: Any?)
    
    func dataRequestFailure(urlString: String?, request: URLRequest?, response: HTTPURLResponse?, error: Any?)
}
```

**注：**分别有请求成功和请求失败的代理。urlString为发起请求的传进去的地址，不一定是请求的完整地址，要获取请求的完整地址最好用*request?.url?.absoluteString*获取；request和response分别为代理的请求和响应；result为请求成功后经过序列化的数据；error为请求失败后的错误信息。

**闭包**

```swift
public typealias PTBDataCompletionHandler = (_ isSuccess: Bool, _ urlString: String?, _ request: URLRequest?, _ response: HTTPURLResponse?, _ result: Any?, _ error: Any?) -> ()
```

**注：**闭包的参数多了isSuccess，标识本次请求是否成功；其他参数同代理。



### 下载请求

**代理**

```swift
public protocol PTBDownloadRequestDelegate {
    
    func downloadRequestSuccess(urlString: String?, request: URLRequest?, response: HTTPURLResponse?, destinationUrl: URL?, result: Any?)
    
    func downloadRequestFailure(urlString: String?, request: URLRequest?, response: HTTPURLResponse?, destinationUrl: URL?, error: Any?)
    
    func downloadProgress(urlString: String?, request: URLRequest?, progress: Progress)
}
```

**注：**代理中请求和成功方法参数多了*destinationUrl*，存储下载后存放的文件目录；其他参数同数据请求；下载进度回调里*progress*存放进度信息。

**闭包**

```swift
public typealias PTBDownloadCompletionHandler = (_ isSuccess: Bool, _ request: URLRequest?, _ response: HTTPURLResponse?, _ destinationUrl: URL?, _ result: Any?, _ error: Any?) -> ()
```

```swift
public typealias PTBProgressHandler = (_ progress: Progress) -> ()
```

注：参数同上。



### 上传请求

**代理**

```swift
public protocol PTBUploadRequestDelegate {
    
    func uploadRequestSuccess(fileUrl: URL?, request: URLRequest?, response: HTTPURLResponse?, result: Any?)
    
    func uploadRequestFailure(fileUrl: URL?, request: URLRequest?, response: HTTPURLResponse?, error: Any?)
    
    func uploadProgress(fileUrl: URL?, request: URLRequest?, progress: Progress)
}
```

**注：**上传代理同样有三个，参数fileUrl标识上传文件的本地目录，其他参数同下载。

**闭包**

```swift
public typealias PTBUploadCompletionHandler = (_ isSuccess: Bool,  _ fileUrl: URL?, _ request: URLRequest?, _ response: HTTPURLResponse?, _ result: Any?, _ error: Any?) -> ()
```

**注：**参数同上。



# 使用方法

## 基础设置

一、通过Cocopods导入Alamofire开源库

```
# Uncomment this line to define a global platform for your project
platform :ios, '8.0'
inhibit_all_warnings!
# Uncomment this line if you're using Swift
use_frameworks!9

target 'YourTargetName' do
	pod 'Alamofire'
end
```

二、将**PTBNetWorkingTool.swift**文件加到项目中。

三、对**PTBNetWorkingTool**的基础参数进行设置（如果需要），通常在Appdelegate文件里。

```swift
PTBNetWorkingTool.setBaseUrl(baseUrl: "http://www.huxiamai.com/Public/api/")
PTBNetWorkingTool.setBaseParameters(parameters: ["CLIENT_SIGN" : "wshoppingApp2016"])
PTBNetWorkingTool.setResponseType(type: .json)
PTBNetWorkingTool.setHttpHeaders(httpHeaders: ["application/x-www-form-urlencoded" : "Content-Type", "application/json" : "Accept"])
```



## 数据请求

**代理回调**

发起请求：

```swift
PTBNetWorkingTool.request(to: "PublicManage/smsVerifyCode", parameters: ["sellerNo" : "13333333333"], delegate: self)
```

接收回调：

```swift
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
```



**闭包回调**

```swift
    func dataRequest() {
        PTBNetWorkingTool.request(to: "PublicManage/smsVerifyCode", parameters: ["sellerNo" : "13333333333"], delegate: nil) { (isSuccess, urlString, request, response, result, error) in
            
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
```



## 下载请求

**代理回调**

发起请求：

```swift
PTBNetWorkingTool.download(from: "http://oerrev9h1.bkt.clouddn.com//Lable/20161224/585e15a843bcd.xml", addBaseSetting: false, delegate: self)
```

接收回调：

```swift
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
```



**闭包回调**

```swift
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
```



## 上传请求

**代理回调**

发起请求：

```swift
PTBNetWorkingTool.upload(multipartFormData: { (multipartFormData) in
            multipartFormData.append(UIImagePNGRepresentation(UIImage(named: "messi")!)!, withName: "avatar_file", fileName: "avatar_file.jpeg", mimeType: "image/jpeg")
        },to: "FileManage/Upload", delegate: self)
```

接收回调：

```swift
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
```



**闭包回调**

```swift
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
```



**注：**具体使用见Demo。

​																		

​																		*2017.05.22  By PerTerbin*