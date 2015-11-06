import Foundation

/// Responsible for managing the mapping of `ServerTrustPolicy` objects to a given host.
public class ServerTrustPolicyManager {
    /// The dictionary of policies mapped to a particular host.
    public let policies: [String: ServerTrustPolicy]
    
    /**
    Initializes the `ServerTrustPolicyManager` instance with the given policies.
    Since different servers and web services can have different leaf certificates, intermediate and even root
    certficates, it is important to have the flexibility to specify evaluation policies on a per host basis. This
    allows for scenarios such as using default evaluation for host1, certificate pinning for host2, public key
    pinning for host3 and disabling evaluation for host4.
    - parameter policies: A dictionary of all policies mapped to a particular host.
    - returns: The new `ServerTrustPolicyManager` instance.
    */
    public init(policies: [String: ServerTrustPolicy]) {
        self.policies = policies
    }
    
    /**
    Returns the `ServerTrustPolicy` for the given host if applicable.
    By default, this method will return the policy that perfectly matches the given host. Subclasses could override
    this method and implement more complex mapping implementations such as wildcards.
    - parameter host: The host to use when searching for a matching policy.
    - returns: The server trust policy for the given host if found.
    */
    public func serverTrustPolicyForHost(host: String) -> ServerTrustPolicy? {
        return policies[host]
    }
}

// MARK: -

extension NSURLSession {
    private struct AssociatedKeys {
        static var ManagerKey = "NSURLSession.ServerTrustPolicyManager"
    }
    
    var serverTrustPolicyManager: ServerTrustPolicyManager? {
        get {
            return objc_getAssociatedObject(self, &AssociatedKeys.ManagerKey) as? ServerTrustPolicyManager
        }
        set (manager) {
            objc_setAssociatedObject(self, &AssociatedKeys.ManagerKey, manager, .OBJC_ASSOCIATION_RETAIN_NONATOMIC)
        }
    }
}

// MARK: - ServerTrustPolicy

/**
The `ServerTrustPolicy` evaluates the server trust generally provided by an `NSURLAuthenticationChallenge` when
connecting to a server over a secure HTTPS connection. The policy configuration then evaluates the server trust
with a given set of criteria to determine whether the server trust is valid and the connection should be made.
Using pinned certificates or public keys for evaluation helps prevent man-in-the-middle (MITM) attacks and other
vulnerabilities. Applications dealing with sensitive customer data or financial information are strongly encouraged
to route all communication over an HTTPS connection with pinning enabled.
- PerformDefaultEvaluation: Uses the default server trust evaluation while allowing you to control whether to
validate the host provided by the challenge. Applications are encouraged to always
validate the host in production environments to guarantee the validity of the server's
certificate chain.
- PinCertificates:          Uses the pinned certificates to validate the server trust. The server trust is
considered valid if one of the pinned certificates match one of the server certificates.
By validating both the certificate chain and host, certificate pinning provides a very
secure form of server trust validation mitigating most, if not all, MITM attacks.
Applications are encouraged to always validate the host and require a valid certificate
chain in production environments.
- PinPublicKeys:            Uses the pinned public keys to validate the server trust. The server trust is considered
valid if one of the pinned public keys match one of the server certificate public keys.
By validating both the certificate chain and host, public key pinning provides a very
secure form of server trust validation mitigating most, if not all, MITM attacks.
Applications are encouraged to always validate the host and require a valid certificate
chain in production environments.
- DisableEvaluation:        Disables all evaluation which in turn will always consider any server trust as valid.
- CustomEvaluation:         Uses the associated closure to evaluate the validity of the server trust.
*/
public enum ServerTrustPolicy {
    case PerformDefaultEvaluation(validateHost: Bool)
    case PinCertificates(certificates: [SecCertificate], validateCertificateChain: Bool, validateHost: Bool)
    case PinPublicKeys(publicKeys: [SecKey], validateCertificateChain: Bool, validateHost: Bool)
    case DisableEvaluation
    case CustomEvaluation((serverTrust: SecTrust, host: String) -> Bool)
    
    // MARK: - Bundle Location
    
    /**
    Returns all certificates within the given bundle with a `.cer` file extension.
    - parameter bundle: The bundle to search for all `.cer` files.
    - returns: All certificates within the given bundle.
    */
    public static func certificatesInBundle(bundle: NSBundle = NSBundle.mainBundle()) -> [SecCertificate] {
        var certificates: [SecCertificate] = []
        
        for path in bundle.pathsForResourcesOfType(".cer", inDirectory: nil) {
            if let
                certificateData = NSData(contentsOfFile: path),
                certificate = SecCertificateCreateWithData(nil, certificateData)
            {
                certificates.append(certificate)
            }
        }
        
        return certificates
    }
    
    /**
    Returns all public keys within the given bundle with a `.cer` file extension.
    - parameter bundle: The bundle to search for all `*.cer` files.
    - returns: All public keys within the given bundle.
    */
    public static func publicKeysInBundle(bundle: NSBundle = NSBundle.mainBundle()) -> [SecKey] {
        var publicKeys: [SecKey] = []
        
        for certificate in certificatesInBundle(bundle) {
            if let publicKey = publicKeyForCertificate(certificate) {
                publicKeys.append(publicKey)
            }
        }
        
        return publicKeys
    }
    
    // MARK: - Evaluation
    
    /**
    Evaluates whether the server trust is valid for the given host.
    - parameter serverTrust: The server trust to evaluate.
    - parameter host:        The host of the challenge protection space.
    - returns: Whether the server trust is valid.
    */
    public func evaluateServerTrust(serverTrust: SecTrust, isValidForHost host: String) -> Bool {
        var serverTrustIsValid = false
        
        switch self {
        case let .PerformDefaultEvaluation(validateHost):
            let policy = SecPolicyCreateSSL(true, validateHost ? host as CFString : nil)
            SecTrustSetPolicies(serverTrust, [policy])
            
            serverTrustIsValid = trustIsValid(serverTrust)
        case let .PinCertificates(pinnedCertificates, validateCertificateChain, validateHost):
            if validateCertificateChain {
                let policy = SecPolicyCreateSSL(true, validateHost ? host as CFString : nil)
                SecTrustSetPolicies(serverTrust, [policy])
                
                SecTrustSetAnchorCertificates(serverTrust, pinnedCertificates)
                SecTrustSetAnchorCertificatesOnly(serverTrust, true)
                
                serverTrustIsValid = trustIsValid(serverTrust)
            } else {
                let serverCertificatesDataArray = certificateDataForTrust(serverTrust)
                
                //======================================================================================================
                // The following `[] +` is a temporary workaround for a Swift 2.0 compiler error. This workaround should
                // be removed once the following radar has been resolved:
                //   - http://openradar.appspot.com/radar?id=6082025006039040
                //======================================================================================================
                
                let pinnedCertificatesDataArray = certificateDataForCertificates([] + pinnedCertificates)
                
                outerLoop: for serverCertificateData in serverCertificatesDataArray {
                    for pinnedCertificateData in pinnedCertificatesDataArray {
                        if serverCertificateData.isEqualToData(pinnedCertificateData) {
                            serverTrustIsValid = true
                            break outerLoop
                        }
                    }
                }
            }
        case let .PinPublicKeys(pinnedPublicKeys, validateCertificateChain, validateHost):
            var certificateChainEvaluationPassed = true
            
            if validateCertificateChain {
                let policy = SecPolicyCreateSSL(true, validateHost ? host as CFString : nil)
                SecTrustSetPolicies(serverTrust, [policy])
                
                certificateChainEvaluationPassed = trustIsValid(serverTrust)
            }
            
            if certificateChainEvaluationPassed {
                outerLoop: for serverPublicKey in ServerTrustPolicy.publicKeysForTrust(serverTrust) as [AnyObject] {
                    for pinnedPublicKey in pinnedPublicKeys as [AnyObject] {
                        if serverPublicKey.isEqual(pinnedPublicKey) {
                            serverTrustIsValid = true
                            break outerLoop
                        }
                    }
                }
            }
        case .DisableEvaluation:
            serverTrustIsValid = true
        case let .CustomEvaluation(closure):
            serverTrustIsValid = closure(serverTrust: serverTrust, host: host)
        }
        
        return serverTrustIsValid
    }
    
    // MARK: - Private - Trust Validation
    
    private func trustIsValid(trust: SecTrust) -> Bool {
        var isValid = false
        
        var result = SecTrustResultType(kSecTrustResultInvalid)
        let status = SecTrustEvaluate(trust, &result)
        
        if status == errSecSuccess {
            let unspecified = SecTrustResultType(kSecTrustResultUnspecified)
            let proceed = SecTrustResultType(kSecTrustResultProceed)
            
            isValid = result == unspecified || result == proceed
        }
        
        return isValid
    }
    
    // MARK: - Private - Certificate Data
    
    private func certificateDataForTrust(trust: SecTrust) -> [NSData] {
        var certificates: [SecCertificate] = []
        
        for index in 0..<SecTrustGetCertificateCount(trust) {
            if let certificate = SecTrustGetCertificateAtIndex(trust, index) {
                certificates.append(certificate)
            }
        }
        
        return certificateDataForCertificates(certificates)
    }
    
    private func certificateDataForCertificates(certificates: [SecCertificate]) -> [NSData] {
        return certificates.map { SecCertificateCopyData($0) as NSData }
    }
    
    // MARK: - Private - Public Key Extraction
    
    private static func publicKeysForTrust(trust: SecTrust) -> [SecKey] {
        var publicKeys: [SecKey] = []
        
        for index in 0..<SecTrustGetCertificateCount(trust) {
            if let
                certificate = SecTrustGetCertificateAtIndex(trust, index),
                publicKey = publicKeyForCertificate(certificate)
            {
                publicKeys.append(publicKey)
            }
        }
        
        return publicKeys
    }
    
    private static func publicKeyForCertificate(certificate: SecCertificate) -> SecKey? {
        var publicKey: SecKey?
        
        let policy = SecPolicyCreateBasicX509()
        var trust: SecTrust?
        let trustCreationStatus = SecTrustCreateWithCertificates(certificate, policy, &trust)
        
        if let trust = trust where trustCreationStatus == errSecSuccess {
            publicKey = SecTrustCopyPublicKey(trust)
        }
        
        return publicKey
    }
}
import Foundation

extension Manager {
    private enum Uploadable {
        case Data(NSURLRequest, NSData)
        case File(NSURLRequest, NSURL)
        case Stream(NSURLRequest, NSInputStream)
    }
    
    private func upload(uploadable: Uploadable) -> Request {
        var uploadTask: NSURLSessionUploadTask!
        var HTTPBodyStream: NSInputStream?
        
        switch uploadable {
        case .Data(let request, let data):
            dispatch_sync(queue) {
                uploadTask = self.session.uploadTaskWithRequest(request, fromData: data)
            }
        case .File(let request, let fileURL):
            dispatch_sync(queue) {
                uploadTask = self.session.uploadTaskWithRequest(request, fromFile: fileURL)
            }
        case .Stream(let request, let stream):
            dispatch_sync(queue) {
                uploadTask = self.session.uploadTaskWithStreamedRequest(request)
            }
            
            HTTPBodyStream = stream
        }
        
        let request = Request(session: session, task: uploadTask)
        
        if HTTPBodyStream != nil {
            request.delegate.taskNeedNewBodyStream = { _, _ in
                return HTTPBodyStream
            }
        }
        
        delegate[request.delegate.task] = request.delegate
        
        if startRequestsImmediately {
            request.resume()
        }
        
        return request
    }
    
    // MARK: File
    
