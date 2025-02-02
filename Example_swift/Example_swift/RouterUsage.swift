//
//  RouterUsage.swift
//  Example_swift
//
//  Created by flywithbug on 2021/7/22.
//

import SafariServices

import HBRouter
import Business_Pod_test


class RouterUsage {
    func handler()  {
//        send
    }
    //注册handler
    public  static func registerHandler(){
        HBRouter.shared().setDefault("hb", host: "router.com")
        HBRouter.shared().registeViewController(["http://","https://"], factory: RouterUsage.webViewControllerFactory)
//        HBRouter.shared().registeHander(["http://","https://"], factory: RouterUsage.openWebViewController)
        HBRouter.shared().registeHander(["bridge://"], factory: RouterUsage.handlerBridge)
        HBRouter.shared().registeHander(["hb://flutter.com"], factory: RouterUsage.handlerflutter)
    }
    
    public static func registRouterMapping(){
        
        HBRouter.shared().registRouter(["home_swift":"ViewController",
                                        "vc_01_oc":"ViewController01",
                                        "login":"LoginViewController",], bundleClass: RouterUsage.self)
        //注册另一个bundle中的路由
        HBRouter.shared().registRouter(HBRouter.shared().defaultRouterScheme,
                                        mapping:
                                            [
                                             "bvc_02_swift":"BViewController02",
                                            ],
                                        bundle:   "Business_Pod_test",
                                        host:     HBRouter.shared().defaultRouterHost,
                                        targetType:.undefined)
        
        
        RouterManager.registRouter()
        BRouterManager.registRouter()
    }
    
    static func handlerflutter(_ action:HBRouterAction) -> Any? {
        Dlog(action.url?.absoluteURL ?? "")
        return nil
    }
    
    
    static func webViewControllerFactory(_ action:HBRouterAction) -> UIViewController?{
        guard var url = action.url else {
            return nil
        }
        for item in action.params{
            if let value = item.value as? String {
                url.appendQueryParameters([item.key:value])
            }
        }
        action.options = [.present]
        let safar = SFSafariViewController.init(url: url)
        return safar
    }
    
    static func openWebViewController(_ action:HBRouterAction) -> Any? {
        return HBRouter.shared().openController(action)
    }
    
    static func handlerBridge(_ action:HBRouterAction) -> Any? {
//        Dlog("path:\(action.path ?? ""),host:\(action.host ?? "")")
        if let callBackBlock = action.callBackBlock {
            callBackBlock("handlerBridge")
        }
        //调用方式优化
        if action.path == "/routerActionTest" {
           return routerActionTest(action)
        }
        if action.path == "/hbRouterPushtest" {
            return hbRouterPushtest(action)
        }
        
        if action.path == "/navigationPushtest" {
            return navigationPushtest(action)
        }
        if action.path == "/matchPages" {
            return matchPages(action:action)
        }
        return nil
    }
    
    static func matchPages(action:HBRouterAction) -> Any?  {
        
        let array = HBRouter.shared().matchPages(path: "home_swift")
        action.callBackBlock?(["match":action.routerURLPattern()!,"viewControllers":array ?? []])
        return array
    }
    
    
    
    
    public static func  dataSource() -> [HBRouterAction] {
        var dataSource:[HBRouterAction] = []
        var action = HBRouterAction.init(urlPattern: "https://www.baidu.com/s?wd=name&rsv_spt=1&rsv_iqid=0xaf313311006a4028&issp=1&f=8&rsv_bp=1&rsv_idx=2&ie=utf-8&tn=baiduhome_pg&rsv_enter=1&rsv_dl=tb&rsv_sug3=12&rsv_sug1=3&rsv_sug7=100&rsv_sug2=0&rsv_btype=i&inputT=2967&rsv_sug4=3153")
        action.addValue("网页跳转测试", key: "subTitle")
        action.callBackBlock = { (value) in
            Dlog("\(value ?? "---")")
        }
        dataSource.append(action)
        
        for item in HBRouter.shared().routerMapping{
            
            let action = HBRouterAction.init(urlPattern: item.key)
            action.addValue("已注册原生路由跳转测试", key: "subTitle")
            action.callBackBlock = { (value) in
                Dlog("\(value ?? "---")")
            }
            dataSource.append(action)
        }
        dataSource.append(action)
        
         
        action = HBRouterAction.init(path:"home_swift")
        action.addValue("跳转调用测试页面", key: "subTitle")
        action.addValue(RouterUsage.bridgeDataSource(), key: "dataSource")
        dataSource.append(action)
        
        
        return dataSource
    }
    
