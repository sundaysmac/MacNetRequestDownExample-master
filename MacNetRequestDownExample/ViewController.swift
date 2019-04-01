//
//  ViewController.swift
//  MacNetRequestDownExample
//
//  Created by cb_2018 on 2019/4/1.
//  Copyright © 2019 cfwf. All rights reserved.
//

import Cocoa

class ViewController: NSViewController {

    override var representedObject: Any? {
        didSet {
        // Update the view, if already loaded.
        }
    }

    //6断点续传
    var downTask: URLSessionDownloadTask?
    var resumeData: Data?
    @IBAction func startDown(_ sender: NSButton) {
        let defaultConfigObject = URLSessionConfiguration.default
        let session = URLSession(configuration: defaultConfigObject, delegate: self, delegateQueue: OperationQueue.main)
        let url = URL(string: "http://")
        let task = session.downloadTask(with: url!)
        self.downTask = task
        task.resume()
    }
    
    @IBAction func stopDown(_ sender: NSButton) {
        self.downTask?.cancel(byProducingResumeData: { (data) in
            self.resumeData = data
        })
    }
    @IBAction func resumeDown(_ sender: NSButton) {
        let defaultConfigObject = URLSessionConfiguration.default
        let session = URLSession(configuration: defaultConfigObject, delegate: self, delegateQueue: OperationQueue.main)
        self.downTask = session.downloadTask(withResumeData: self.resumeData!)
        self.downTask?.resume()
    }
    override func viewDidLoad() {
        super.viewDidLoad()
        
        //Cookie编程
        //添加Cookie
        let cookie = HTTPCookie(properties: [HTTPCookiePropertyKey.domain : ".reddit.com",HTTPCookiePropertyKey.path : "/"])
        HTTPCookieStorage.shared.setCookie(cookie!)
        //删除Cookie
        if let cookies = HTTPCookieStorage.shared.cookies {
            for cookie in cookies {
                HTTPCookieStorage.shared.deleteCookie(cookie)
            }
        }
        
        
    }
    ////1 使用系统默认的方式创建URLSession 基本流程如下
    let kServerBaseUrl = "http://127.0.0.1/iosxHelper/SAPI"
    func urlSessionNoDelegateTest() {
        //创建一个默认的Session配置
        let defaultConfigObject = URLSessionConfiguration.default
        //创建URLSession，对于系统的默认的代理进行收到数据处理的情况，设置delegate参数
        //为nil，同时设置代理执行的队列为主线程队列，在此也可以创建自己的私有队列
        let session = URLSession(configuration: defaultConfigObject, delegate: nil, delegateQueue: OperationQueue.main)
        let url = URL(string: kServerBaseUrl + "/VersionCheck")!
        //构造URLRequest对象， （接口的url路径，缓存规则协议约定的策略,超时时间）
        var request = URLRequest(url: url, cachePolicy: .useProtocolCachePolicy, timeoutInterval: 30)
        request.httpMethod = "POST"
        request.setValue("application/x-www-form-urlencode", forHTTPHeaderField: "content-type")
        let post = "versionNo=1.0&platform=Mac&channel=appstore*appName=DBAppx"
        let postData = post.data(using: String.Encoding.utf8)
        request.httpBody = postData
        let dataTask = session.dataTask(with: request) { (data, response, error) -> Void in
            let responseStr = String(data: data!, encoding: String.Encoding.utf8)
            print("data = \(String(describing: responseStr))")
        }
        dataTask.resume()
    }
    //2使用自定义代理方法创建URLSession
    func urlSessionDelegateTest() {
        //使用默认配置
        let defaultConfigObject = URLSessionConfiguration.default
        //创建session并设置代理
        let session = URLSession(configuration: defaultConfigObject, delegate: self, delegateQueue: OperationQueue.main)
        let url = URL(string: kServerBaseUrl + "/Version")!
        var request = URLRequest(url: url, cachePolicy: .useProtocolCachePolicy, timeoutInterval: 30)
        request.httpMethod = "POST"
        request.setValue("application/x-www-form-urlencode", forHTTPHeaderField: "content-type")
        let post = "versionNo=1.0&platform=Mac&channel=appstore*appName=DBAppx"
        let postData = post.data(using: String.Encoding.utf8)
        let uploadTask = session.uploadTask(with: request, from: postData) { (data, response, error) -> Void in
            let responseStr = String(data: data!, encoding: String.Encoding.utf8)
            print("uploadTask data = \(String(describing: responseStr))")
        }
        uploadTask.resume()
    }
    //3文件下载
    func urlSessionDownLoadFileTest() {
        let defaultConfigObject = URLSessionConfiguration.default
        //创建session制定代理和任务队列
        let session = URLSession(configuration: defaultConfigObject, delegate: self, delegateQueue: OperationQueue.main)
        //制定下载文件的URL
        let url = URL(string: "http://...png")
        //创建Download任务
        let task = session.downloadTask(with: url!)
        task.resume()
    }
    //4文件上传 流式文件上传客户端代码
    func urlSeseionUploadFileTst() {
        let uploadURL = URL(string: "http://127.0.0.1/fileUpload.php")!
        var request = URLRequest(url: uploadURL)
        request.httpMethod = "POST"
        //要上传的路径，假设document目录下有个AppBkIcon.png文件
        let uploadFileURL = URL(fileURLWithPath: NSHomeDirectory()).appendingPathComponent("Documents").appendingPathComponent("ppBkIcon.png")
        request.setValue("applicaiton/octet-stream", forHTTPHeaderField: "Content-type")
        let defaultConfigObject = URLSessionConfiguration.default
        let session = URLSession(configuration: defaultConfigObject, delegate: self, delegateQueue: OperationQueue.main)
        let uploadTask = session.uploadTask(with: request, fromFile: uploadFileURL) { (data, reponse, error) -> Void in
            if error != nil {
                print("error \(String(describing: error))")
            }
        }
        uploadTask.resume()
    }
    //5表单文件上传
    func urlSessionUploadFormFileTest() {
        //服务器地址
        let urlString = "http:127.0.0.1/formUpload.php"
        let url = URL(string: urlString)
        //上传文件的路径
        let fileURL = URL(fileURLWithPath: NSHomeDirectory()).appendingPathComponent("Documents").appendingPathComponent("AppBkIcon.png")
        let fileName = fileURL.lastPathComponent
        let fileData = try? Data(contentsOf: fileURL)
        let boundary = "-bounday"
        //上传的数据缓存
        var dataSend = Data()
        //bounary参数填充开始
        dataSend.append("--\(boundary)\r\n".data(using: String.Encoding.utf8)!)
        //form表单的参数
        dataSend.append("Content-Disposition: form-data; name=\"file\";filename=\"\(fileName)\"\r\n".data(using: String.Encoding.utf8)!)
        dataSend.append("Content-Type: applicaiton/octet-stream\r\n\r\n".data(using: String.Encoding.utf8)!)
        dataSend.append(fileData!)
        dataSend.append("\r\n".data(using: String.Encoding.utf8)!)
        //boundary参数填充结束
        dataSend.append("--\(boundary)--\r\n\r\n".data(using: String.Encoding.utf8)!)
        //请求参数
        var request = URLRequest(url: url!)
        request.httpMethod = "POST"
        request.httpBody = dataSend
        request.setValue("multipart/form-data; boundary=\(boundary)", forHTTPHeaderField: "Content-Type")
        
        let sessionConfiguration = URLSessionConfiguration.default
        let session = URLSession(configuration: sessionConfiguration, delegate: self, delegateQueue: nil)
        
        //发起上传任务
        let sessionUploadTask = session.uploadTask(with: request, from: dataSend)
        sessionUploadTask.resume()
    }
    
