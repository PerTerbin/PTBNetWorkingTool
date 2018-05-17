//
//  PTBNetWorkingTool.swift
//  PTBNetWorkingTool
//
//  Created by PerTerbin on 2017/5/16.
//  Copyright © 2017年 PerTerbin. All rights reserved.
//

import Foundation
import Alamofire

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

// 请求后的数据序列化类型
public enum PTBResponseType: String {
    case none   = "NONE"        // 直接返回HTTPResponse，未序列化
    case data   = "DATA"        // 序列化为Data
    case json   = "JSON"        // 序列化为JSON
    case string = "STRING"      // 序列化为String
    case any    = "ANY"         // 序列化为Any
}

public protocol PTBDataRequestDelegate {
    
    func dataRequestSuccess(urlString: String?, request: URLRequest?, response: HTTPURLResponse?, result: Any?)
    
    func dataRequestFailure(urlString: String?, request: URLRequest?, response: HTTPURLResponse?, error: Any?)
}

public protocol PTBDownloadRequestDelegate {
    
    func downloadRequestSuccess(urlString: String?, request: URLRequest?, response: HTTPURLResponse?, destinationUrl: URL?, result: Any?)
    
    func downloadRequestFailure(urlString: String?, request: URLRequest?, response: HTTPURLResponse?, destinationUrl: URL?, error: Any?)
    
    func downloadProgress(urlString: String?, request: URLRequest?, progress: Progress)
}

public protocol PTBUploadRequestDelegate {
    
    func uploadRequestSuccess(fileUrl: URL?, request: URLRequest?, response: HTTPURLResponse?, result: Any?)
    
    func uploadRequestFailure(fileUrl: URL?, request: URLRequest?, response: HTTPURLResponse?, error: Any?)
    
    func uploadProgress(fileUrl: URL?, request: URLRequest?, progress: Progress)
}

public typealias PTBDataCompletionHandler = (_ isSuccess: Bool, _ urlString: String?, _ request: URLRequest?, _ response: HTTPURLResponse?, _ result: Any?, _ error: Any?) -> ()

public typealias PTBDownloadCompletionHandler = (_ isSuccess: Bool, _ request: URLRequest?, _ response: HTTPURLResponse?, _ destinationUrl: URL?, _ result: Any?, _ error: Any?) -> ()

public typealias PTBUploadCompletionHandler = (_ isSuccess: Bool,  _ fileUrl: URL?, _ request: URLRequest?, _ response: HTTPURLResponse?, _ result: Any?, _ error: Any?) -> ()

public typealias PTBProgressHandler = (_ progress: Progress) -> ()

public struct PTBNetWorkingTool {
    
    private static var httpHeaders: [String: String]?
    
    private static var baseParameters: [String: Any]?
    
    private static var baseUrl: String?
    
    private static var responseType: PTBResponseType = .json
    
    // MARK: - public
    // MARK: initSetting
    // 设置初始参数
    public static func setHttpHeaders(httpHeaders: [String: String]) {
        self.httpHeaders = httpHeaders
    }
    
    public static func setBaseParameters(parameters: [String: Any]) {
        self.baseParameters = parameters
    }
    
    // 设置初始地址
    public static func setBaseUrl(baseUrl: String) {
        self.baseUrl = baseUrl
    }
    
    // 设置解析类型，默认是JSON
    public static func setResponseType(type: PTBResponseType) {
        self.responseType = type
    }
    
    // MARK: - dataRequest
    /// 通过地址进行数据请求
    ///
    /// - Parameters:
    ///   - method:             请求类型，默认POST
    ///   - urlString:          请求地址
    ///   - parameters:         请求的参数
    ///   - addBaseSetting:     是否添加基本设置，默认添加
    ///   - httpHeaders:        请求头，可选，为空则用初始设置的请求头
    ///   - delegate:           请求完成后的代理，可选
    ///   - completionHandler:  请求完成的回调，当代理为空时执行该回调
    public static func request(method: PTBHTTPMethod = .post, to urlString: String, parameters: [String: Any]?, addBaseSetting: Bool = true, httpHeaders: [String: String]? = nil, delegate: PTBDataRequestDelegate?, completionHandler: PTBDataCompletionHandler? = nil) {
        
        var url: String = urlString
        var params: [String: Any]? = parameters
        
        if addBaseSetting {
            let realSetting: (String, [String: Any]?) = self.addBaseSetting(url: url, parameters: params)
            url = realSetting.0
            params = realSetting.1
        }
        
        let request: DataRequest = Alamofire.request(url, method: HTTPMethod(rawValue: method.rawValue)!, parameters: params, headers: httpHeaders ?? self.httpHeaders)
        if let _ = completionHandler {
            self.dataResponseSerializer(urlString: urlString, request: request, delegate: delegate, completionHandler: completionHandler!)
        } else {
            self.dataResponseSerializer(urlString: urlString, request: request, delegate: delegate)
        }
    }
    
