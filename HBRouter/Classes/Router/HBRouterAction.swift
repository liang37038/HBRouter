//
//  HBURLAction.swift
//  HBRouter
//
//  Created by flywithbug on 2021/7/6.
//

import UIKit

//原生路由跳转 Action

@objcMembers  open class HBRouterAction:NSObject {
    //默认转场为push
    public var options:[HBRouterOption] = HBRouterMCache.shared().options
    
    
    /// 设置转场动画类型
    /// - Parameters:
    ///   - modal: push or present
    ///   - animation: 是否有动画
    ///   - fullScreen: 是否全屏 iOS13之后
    ///   - wrap_nc: bool  是否添加导航栏
    public func setTransition(_ modal:HBRouterOption = .push, animation:Bool = true, fullScreen:Bool = true,wrap_nc:Bool = true){
        if modal != .push && modal != .present {
            assert(false, "modal 必须为 push or present")
        }
        options = [modal]
        self.fullScreen = fullScreen
        self.wrap_nc = wrap_nc
        if fullScreen {
            options.append(.fullScreen)
        }
        if wrap_nc {
            options.append(.wrap_nc)
        }
    }
    
    private var _option:HBRouterOption = .push
    public var option:HBRouterOption {
        set{
            
            if newValue != _option {
                options.removeAll()
                options.removeAll { (opt) -> Bool in
                    return opt == _option
                }
                if self.fullScreen {
                    options.append(.fullScreen)
                }else{
                    options.removeAll { (opt) -> Bool in
                        return opt == .fullScreen
                    }
                }
                if self.wrap_nc {
                    options.append(.wrap_nc)
                }else{
                    options.removeAll { (opt) -> Bool in
                        return opt == .wrap_nc
                    }
                }
                options.append(newValue)
            }
            _option = newValue
        }
        get {
            return _option
        }
    }
    
    @objc
    public var wrapNavgClass:UINavigationController.Type?
    
    public private(set) var params = [String:Any]()
   
    
    public var fullScreen:Bool = true
    public var wrap_nc:Bool = true
    
    
    //作为外部链接打开
    public var openExternal:Bool = false
    
    //使用导航栈内已存在页面
    public var useExistPage:Bool = false
  
    //控制器链路
    public weak var from:UIViewController?
    public weak var current:UIViewController?
    public weak var next:UIViewController?
    public var target:HBRouterTarget?
    
    //转场动画
    public var animation:Bool = true
    public var needLogin:Bool = false
    
    //页面内消息接收
//    private var _messageReceivingBlock:((_ response:HBRouterResponse)->Void)? = nil
//    public  var messageReceivingBlock:((_ response:HBRouterResponse)->Void)?{
//        set{
//            #if DEBUG
//            if _messageReceivingBlock  != nil{
//                //容错处理，避免多处设置回调
//                assert(false, "此回调只能设置一次，请检查代码")
//            }
//            #else
//            #endif
//            _messageReceivingBlock = newValue
//        }
//        get{
//            return _messageReceivingBlock
//        }
//    }
    
    
    //转场或者调用完成状态回调
    private var _openStateBlock:((_ response:HBRouterResponse)->Void)? = nil
    public  var openCompleteBlock:((_ response:HBRouterResponse)->Void)?{
        set{
            #if DEBUG
            if _openStateBlock  != nil{
                //容错处理，避免多处设置回调
                assert(false, "此回调只能设置一次，请检查代码")
            }
            #else
            #endif
            _openStateBlock = newValue
        }
        get{
            return _openStateBlock
        }
    }
    //回调
    private var _callBackBlock:((_ value:Any?)->Void)? = nil
    public var callBackBlock:((_ value:Any?)->Void)? {
        set{
            #if DEBUG
            if _callBackBlock  != nil{
                //容错处理，避免多处设置回调
                assert(false, "此回调只能设置一次，请检查代码")
            }
            #else
            #endif
            
            _callBackBlock = newValue
        }
        get {
            return _callBackBlock
        }
    }
    
    
    public private(set) var url:URL?

    
    public private(set) var scheme:String?
    public private(set) var path:String?
    public private(set) var host:String?
    
    public init(url:URL) {
        super.init()
        self.initt(url: url)
    }
    
    
    