    //服务器端php上传处理代码，脚本文件formUpload.php
    //    <?php
    //    if ($_FILES["file"]["error"] > 0)
    //    {
    //    echo "Return Code: ".$_FILES["file"]["error"]."<br />";
    //    }
    //    else
    //    {
    //        echo "Upload: ".$_FILE["file"]["name"]."<br />"
    //        echo "Type: ".$_FILE["file"]["type"]."<br />"
    //        echo "Size: ".$_FILE["file"]["size"] / 1024."kb<br />"
    //        echo "Temp file: ".$_FILE["file"]["tmp_name"]."<br />"
    //        if (file_exists("upload/". $_FILES["file"]["name"]))
    //        {
    //            echo $_FILES["file"]["name"]. "already exists.";
    //        }
    //        else
    //        {
    //            move_upload_file($_FILES["file"]["name"], "upload/". $_FILES["file"]["name"]);
    //            echo "Stroed in: ". "upload/". _FILES["file"]["name"];
    //        }
    //    }
    //    ?>
    //新建一个formUpload.html文件
    //    <html>
    //        <body>
    //            <form aciton="fileUpload.php" method="psot" enctype"multipart/form-data">
    //            <label for="file">FileName:</label>
    //            <input type="file" name="file" id="file" />
    //            <br />
    //            <input type="submit" name="submit" value="Submit" />
    //        </body>
    //    </html>
    //将上述formUpload.php和fromUpload.html都复制到XAMPP的htdocs跟目录，完成服务端发布然后客户端测试
    
    
    //缓存策略
    /****
     *1.userProtocolCachePolicy：协议规定的缓存策略 模式使用这种策略
     *2.reloadIgnoringLocalCacheData: 不适用缓存，永远适用网路数据
     *3.returnCacheDataElseLoad: 适用缓存数据，不管数据是否过期，如果缓存没有数据才请求网络数据
     *4.returnCacheDataDontLoad: 仅仅适用缓存数据
     **/
    
    
    //7 使用实例
    let kServerBaseUrl1 = "http://www.iosxhelper.com/"
    func httpGetTest() {
        let httpClient = HTTPClient()
        let urlString = "\(kServerBaseUrl1)\("/VersionCheck")"
        let url = URL(string: urlString)
        httpClient.get(url!, parameters: nil, success: { (responseObject: Any?) -> Void in
            print("get data \(responseObject!)")
        }) { (error: Error?) -> Void in
            
        }
    }
    func postStringTest() {
        let httpClient = HTTPClient()
        let urlString = "\(kServerBaseUrl1)\(/VersionCheck)"
        let url = URL(string: urlString)
        let paras = "versionNo=1.0&platform=Mac&channel=appstore&appName=DBAppX"
        httpClient.post(url!, parameters: paras, success: { (responseObject: Any?) -> Void in
            print("post String responseObject = \(responseObject)")
        }) { (error: Error?) -> Void in
            
        }
    }
    func postDictionaryTest() {
        let httpClient = HTTPClient()
        let urlString = "\(kServerBaseUrl1)\("/VersionCheck")"
        let url = URL(string: urlString)
        let paras = ["verisonNo":"1.0","platform":"Mac","channel":"appstore","appName":"DBAppX"]
        httpClient.post(url!, parameters: paras, success: { (responseObject: Any?) -> Void in
            print("post Dictonary responseObject =\(responseObject!)")
        }) { (error: Error?) -> Void in
            
        }
    }
}