    /// 通过Request进行数据请求
    ///
    /// - Parameters:
    ///   - request:            请求的Request对象
    ///   - delegate:           请求完成后的代理
    ///   - completionHandler:  请求完成的回调，当代理为空时执行该回调
    public static func request(with request: URLRequest, delegate: PTBDataRequestDelegate?, completionHandler: PTBDataCompletionHandler? = nil) {
        
        let request: DataRequest = Alamofire.request(request)
        if let _ = completionHandler {
            self.dataResponseSerializer(urlString: nil, request: request, delegate: delegate, completionHandler: completionHandler!)
        } else {
            self.dataResponseSerializer(urlString: nil, request: request, delegate: delegate)
        }
    }
    
    // MARK: - downloadRequest
    /// 通过地址进行下载请求
    ///
    /// - Parameters:
    ///   - method:             请求类型
    ///   - urlString:          请求地址
    ///   - parameters:         请求参数
    ///   - directory:          缓存地址
    ///   - domain:             缓存domain
    ///   - addBaseSetting:     是否添加基本设置，默认添加
    ///   - httpHeaders:        请求头，可选，为空则用初始设置的请求头
    ///   - delegate:           下载完成的代理
    ///   - progressHandler:    进度回调
    ///   - completionHandler:  下载完成后的回调，当代理为空时执行该回调
    public static func download(method: PTBHTTPMethod = .get, from urlString: String, parameters: [String: Any]? = nil, httpHeaders: [String: String]? = nil, for directory: FileManager.SearchPathDirectory = .documentDirectory, in domain: FileManager.SearchPathDomainMask = .userDomainMask, addBaseSetting: Bool = true, delegate: PTBDownloadRequestDelegate?, progressHandler: PTBProgressHandler? = nil, completionHandler: PTBDownloadCompletionHandler? = nil) {
        
        var url: String = urlString
        var params: [String: Any]? = parameters
        
        if addBaseSetting {
            let realSetting: (String, [String: Any]?) = self.addBaseSetting(url: url, parameters: params)
            url = realSetting.0
            params = realSetting.1
        }
        
        let request: DownloadRequest = Alamofire.download(url, method: HTTPMethod(rawValue: method.rawValue)!, parameters: params, headers: httpHeaders ?? self.httpHeaders, to: DownloadRequest.suggestedDownloadDestination(for: directory, in: domain))
        request.downloadProgress { (progress) in
            if let _ = delegate {
                delegate?.downloadProgress(urlString: urlString, request: request.request, progress: progress)
            } else {
                progressHandler?(progress)
            }
        }
        if let _ = completionHandler {
            self.downloadResponseSerializer(urlString: urlString, request: request, delegate: delegate, completionHandler: completionHandler!)
        } else {
            self.downloadResponseSerializer(urlString: urlString, request: request, delegate: delegate)
        }
    }
    