    /// 使用默认路由和host初始化action
    /// - Parameter path: router Path
    public init(path:routerPath){
        super.init()
        self.scheme = HBRouterMCache.shared().defaultRouterScheme
        self.host =  HBRouterMCache.shared().defaultRouterHost
        self.path = path
        if !path.hasPrefix("/") {
            self.path =  "/\(path)"
        }
        if path.hasSuffix("/") {
            self.path = String(self.path!.prefix(self.path!.count - 1))
        }
        self.url = URL.init(string: "\(self.scheme!)://\(self.host!)\(self.path!)")
    }
    
    public init(_ scheme:routerScheme,host:routerHost,path:routerPath){
        super.init()
        self.scheme = scheme
        self.host = host
        self.path = path
        
        //  hb:// or  hb
        if scheme.hasSuffix("://") {
            self.scheme = String(scheme.prefix(scheme.count - 3))
        }else if scheme.contains("://"){
            assert(false, "格式不正确")
        }
        
        if host.hasSuffix("/") {
            self.host = String(host.prefix(host.count - 1))
        }else if host .contains("/"){
            assert(false, "格式不正确")
        }
        if !path.hasPrefix("/") {
            self.path =  "/\(path)"
        }
        if path.hasSuffix("/") {
            self.path = String(self.path!.prefix(self.path!.count - 1))
        }
        self.url = URL.init(string: "\(scheme)://\(host)\(self.path!)")
    }
    
    //bh://router.com/path
    //hb://router.com
    //hb://
    public  init(urlPattern:routerURLPattern){
        super.init()
        
        if !urlPattern.contains("://") {
            guard let _url = URL.init(string: "\(urlPattern)://") else {
                assert(false, "不符合 urlPatter规则")
                return
            }
            self.initt(url: _url)
        }else{
            if urlPattern.components(separatedBy: "://").count != 2 {
                assert(false, "不符合 urlPatter规则")
            }
            guard let _url = URL.init(string: urlPattern) else {
                assert(false, "不符合 urlPatter规则")
                return
            }
            self.initt(url: _url)
        }
        
        
    }
    
    private func initt(url:URL){
        self.url = url
        scheme = url.scheme
        host = url.host
        path = url.path
        if scheme == nil {
            assert(false, "URL 格式不正确, 必须包含 scheme 示例：hb:// 或者 https:// ")
        }
        
        guard let para = url.queryParameters else {
            return
        }
        for item in para{
            params[item.key] = item.value
        }
    }
    
    
    public func routerURLPattern() -> routerURLPattern?{
        if let scheme = scheme {
            if let host = host {
                if let path = path {
                    return "\(scheme)://\(host)\(path)"
                }
                return "\(scheme)://\(host)"
            }
            return scheme
        }
        return nil
    }
    
    
    public func externalURL() ->URL?{
        guard var url = url else {
            return nil
        }
        for item in params{
            if let value = item.value as? String {
                url.appendQueryParameters([item.key:value])
            }
        }
        return url
    }
    
    public func toString() -> String{
        return "\(routerURLPattern() ?? "-")\nparams:\(params)"
    }
}


extension HBRouterAction{
    
   
    
    /// add params
    /// - Parameter
    public func addEntriesFromDictonary(_ entries:[String:Any]){
        for item in entries{
            self.params[item.key] = item.value
        }
    }
    
    
    public func addParamsFromURLAction(_ routerAction:HBRouterAction?) {
        if let action = routerAction {
            self.addEntriesFromDictonary(action.params)
        }
       
    }
    
    
    
    //any nil时，删除对应Key的Value值
    public func addValue(_ value:Any?, key:String?){
        if key == nil {
            return
        }
        self.params[key!] = value
    }
    
    public func removeValue(key:String?){
        if key == nil {
            return
        }
        self.params.removeValue(forKey: key!)
    }
    public func any(_ key:String)-> Any?{
        return self.params[key]
    }
    
    public func intValue(_ key:String)->Int?{
        return intValue(any(key))
    }
    
    public func doubleValue(_ key:String)->Double?{
        return doubleValue(any(key))
    }
    
    public func numberValue(_ key:String)->NSNumber?{
        return numberValue(any(key))
    }
    