//urlSessionDelegateTest
extension ViewController:URLSessionDelegate {
    
}
//实现下载协议 urlSessionDownLoadFileTest
extension ViewController: URLSessionDownloadDelegate {
    //下载完成
    func urlSession(_ session: URLSession, downloadTask: URLSessionDownloadTask, didFinishDownloadingTo location: URL) {
        let fileName = downloadTask.originalRequest?.url?.lastPathComponent
        let fileManager = FileManager.default
        //要保存的路径
        let downloadURL = URL(fileURLWithPath: NSHomeDirectory()).appendingPathComponent("Download").appendingPathComponent(fileName!)
        //从下载的临时路径移动到期望的路径
        do {
            try fileManager.moveItem(at: location, to: downloadURL)
        } catch let error {
            print("error \(error)")
        }
    }
    //接受到数据以后的回调
    func urlSession(_ session: URLSession, downloadTask: URLSessionDownloadTask, didWriteData bytesWritten: Int64, totalBytesWritten: Int64, totalBytesExpectedToWrite: Int64) {
        print("receive byte \(bytesWritten) of totalBytes \(totalBytesExpectedToWrite)")
    }
}

//MARK:- 文件上传 流式文件上传客户端代码
//func urlSeseionUploadFileTst
extension ViewController:URLSessionTaskDelegate {
    func urlSession(_ session: URLSession, task: URLSessionTask, didSendBodyData bytesSent: Int64, totalBytesSent: Int64, totalBytesExpectedToSend: Int64) {
        print("Send btyes \(bytesSent) of totalBytes \(totalBytesExpectedToSend)")
    }
    //服务器创建fileUpload.php脚本，复制到XAMPP的htdocs跟目录下
    //    <?php
    //     //上传后保存的文件路径和名称
    //    $file = 'upload/recording.png'
    //    //获取上传的内容
    //    $request_body = @file_get_contents('php://input')
    //    //解析文件mime类型
    //    $mime_type = $file_info->buffer($request_body);
    //    //根据mime类型处理
    //    switch($mime_type)
    //    {
    //    case "image/png; charset=binary":
    //        //写文件到制定路径
    //    file_put_contents($file,$request_body);
    //    break;
    //    default;
    //    }
    