    /// 通过Request进行下载请求
    ///
    /// - Parameters:
    ///   - request:            请求的Request对象
    ///   - directory:          缓存地址
    ///   - domain:             缓存domain
    ///   - delegate:           下载完成的代理
    ///   - progressHandler:    进度回调
    ///   - completionHandler:  下载完成后的回调，当代理为空时执行该回调
    public static func download(request: URLRequest, for directory: FileManager.SearchPathDirectory = .documentDirectory, in domain: FileManager.SearchPathDomainMask = .userDomainMask, delegate: PTBDownloadRequestDelegate?, progressHandler: PTBProgressHandler? = nil, completionHandler: PTBDownloadCompletionHandler? = nil) {
        
        let request: DownloadRequest = Alamofire.download(request, to: DownloadRequest.suggestedDownloadDestination(for: directory, in: domain))
        request.downloadProgress { (progress) in
            if let _ = delegate {
                delegate?.downloadProgress(urlString: nil, request: request.request, progress: progress)
            } else {
                progressHandler?(progress)
            }
        }
        if let _ = completionHandler {
            self.downloadResponseSerializer(urlString: nil, request: request, delegate: delegate, completionHandler: completionHandler!)
        } else {
            self.downloadResponseSerializer(urlString: nil, request: request, delegate: delegate)
        }
    }
    
    
    /// 通过未下载完成的数据进行下载请求
    ///
    /// - Parameters:
    ///   - resumeData:         未下载完的数据
    ///   - directory:          缓存地址
    ///   - domain:             缓存domain
    ///   - delegate:           下载完成的代理，可选
    ///   - progressHandler:    进度回调
    ///   - completionHandler:  下载完成后的回调，当代理为空时执行该回调
    public static func download(resumingWith resumeData: Data, for directory: FileManager.SearchPathDirectory = .documentDirectory, in domain: FileManager.SearchPathDomainMask = .userDomainMask, delegate: PTBDownloadRequestDelegate?, progressHandler: PTBProgressHandler? = nil, completionHandler: PTBDownloadCompletionHandler? = nil) {
        
        let request: DownloadRequest = Alamofire.download(resumingWith: resumeData, to: DownloadRequest.suggestedDownloadDestination(for: directory, in: domain))
        request.downloadProgress { (progress) in
            if let _ = delegate {
                delegate?.downloadProgress(urlString: nil, request: request.request, progress: progress)
            } else {
                progressHandler?(progress)
            }
        }
        if let _ = completionHandler {
            self.downloadResponseSerializer(urlString: nil, request: request, delegate: delegate, completionHandler: completionHandler!)
        } else {
            self.downloadResponseSerializer(urlString: nil, request: request, delegate: delegate)
        }
    }
    
    // MARK: - uploadRequest
    
    // MARK: Data
    
    /// 根据data和url上传
    ///
    /// - Parameters:
    ///   - data:               上传的数据
    ///   - urlString:          上传的地址
    ///   - method:             请求类型
    ///   - addBaseSetting:     是否添加基本设置，默认添加
    ///   - httpHeaders:        请求头，可选，为空则用初始设置的请求头
    ///   - delegate:           上传完成的代理，可选
    ///   - progressHandler:    进度回调
    ///   - completionHandler:  上传完成后的回调，当代理为空时执行该回调
    static func upload(data: Data, to urlString: String, method: PTBHTTPMethod, addBaseSetting: Bool = true, httpHeaders: [String: String]? = nil, delegate: PTBUploadRequestDelegate?, progressHandler: PTBProgressHandler? = nil, completionHandler: PTBUploadCompletionHandler? = nil) {
        
        var url: String = urlString
        
        if addBaseSetting {
            let realSetting: (String, [String: Any]?) = self.addBaseSetting(url: url, parameters: nil)
            url = realSetting.0
        }
        
        let request: UploadRequest = Alamofire.upload(data, to: url, method: HTTPMethod(rawValue: method.rawValue)!, headers: httpHeaders ?? self.httpHeaders)
        request.uploadProgress { (progress) in
            if let _ = delegate {
                delegate?.uploadProgress(fileUrl: nil, request: request.request, progress: progress)
            } else {
                progressHandler?(progress)
            }
        }
        if let _ = completionHandler {
            self.uploadResponseSerializer(fileUrl: nil, request: request, delegate: delegate, completionHandler: completionHandler!)
        } else {
            self.uploadResponseSerializer(fileUrl: nil, request: request, delegate: delegate)
        }
    }
    
    
    /// 根据data和request上传
    ///
    /// - Parameters:
    ///   - data:               上传的数据
    ///   - request:            上传的request
    ///   - method:             请求类型
    ///   - delegate:           上传完成的代理，可选
    ///   - progressHandler:    进度回调
    ///   - completionHandler:  上传完成后的回调，当代理为空时执行该回调
    static func upload(data: Data, with request: URLRequest, method: PTBHTTPMethod, delegate: PTBUploadRequestDelegate?, progressHandler: PTBProgressHandler? = nil, completionHandler: PTBUploadCompletionHandler? = nil) {
        
        let request: UploadRequest = Alamofire.upload(data, with: request)
        request.uploadProgress { (progress) in
            if let _ = delegate {
                delegate?.uploadProgress(fileUrl: nil, request: request.request, progress: progress)
            } else {
                progressHandler?(progress)
            }
        }
        if let _ = completionHandler {
            self.uploadResponseSerializer(fileUrl: nil, request: request, delegate: delegate, completionHandler: completionHandler!)
        } else {
            self.uploadResponseSerializer(fileUrl: nil, request: request, delegate: delegate)
        }
    }
    
    // MARK: File
    