    /**
    Creates a request for uploading a file to the specified URL request.
    If `startRequestsImmediately` is `true`, the request will have `resume()` called before being returned.
    - parameter URLRequest: The URL request
    - parameter file:       The file to upload
    - returns: The created upload request.
    */
    public func upload(URLRequest: URLRequestConvertible, file: NSURL) -> Request {
        return upload(.File(URLRequest.URLRequest, file))
    }
    
    /**
    Creates a request for uploading a file to the specified URL request.
    If `startRequestsImmediately` is `true`, the request will have `resume()` called before being returned.
    - parameter method:    The HTTP method.
    - parameter URLString: The URL string.
    - parameter headers:   The HTTP headers. `nil` by default.
    - parameter file:      The file to upload
    - returns: The created upload request.
    */
    public func upload(
        method: Method,
        _ URLString: URLStringConvertible,
        headers: [String: String]? = nil,
        file: NSURL)
        -> Request
    {
        let mutableURLRequest = URLRequest(method, URLString, headers: headers)
        return upload(mutableURLRequest, file: file)
    }
    
    // MARK: Data
    
    /**
    Creates a request for uploading data to the specified URL request.
    If `startRequestsImmediately` is `true`, the request will have `resume()` called before being returned.
    - parameter URLRequest: The URL request.
    - parameter data:       The data to upload.
    - returns: The created upload request.
    */
    public func upload(URLRequest: URLRequestConvertible, data: NSData) -> Request {
        return upload(.Data(URLRequest.URLRequest, data))
    }
    
    /**
    Creates a request for uploading data to the specified URL request.
    If `startRequestsImmediately` is `true`, the request will have `resume()` called before being returned.
    - parameter method:    The HTTP method.
    - parameter URLString: The URL string.
    - parameter headers:   The HTTP headers. `nil` by default.
    - parameter data:      The data to upload
    - returns: The created upload request.
    */
    public func upload(
        method: Method,
        _ URLString: URLStringConvertible,
        headers: [String: String]? = nil,
        data: NSData)
        -> Request
    {
        let mutableURLRequest = URLRequest(method, URLString, headers: headers)
        
        return upload(mutableURLRequest, data: data)
    }
    
    // MARK: Stream
    
    /**
    Creates a request for uploading a stream to the specified URL request.
    If `startRequestsImmediately` is `true`, the request will have `resume()` called before being returned.
    - parameter URLRequest: The URL request.
    - parameter stream:     The stream to upload.
    - returns: The created upload request.
    */
    public func upload(URLRequest: URLRequestConvertible, stream: NSInputStream) -> Request {
        return upload(.Stream(URLRequest.URLRequest, stream))
    }
    
    /**
    Creates a request for uploading a stream to the specified URL request.
    If `startRequestsImmediately` is `true`, the request will have `resume()` called before being returned.
    - parameter method:    The HTTP method.
    - parameter URLString: The URL string.
    - parameter headers:   The HTTP headers. `nil` by default.
    - parameter stream:    The stream to upload.
    - returns: The created upload request.
    */
    public func upload(
        method: Method,
        _ URLString: URLStringConvertible,
        headers: [String: String]? = nil,
        stream: NSInputStream)
        -> Request
    {
        let mutableURLRequest = URLRequest(method, URLString, headers: headers)
        
        return upload(mutableURLRequest, stream: stream)
    }
    
    // MARK: MultipartFormData
    
    /// Default memory threshold used when encoding `MultipartFormData`.
    public static let MultipartFormDataEncodingMemoryThreshold: UInt64 = 10 * 1024 * 1024
    
    /**
    Defines whether the `MultipartFormData` encoding was successful and contains result of the encoding as
    associated values.
    - Success: Represents a successful `MultipartFormData` encoding and contains the new `Request` along with
    streaming information.
    - Failure: Used to represent a failure in the `MultipartFormData` encoding and also contains the encoding
    error.
    */
    public enum MultipartFormDataEncodingResult {
        case Success(request: Request, streamingFromDisk: Bool, streamFileURL: NSURL?)
        case Failure(ErrorType)
    }
    
    /**
    Encodes the `MultipartFormData` and creates a request to upload the result to the specified URL request.
    It is important to understand the memory implications of uploading `MultipartFormData`. If the cummulative
    payload is small, encoding the data in-memory and directly uploading to a server is the by far the most
    efficient approach. However, if the payload is too large, encoding the data in-memory could cause your app to
    be terminated. Larger payloads must first be written to disk using input and output streams to keep the memory
    footprint low, then the data can be uploaded as a stream from the resulting file. Streaming from disk MUST be
    used for larger payloads such as video content.
    The `encodingMemoryThreshold` parameter allows Alamofire to automatically determine whether to encode in-memory
    or stream from disk. If the content length of the `MultipartFormData` is below the `encodingMemoryThreshold`,
    encoding takes place in-memory. If the content length exceeds the threshold, the data is streamed to disk
    during the encoding process. Then the result is uploaded as data or as a stream depending on which encoding
    technique was used.
    If `startRequestsImmediately` is `true`, the request will have `resume()` called before being returned.
    - parameter method:                  The HTTP method.
    - parameter URLString:               The URL string.
    - parameter headers:                 The HTTP headers. `nil` by default.
    - parameter multipartFormData:       The closure used to append body parts to the `MultipartFormData`.
    - parameter encodingMemoryThreshold: The encoding memory threshold in bytes.
    `MultipartFormDataEncodingMemoryThreshold` by default.
    - parameter encodingCompletion:      The closure called when the `MultipartFormData` encoding is complete.
    */
    public func upload(
        method: Method,
        _ URLString: URLStringConvertible,
        headers: [String: String]? = nil,
        multipartFormData: MultipartFormData -> Void,
        encodingMemoryThreshold: UInt64 = Manager.MultipartFormDataEncodingMemoryThreshold,
        encodingCompletion: (MultipartFormDataEncodingResult -> Void)?)
    {
        let mutableURLRequest = URLRequest(method, URLString, headers: headers)
        
        return upload(
            mutableURLRequest,
            multipartFormData: multipartFormData,
            encodingMemoryThreshold: encodingMemoryThreshold,
            encodingCompletion: encodingCompletion
        )
    }
    
    /**
    Encodes the `MultipartFormData` and creates a request to upload the result to the specified URL request.
    It is important to understand the memory implications of uploading `MultipartFormData`. If the cummulative
    payload is small, encoding the data in-memory and directly uploading to a server is the by far the most
    efficient approach. However, if the payload is too large, encoding the data in-memory could cause your app to
    be terminated. Larger payloads must first be written to disk using input and output streams to keep the memory
    footprint low, then the data can be uploaded as a stream from the resulting file. Streaming from disk MUST be
    used for larger payloads such as video content.
    The `encodingMemoryThreshold` parameter allows Alamofire to automatically determine whether to encode in-memory
    or stream from disk. If the content length of the `MultipartFormData` is below the `encodingMemoryThreshold`,
    encoding takes place in-memory. If the content length exceeds the threshold, the data is streamed to disk
    during the encoding process. Then the result is uploaded as data or as a stream depending on which encoding
    technique was used.
    If `startRequestsImmediately` is `true`, the request will have `resume()` called before being returned.
    - parameter URLRequest:              The URL request.
    - parameter multipartFormData:       The closure used to append body parts to the `MultipartFormData`.
    - parameter encodingMemoryThreshold: The encoding memory threshold in bytes.
    `MultipartFormDataEncodingMemoryThreshold` by default.
    - parameter encodingCompletion:      The closure called when the `MultipartFormData` encoding is complete.
    */
    public func upload(
        URLRequest: URLRequestConvertible,
        multipartFormData: MultipartFormData -> Void,
        encodingMemoryThreshold: UInt64 = Manager.MultipartFormDataEncodingMemoryThreshold,
        encodingCompletion: (MultipartFormDataEncodingResult -> Void)?)
    {
        dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0)) {
            let formData = MultipartFormData()
            multipartFormData(formData)
            
            let URLRequestWithContentType = URLRequest.URLRequest
            URLRequestWithContentType.setValue(formData.contentType, forHTTPHeaderField: "Content-Type")
            
            let isBackgroundSession = self.session.configuration.identifier != nil
            
            if formData.contentLength < encodingMemoryThreshold && !isBackgroundSession {
                do {
                    let data = try formData.encode()
                    let encodingResult = MultipartFormDataEncodingResult.Success(
                        request: self.upload(URLRequestWithContentType, data: data),
                        streamingFromDisk: false,
                        streamFileURL: nil
                    )
                    
                    dispatch_async(dispatch_get_main_queue()) {
                        encodingCompletion?(encodingResult)
                    }
                } catch {
                    dispatch_async(dispatch_get_main_queue()) {
                        encodingCompletion?(.Failure(error as NSError))
                    }
                }
            } else {
                let fileManager = NSFileManager.defaultManager()
                let tempDirectoryURL = NSURL(fileURLWithPath: NSTemporaryDirectory())
                let directoryURL = tempDirectoryURL.URLByAppendingPathComponent("com.alamofire.manager/multipart.form.data")
                let fileName = NSUUID().UUIDString
                let fileURL = directoryURL.URLByAppendingPathComponent(fileName)
                
                do {
                    try fileManager.createDirectoryAtURL(directoryURL, withIntermediateDirectories: true, attributes: nil)
                    try formData.writeEncodedDataToDisk(fileURL)
                    
                    dispatch_async(dispatch_get_main_queue()) {
                        let encodingResult = MultipartFormDataEncodingResult.Success(
                            request: self.upload(URLRequestWithContentType, file: fileURL),
                            streamingFromDisk: true,
                            streamFileURL: fileURL
                        )
                        encodingCompletion?(encodingResult)
                    }
                } catch {
                    dispatch_async(dispatch_get_main_queue()) {
                        encodingCompletion?(.Failure(error as NSError))
                    }
                }
            }
        }
    }
}

// MARK: -

extension Request {
    
    // MARK: - UploadTaskDelegate
    
    class UploadTaskDelegate: DataTaskDelegate {
        var uploadTask: NSURLSessionUploadTask? { return task as? NSURLSessionUploadTask }
        var uploadProgress: ((Int64, Int64, Int64) -> Void)!
        
        // MARK: - NSURLSessionTaskDelegate
        
        // MARK: Override Closures
        
        var taskDidSendBodyData: ((NSURLSession, NSURLSessionTask, Int64, Int64, Int64) -> Void)?
        
        // MARK: Delegate Methods
        
        func URLSession(
            session: NSURLSession,
            task: NSURLSessionTask,
            didSendBodyData bytesSent: Int64,
            totalBytesSent: Int64,
            totalBytesExpectedToSend: Int64)
        {
            if let taskDidSendBodyData = taskDidSendBodyData {
                taskDidSendBodyData(session, task, bytesSent, totalBytesSent, totalBytesExpectedToSend)
            } else {
                progress.totalUnitCount = totalBytesExpectedToSend
                progress.completedUnitCount = totalBytesSent
                
                uploadProgress?(bytesSent, totalBytesSent, totalBytesExpectedToSend)
            }
        }
    }
}

// MARK: - URLStringConvertible

/**
Types adopting the `URLStringConvertible` protocol can be used to construct URL strings, which are then used to
construct URL requests.
*/
public protocol URLStringConvertible {
    /**
    A URL that conforms to RFC 2396.
    Methods accepting a `URLStringConvertible` type parameter parse it according to RFCs 1738 and 1808.
    See https://tools.ietf.org/html/rfc2396
    See https://tools.ietf.org/html/rfc1738
    See https://tools.ietf.org/html/rfc1808
    */
    var URLString: String { get }
}