    //MARK: -    缓存控制编程
    func urlSession(_ session: URLSession, dataTask: URLSessionDataTask, willCacheResponse proposedResponse: CachedURLResponse, completionHandler: @escaping (CachedURLResponse) -> Swift.Void) {
        var returnCacheResponse = proposedResponse
        var newUserInfo = [String: Any]()
        newUserInfo = ["Chched Date": Date()]
        #if ALLOW_CACHING
        returnCacheResponse = CachedURLResponse(response: proposedResponse.response, data: proposedResponse.data, userInfo: newUserInfo, storagePolicy: proposedResponse.storagePolicy)
        completionHandler(returnCacheResponse)
        #else
        completionHandler(returnCacheResponse)
        #endif
        
    }
    
    //MARK:- //6断点续传 重新下载开始回调表示从fileOffset字节处开始
    func urlSession(_ session: URLSession, downloadTask: URLSessionDownloadTask, didResumeAtOffset fileOffset: Int64, expectedTotalBytes: Int64) {
        print("resumeAtOffset bytes \(fileOffset) of totalBytes \(expectedTotalBytes)")
    }
    //当传输失败 网络异常，回收到一下回调 可以从error中获得resumData
    func urlSession(_ session: URLSession, task: URLSessionTask, didCompleteWithError error: Error?) {
        if error != nil {
            let sessionError = error! as NSError
            if let resumeData = sessionError.userInfo[NSURLSessionDownloadTaskResumeData] {
                print("resumeDat \(resumeData)")
                self.resumeData = resumeData as? Data
            }
            print("error \(String(describing: error))")
        }
    }
}


//MARK:- 7 HTTPClient工具类的实现
typealias HTTPSesionDataTaskCompetionBlock = (_ response: URLResponse?, _ responseObject: Any?, _ error: Error) -> ()
class HTTPClientSessionDelegate: NSObject, URLSessionDataDelegate {
    var taskCompletionHandler: HTTPSesionDataTaskCompetionBlock?
    var buffer: Data = Data()
    
    func urlSession(_ session: URLSession, dataTask: URLSessionDataTask, didReceive data: Data) {
        //缓存接收到的数据
        self.buffer.append(data)
    }
    