    public func stringValue(_ key:String)->String?{
        return stringValue(any(key))
    }
    
    public func boolValue(_ key:String)->Bool?{
        return boolValue(any(key))
    }
    
    
    
    
    //类型自动化转换
    private func intValue(_ value:Any?) -> Int? {
        if let val = value as? Int{
            return val
        }
        if let val = value as? Bool{
            return val ? 1 : 0
        }
        
        if let val = value as? Double {
            return Int(val)
        }
        
        if let val = value as? NSNumber {
            return Int(val.intValue)
        }
        if let val = value as? String {
            return Int(val) ?? 0
        }
        return nil
    }
    
    private func doubleValue(_ value:Any?) -> Double? {
        if let val = value as? Double {
            return val
        }
        if let val = value as? Int{
            return Double(val)
        }
        if let val = value as? Bool{
            return val ? 1 : 0
        }
        if let val = value as? NSNumber {
            return val.doubleValue
        }
        if let val = value as? String {
            return Double(val)
        }
        return nil
    }
    
    
    private func stringValue(_ value:Any?) -> String? {
        if let val = value as? String {
            return val
        }
        if let val = value as? Double{
            return String.init(val)
        }
        if let val = value as? NSNumber {
            return val.stringValue
        }
        if let val = value as? Bool{
            return val ? "1" : "0"
        }
        if let val = value as? Int{
            return String.init(val)
        }
        return nil
    }
    
    private func numberValue(_ value:Any?) -> NSNumber? {
        if let val = value as? NSNumber {
            return val
        }
        if let val = value as? Int{
            return  NSNumber(value:val)
        }
        if let val = value as? Double{
            return NSNumber(value:val)
        }
        if let val = value as? Bool{
            return val ? 1 : 0
        }
        if let val = value as? String {
            if let val = Double(val) {
                return NSNumber(value: val)
            }
            return nil
        }
        return nil
    }
    private func boolValue(_ value:Any?) -> Bool?{
        if let val = value as? Bool{
            return val
        }
        return numberValue(value)?.boolValue
    }
}




//导航跳转Target
@objcMembers  open class HBRouterTarget:NSObject {
    public var  scheme:String  //scheme
    public var  host:String
    public var  path:String   //
    public var  target:String
    public var  targetClass:AnyClass?
    public var  bundle:String  //注册路由所属bundle name
    public var  url:URL?
    