extension String: URLStringConvertible {
    public var URLString: String {
        return self
    }
}

extension NSURL: URLStringConvertible {
    public var URLString: String {
        return absoluteString
    }
}

extension NSURLComponents: URLStringConvertible {
    public var URLString: String {
        return URL!.URLString
    }
}

extension NSURLRequest: URLStringConvertible {
    public var URLString: String {
        return URL!.URLString
    }
}

// MARK: - URLRequestConvertible

/**
Types adopting the `URLRequestConvertible` protocol can be used to construct URL requests.
*/
public protocol URLRequestConvertible {
    /// The URL request.
    var URLRequest: NSMutableURLRequest { get }
}

extension NSURLRequest: URLRequestConvertible {
    public var URLRequest: NSMutableURLRequest {
        return self.mutableCopy() as! NSMutableURLRequest
    }
}

// MARK: - Convenience

func URLRequest(
    method: Method,
    _ URLString: URLStringConvertible,
    headers: [String: String]? = nil)
    -> NSMutableURLRequest
{
    let mutableURLRequest = NSMutableURLRequest(URL: NSURL(string: URLString.URLString)!)
    mutableURLRequest.HTTPMethod = method.rawValue
    
    if let headers = headers {
        for (headerField, headerValue) in headers {
            mutableURLRequest.setValue(headerValue, forHTTPHeaderField: headerField)
        }
    }
    
    return mutableURLRequest
}

// MARK: - Request Methods

/**
Creates a request using the shared manager instance for the specified method, URL string, parameters, and
parameter encoding.
- parameter method:     The HTTP method.
- parameter URLString:  The URL string.
- parameter parameters: The parameters. `nil` by default.
- parameter encoding:   The parameter encoding. `.URL` by default.
- parameter headers:    The HTTP headers. `nil` by default.
- returns: The created request.
*/
public func request(
    method: Method,
    _ URLString: URLStringConvertible,
    parameters: [String: AnyObject]? = nil,
    encoding: ParameterEncoding = .URL,
    headers: [String: String]? = nil)
    -> Request
{
    return Manager.sharedInstance.request(
        method,
        URLString,
        parameters: parameters,
        encoding: encoding,
        headers: headers
    )
}

/**
Creates a request using the shared manager instance for the specified URL request.
If `startRequestsImmediately` is `true`, the request will have `resume()` called before being returned.
- parameter URLRequest: The URL request
- returns: The created request.
*/
public func request(URLRequest: URLRequestConvertible) -> Request {
    return Manager.sharedInstance.request(URLRequest.URLRequest)
}

// MARK: - Upload Methods

// MARK: File

/**
Creates an upload request using the shared manager instance for the specified method, URL string, and file.
- parameter method:    The HTTP method.
- parameter URLString: The URL string.
- parameter headers:   The HTTP headers. `nil` by default.
- parameter file:      The file to upload.
- returns: The created upload request.
*/
public func upload(
    method: Method,
    _ URLString: URLStringConvertible,
    headers: [String: String]? = nil,
    file: NSURL)
    -> Request
{
    return Manager.sharedInstance.upload(method, URLString, headers: headers, file: file)
}

/**
Creates an upload request using the shared manager instance for the specified URL request and file.
- parameter URLRequest: The URL request.
- parameter file:       The file to upload.
- returns: The created upload request.
*/
public func upload(URLRequest: URLRequestConvertible, file: NSURL) -> Request {
    return Manager.sharedInstance.upload(URLRequest, file: file)
}

// MARK: Data

/**
Creates an upload request using the shared manager instance for the specified method, URL string, and data.
- parameter method:    The HTTP method.
- parameter URLString: The URL string.
- parameter headers:   The HTTP headers. `nil` by default.
- parameter data:      The data to upload.
- returns: The created upload request.
*/
public func upload(
    method: Method,
    _ URLString: URLStringConvertible,
    headers: [String: String]? = nil,
    data: NSData)
    -> Request
{
    return Manager.sharedInstance.upload(method, URLString, headers: headers, data: data)
}

/**
Creates an upload request using the shared manager instance for the specified URL request and data.
- parameter URLRequest: The URL request.
- parameter data:       The data to upload.
- returns: The created upload request.
*/
public func upload(URLRequest: URLRequestConvertible, data: NSData) -> Request {
    return Manager.sharedInstance.upload(URLRequest, data: data)
}

// MARK: Stream

/**
Creates an upload request using the shared manager instance for the specified method, URL string, and stream.
- parameter method:    The HTTP method.
- parameter URLString: The URL string.
- parameter headers:   The HTTP headers. `nil` by default.
- parameter stream:    The stream to upload.
- returns: The created upload request.
*/
public func upload(
    method: Method,
    _ URLString: URLStringConvertible,
    headers: [String: String]? = nil,
    stream: NSInputStream)
    -> Request
{
    return Manager.sharedInstance.upload(method, URLString, headers: headers, stream: stream)
}

/**
Creates an upload request using the shared manager instance for the specified URL request and stream.
- parameter URLRequest: The URL request.
- parameter stream:     The stream to upload.
- returns: The created upload request.
*/
public func upload(URLRequest: URLRequestConvertible, stream: NSInputStream) -> Request {
    return Manager.sharedInstance.upload(URLRequest, stream: stream)
}

// MARK: MultipartFormData

/**
Creates an upload request using the shared manager instance for the specified method and URL string.
- parameter method:                  The HTTP method.
- parameter URLString:               The URL string.
- parameter headers:                 The HTTP headers. `nil` by default.
- parameter multipartFormData:       The closure used to append body parts to the `MultipartFormData`.
- parameter encodingMemoryThreshold: The encoding memory threshold in bytes.
`MultipartFormDataEncodingMemoryThreshold` by default.
- parameter encodingCompletion:      The closure called when the `MultipartFormData` encoding is complete.
*/
public func upload(
    method: Method,
    _ URLString: URLStringConvertible,
    headers: [String: String]? = nil,
    multipartFormData: MultipartFormData -> Void,
    encodingMemoryThreshold: UInt64 = Manager.MultipartFormDataEncodingMemoryThreshold,
    encodingCompletion: (Manager.MultipartFormDataEncodingResult -> Void)?)
{
    return Manager.sharedInstance.upload(
        method,
        URLString,
        headers: headers,
        multipartFormData: multipartFormData,
        encodingMemoryThreshold: encodingMemoryThreshold,
        encodingCompletion: encodingCompletion
    )
}

/**
Creates an upload request using the shared manager instance for the specified method and URL string.
- parameter URLRequest:              The URL request.
- parameter multipartFormData:       The closure used to append body parts to the `MultipartFormData`.
- parameter encodingMemoryThreshold: The encoding memory threshold in bytes.
`MultipartFormDataEncodingMemoryThreshold` by default.
- parameter encodingCompletion:      The closure called when the `MultipartFormData` encoding is complete.
*/
public func upload(
    URLRequest: URLRequestConvertible,
    multipartFormData: MultipartFormData -> Void,
    encodingMemoryThreshold: UInt64 = Manager.MultipartFormDataEncodingMemoryThreshold,
    encodingCompletion: (Manager.MultipartFormDataEncodingResult -> Void)?)
{
    return Manager.sharedInstance.upload(
        URLRequest,
        multipartFormData: multipartFormData,
        encodingMemoryThreshold: encodingMemoryThreshold,
        encodingCompletion: encodingCompletion
    )
}

// MARK: - Download Methods

// MARK: URL Request

/**
Creates a download request using the shared manager instance for the specified method and URL string.
- parameter method:      The HTTP method.
- parameter URLString:   The URL string.
- parameter parameters:  The parameters. `nil` by default.
- parameter encoding:    The parameter encoding. `.URL` by default.
- parameter headers:     The HTTP headers. `nil` by default.
- parameter destination: The closure used to determine the destination of the downloaded file.
- returns: The created download request.
*/
public func download(
    method: Method,
    _ URLString: URLStringConvertible,
    parameters: [String: AnyObject]? = nil,
    encoding: ParameterEncoding = .URL,
    headers: [String: String]? = nil,
    destination: Request.DownloadFileDestination)
    -> Request
{
    return Manager.sharedInstance.download(
        method,
        URLString,
        parameters: parameters,
        encoding: encoding,
        headers: headers,
        destination: destination
    )
}

/**
Creates a download request using the shared manager instance for the specified URL request.
- parameter URLRequest:  The URL request.
- parameter destination: The closure used to determine the destination of the downloaded file.
- returns: The created download request.
*/
public func download(URLRequest: URLRequestConvertible, destination: Request.DownloadFileDestination) -> Request {
    return Manager.sharedInstance.download(URLRequest, destination: destination)
}

// MARK: Resume Data

/**
Creates a request using the shared manager instance for downloading from the resume data produced from a
previous request cancellation.
- parameter resumeData:  The resume data. This is an opaque data blob produced by `NSURLSessionDownloadTask`
when a task is cancelled. See `NSURLSession -downloadTaskWithResumeData:` for additional
information.
- parameter destination: The closure used to determine the destination of the downloaded file.
- returns: The created download request.
*/
public func download(resumeData data: NSData, destination: Request.DownloadFileDestination) -> Request {
    return Manager.sharedInstance.download(data, destination: destination)
}
import Foundation

/// Responsible for managing the mapping of `ServerTrustPolicy` objects to a given host.
public class ServerTrustPolicyManager {
    /// The dictionary of policies mapped to a particular host.
    public let policies: [String: ServerTrustPolicy]
    
    /**
    Initializes the `ServerTrustPolicyManager` instance with the given policies.
    Since different servers and web services can have different leaf certificates, intermediate and even root
    certficates, it is important to have the flexibility to specify evaluation policies on a per host basis. This
    allows for scenarios such as using default evaluation for host1, certificate pinning for host2, public key
    pinning for host3 and disabling evaluation for host4.
    - parameter policies: A dictionary of all policies mapped to a particular host.
    - returns: The new `ServerTrustPolicyManager` instance.
    */
    public init(policies: [String: ServerTrustPolicy]) {
        self.policies = policies
    }
    
    /**
    Returns the `ServerTrustPolicy` for the given host if applicable.
    By default, this method will return the policy that perfectly matches the given host. Subclasses could override
    this method and implement more complex mapping implementations such as wildcards.
    - parameter host: The host to use when searching for a matching policy.
    - returns: The server trust policy for the given host if found.
    */
    public func serverTrustPolicyForHost(host: String) -> ServerTrustPolicy? {
        return policies[host]
    }
}

// MARK: -

extension NSURLSession {
    private struct AssociatedKeys {
        static var ManagerKey = "NSURLSession.ServerTrustPolicyManager"
    }
    
    var serverTrustPolicyManager: ServerTrustPolicyManager? {
        get {
            return objc_getAssociatedObject(self, &AssociatedKeys.ManagerKey) as? ServerTrustPolicyManager
        }
        set (manager) {
            objc_setAssociatedObject(self, &AssociatedKeys.ManagerKey, manager, .OBJC_ASSOCIATION_RETAIN_NONATOMIC)
        }
    }
}

// MARK: - ServerTrustPolicy