    func urlSession(_ session: URLSession, task: URLSessionTask, didCompleteWithError error: Error?) {
        let responseStr = String(data: self.buffer, encoding: String.Encoding.utf8)
        print("didReceive data =\(String(describing: responseStr))")
        if let callback = taskCompletionHandler {
            callback(task.response,responseStr,error!)
        }
        //释放session资源
        session.finishTasksAndInvalidate()
    }
}
//HTTPClient类 定义外部访问接口GET/POST,穿件URLSessionDataTask任务实例，实现代理功能路由到具体的协议代理处理类
class HTTPClient: NSObject {
    var sessionConfiguration = URLSessionConfiguration.default
    lazy var operationQueue: OperationQueue = {
        let operationQueue = OperationQueue()
        operationQueue.maxConcurrentOperationCount = 1
        return operationQueue
    }()
    lazy var session: URLSession = {
        return URLSession(configuration: self.sessionConfiguration, delegate: self, delegateQueue: self.operationQueue)
    }()
    
    //代理缓存
    var taskDelegates = [AnyHashable: HTTPClientSessionDelegate?]()
    //资源保护锁
    var lock = NSLock()
    
    func get(_ url: URL, parameters: Any?, success:@escaping (_ responseData: Any) -> Void,failure:@escaping (_ error: Error?) -> Void) {
        var request: URLRequest
        let postStr = self.formatParas(paras: parameters!)
        if let paras = postStr {
            let baseURLString = url.path + "?" + paras
            request = URLRequest(url: URL(string: baseURLString)!)
        }
        else
        {
            request = URLRequest(url: url)
        }
        let task = self.dataTask(with: request, success: success, failure: failure)
        task.resume()
    }
    
    func post(_ url: URL, parameters: Any?, success: @escaping(_ responseData: Any?) -> Void, failure: @escaping(_ error: Error?) -> Void) {
        var request = URLRequest(url: url)
        request.httpMethod = "POST"
        let postStr = self.formatParas(paras: parameters!)
        if let str = postStr {
            let postData = str.data(using: String.Encoding.utf8)!
            request.httpBody = postData
        }
        let task = self.dataTask(with: request, success: success, failure: failure)
        task.resume()
    }
    //参数格式化
    func formatParas(paras parameters: Any) -> String? {
        var postStr: String?
        if (parameters is String) {
            postStr = parameters as? String
        }
        if (parameters is [AnyHashable: Any]) {
            let keyValues = parameters as! [AnyHashable: Any]
            var tempStr = String()
            var index = 0
            for(key, obj) in keyValues {
                if index > 0 {
                    tempStr += "&"
                }
                let kv = "\(key)=\(obj)"
                tempStr += kv
                index += 1
            }
            postStr = tempStr
        }
        return postStr
    }
    
    func add(_ completionHandler: @escaping HTTPSesionDataTaskCompetionBlock, for task: URLSessionDataTask) {
        let sessionDelegate = HTTPClientSessionDelegate()
        sessionDelegate.taskCompletionHandler = completionHandler
        self.lock.lock()
        self.taskDelegates[(task.taskIdentifier)] = sessionDelegate
        self.lock.unlock()
    }
    
    func dataTask(with request: URLRequest, success: @escaping(_ responseData: Any?) -> Void,failure: @escaping(_ error: Error?) -> Void) -> URLSessionDataTask {
        let dataTask = self.session.dataTask(with: request)
        let complectionHandler = {
            (response: URLResponse?, responseObject: Any?, error: Error?) -> (Void) in
                if error != nil {
                    failure(error)
                }
                else
                {
                	success(responseObject)
                }
            
        }
        self.add(complectionHandler, for:dataTask)
        return dataTask
    }
}
//代理协议
extension HTTPClient: URLSessionDataDelegate {
    //数据接收
    func urlSession(_ session: URLSession, dataTask: URLSessionDataTask, didReceive data: Data) {
        let sessionDelegate = self.taskDelegates[(dataTask.taskIdentifier)]
        if let delegate = sessionDelegate {
            delegate?.urlSession(session, dataTask: dataTask, didReceive: data)
        }
    }
    //请求完成的
    func urlSession(_ session: URLSession, task: URLSessionTask, didCompleteWithError error: Error?) {
        let sessionDelegate = self.taskDelegates[(task.taskIdentifier)]
        if let delegate = sessionDelegate {
            delegate?.urlSession(session, task: task, didCompleteWithError: error)
        }
    }
}