    /// 根据本地文件地址和url上传
    ///
    /// - Parameters:
    ///   - fileUrl:            上传的文件地址
    ///   - urlString:          上传的地址
    ///   - method:             请求类型
    ///   - addBaseSetting:     是否添加基本设置，默认添加
    ///   - httpHeaders:        请求头，可选，为空则用初始设置的请求头
    ///   - delegate:           上传完成的代理，可选
    ///   - progressHandler:    进度回调
    ///   - completionHandler:  上传完成后的回调，当代理为空时执行该回调
    static func upload(fileUrl: URL, to urlString: String, method: PTBHTTPMethod, addBaseSetting: Bool = true, httpHeaders: [String: String]? = nil, delegate: PTBUploadRequestDelegate?, progressHandler: PTBProgressHandler? = nil, completionHandler: PTBUploadCompletionHandler? = nil) {
        
        var url: String = urlString
        
        if addBaseSetting {
            let realSetting: (String, [String: Any]?) = self.addBaseSetting(url: url, parameters: nil)
            url = realSetting.0
        }
        
        let request: UploadRequest = Alamofire.upload(fileUrl, to: url, method: HTTPMethod(rawValue: method.rawValue)!, headers: httpHeaders ?? self.httpHeaders)
        request.uploadProgress { (progress) in
            if let _ = delegate {
                delegate?.uploadProgress(fileUrl: fileUrl, request: request.request, progress: progress)
            } else {
                progressHandler?(progress)
            }
        }
        if let _ = completionHandler {
            self.uploadResponseSerializer(fileUrl: fileUrl, request: request, delegate: delegate, completionHandler: completionHandler!)
        } else {
            self.uploadResponseSerializer(fileUrl: fileUrl, request: request, delegate: delegate)
        }
    }
    
    /// 根据本地文件地址和request上传
    ///
    /// - Parameters:
    ///   - fileUrl:            上传的文件地址
    ///   - request:            上传的request
    ///   - method:             请求类型
    ///   - delegate:           上传完成的代理，可选
    ///   - progressHandler:    进度回调
    ///   - completionHandler:  上传完成后的回调，当代理为空时执行该回调
    static func upload(fileUrl: URL, with request: URLRequest, method: PTBHTTPMethod, delegate: PTBUploadRequestDelegate?, progressHandler: PTBProgressHandler? = nil, completionHandler: PTBUploadCompletionHandler? = nil) {
        
        let request: UploadRequest = Alamofire.upload(fileUrl, with: request)
        request.uploadProgress { (progress) in
            if let _ = delegate {
                delegate?.uploadProgress(fileUrl: fileUrl, request: request.request, progress: progress)
            } else {
                progressHandler?(progress)
            }
        }
        if let _ = completionHandler {
            self.uploadResponseSerializer(fileUrl: fileUrl, request: request, delegate: delegate, completionHandler: completionHandler!)
        } else {
            self.uploadResponseSerializer(fileUrl: fileUrl, request: request, delegate: delegate)
        }
    }
    
    // MARK: InputStream
    
    /// 根据stream和url上传
    ///
    /// - Parameters:
    ///   - stream:             上传的数据流
    ///   - urlString:          上传的地址
    ///   - method:             请求类型
    ///   - addBaseSetting:     是否添加基本设置，默认添加
    ///   - httpHeaders:        请求头，可选，为空则用初始设置的请求头
    ///   - delegate:           上传完成的代理，可选
    ///   - progressHandler:    进度回调
    ///   - completionHandler:  上传完成后的回调，当代理为空时执行该回调
    static func upload(stream: InputStream, to urlString: String, method: PTBHTTPMethod, addBaseSetting: Bool = true, httpHeaders: [String: String]? = nil, delegate: PTBUploadRequestDelegate?, progressHandler: PTBProgressHandler? = nil, completionHandler: PTBUploadCompletionHandler? = nil) {
        
        var url: String = urlString
        
        if addBaseSetting {
            let realSetting: (String, [String: Any]?) = self.addBaseSetting(url: url, parameters: nil)
            url = realSetting.0
        }
        
        let request: UploadRequest = Alamofire.upload(stream, to: url, method: HTTPMethod(rawValue: method.rawValue)!, headers: httpHeaders ?? self.httpHeaders)
        request.uploadProgress { (progress) in
            if let _ = delegate {
                delegate?.uploadProgress(fileUrl: nil, request: request.request, progress: progress)
            } else {
                progressHandler?(progress)
            }
        }
        if let _ = completionHandler {
            self.uploadResponseSerializer(fileUrl: nil, request: request, delegate: delegate, completionHandler: completionHandler!)
        } else {
            self.uploadResponseSerializer(fileUrl: nil, request: request, delegate: delegate)
        }
    }
    