/**
The `ServerTrustPolicy` evaluates the server trust generally provided by an `NSURLAuthenticationChallenge` when
connecting to a server over a secure HTTPS connection. The policy configuration then evaluates the server trust
with a given set of criteria to determine whether the server trust is valid and the connection should be made.
Using pinned certificates or public keys for evaluation helps prevent man-in-the-middle (MITM) attacks and other
vulnerabilities. Applications dealing with sensitive customer data or financial information are strongly encouraged
to route all communication over an HTTPS connection with pinning enabled.
- PerformDefaultEvaluation: Uses the default server trust evaluation while allowing you to control whether to
validate the host provided by the challenge. Applications are encouraged to always
validate the host in production environments to guarantee the validity of the server's
certificate chain.
- PinCertificates:          Uses the pinned certificates to validate the server trust. The server trust is
considered valid if one of the pinned certificates match one of the server certificates.
By validating both the certificate chain and host, certificate pinning provides a very
secure form of server trust validation mitigating most, if not all, MITM attacks.
Applications are encouraged to always validate the host and require a valid certificate
chain in production environments.
- PinPublicKeys:            Uses the pinned public keys to validate the server trust. The server trust is considered
valid if one of the pinned public keys match one of the server certificate public keys.
By validating both the certificate chain and host, public key pinning provides a very
secure form of server trust validation mitigating most, if not all, MITM attacks.
Applications are encouraged to always validate the host and require a valid certificate
chain in production environments.
- DisableEvaluation:        Disables all evaluation which in turn will always consider any server trust as valid.
- CustomEvaluation:         Uses the associated closure to evaluate the validity of the server trust.
*/
public enum ServerTrustPolicy {
    case PerformDefaultEvaluation(validateHost: Bool)
    case PinCertificates(certificates: [SecCertificate], validateCertificateChain: Bool, validateHost: Bool)
    case PinPublicKeys(publicKeys: [SecKey], validateCertificateChain: Bool, validateHost: Bool)
    case DisableEvaluation
    case CustomEvaluation((serverTrust: SecTrust, host: String) -> Bool)
    
    // MARK: - Bundle Location
    
    /**
    Returns all certificates within the given bundle with a `.cer` file extension.
    - parameter bundle: The bundle to search for all `.cer` files.
    - returns: All certificates within the given bundle.
    */
    public static func certificatesInBundle(bundle: NSBundle = NSBundle.mainBundle()) -> [SecCertificate] {
        var certificates: [SecCertificate] = []
        
        for path in bundle.pathsForResourcesOfType(".cer", inDirectory: nil) {
            if let
                certificateData = NSData(contentsOfFile: path),
                certificate = SecCertificateCreateWithData(nil, certificateData)
            {
                certificates.append(certificate)
            }
        }
        
        return certificates
    }
    
    /**
    Returns all public keys within the given bundle with a `.cer` file extension.
    - parameter bundle: The bundle to search for all `*.cer` files.
    - returns: All public keys within the given bundle.
    */
    public static func publicKeysInBundle(bundle: NSBundle = NSBundle.mainBundle()) -> [SecKey] {
        var publicKeys: [SecKey] = []
        
        for certificate in certificatesInBundle(bundle) {
            if let publicKey = publicKeyForCertificate(certificate) {
                publicKeys.append(publicKey)
            }
        }
        
        return publicKeys
    }
    
    // MARK: - Evaluation
    
    /**
    Evaluates whether the server trust is valid for the given host.
    - parameter serverTrust: The server trust to evaluate.
    - parameter host:        The host of the challenge protection space.
    - returns: Whether the server trust is valid.
    */
    public func evaluateServerTrust(serverTrust: SecTrust, isValidForHost host: String) -> Bool {
        var serverTrustIsValid = false
        
        switch self {
        case let .PerformDefaultEvaluation(validateHost):
            let policy = SecPolicyCreateSSL(true, validateHost ? host as CFString : nil)
            SecTrustSetPolicies(serverTrust, [policy])
            
            serverTrustIsValid = trustIsValid(serverTrust)
        case let .PinCertificates(pinnedCertificates, validateCertificateChain, validateHost):
            if validateCertificateChain {
                let policy = SecPolicyCreateSSL(true, validateHost ? host as CFString : nil)
                SecTrustSetPolicies(serverTrust, [policy])
                
                SecTrustSetAnchorCertificates(serverTrust, pinnedCertificates)
                SecTrustSetAnchorCertificatesOnly(serverTrust, true)
                
                serverTrustIsValid = trustIsValid(serverTrust)
            } else {
                let serverCertificatesDataArray = certificateDataForTrust(serverTrust)
                
                //======================================================================================================
                // The following `[] +` is a temporary workaround for a Swift 2.0 compiler error. This workaround should
                // be removed once the following radar has been resolved:
                //   - http://openradar.appspot.com/radar?id=6082025006039040
                //======================================================================================================
                
                let pinnedCertificatesDataArray = certificateDataForCertificates([] + pinnedCertificates)
                
                outerLoop: for serverCertificateData in serverCertificatesDataArray {
                    for pinnedCertificateData in pinnedCertificatesDataArray {
                        if serverCertificateData.isEqualToData(pinnedCertificateData) {
                            serverTrustIsValid = true
                            break outerLoop
                        }
                    }
                }
            }
        case let .PinPublicKeys(pinnedPublicKeys, validateCertificateChain, validateHost):
            var certificateChainEvaluationPassed = true
            
            if validateCertificateChain {
                let policy = SecPolicyCreateSSL(true, validateHost ? host as CFString : nil)
                SecTrustSetPolicies(serverTrust, [policy])
                
                certificateChainEvaluationPassed = trustIsValid(serverTrust)
            }
            
            if certificateChainEvaluationPassed {
                outerLoop: for serverPublicKey in ServerTrustPolicy.publicKeysForTrust(serverTrust) as [AnyObject] {
                    for pinnedPublicKey in pinnedPublicKeys as [AnyObject] {
                        if serverPublicKey.isEqual(pinnedPublicKey) {
                            serverTrustIsValid = true
                            break outerLoop
                        }
                    }
                }
            }
        case .DisableEvaluation:
            serverTrustIsValid = true
        case let .CustomEvaluation(closure):
            serverTrustIsValid = closure(serverTrust: serverTrust, host: host)
        }
        
        return serverTrustIsValid
    }
    
    // MARK: - Private - Trust Validation
    
    private func trustIsValid(trust: SecTrust) -> Bool {
        var isValid = false
        
        var result = SecTrustResultType(kSecTrustResultInvalid)
        let status = SecTrustEvaluate(trust, &result)
        
        if status == errSecSuccess {
            let unspecified = SecTrustResultType(kSecTrustResultUnspecified)
            let proceed = SecTrustResultType(kSecTrustResultProceed)
            
            isValid = result == unspecified || result == proceed
        }
        
        return isValid
    }
    
    // MARK: - Private - Certificate Data
    
    private func certificateDataForTrust(trust: SecTrust) -> [NSData] {
        var certificates: [SecCertificate] = []
        
        for index in 0..<SecTrustGetCertificateCount(trust) {
            if let certificate = SecTrustGetCertificateAtIndex(trust, index) {
                certificates.append(certificate)
            }
        }
        
        return certificateDataForCertificates(certificates)
    }
    
    private func certificateDataForCertificates(certificates: [SecCertificate]) -> [NSData] {
        return certificates.map { SecCertificateCopyData($0) as NSData }
    }
    
    // MARK: - Private - Public Key Extraction
    
    private static func publicKeysForTrust(trust: SecTrust) -> [SecKey] {
        var publicKeys: [SecKey] = []
        
        for index in 0..<SecTrustGetCertificateCount(trust) {
            if let
                certificate = SecTrustGetCertificateAtIndex(trust, index),
                publicKey = publicKeyForCertificate(certificate)
            {
                publicKeys.append(publicKey)
            }
        }
        
        return publicKeys
    }
    
    private static func publicKeyForCertificate(certificate: SecCertificate) -> SecKey? {
        var publicKey: SecKey?
        
        let policy = SecPolicyCreateBasicX509()
        var trust: SecTrust?
        let trustCreationStatus = SecTrustCreateWithCertificates(certificate, policy, &trust)
        
        if let trust = trust where trustCreationStatus == errSecSuccess {
            publicKey = SecTrustCopyPublicKey(trust)
        }
        
        return publicKey
    }
}
import Foundation

extension Manager {
    private enum Uploadable {
        case Data(NSURLRequest, NSData)
        case File(NSURLRequest, NSURL)
        case Stream(NSURLRequest, NSInputStream)
    }
    
    private func upload(uploadable: Uploadable) -> Request {
        var uploadTask: NSURLSessionUploadTask!
        var HTTPBodyStream: NSInputStream?
        
        switch uploadable {
        case .Data(let request, let data):
            dispatch_sync(queue) {
                uploadTask = self.session.uploadTaskWithRequest(request, fromData: data)
            }
        case .File(let request, let fileURL):
            dispatch_sync(queue) {
                uploadTask = self.session.uploadTaskWithRequest(request, fromFile: fileURL)
            }
        case .Stream(let request, let stream):
            dispatch_sync(queue) {
                uploadTask = self.session.uploadTaskWithStreamedRequest(request)
            }
            
            HTTPBodyStream = stream
        }
        
        let request = Request(session: session, task: uploadTask)
        
        if HTTPBodyStream != nil {
            request.delegate.taskNeedNewBodyStream = { _, _ in
                return HTTPBodyStream
            }
        }
        
        delegate[request.delegate.task] = request.delegate
        
        if startRequestsImmediately {
            request.resume()
        }
        
        return request
    }
    
    // MARK: File
    
    /**
    Creates a request for uploading a file to the specified URL request.
    If `startRequestsImmediately` is `true`, the request will have `resume()` called before being returned.
    - parameter URLRequest: The URL request
    - parameter file:       The file to upload
    - returns: The created upload request.
    */
    public func upload(URLRequest: URLRequestConvertible, file: NSURL) -> Request {
        return upload(.File(URLRequest.URLRequest, file))
    }
    
    /**
    Creates a request for uploading a file to the specified URL request.
    If `startRequestsImmediately` is `true`, the request will have `resume()` called before being returned.
    - parameter method:    The HTTP method.
    - parameter URLString: The URL string.
    - parameter headers:   The HTTP headers. `nil` by default.
    - parameter file:      The file to upload
    - returns: The created upload request.
    */
    public func upload(
        method: Method,
        _ URLString: URLStringConvertible,
        headers: [String: String]? = nil,
        file: NSURL)
        -> Request
    {
        let mutableURLRequest = URLRequest(method, URLString, headers: headers)
        return upload(mutableURLRequest, file: file)
    }
    
    // MARK: Data
    
    /**
    Creates a request for uploading data to the specified URL request.
    If `startRequestsImmediately` is `true`, the request will have `resume()` called before being returned.
    - parameter URLRequest: The URL request.
    - parameter data:       The data to upload.
    - returns: The created upload request.
    */
    public func upload(URLRequest: URLRequestConvertible, data: NSData) -> Request {
        return upload(.Data(URLRequest.URLRequest, data))
    }
    
    /**
    Creates a request for uploading data to the specified URL request.
    If `startRequestsImmediately` is `true`, the request will have `resume()` called before being returned.
    - parameter method:    The HTTP method.
    - parameter URLString: The URL string.
    - parameter headers:   The HTTP headers. `nil` by default.
    - parameter data:      The data to upload
    - returns: The created upload request.
    */
    public func upload(
        method: Method,
        _ URLString: URLStringConvertible,
        headers: [String: String]? = nil,
        data: NSData)
        -> Request
    {
        let mutableURLRequest = URLRequest(method, URLString, headers: headers)
        
        return upload(mutableURLRequest, data: data)
    }
    
    // MARK: Stream
    
    /**
    Creates a request for uploading a stream to the specified URL request.
    If `startRequestsImmediately` is `true`, the request will have `resume()` called before being returned.
    - parameter URLRequest: The URL request.
    - parameter stream:     The stream to upload.
    - returns: The created upload request.
    */
    public func upload(URLRequest: URLRequestConvertible, stream: NSInputStream) -> Request {
        return upload(.Stream(URLRequest.URLRequest, stream))
    }
    