    public func routerURLPattern() -> routerURLPattern{
        return "\(scheme)://\(host)\(path)"
    }
    //target 调用类型
    public var  targetType:HBTargetType

    
    /// 规则定义
    /// - Parameters:
    ///   - scheme: hb://  & hb   &   https://  & http
    ///   - host: router.com
    ///   - path: /home/page/detail
    ///   - target: 目标类
    ///   - bundle: 目标类所在库的库名
    ///   - targetType: 目标类能力类型
    public init(scheme:String,host:String,path:String,target:String,bundle:String,targetType:HBTargetType = .undefined) {
        self.scheme = scheme
        if scheme.hasSuffix("://") {
            self.scheme = String(scheme.prefix(scheme.count - 3))
        }else if scheme.contains("://"){
            assert(false, "格式不正确")
        }
        self.host = host
        if host.hasSuffix("/") {
            self.host = String(host.prefix(host.count - 1))
        }else if host.contains("/"){
            assert(false, "格式不正确")
        }
        self.path = path
        if path.hasSuffix("/") {
            self.path = String(self.path.prefix(self.path.count - 1))
        }
        if !path.hasPrefix("/"){
            self.path = "/\(self.path)"
        }
        self.target = target
        self.bundle = bundle
        self.targetType = targetType
        
        super.init()
        
        if let _url = URL.init(string: routerURLPattern()) {
            self.url = _url
        }else{
           assert(false, "\(routerURLPattern()) 注册规则(scheme://host/path)不正确，请检查注册元数据")
        }
        if let target =  HBClassFromString(string: target,bundle: bundle){
            self.targetClass = target
            if targetType == .undefined {
                if self.targetClass is UIViewController.Type{
                    self.targetType = .controller
                }
            }
        }else{
            #if DEBUG
            assert(false, "target 类型无法获取，请检查注册对象")
            #else
            #endif
           
        }
    }
    
    
    // objective-c 的bundle 为空字符
    public init(path:String,target:String,bundle:String) {
        self.scheme = HBRouterMCache.shared().defaultRouterScheme
        if scheme.hasSuffix("://") {
            self.scheme = String(scheme.prefix(scheme.count - 3))
        }else if scheme.contains("://"){
            assert(false, "格式不正确")
        }
        self.host =  HBRouterMCache.shared().defaultRouterHost
        if host.hasSuffix("/") {
            self.host = String(host.prefix(host.count - 1))
        }else if host.contains("/"){
            assert(false, "格式不正确")
        }
        self.path = path
        if path.hasSuffix("/") {
            self.path = String(self.path.prefix(self.path.count - 1))
        }
        if !path.hasPrefix("/"){
            self.path = "/\(self.path)"
        }
        self.target = target
        self.bundle = bundle
        self.targetType = .undefined
        
        super.init()
        
        if let _url = URL.init(string: routerURLPattern()) {
            self.url = _url
        }else{
           assert(false, "\(routerURLPattern()) 注册规则(scheme://host/path)不正确，请检查注册元数据")
        }
        if let target =  HBClassFromString(string: target,bundle: bundle){
            self.targetClass = target
            if targetType == .undefined {
                if self.targetClass is UIViewController.Type{
                    self.targetType = .controller
                }
            }
        }else{
            #if DEBUG
            assert(false, "target 类型无法获取，请检查注册对象")
            #else
            #endif
           
        }
    }
    
    
    // objective-c 的bundle 为空字符
    public init(path:String,target:String) {
        self.scheme = HBRouterMCache.shared().defaultRouterScheme
        if scheme.hasSuffix("://") {
            self.scheme = String(scheme.prefix(scheme.count - 3))
        }else if scheme.contains("://"){
            assert(false, "格式不正确")
        }
        self.host =  HBRouterMCache.shared().defaultRouterHost
        if host.hasSuffix("/") {
            self.host = String(host.prefix(host.count - 1))
        }else if host.contains("/"){
            assert(false, "格式不正确")
        }
        self.path = path
        if path.hasSuffix("/") {
            self.path = String(self.path.prefix(self.path.count - 1))
        }
        if !path.hasPrefix("/"){
            self.path = "/\(self.path)"
        }
        self.target = target
        self.bundle = ""
        self.targetType = .undefined
        
        super.init()
        
        if let _url = URL.init(string: routerURLPattern()) {
            self.url = _url
        }else{
           assert(false, "\(routerURLPattern()) 注册规则(scheme://host/path)不正确，请检查注册元数据")
        }
        if let target =  HBClassFromString(string: target,bundle: bundle){
            self.targetClass = target
            if targetType == .undefined {
                if self.targetClass is UIViewController.Type{
                    self.targetType = .controller
                }
            }
        }else{
            #if DEBUG
            assert(false, "target 类型无法获取，请检查注册对象")
            #else
            #endif
           
        }
    }
    
}





extension UIViewController {
    private struct AssociatedKey {
        static var routeActionIdentifier: String = "routeActionIdentifier"
        static var routeURLPatternIdentifier: String = "routeURLPatternIdentifier"
    }
    @objc
    public private(set) var routeAction:HBRouterAction?{
        get {
            return objc_getAssociatedObject(self, &AssociatedKey.routeActionIdentifier) as? HBRouterAction
        }
         set {
            objc_setAssociatedObject(self, &AssociatedKey.routeActionIdentifier, newValue, .OBJC_ASSOCIATION_RETAIN_NONATOMIC)
        }
    }
    @objc
    public private(set) var routeURLPattern:String?{
        get {
            return objc_getAssociatedObject(self, &AssociatedKey.routeURLPatternIdentifier) as? String
        }
        set {
            objc_setAssociatedObject(self, &AssociatedKey.routeURLPatternIdentifier, newValue, .OBJC_ASSOCIATION_RETAIN_NONATOMIC)
        }
    }
    
    @objc
    func setRouterAction(_ routeAction:HBRouterAction) {
        self.routeAction = routeAction
        self.routeURLPattern = routeAction.routerURLPattern()
    }
    
}