    /// 根据stream和request上传
    ///
    /// - Parameters:
    ///   - stream:             上传的数据流
    ///   - request:            上传的request
    ///   - method:             请求类型
    ///   - delegate:           上传完成的代理，可选
    ///   - progressHandler:    进度回调
    ///   - completionHandler:  上传完成后的回调，当代理为空时执行该回调
    static func upload(stream: InputStream, with request: URLRequest, method: PTBHTTPMethod, delegate: PTBUploadRequestDelegate?, progressHandler: PTBProgressHandler? = nil, completionHandler: PTBUploadCompletionHandler? = nil) {
        
        let request: UploadRequest = Alamofire.upload(stream, with: request)
        request.uploadProgress { (progress) in
            if let _ = delegate {
                delegate?.uploadProgress(fileUrl: nil, request: request.request, progress: progress)
            } else {
                progressHandler?(progress)
            }
        }
        if let _ = completionHandler {
            self.uploadResponseSerializer(fileUrl: nil, request: request, delegate: delegate, completionHandler: completionHandler!)
        } else {
            self.uploadResponseSerializer(fileUrl: nil, request: request, delegate: delegate)
        }
    }
    
    // MARK: MultipartFormData
    
    /// 多表单数据和url上传
    ///
    /// - Parameters:
    ///   - multipartFormData:          拼接多表单数据的闭包
    ///   - encodingMemoryThreshold:    编码内存的临界值
    ///   - url:                        请求的url
    ///   - method:                     请求类型
    ///   - addBaseSetting:             是否添加基本设置，默认添加
    ///   - httpHeaders:                请求头，可选，为空则用初始设置的请求头
    ///   - delegate:                   上传完成的代理，可选
    ///   - progressHandler:            进度回调
    ///   - completionHandler:          上传完成后的回调，当代理为空时执行该回调
    static func upload(multipartFormData: @escaping (MultipartFormData) -> Void, usingThreshold encodingMemoryThreshold: UInt64 = SessionManager.multipartFormDataEncodingMemoryThreshold, to urlString: String, method: PTBHTTPMethod = .post, addBaseSetting: Bool = true, httpHeaders: [String: String]? = nil, delegate: PTBUploadRequestDelegate?, progressHandler: PTBProgressHandler? = nil, completionHandler: PTBUploadCompletionHandler? = nil) {
       
        var url: String = urlString
        
        if addBaseSetting {
            let realSetting: (String, [String: Any]?) = self.addBaseSetting(url: url, parameters: nil)
            url = realSetting.0
        }
        
        Alamofire.upload(multipartFormData: multipartFormData, usingThreshold: encodingMemoryThreshold, to: url, method: HTTPMethod(rawValue: method.rawValue)!, headers: httpHeaders ?? self.httpHeaders, encodingCompletion: {
            encodingResult in
            switch encodingResult {
            case .success(let request, _, let fileUrl):
                request.uploadProgress(closure: { (progress) in
                    if let _ = delegate {
                        delegate?.uploadProgress(fileUrl: nil, request: request.request, progress: progress)
                    } else {
                        progressHandler?(progress)
                    }
                })
                if let _ = completionHandler {
                    self.uploadResponseSerializer(fileUrl: fileUrl, request: request, delegate: delegate, completionHandler: completionHandler!)
                } else {
                    self.uploadResponseSerializer(fileUrl: fileUrl, request: request, delegate: delegate)
                }
            case .failure(let error):
                if let _ = completionHandler {
                    self.uploadResponseSerializer(fileUrl: nil, request: nil, error: error, delegate: delegate, completionHandler: completionHandler!)
                } else {
                    self.uploadResponseSerializer(fileUrl: nil, request: nil, error: error, delegate: delegate)
                }
            }
        })
    }
    
    
    /// 多表单数据和request上传
    ///
    /// - Parameters:
    ///   - multipartFormData:          拼接多表单数据的闭包
    ///   - encodingMemoryThreshold:    编码内存的临界值
    ///   - urlRequest:                 请求的request
    ///   - delegate:                   上传完成的代理，可选
    ///   - progressHandler:            进度回调
    ///   - completionHandler:          上传完成后的回调，当代理为空时执行该回调
    static func upload(multipartFormData: @escaping (MultipartFormData) -> Void, usingThreshold encodingMemoryThreshold: UInt64 = SessionManager.multipartFormDataEncodingMemoryThreshold, with urlRequest: URLRequest, delegate: PTBUploadRequestDelegate?, progressHandler: PTBProgressHandler? = nil, completionHandler: PTBUploadCompletionHandler? = nil) {
        
        Alamofire.upload(multipartFormData: multipartFormData, usingThreshold: encodingMemoryThreshold, with: urlRequest, encodingCompletion: {
            encodingResult in
            switch encodingResult {
            case .success(let request, _, let fileUrl):
                request.uploadProgress(closure: { (progress) in
                    if let _ = delegate {
                        delegate?.uploadProgress(fileUrl: nil, request: request.request, progress: progress)
                    } else {
                        progressHandler?(progress)
                    }
                })
                if let _ = completionHandler {
                    self.uploadResponseSerializer(fileUrl: fileUrl, request: request, delegate: delegate, completionHandler: completionHandler!)
                } else {
                    self.uploadResponseSerializer(fileUrl: fileUrl, request: request, delegate: delegate)
                }
            case .failure(let error):
                if let _ = completionHandler {
                    self.uploadResponseSerializer(fileUrl: nil, request: nil, error: error, delegate: delegate, completionHandler: completionHandler!)
                } else {
                    self.uploadResponseSerializer(fileUrl: nil, request: nil, error: error, delegate: delegate)
                }
            }
        })
    }
    
    
    // MARK: - private
    private static func addBaseSetting(url: String, parameters: [String: Any]?) -> (String, [String: Any]?) {
        var realUrl: String = url
        var realParameters: [String: Any]? = parameters
        
        if let _ = baseUrl {
            realUrl = baseUrl! + url
        }
        if let _ = baseParameters, let _ = realParameters {
            for object in baseParameters! {
                realParameters![object.key] = object.value
            }
        }
        
        return (realUrl, realParameters)
    }
    