    /**
    Creates a request for uploading a stream to the specified URL request.
    If `startRequestsImmediately` is `true`, the request will have `resume()` called before being returned.
    - parameter method:    The HTTP method.
    - parameter URLString: The URL string.
    - parameter headers:   The HTTP headers. `nil` by default.
    - parameter stream:    The stream to upload.
    - returns: The created upload request.
    */
    public func upload(
        method: Method,
        _ URLString: URLStringConvertible,
        headers: [String: String]? = nil,
        stream: NSInputStream)
        -> Request
    {
        let mutableURLRequest = URLRequest(method, URLString, headers: headers)
        
        return upload(mutableURLRequest, stream: stream)
    }
    
    // MARK: MultipartFormData
    
    /// Default memory threshold used when encoding `MultipartFormData`.
    public static let MultipartFormDataEncodingMemoryThreshold: UInt64 = 10 * 1024 * 1024
    
    /**
    Defines whether the `MultipartFormData` encoding was successful and contains result of the encoding as
    associated values.
    - Success: Represents a successful `MultipartFormData` encoding and contains the new `Request` along with
    streaming information.
    - Failure: Used to represent a failure in the `MultipartFormData` encoding and also contains the encoding
    error.
    */
    public enum MultipartFormDataEncodingResult {
        case Success(request: Request, streamingFromDisk: Bool, streamFileURL: NSURL?)
        case Failure(ErrorType)
    }
    
    /**
    Encodes the `MultipartFormData` and creates a request to upload the result to the specified URL request.
    It is important to understand the memory implications of uploading `MultipartFormData`. If the cummulative
    payload is small, encoding the data in-memory and directly uploading to a server is the by far the most
    efficient approach. However, if the payload is too large, encoding the data in-memory could cause your app to
    be terminated. Larger payloads must first be written to disk using input and output streams to keep the memory
    footprint low, then the data can be uploaded as a stream from the resulting file. Streaming from disk MUST be
    used for larger payloads such as video content.
    The `encodingMemoryThreshold` parameter allows Alamofire to automatically determine whether to encode in-memory
    or stream from disk. If the content length of the `MultipartFormData` is below the `encodingMemoryThreshold`,
    encoding takes place in-memory. If the content length exceeds the threshold, the data is streamed to disk
    during the encoding process. Then the result is uploaded as data or as a stream depending on which encoding
    technique was used.
    If `startRequestsImmediately` is `true`, the request will have `resume()` called before being returned.
    - parameter method:                  The HTTP method.
    - parameter URLString:               The URL string.
    - parameter headers:                 The HTTP headers. `nil` by default.
    - parameter multipartFormData:       The closure used to append body parts to the `MultipartFormData`.
    - parameter encodingMemoryThreshold: The encoding memory threshold in bytes.
    `MultipartFormDataEncodingMemoryThreshold` by default.
    - parameter encodingCompletion:      The closure called when the `MultipartFormData` encoding is complete.
    */
    public func upload(
        method: Method,
        _ URLString: URLStringConvertible,
        headers: [String: String]? = nil,
        multipartFormData: MultipartFormData -> Void,
        encodingMemoryThreshold: UInt64 = Manager.MultipartFormDataEncodingMemoryThreshold,
        encodingCompletion: (MultipartFormDataEncodingResult -> Void)?)
    {
        let mutableURLRequest = URLRequest(method, URLString, headers: headers)
        
        return upload(
            mutableURLRequest,
            multipartFormData: multipartFormData,
            encodingMemoryThreshold: encodingMemoryThreshold,
            encodingCompletion: encodingCompletion
        )
    }
    
    /**
    Encodes the `MultipartFormData` and creates a request to upload the result to the specified URL request.
    It is important to understand the memory implications of uploading `MultipartFormData`. If the cummulative
    payload is small, encoding the data in-memory and directly uploading to a server is the by far the most
    efficient approach. However, if the payload is too large, encoding the data in-memory could cause your app to
    be terminated. Larger payloads must first be written to disk using input and output streams to keep the memory
    footprint low, then the data can be uploaded as a stream from the resulting file. Streaming from disk MUST be
    used for larger payloads such as video content.
    The `encodingMemoryThreshold` parameter allows Alamofire to automatically determine whether to encode in-memory
    or stream from disk. If the content length of the `MultipartFormData` is below the `encodingMemoryThreshold`,
    encoding takes place in-memory. If the content length exceeds the threshold, the data is streamed to disk
    during the encoding process. Then the result is uploaded as data or as a stream depending on which encoding
    technique was used.
    If `startRequestsImmediately` is `true`, the request will have `resume()` called before being returned.
    - parameter URLRequest:              The URL request.
    - parameter multipartFormData:       The closure used to append body parts to the `MultipartFormData`.
    - parameter encodingMemoryThreshold: The encoding memory threshold in bytes.
    `MultipartFormDataEncodingMemoryThreshold` by default.
    - parameter encodingCompletion:      The closure called when the `MultipartFormData` encoding is complete.
    */
    public func upload(
        URLRequest: URLRequestConvertible,
        multipartFormData: MultipartFormData -> Void,
        encodingMemoryThreshold: UInt64 = Manager.MultipartFormDataEncodingMemoryThreshold,
        encodingCompletion: (MultipartFormDataEncodingResult -> Void)?)
    {
        dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0)) {
            let formData = MultipartFormData()
            multipartFormData(formData)
            
            let URLRequestWithContentType = URLRequest.URLRequest
            URLRequestWithContentType.setValue(formData.contentType, forHTTPHeaderField: "Content-Type")
            
            let isBackgroundSession = self.session.configuration.identifier != nil
            
            if formData.contentLength < encodingMemoryThreshold && !isBackgroundSession {
                do {
                    let data = try formData.encode()
                    let encodingResult = MultipartFormDataEncodingResult.Success(
                        request: self.upload(URLRequestWithContentType, data: data),
                        streamingFromDisk: false,
                        streamFileURL: nil
                    )
                    
                    dispatch_async(dispatch_get_main_queue()) {
                        encodingCompletion?(encodingResult)
                    }
                } catch {
                    dispatch_async(dispatch_get_main_queue()) {
                        encodingCompletion?(.Failure(error as NSError))
                    }
                }
            } else {
                let fileManager = NSFileManager.defaultManager()
                let tempDirectoryURL = NSURL(fileURLWithPath: NSTemporaryDirectory())
                let directoryURL = tempDirectoryURL.URLByAppendingPathComponent("com.alamofire.manager/multipart.form.data")
                let fileName = NSUUID().UUIDString
                let fileURL = directoryURL.URLByAppendingPathComponent(fileName)
                
                do {
                    try fileManager.createDirectoryAtURL(directoryURL, withIntermediateDirectories: true, attributes: nil)
                    try formData.writeEncodedDataToDisk(fileURL)
                    
                    dispatch_async(dispatch_get_main_queue()) {
                        let encodingResult = MultipartFormDataEncodingResult.Success(
                            request: self.upload(URLRequestWithContentType, file: fileURL),
                            streamingFromDisk: true,
                            streamFileURL: fileURL
                        )
                        encodingCompletion?(encodingResult)
                    }
                } catch {
                    dispatch_async(dispatch_get_main_queue()) {
                        encodingCompletion?(.Failure(error as NSError))
                    }
                }
            }
        }
    }
}

// MARK: -

extension Request {
    
    // MARK: - UploadTaskDelegate
    
    class UploadTaskDelegate: DataTaskDelegate {
        var uploadTask: NSURLSessionUploadTask? { return task as? NSURLSessionUploadTask }
        var uploadProgress: ((Int64, Int64, Int64) -> Void)!
        
        // MARK: - NSURLSessionTaskDelegate
        
        // MARK: Override Closures
        
        var taskDidSendBodyData: ((NSURLSession, NSURLSessionTask, Int64, Int64, Int64) -> Void)?
        
        // MARK: Delegate Methods
        
        func URLSession(
            session: NSURLSession,
            task: NSURLSessionTask,
            didSendBodyData bytesSent: Int64,
            totalBytesSent: Int64,
            totalBytesExpectedToSend: Int64)
        {
            if let taskDidSendBodyData = taskDidSendBodyData {
                taskDidSendBodyData(session, task, bytesSent, totalBytesSent, totalBytesExpectedToSend)
            } else {
                progress.totalUnitCount = totalBytesExpectedToSend
                progress.completedUnitCount = totalBytesSent
                
                uploadProgress?(bytesSent, totalBytesSent, totalBytesExpectedToSend)
            }
        }
    }
}

// MARK: - URLStringConvertible

/**
Types adopting the `URLStringConvertible` protocol can be used to construct URL strings, which are then used to
construct URL requests.
*/
public protocol URLStringConvertible {
    /**
    A URL that conforms to RFC 2396.
    Methods accepting a `URLStringConvertible` type parameter parse it according to RFCs 1738 and 1808.
    See https://tools.ietf.org/html/rfc2396
    See https://tools.ietf.org/html/rfc1738
    See https://tools.ietf.org/html/rfc1808
    */
    var URLString: String { get }
}

extension String: URLStringConvertible {
    public var URLString: String {
        return self
    }
}

extension NSURL: URLStringConvertible {
    public var URLString: String {
        return absoluteString
    }
}

extension NSURLComponents: URLStringConvertible {
    public var URLString: String {
        return URL!.URLString
    }
}

extension NSURLRequest: URLStringConvertible {
    public var URLString: String {
        return URL!.URLString
    }
}

// MARK: - URLRequestConvertible

/**
Types adopting the `URLRequestConvertible` protocol can be used to construct URL requests.
*/
public protocol URLRequestConvertible {
    /// The URL request.
    var URLRequest: NSMutableURLRequest { get }
}

extension NSURLRequest: URLRequestConvertible {
    public var URLRequest: NSMutableURLRequest {
        return self.mutableCopy() as! NSMutableURLRequest
    }
}

// MARK: - Convenience

func URLRequest(
    method: Method,
    _ URLString: URLStringConvertible,
    headers: [String: String]? = nil)
    -> NSMutableURLRequest
{
    let mutableURLRequest = NSMutableURLRequest(URL: NSURL(string: URLString.URLString)!)
    mutableURLRequest.HTTPMethod = method.rawValue
    
    if let headers = headers {
        for (headerField, headerValue) in headers {
            mutableURLRequest.setValue(headerValue, forHTTPHeaderField: headerField)
        }
    }
    
    return mutableURLRequest
}

// MARK: - Request Methods

/**
Creates a request using the shared manager instance for the specified method, URL string, parameters, and
parameter encoding.
- parameter method:     The HTTP method.
- parameter URLString:  The URL string.
- parameter parameters: The parameters. `nil` by default.
- parameter encoding:   The parameter encoding. `.URL` by default.
- parameter headers:    The HTTP headers. `nil` by default.
- returns: The created request.
*/
public func request(
    method: Method,
    _ URLString: URLStringConvertible,
    parameters: [String: AnyObject]? = nil,
    encoding: ParameterEncoding = .URL,
    headers: [String: String]? = nil)
    -> Request
{
    return Manager.sharedInstance.request(
        method,
        URLString,
        parameters: parameters,
        encoding: encoding,
        headers: headers
    )
}

/**
Creates a request using the shared manager instance for the specified URL request.
If `startRequestsImmediately` is `true`, the request will have `resume()` called before being returned.
- parameter URLRequest: The URL request
- returns: The created request.
*/
public func request(URLRequest: URLRequestConvertible) -> Request {
    return Manager.sharedInstance.request(URLRequest.URLRequest)
}