    public static func bridgeDataSource() -> [HBRouterAction] {
        
        var dataSource:[HBRouterAction] = []
        var action = HBRouterAction.init(urlPattern: "bridge://host.com/routerActionTest")
        action.addValue("基础功能测试，HBRouterAction参数获取", key: "subTitle")
        action.callBackBlock = { (value) in
            Dlog("\(value ?? "---")")
        }
        dataSource.append(action)
        
        action = HBRouterAction.init(urlPattern: "bridge://host.com/navigationPushtest")
        action.animation = false
        action.addValue("原生连续跳转，关闭转场动画", key: "subTitle")
        action.callBackBlock = { (value) in
            Dlog("\(value ?? "---")")
        }
        dataSource.append(action)
        
        action = HBRouterAction.init(urlPattern: "bridge://host.com/navigationPushtest?a=10")
        action.animation = true
        action.addValue("原生连续跳转，打开转场动画", key: "subTitle")
        action.callBackBlock = { (value) in
            Dlog("\(value ?? "---")")
        }
        dataSource.append(action)
        
        action = HBRouterAction.init(urlPattern: "bridge://host.com/hbRouterPushtest?a=10")
        action.animation = false
        action.addValue("HBRouter 连续跳转测试,关闭转场动画", key: "subTitle")
        action.callBackBlock = { (value) in
            Dlog("\(value ?? "---")")
        }
        dataSource.append(action)
        
        action = HBRouterAction.init(urlPattern: "bridge://host.com/hbRouterPushtest?a=10")
        action.animation = true
        action.addValue("HBRouter 连续跳转测试，打开转场动画", key: "subTitle")
        action.callBackBlock = { (value) in
            Dlog("\(value ?? "---")")
        }
        dataSource.append(action)
        
        action = HBRouterAction.init(urlPattern: "bridge://host.com/matchPages?a=10")
        action.animation = true
        action.addValue("获取栈中页面", key: "subTitle")
        action.callBackBlock = { (value) in
            
            Dlog("\(value ?? "---")")
        }
        dataSource.append(action)
        return dataSource
    }
    
    
    
    
    

}

extension RouterUsage{
    
    static func hbRouterPushtest(_ _action:HBRouterAction) -> Any?{
        var action = HBRouterAction.init(path: "vc_01_oc")
        action.animation = _action.animation
        action.addValue("abc", key: "value")
        action.openCompleteBlock = { (response:HBRouterResponse) in
            Dlog("isSuccess:\(response.code == 0),value:\(response.data ?? "null")")
        }
        Dlog(HBRouter.shared().open(action: action).debugDescription)
        Dlog(HBRouter.shared().open(action: action).debugDescription)
        
        action = HBRouterAction.init(path: "vc_02_oc")
        action.animation = _action.animation
        Dlog(HBRouter.shared().open(action: action).debugDescription)
        Dlog(HBRouter.shared().open(action: action).debugDescription)
        Dlog(HBRouter.shared().open(action: action).debugDescription)
        Dlog(HBRouter.shared().open(action: action).debugDescription)
        
        
        
        return true
    }
    
    static func navigationPushtest(_ action:HBRouterAction) -> Any?{
        let nav = UIViewController.topMost?.navigationController
        let vc1 = ViewController01.init()
        
        let vc2 = ViewController02.init()
        nav?.pushViewController(vc1, animated: action.animation)
        nav?.pushViewController(vc2, animated: action.animation)
//        vc1 = ViewController01.init()
        nav?.pushViewController(vc1, animated: action.animation)
        nav?.pushViewController(vc2, animated: action.animation)

        return true
    }
    static func routerActionTest(_ action:HBRouterAction) -> Any?{
        
        Dlog("==============================routerActionTest==============================")
        
        var scheme = "https://"
        Dlog(scheme)
        scheme = String(scheme.prefix(scheme.count - 3))
        Dlog(scheme)
        
        
        
        
        
        var url:URL = URL.init(string: "http://www.baidu.com/path/home/page1?abc=1&a=10")!
        url.appendQueryParameters(["url":"https://www.baidu.com?c=2302322aaaa&d=4"])
        Dlog(url.scheme ?? "");
        Dlog(url.host ?? "");
        Dlog(url.path );
        Dlog(url.pathComponents );
        Dlog(url.relativePath)
        Dlog(url.absoluteString)
        Dlog(url.deletingAllPathComponents())
        
        Dlog(url.queryParameters as Any)
        let action:HBRouterAction = HBRouterAction(url: url)
        
        Dlog( action.stringValue("url") ?? "")
        
        Dlog(action.scheme ?? "")
        Dlog(action.host ?? "")
        Dlog(action.path ?? "")
        Dlog(action.params)

        Dlog( action.stringValue("a") ?? "")
        Dlog( action.intValue("a") ?? "")
        Dlog( action.boolValue("a") ?? "")
        Dlog( action.numberValue("a") ?? "")
        Dlog( action.doubleValue("a") ?? "")
        
        Dlog("==============================routerActionTest==============================")

        return true
    }
}
//