    private static func dataResponseSerializer(urlString: String?, request: DataRequest, delegate: PTBDataRequestDelegate?, completionHandler: @escaping PTBDataCompletionHandler = { (_, _, _, _, _, _) in }) {
        
        switch responseType {
        case .none:
            request.response(completionHandler: { (dataResponse) in
                if let _ = delegate {
                    if dataResponse.response?.statusCode == 200 {
                        delegate!.dataRequestSuccess(urlString: urlString, request: dataResponse.request, response: dataResponse.response, result: dataResponse.response)
                    } else {
                        delegate!.dataRequestFailure(urlString: urlString, request: dataResponse.request, response: dataResponse.response, error: dataResponse.response)
                    }
                } else {
                    completionHandler(dataResponse.response?.statusCode == 200, urlString, dataResponse.request, dataResponse.response, dataResponse.response, dataResponse.response)
                }
            })
        case .data:
            request.responseData(completionHandler: { (dataResponse) in
                if let _ = delegate {
                    if dataResponse.result.isSuccess {
                        delegate!.dataRequestSuccess(urlString: urlString, request: dataResponse.request, response: dataResponse.response, result: dataResponse.result.value)
                    } else {
                        delegate!.dataRequestFailure(urlString: urlString, request: dataResponse.request, response: dataResponse.response, error: dataResponse.result.error)
                    }
                } else {
                    completionHandler(dataResponse.result.isSuccess, urlString, dataResponse.request, dataResponse.response, dataResponse.result.value, dataResponse.result.error)
                }
            })
        case .json:
            request.responseJSON(completionHandler: { (dataResponse) in
                if let _ = delegate {
                    if dataResponse.result.isSuccess {
                        delegate!.dataRequestSuccess(urlString: urlString, request: dataResponse.request, response: dataResponse.response, result: dataResponse.result.value)
                    } else {
                        delegate!.dataRequestFailure(urlString: urlString, request: dataResponse.request, response: dataResponse.response, error: dataResponse.result.error)
                    }
                } else {
                    completionHandler(dataResponse.result.isSuccess, urlString, dataResponse.request, dataResponse.response, dataResponse.result.value, dataResponse.result.error)
                }
            })
        case .string:
            request.responseString(completionHandler: { (dataResponse) in
                if let _ = delegate {
                    if dataResponse.result.isSuccess {
                        delegate!.dataRequestSuccess(urlString: urlString, request: dataResponse.request, response: dataResponse.response, result: dataResponse.result.value)
                    } else {
                        delegate!.dataRequestFailure(urlString: urlString, request: dataResponse.request, response: dataResponse.response, error: dataResponse.result.error)
                    }
                } else {
                    completionHandler(dataResponse.result.isSuccess, urlString, dataResponse.request, dataResponse.response, dataResponse.result.value, dataResponse.result.error)
                }
            })
        case .any:
            request.responsePropertyList(completionHandler: { (dataResponse) in
                if let _ = delegate {
                    if dataResponse.result.isSuccess {
                        delegate!.dataRequestSuccess(urlString: urlString, request: dataResponse.request, response: dataResponse.response, result: dataResponse.result.value)
                    } else {
                        delegate!.dataRequestFailure(urlString: urlString, request: dataResponse.request, response: dataResponse.response, error: dataResponse.result.error)
                    }
                } else {
                    completionHandler(dataResponse.result.isSuccess, urlString, dataResponse.request, dataResponse.response, dataResponse.result.value, dataResponse.result.error)
                }
            })
        }
    }
    