// MARK: - Upload Methods

// MARK: File

/**
Creates an upload request using the shared manager instance for the specified method, URL string, and file.
- parameter method:    The HTTP method.
- parameter URLString: The URL string.
- parameter headers:   The HTTP headers. `nil` by default.
- parameter file:      The file to upload.
- returns: The created upload request.
*/
public func upload(
    method: Method,
    _ URLString: URLStringConvertible,
    headers: [String: String]? = nil,
    file: NSURL)
    -> Request
{
    return Manager.sharedInstance.upload(method, URLString, headers: headers, file: file)
}

/**
Creates an upload request using the shared manager instance for the specified URL request and file.
- parameter URLRequest: The URL request.
- parameter file:       The file to upload.
- returns: The created upload request.
*/
public func upload(URLRequest: URLRequestConvertible, file: NSURL) -> Request {
    return Manager.sharedInstance.upload(URLRequest, file: file)
}

// MARK: Data

/**
Creates an upload request using the shared manager instance for the specified method, URL string, and data.
- parameter method:    The HTTP method.
- parameter URLString: The URL string.
- parameter headers:   The HTTP headers. `nil` by default.
- parameter data:      The data to upload.
- returns: The created upload request.
*/
public func upload(
    method: Method,
    _ URLString: URLStringConvertible,
    headers: [String: String]? = nil,
    data: NSData)
    -> Request
{
    return Manager.sharedInstance.upload(method, URLString, headers: headers, data: data)
}

/**
Creates an upload request using the shared manager instance for the specified URL request and data.
- parameter URLRequest: The URL request.
- parameter data:       The data to upload.
- returns: The created upload request.
*/
public func upload(URLRequest: URLRequestConvertible, data: NSData) -> Request {
    return Manager.sharedInstance.upload(URLRequest, data: data)
}

// MARK: Stream

/**
Creates an upload request using the shared manager instance for the specified method, URL string, and stream.
- parameter method:    The HTTP method.
- parameter URLString: The URL string.
- parameter headers:   The HTTP headers. `nil` by default.
- parameter stream:    The stream to upload.
- returns: The created upload request.
*/
public func upload(
    method: Method,
    _ URLString: URLStringConvertible,
    headers: [String: String]? = nil,
    stream: NSInputStream)
    -> Request
{
    return Manager.sharedInstance.upload(method, URLString, headers: headers, stream: stream)
}

/**
Creates an upload request using the shared manager instance for the specified URL request and stream.
- parameter URLRequest: The URL request.
- parameter stream:     The stream to upload.
- returns: The created upload request.
*/
public func upload(URLRequest: URLRequestConvertible, stream: NSInputStream) -> Request {
    return Manager.sharedInstance.upload(URLRequest, stream: stream)
}

// MARK: MultipartFormData

/**
Creates an upload request using the shared manager instance for the specified method and URL string.
- parameter method:                  The HTTP method.
- parameter URLString:               The URL string.
- parameter headers:                 The HTTP headers. `nil` by default.
- parameter multipartFormData:       The closure used to append body parts to the `MultipartFormData`.
- parameter encodingMemoryThreshold: The encoding memory threshold in bytes.
`MultipartFormDataEncodingMemoryThreshold` by default.
- parameter encodingCompletion:      The closure called when the `MultipartFormData` encoding is complete.
*/
public func upload(
    method: Method,
    _ URLString: URLStringConvertible,
    headers: [String: String]? = nil,
    multipartFormData: MultipartFormData -> Void,
    encodingMemoryThreshold: UInt64 = Manager.MultipartFormDataEncodingMemoryThreshold,
    encodingCompletion: (Manager.MultipartFormDataEncodingResult -> Void)?)
{
    return Manager.sharedInstance.upload(
        method,
        URLString,
        headers: headers,
        multipartFormData: multipartFormData,
        encodingMemoryThreshold: encodingMemoryThreshold,
        encodingCompletion: encodingCompletion
    )
}

/**
Creates an upload request using the shared manager instance for the specified method and URL string.
- parameter URLRequest:              The URL request.
- parameter multipartFormData:       The closure used to append body parts to the `MultipartFormData`.
- parameter encodingMemoryThreshold: The encoding memory threshold in bytes.
`MultipartFormDataEncodingMemoryThreshold` by default.
- parameter encodingCompletion:      The closure called when the `MultipartFormData` encoding is complete.
*/
public func upload(
    URLRequest: URLRequestConvertible,
    multipartFormData: MultipartFormData -> Void,
    encodingMemoryThreshold: UInt64 = Manager.MultipartFormDataEncodingMemoryThreshold,
    encodingCompletion: (Manager.MultipartFormDataEncodingResult -> Void)?)
{
    return Manager.sharedInstance.upload(
        URLRequest,
        multipartFormData: multipartFormData,
        encodingMemoryThreshold: encodingMemoryThreshold,
        encodingCompletion: encodingCompletion
    )
}

// MARK: - Download Methods

// MARK: URL Request

/**
Creates a download request using the shared manager instance for the specified method and URL string.
- parameter method:      The HTTP method.
- parameter URLString:   The URL string.
- parameter parameters:  The parameters. `nil` by default.
- parameter encoding:    The parameter encoding. `.URL` by default.
- parameter headers:     The HTTP headers. `nil` by default.
- parameter destination: The closure used to determine the destination of the downloaded file.
- returns: The created download request.
*/
public func download(
    method: Method,
    _ URLString: URLStringConvertible,
    parameters: [String: AnyObject]? = nil,
    encoding: ParameterEncoding = .URL,
    headers: [String: String]? = nil,
    destination: Request.DownloadFileDestination)
    -> Request
{
    return Manager.sharedInstance.download(
        method,
        URLString,
        parameters: parameters,
        encoding: encoding,
        headers: headers,
        destination: destination
    )
}

/**
Creates a download request using the shared manager instance for the specified URL request.
- parameter URLRequest:  The URL request.
- parameter destination: The closure used to determine the destination of the downloaded file.
- returns: The created download request.
*/
public func download(URLRequest: URLRequestConvertible, destination: Request.DownloadFileDestination) -> Request {
    return Manager.sharedInstance.download(URLRequest, destination: destination)
}

// MARK: Resume Data

/**
Creates a request using the shared manager instance for downloading from the resume data produced from a
previous request cancellation.
- parameter resumeData:  The resume data. This is an opaque data blob produced by `NSURLSessionDownloadTask`
when a task is cancelled. See `NSURLSession -downloadTaskWithResumeData:` for additional
information.
- parameter destination: The closure used to determine the destination of the downloaded file.
- returns: The created download request.
*/
public func download(resumeData data: NSData, destination: Request.DownloadFileDestination) -> Request {
    return Manager.sharedInstance.download(data, destination: destination)
}
/**
Responsible for creating and managing `Request` objects, as well as their underlying `NSURLSession`.
*/
public class Manager {
    
    // MARK: - Properties
    
    /**
    A shared instance of `Manager`, used by top-level Alamofire request methods, and suitable for use directly
    for any ad hoc requests.
    */
    public static let sharedInstance: Manager = {
        let configuration = NSURLSessionConfiguration.defaultSessionConfiguration()
        configuration.HTTPAdditionalHeaders = Manager.defaultHTTPHeaders
        
        return Manager(configuration: configuration)
        }()
    
    /**
    Creates default values for the "Accept-Encoding", "Accept-Language" and "User-Agent" headers.
    */
    public static let defaultHTTPHeaders: [String: String] = {
        // Accept-Encoding HTTP Header; see https://tools.ietf.org/html/rfc7230#section-4.2.3
        let acceptEncoding: String = "gzip;q=1.0,compress;q=0.5"
        
        // Accept-Language HTTP Header; see https://tools.ietf.org/html/rfc7231#section-5.3.5
        let acceptLanguage: String = {
            var components: [String] = []
            for (index, languageCode) in (NSLocale.preferredLanguages() as [String]).enumerate() {
                let q = 1.0 - (Double(index) * 0.1)
                components.append("\(languageCode);q=\(q)")
                if q <= 0.5 {
                    break
                }
            }
            
            return components.joinWithSeparator(",")
            }()
        
        // User-Agent Header; see https://tools.ietf.org/html/rfc7231#section-5.5.3
        let userAgent: String = {
            if let info = NSBundle.mainBundle().infoDictionary {
                let executable: AnyObject = info[kCFBundleExecutableKey as String] ?? "Unknown"
                let bundle: AnyObject = info[kCFBundleIdentifierKey as String] ?? "Unknown"
                let version: AnyObject = info[kCFBundleVersionKey as String] ?? "Unknown"
                let os: AnyObject = NSProcessInfo.processInfo().operatingSystemVersionString ?? "Unknown"
                
                var mutableUserAgent = NSMutableString(string: "\(executable)/\(bundle) (\(version); OS \(os))") as CFMutableString
                let transform = NSString(string: "Any-Latin; Latin-ASCII; [:^ASCII:] Remove") as CFString
                
                if CFStringTransform(mutableUserAgent, UnsafeMutablePointer<CFRange>(nil), transform, false) {
                    return mutableUserAgent as String
                }
            }
            
            return "Alamofire"
            }()
        
        return [
            "Accept-Encoding": acceptEncoding,
            "Accept-Language": acceptLanguage,
            "User-Agent": userAgent
        ]
        }()
    
    let queue = dispatch_queue_create(nil, DISPATCH_QUEUE_SERIAL)
    
    /// The underlying session.
    public let session: NSURLSession
    
    /// The session delegate handling all the task and session delegate callbacks.
    public let delegate: SessionDelegate
    
    /// Whether to start requests immediately after being constructed. `true` by default.
    public var startRequestsImmediately: Bool = true
    
    /**
    The background completion handler closure provided by the UIApplicationDelegate
    `application:handleEventsForBackgroundURLSession:completionHandler:` method. By setting the background
    completion handler, the SessionDelegate `sessionDidFinishEventsForBackgroundURLSession` closure implementation
    will automatically call the handler.
    
    If you need to handle your own events before the handler is called, then you need to override the
    SessionDelegate `sessionDidFinishEventsForBackgroundURLSession` and manually call the handler when finished.
    
    `nil` by default.
    */
    public var backgroundCompletionHandler: (() -> Void)?
    
    // MARK: - Lifecycle
    
    /**
    Initializes the `Manager` instance with the specified configuration, delegate and server trust policy.
    - parameter configuration:            The configuration used to construct the managed session.
    `NSURLSessionConfiguration.defaultSessionConfiguration()` by default.
    - parameter delegate:                 The delegate used when initializing the session. `SessionDelegate()` by
    default.
    - parameter serverTrustPolicyManager: The server trust policy manager to use for evaluating all server trust
    challenges. `nil` by default.
    - returns: The new `Manager` instance.
    */
    public init(
        configuration: NSURLSessionConfiguration = NSURLSessionConfiguration.defaultSessionConfiguration(),
        delegate: SessionDelegate = SessionDelegate(),
        serverTrustPolicyManager: ServerTrustPolicyManager? = nil)
    {
        self.delegate = delegate
        self.session = NSURLSession(configuration: configuration, delegate: delegate, delegateQueue: nil)
        
        commonInit(serverTrustPolicyManager: serverTrustPolicyManager)
    }
    
    /**
    Initializes the `Manager` instance with the specified session, delegate and server trust policy.
    - parameter session:                  The URL session.
    - parameter delegate:                 The delegate of the URL session. Must equal the URL session's delegate.
    - parameter serverTrustPolicyManager: The server trust policy manager to use for evaluating all server trust
    challenges. `nil` by default.
    - returns: The new `Manager` instance if the URL session's delegate matches the delegate parameter.
    */
    public init?(
        session: NSURLSession,
        delegate: SessionDelegate,
        serverTrustPolicyManager: ServerTrustPolicyManager? = nil)
    {
        self.delegate = delegate
        self.session = session
        
        guard delegate === session.delegate else { return nil }
        
        commonInit(serverTrustPolicyManager: serverTrustPolicyManager)
    }
    
    private func commonInit(serverTrustPolicyManager serverTrustPolicyManager: ServerTrustPolicyManager?) {
        session.serverTrustPolicyManager = serverTrustPolicyManager
        
        delegate.sessionDidFinishEventsForBackgroundURLSession = { [weak self] session in
            guard let strongSelf = self else { return }
            dispatch_async(dispatch_get_main_queue()) { strongSelf.backgroundCompletionHandler?() }
        }
    }
    
    deinit {
        session.invalidateAndCancel()
    }
    
    // MARK: - Request
    
    /**
    Creates a request for the specified method, URL string, parameters, parameter encoding and headers.
    - parameter method:     The HTTP method.
    - parameter URLString:  The URL string.
    - parameter parameters: The parameters. `nil` by default.
    - parameter encoding:   The parameter encoding. `.URL` by default.
    - parameter headers:    The HTTP headers. `nil` by default.
    - returns: The created request.
    */
    public func request(
        method: Method,
        _ URLString: URLStringConvertible,
        parameters: [String: AnyObject]? = nil,
        encoding: ParameterEncoding = .URL,
        headers: [String: String]? = nil)
        -> Request
    {
        let mutableURLRequest = URLRequest(method, URLString, headers: headers)
        let encodedURLRequest = encoding.encode(mutableURLRequest, parameters: parameters).0
        return request(encodedURLRequest)
    }
    
    /**
    Creates a request for the specified URL request.
    If `startRequestsImmediately` is `true`, the request will have `resume()` called before being returned.
    - parameter URLRequest: The URL request
    - returns: The created request.
    */
    public func request(URLRequest: URLRequestConvertible) -> Request {
        var dataTask: NSURLSessionDataTask!
        
        dispatch_sync(queue) {
            dataTask = self.session.dataTaskWithRequest(URLRequest.URLRequest)
        }
        
        let request = Request(session: session, task: dataTask)
        delegate[request.delegate.task] = request.delegate
        
        if startRequestsImmediately {
            request.resume()
        }
        
        return request
    }
    
    // MARK: - SessionDelegate
    
    /**
    Responsible for handling all delegate callbacks for the underlying session.
    */
    public final class SessionDelegate: NSObject, NSURLSessionDelegate, NSURLSessionTaskDelegate, NSURLSessionDataDelegate, NSURLSessionDownloadDelegate {
        private var subdelegates: [Int: Request.TaskDelegate] = [:]
        private let subdelegateQueue = dispatch_queue_create(nil, DISPATCH_QUEUE_CONCURRENT)
        
        subscript(task: NSURLSessionTask) -> Request.TaskDelegate? {
            get {
                var subdelegate: Request.TaskDelegate?
                dispatch_sync(subdelegateQueue) {
                    subdelegate = self.subdelegates[task.taskIdentifier]
                }
                
                return subdelegate
            }
            
            set {
                dispatch_barrier_async(subdelegateQueue) {
                    self.subdelegates[task.taskIdentifier] = newValue
                }
            }
        }
        
        /**
        Initializes the `SessionDelegate` instance.
        - returns: The new `SessionDelegate` instance.
        */
        public override init() {
            super.init()
        }
        
        // MARK: - NSURLSessionDelegate
        
        // MARK: Override Closures
        
        /// Overrides default behavior for NSURLSessionDelegate method `URLSession:didBecomeInvalidWithError:`.
        public var sessionDidBecomeInvalidWithError: ((NSURLSession, NSError?) -> Void)?
        
        /// Overrides default behavior for NSURLSessionDelegate method `URLSession:didReceiveChallenge:completionHandler:`.
        public var sessionDidReceiveChallenge: ((NSURLSession, NSURLAuthenticationChallenge) -> (NSURLSessionAuthChallengeDisposition, NSURLCredential?))?
        
        /// Overrides default behavior for NSURLSessionDelegate method `URLSessionDidFinishEventsForBackgroundURLSession:`.
        public var sessionDidFinishEventsForBackgroundURLSession: ((NSURLSession) -> Void)?
        
        // MARK: Delegate Methods
        
        /**
        Tells the delegate that the session has been invalidated.
        - parameter session: The session object that was invalidated.
        - parameter error:   The error that caused invalidation, or nil if the invalidation was explicit.
        */
        public func URLSession(session: NSURLSession, didBecomeInvalidWithError error: NSError?) {
            sessionDidBecomeInvalidWithError?(session, error)
        }
        
        /**
        Requests credentials from the delegate in response to a session-level authentication request from the remote server.
        - parameter session:           The session containing the task that requested authentication.
        - parameter challenge:         An object that contains the request for authentication.
        - parameter completionHandler: A handler that your delegate method must call providing the disposition and credential.
        */
        public func URLSession(
            session: NSURLSession,
            didReceiveChallenge challenge: NSURLAuthenticationChallenge,
            completionHandler: ((NSURLSessionAuthChallengeDisposition, NSURLCredential?) -> Void))
        {
            var disposition: NSURLSessionAuthChallengeDisposition = .PerformDefaultHandling
            var credential: NSURLCredential?
            
            if let sessionDidReceiveChallenge = sessionDidReceiveChallenge {
                (disposition, credential) = sessionDidReceiveChallenge(session, challenge)
            } else if challenge.protectionSpace.authenticationMethod == NSURLAuthenticationMethodServerTrust {
                let host = challenge.protectionSpace.host
                
                if let
                    serverTrustPolicy = session.serverTrustPolicyManager?.serverTrustPolicyForHost(host),
                    serverTrust = challenge.protectionSpace.serverTrust
                {
                    if serverTrustPolicy.evaluateServerTrust(serverTrust, isValidForHost: host) {
                        disposition = .UseCredential
                        credential = NSURLCredential(forTrust: serverTrust)
                    } else {
                        disposition = .CancelAuthenticationChallenge
                    }
                }
            }
            
            completionHandler(disposition, credential)
        }
        
        /**
        Tells the delegate that all messages enqueued for a session have been delivered.
        - parameter session: The session that no longer has any outstanding requests.
        */
        public func URLSessionDidFinishEventsForBackgroundURLSession(session: NSURLSession) {
            sessionDidFinishEventsForBackgroundURLSession?(session)
        }
        
        // MARK: - NSURLSessionTaskDelegate
        
        // MARK: Override Closures
        
        /// Overrides default behavior for NSURLSessionTaskDelegate method `URLSession:task:willPerformHTTPRedirection:newRequest:completionHandler:`.
        public var taskWillPerformHTTPRedirection: ((NSURLSession, NSURLSessionTask, NSHTTPURLResponse, NSURLRequest) -> NSURLRequest?)?
        
        /// Overrides default behavior for NSURLSessionTaskDelegate method `URLSession:task:didReceiveChallenge:completionHandler:`.
        public var taskDidReceiveChallenge: ((NSURLSession, NSURLSessionTask, NSURLAuthenticationChallenge) -> (NSURLSessionAuthChallengeDisposition, NSURLCredential?))?
        
        /// Overrides default behavior for NSURLSessionTaskDelegate method `URLSession:session:task:needNewBodyStream:`.
        public var taskNeedNewBodyStream: ((NSURLSession, NSURLSessionTask) -> NSInputStream!)?
        
        /// Overrides default behavior for NSURLSessionTaskDelegate method `URLSession:task:didSendBodyData:totalBytesSent:totalBytesExpectedToSend:`.
        public var taskDidSendBodyData: ((NSURLSession, NSURLSessionTask, Int64, Int64, Int64) -> Void)?
        
        /// Overrides default behavior for NSURLSessionTaskDelegate method `URLSession:task:didCompleteWithError:`.
        public var taskDidComplete: ((NSURLSession, NSURLSessionTask, NSError?) -> Void)?
        
        // MARK: Delegate Methods
        
        /**
        Tells the delegate that the remote server requested an HTTP redirect.
        - parameter session:           The session containing the task whose request resulted in a redirect.
        - parameter task:              The task whose request resulted in a redirect.
        - parameter response:          An object containing the server’s response to the original request.
        - parameter request:           A URL request object filled out with the new location.
        - parameter completionHandler: A closure that your handler should call with either the value of the request
        parameter, a modified URL request object, or NULL to refuse the redirect and
        return the body of the redirect response.
        */
        public func URLSession(
            session: NSURLSession,
            task: NSURLSessionTask,
            willPerformHTTPRedirection response: NSHTTPURLResponse,
            newRequest request: NSURLRequest,
            completionHandler: ((NSURLRequest?) -> Void))
        {
            var redirectRequest: NSURLRequest? = request
            
            if let taskWillPerformHTTPRedirection = taskWillPerformHTTPRedirection {
                redirectRequest = taskWillPerformHTTPRedirection(session, task, response, request)
            }
            
            completionHandler(redirectRequest)
        }
        
        /**
        Requests credentials from the delegate in response to an authentication request from the remote server.
        - parameter session:           The session containing the task whose request requires authentication.
        - parameter task:              The task whose request requires authentication.
        - parameter challenge:         An object that contains the request for authentication.
        - parameter completionHandler: A handler that your delegate method must call providing the disposition and credential.
        */
        public func URLSession(
            session: NSURLSession,
            task: NSURLSessionTask,
            didReceiveChallenge challenge: NSURLAuthenticationChallenge,
            completionHandler: ((NSURLSessionAuthChallengeDisposition, NSURLCredential?) -> Void))
        {
            if let taskDidReceiveChallenge = taskDidReceiveChallenge {
                completionHandler(taskDidReceiveChallenge(session, task, challenge))
            } else if let delegate = self[task] {
                delegate.URLSession(
                    session,
                    task: task,
                    didReceiveChallenge: challenge,
                    completionHandler: completionHandler
                )
            } else {
                URLSession(session, didReceiveChallenge: challenge, completionHandler: completionHandler)
            }
        }
        
        /**
        Tells the delegate when a task requires a new request body stream to send to the remote server.
        - parameter session:           The session containing the task that needs a new body stream.
        - parameter task:              The task that needs a new body stream.
        - parameter completionHandler: A completion handler that your delegate method should call with the new body stream.
        */
        public func URLSession(
            session: NSURLSession,
            task: NSURLSessionTask,
            needNewBodyStream completionHandler: ((NSInputStream?) -> Void))
        {
            if let taskNeedNewBodyStream = taskNeedNewBodyStream {
                completionHandler(taskNeedNewBodyStream(session, task))
            } else if let delegate = self[task] {
                delegate.URLSession(session, task: task, needNewBodyStream: completionHandler)
            }
        }
        
        /**
        Periodically informs the delegate of the progress of sending body content to the server.
        - parameter session:                  The session containing the data task.
        - parameter task:                     The data task.
        - parameter bytesSent:                The number of bytes sent since the last time this delegate method was called.
        - parameter totalBytesSent:           The total number of bytes sent so far.
        - parameter totalBytesExpectedToSend: The expected length of the body data.
        */
        public func URLSession(
            session: NSURLSession,
            task: NSURLSessionTask,
            didSendBodyData bytesSent: Int64,
            totalBytesSent: Int64,
            totalBytesExpectedToSend: Int64)
        {
            if let taskDidSendBodyData = taskDidSendBodyData {
                taskDidSendBodyData(session, task, bytesSent, totalBytesSent, totalBytesExpectedToSend)
            } else if let delegate = self[task] as? Request.UploadTaskDelegate {
                delegate.URLSession(
                    session,
                    task: task,
                    didSendBodyData: bytesSent,
                    totalBytesSent: totalBytesSent,
                    totalBytesExpectedToSend: totalBytesExpectedToSend
                )
            }
        }
        