    private static func downloadResponseSerializer(urlString: String?, request: DownloadRequest, delegate: PTBDownloadRequestDelegate?, completionHandler: @escaping PTBDownloadCompletionHandler = { (_, _, _, _, _, _) in }) {
        
        switch responseType {
        case .none:
            request.response(completionHandler: { (dataResponse) in
                if let _ = delegate {
                    if dataResponse.response?.statusCode == 200 {
                        delegate!.downloadRequestSuccess(urlString: urlString, request: dataResponse.request, response: dataResponse.response, destinationUrl: dataResponse.destinationURL, result: dataResponse.response)
                    } else {
                        delegate!.downloadRequestFailure(urlString: urlString, request: dataResponse.request, response: dataResponse.response, destinationUrl: dataResponse.destinationURL, error: dataResponse.response)
                    }
                } else {
                    completionHandler(dataResponse.response?.statusCode == 200, dataResponse.request, dataResponse.response, dataResponse.destinationURL, dataResponse.response, dataResponse.response)
                }
            })
        case .data:
            request.responseData(completionHandler: { (dataResponse) in
                if let _ = delegate {
                    if dataResponse.result.isSuccess {
                        delegate!.downloadRequestSuccess(urlString: urlString, request: dataResponse.request, response: dataResponse.response, destinationUrl: dataResponse.destinationURL, result: dataResponse.result.value)
                    } else {
                        delegate!.downloadRequestFailure(urlString: urlString, request: dataResponse.request, response: dataResponse.response, destinationUrl: dataResponse.destinationURL, error: dataResponse.result.error)
                    }
                } else {
                    completionHandler(dataResponse.result.isSuccess, dataResponse.request, dataResponse.response, dataResponse.destinationURL, dataResponse.result.value, dataResponse.result.error)
                }
            })
        case .json:
            request.responseJSON(completionHandler: { (dataResponse) in
                if let _ = delegate {
                    if dataResponse.result.isSuccess {
                        delegate!.downloadRequestSuccess(urlString: urlString, request: dataResponse.request, response: dataResponse.response, destinationUrl: dataResponse.destinationURL, result: dataResponse.result.value)
                    } else {
                        delegate!.downloadRequestFailure(urlString: urlString, request: dataResponse.request, response: dataResponse.response, destinationUrl: dataResponse.destinationURL, error: dataResponse.result.error)
                    }
                } else {
                    completionHandler(dataResponse.result.isSuccess, dataResponse.request, dataResponse.response, dataResponse.destinationURL, dataResponse.result.value, dataResponse.result.error)
                }
            })
        case .string:
            request.responseString(completionHandler: { (dataResponse) in
                if let _ = delegate {
                    if dataResponse.result.isSuccess {
                        delegate!.downloadRequestSuccess(urlString: urlString, request: dataResponse.request, response: dataResponse.response, destinationUrl: dataResponse.destinationURL, result: dataResponse.result.value)
                    } else {
                        delegate!.downloadRequestFailure(urlString: urlString, request: dataResponse.request, response: dataResponse.response, destinationUrl: dataResponse.destinationURL, error: dataResponse.result.error)
                    }
                } else {
                    completionHandler(dataResponse.result.isSuccess, dataResponse.request, dataResponse.response, dataResponse.destinationURL, dataResponse.result.value, dataResponse.result.error)
                }
            })
        case .any:
            request.responsePropertyList(completionHandler: { (dataResponse) in
                if let _ = delegate {
                    if dataResponse.result.isSuccess {
                        delegate!.downloadRequestSuccess(urlString: urlString, request: dataResponse.request, response: dataResponse.response, destinationUrl: dataResponse.destinationURL, result: dataResponse.result.value)
                    } else {
                        delegate!.downloadRequestFailure(urlString: urlString, request: dataResponse.request, response: dataResponse.response, destinationUrl: dataResponse.destinationURL, error: dataResponse.result.error)
                    }
                } else {
                    completionHandler(dataResponse.result.isSuccess, dataResponse.request, dataResponse.response, dataResponse.destinationURL, dataResponse.result.value, dataResponse.result.error)
                }
            })
        }
    }

    private static func uploadResponseSerializer(fileUrl: URL?, request: UploadRequest?, error: Error? = nil, delegate: PTBUploadRequestDelegate?, completionHandler: @escaping PTBUploadCompletionHandler = { (_, _, _, _, _, _) in }) {
        
        if request == nil {
            if let _ = delegate {
                delegate!.uploadRequestFailure(fileUrl: fileUrl, request: nil, response: nil, error: error)
            } else {
                completionHandler(false, fileUrl, nil, nil, nil, error)
            }
            return
        }
        
        switch responseType {
        case .none:
            request!.response(completionHandler: { (dataResponse) in
                if let _ = delegate {
                    if dataResponse.response?.statusCode == 200 {
                        delegate!.uploadRequestSuccess(fileUrl: fileUrl, request: dataResponse.request, response: dataResponse.response, result: dataResponse.response)
                    } else {
                        delegate!.uploadRequestFailure(fileUrl: fileUrl, request: dataResponse.request, response: dataResponse.response, error: dataResponse.response)
                    }
                } else {
                    completionHandler(dataResponse.response?.statusCode == 200, fileUrl, dataResponse.request, dataResponse.response, dataResponse.response, dataResponse.response)
                }
            })
        case .data:
            request!.responseData(completionHandler: { (dataResponse) in
                if let _ = delegate {
                    if dataResponse.result.isSuccess {
                        delegate!.uploadRequestSuccess(fileUrl: fileUrl, request: dataResponse.request, response: dataResponse.response, result: dataResponse.result.value)
                    } else {
                        delegate!.uploadRequestFailure(fileUrl: fileUrl, request: dataResponse.request, response: dataResponse.response, error: dataResponse.result.error)
                    }
                } else {
                    completionHandler(dataResponse.result.isSuccess, fileUrl, dataResponse.request, dataResponse.response, dataResponse.result.value, dataResponse.result.error)
                }
            })
        case .json:
            request!.responseJSON(completionHandler: { (dataResponse) in
                if let _ = delegate {
                    if dataResponse.result.isSuccess {
                        delegate!.uploadRequestSuccess(fileUrl: fileUrl, request: dataResponse.request, response: dataResponse.response, result: dataResponse.result.value)
                    } else {
                        delegate!.uploadRequestFailure(fileUrl: fileUrl, request: dataResponse.request, response: dataResponse.response, error: dataResponse.result.error)
                    }
                } else {
                    completionHandler(dataResponse.result.isSuccess, fileUrl, dataResponse.request, dataResponse.response, dataResponse.result.value, dataResponse.result.error)
                }
            })
        case .string:
            request!.responseString(completionHandler: { (dataResponse) in
                if let _ = delegate {
                    if dataResponse.result.isSuccess {
                        delegate!.uploadRequestSuccess(fileUrl: fileUrl, request: dataResponse.request, response: dataResponse.response, result: dataResponse.result.value)
                    } else {
                        delegate!.uploadRequestFailure(fileUrl: fileUrl, request: dataResponse.request, response: dataResponse.response, error: dataResponse.result.error)
                    }
                } else {
                    completionHandler(dataResponse.result.isSuccess, fileUrl, dataResponse.request, dataResponse.response, dataResponse.result.value, dataResponse.result.error)
                }
            })
        case .any:
            request!.responsePropertyList(completionHandler: { (dataResponse) in
                if let _ = delegate {
                    if dataResponse.result.isSuccess {
                        delegate!.uploadRequestSuccess(fileUrl: fileUrl, request: dataResponse.request, response: dataResponse.response, result: dataResponse.result.value)
                    } else {
                        delegate!.uploadRequestFailure(fileUrl: fileUrl, request: dataResponse.request, response: dataResponse.response, error: dataResponse.result.error)
                    }
                } else {
                    completionHandler(dataResponse.result.isSuccess, fileUrl, dataResponse.request, dataResponse.response, dataResponse.result.value, dataResponse.result.error)
                }
            })
        }
    }
    
}