        /**
        Tells the delegate that the task finished transferring data.
        - parameter session: The session containing the task whose request finished transferring data.
        - parameter task:    The task whose request finished transferring data.
        - parameter error:   If an error occurred, an error object indicating how the transfer failed, otherwise nil.
        */
        public func URLSession(session: NSURLSession, task: NSURLSessionTask, didCompleteWithError error: NSError?) {
            if let taskDidComplete = taskDidComplete {
                taskDidComplete(session, task, error)
            } else if let delegate = self[task] {
                delegate.URLSession(session, task: task, didCompleteWithError: error)
            }
            
            self[task] = nil
        }
        
        // MARK: - NSURLSessionDataDelegate
        
        // MARK: Override Closures
        
        /// Overrides default behavior for NSURLSessionDataDelegate method `URLSession:dataTask:didReceiveResponse:completionHandler:`.
        public var dataTaskDidReceiveResponse: ((NSURLSession, NSURLSessionDataTask, NSURLResponse) -> NSURLSessionResponseDisposition)?
        
        /// Overrides default behavior for NSURLSessionDataDelegate method `URLSession:dataTask:didBecomeDownloadTask:`.
        public var dataTaskDidBecomeDownloadTask: ((NSURLSession, NSURLSessionDataTask, NSURLSessionDownloadTask) -> Void)?
        
        /// Overrides default behavior for NSURLSessionDataDelegate method `URLSession:dataTask:didReceiveData:`.
        public var dataTaskDidReceiveData: ((NSURLSession, NSURLSessionDataTask, NSData) -> Void)?
        
        /// Overrides default behavior for NSURLSessionDataDelegate method `URLSession:dataTask:willCacheResponse:completionHandler:`.
        public var dataTaskWillCacheResponse: ((NSURLSession, NSURLSessionDataTask, NSCachedURLResponse) -> NSCachedURLResponse!)?
        
        // MARK: Delegate Methods
        
        /**
        Tells the delegate that the data task received the initial reply (headers) from the server.
        - parameter session:           The session containing the data task that received an initial reply.
        - parameter dataTask:          The data task that received an initial reply.
        - parameter response:          A URL response object populated with headers.
        - parameter completionHandler: A completion handler that your code calls to continue the transfer, passing a
        constant to indicate whether the transfer should continue as a data task or
        should become a download task.
        */
        public func URLSession(
            session: NSURLSession,
            dataTask: NSURLSessionDataTask,
            didReceiveResponse response: NSURLResponse,
            completionHandler: ((NSURLSessionResponseDisposition) -> Void))
        {
            var disposition: NSURLSessionResponseDisposition = .Allow
            
            if let dataTaskDidReceiveResponse = dataTaskDidReceiveResponse {
                disposition = dataTaskDidReceiveResponse(session, dataTask, response)
            }
            
            completionHandler(disposition)
        }
        
        /**
        Tells the delegate that the data task was changed to a download task.
        - parameter session:      The session containing the task that was replaced by a download task.
        - parameter dataTask:     The data task that was replaced by a download task.
        - parameter downloadTask: The new download task that replaced the data task.
        */
        public func URLSession(
            session: NSURLSession,
            dataTask: NSURLSessionDataTask,
            didBecomeDownloadTask downloadTask: NSURLSessionDownloadTask)
        {
            if let dataTaskDidBecomeDownloadTask = dataTaskDidBecomeDownloadTask {
                dataTaskDidBecomeDownloadTask(session, dataTask, downloadTask)
            } else {
                let downloadDelegate = Request.DownloadTaskDelegate(task: downloadTask)
                self[downloadTask] = downloadDelegate
            }
        }
        
        /**
        Tells the delegate that the data task has received some of the expected data.
        - parameter session:  The session containing the data task that provided data.
        - parameter dataTask: The data task that provided data.
        - parameter data:     A data object containing the transferred data.
        */
        public func URLSession(session: NSURLSession, dataTask: NSURLSessionDataTask, didReceiveData data: NSData) {
            if let dataTaskDidReceiveData = dataTaskDidReceiveData {
                dataTaskDidReceiveData(session, dataTask, data)
            } else if let delegate = self[dataTask] as? Request.DataTaskDelegate {
                delegate.URLSession(session, dataTask: dataTask, didReceiveData: data)
            }
        }
        
        /**
        Asks the delegate whether the data (or upload) task should store the response in the cache.
        - parameter session:           The session containing the data (or upload) task.
        - parameter dataTask:          The data (or upload) task.
        - parameter proposedResponse:  The default caching behavior. This behavior is determined based on the current
        caching policy and the values of certain received headers, such as the Pragma
        and Cache-Control headers.
        - parameter completionHandler: A block that your handler must call, providing either the original proposed
        response, a modified version of that response, or NULL to prevent caching the
        response. If your delegate implements this method, it must call this completion
        handler; otherwise, your app leaks memory.
        */
        public func URLSession(
            session: NSURLSession,
            dataTask: NSURLSessionDataTask,
            willCacheResponse proposedResponse: NSCachedURLResponse,
            completionHandler: ((NSCachedURLResponse?) -> Void))
        {
            if let dataTaskWillCacheResponse = dataTaskWillCacheResponse {
                completionHandler(dataTaskWillCacheResponse(session, dataTask, proposedResponse))
            } else if let delegate = self[dataTask] as? Request.DataTaskDelegate {
                delegate.URLSession(
                    session,
                    dataTask: dataTask,
                    willCacheResponse: proposedResponse,
                    completionHandler: completionHandler
                )
            } else {
                completionHandler(proposedResponse)
            }
        }
        
        // MARK: - NSURLSessionDownloadDelegate
        
        // MARK: Override Closures
        
        /// Overrides default behavior for NSURLSessionDownloadDelegate method `URLSession:downloadTask:didFinishDownloadingToURL:`.
        public var downloadTaskDidFinishDownloadingToURL: ((NSURLSession, NSURLSessionDownloadTask, NSURL) -> Void)?
        
        /// Overrides default behavior for NSURLSessionDownloadDelegate method `URLSession:downloadTask:didWriteData:totalBytesWritten:totalBytesExpectedToWrite:`.
        public var downloadTaskDidWriteData: ((NSURLSession, NSURLSessionDownloadTask, Int64, Int64, Int64) -> Void)?
        
        /// Overrides default behavior for NSURLSessionDownloadDelegate method `URLSession:downloadTask:didResumeAtOffset:expectedTotalBytes:`.
        public var downloadTaskDidResumeAtOffset: ((NSURLSession, NSURLSessionDownloadTask, Int64, Int64) -> Void)?
        
        // MARK: Delegate Methods
        
        /**
        Tells the delegate that a download task has finished downloading.
        - parameter session:      The session containing the download task that finished.
        - parameter downloadTask: The download task that finished.
        - parameter location:     A file URL for the temporary file. Because the file is temporary, you must either
        open the file for reading or move it to a permanent location in your app’s sandbox
        container directory before returning from this delegate method.
        */
        public func URLSession(
            session: NSURLSession,
            downloadTask: NSURLSessionDownloadTask,
            didFinishDownloadingToURL location: NSURL)
        {
            if let downloadTaskDidFinishDownloadingToURL = downloadTaskDidFinishDownloadingToURL {
                downloadTaskDidFinishDownloadingToURL(session, downloadTask, location)
            } else if let delegate = self[downloadTask] as? Request.DownloadTaskDelegate {
                delegate.URLSession(session, downloadTask: downloadTask, didFinishDownloadingToURL: location)
            }
        }
        
        /**
        Periodically informs the delegate about the download’s progress.
        - parameter session:                   The session containing the download task.
        - parameter downloadTask:              The download task.
        - parameter bytesWritten:              The number of bytes transferred since the last time this delegate
        method was called.
        - parameter totalBytesWritten:         The total number of bytes transferred so far.
        - parameter totalBytesExpectedToWrite: The expected length of the file, as provided by the Content-Length
        header. If this header was not provided, the value is
        `NSURLSessionTransferSizeUnknown`.
        */
        public func URLSession(
            session: NSURLSession,
            downloadTask: NSURLSessionDownloadTask,
            didWriteData bytesWritten: Int64,
            totalBytesWritten: Int64,
            totalBytesExpectedToWrite: Int64)
        {
            if let downloadTaskDidWriteData = downloadTaskDidWriteData {
                downloadTaskDidWriteData(session, downloadTask, bytesWritten, totalBytesWritten, totalBytesExpectedToWrite)
            } else if let delegate = self[downloadTask] as? Request.DownloadTaskDelegate {
                delegate.URLSession(
                    session,
                    downloadTask: downloadTask,
                    didWriteData: bytesWritten,
                    totalBytesWritten: totalBytesWritten,
                    totalBytesExpectedToWrite: totalBytesExpectedToWrite
                )
            }
        }
        
        /**
        Tells the delegate that the download task has resumed downloading.
        - parameter session:            The session containing the download task that finished.
        - parameter downloadTask:       The download task that resumed. See explanation in the discussion.
        - parameter fileOffset:         If the file's cache policy or last modified date prevents reuse of the
        existing content, then this value is zero. Otherwise, this value is an
        integer representing the number of bytes on disk that do not need to be
        retrieved again.
        - parameter expectedTotalBytes: The expected length of the file, as provided by the Content-Length header.
        If this header was not provided, the value is NSURLSessionTransferSizeUnknown.
        */
        public func URLSession(
            session: NSURLSession,
            downloadTask: NSURLSessionDownloadTask,
            didResumeAtOffset fileOffset: Int64,
            expectedTotalBytes: Int64)
        {
            if let downloadTaskDidResumeAtOffset = downloadTaskDidResumeAtOffset {
                downloadTaskDidResumeAtOffset(session, downloadTask, fileOffset, expectedTotalBytes)
            } else if let delegate = self[downloadTask] as? Request.DownloadTaskDelegate {
                delegate.URLSession(
                    session,
                    downloadTask: downloadTask,
                    didResumeAtOffset: fileOffset,
                    expectedTotalBytes: expectedTotalBytes
                )
            }
        }
        
        // MARK: - NSURLSessionStreamDelegate
        
        var _streamTaskReadClosed: Any?
        var _streamTaskWriteClosed: Any?
        var _streamTaskBetterRouteDiscovered: Any?
        var _streamTaskDidBecomeInputStream: Any?
        
        // MARK: - NSObject
        
        public override func respondsToSelector(selector: Selector) -> Bool {
            switch selector {
            case "URLSession:didBecomeInvalidWithError:":
                return sessionDidBecomeInvalidWithError != nil
            case "URLSession:didReceiveChallenge:completionHandler:":
                return sessionDidReceiveChallenge != nil
            case "URLSessionDidFinishEventsForBackgroundURLSession:":
                return sessionDidFinishEventsForBackgroundURLSession != nil
            case "URLSession:task:willPerformHTTPRedirection:newRequest:completionHandler:":
                return taskWillPerformHTTPRedirection != nil
            case "URLSession:dataTask:didReceiveResponse:completionHandler:":
                return dataTaskDidReceiveResponse != nil
            default:
                return self.dynamicType.instancesRespondToSelector(selector)
            }
        }
    }
}