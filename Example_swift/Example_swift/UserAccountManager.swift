//
//  UserAccountManager.swift
//  Example_swift
//
//  Created by flywithbug on 2021/7/30.
//

import UIKit
import HBRouter

@objcMembers class UserAccountManager: NSObject {
    
    public var loginState:Bool = false
    private static let shareInstance = UserAccountManager()
    private override init() {
        super.init()
        HBRouter.shared().deleage = self
        
    }
    @discardableResult
    public static func share() -> UserAccountManager{
        return shareInstance
    }
    func login(completion:((Bool)->Void)? = nil)  {
        //模拟登陆
        DispatchQueue.main.asyncAfter(deadline: .now() + 3) {
            self.loginState = true
            completion?(true)
        }
    }
}

extension UserAccountManager:HBRouterDelegate {
    func loginStatus(_ action: HBRouterAction, completion: ((Bool) -> Void)?) -> Bool {
        if loginState == false {
            let action = HBRouterAction.init(path:"login")
            action.options = [.present,.wrap_nc]
            action.callBackBlock = { (value) in
                completion?(value as? Bool ?? false)
            }
            HBRouter.shared().openRouterAction(action)
        }
        return self.loginState
    }
    
    func onMatchRouterAction(_ action: HBRouterAction, any: Any?) {

       
    }
    func shouldOpenRouter(_ action: HBRouterAction) -> Bool {
       
        return true
    }
    
    func willOpenRouter(_ action: HBRouterAction) {
            
    }
    
    func didOpenRouter(_ action: HBRouterAction) {
        
    }
    
    func shouldOpenExternal(_ action: HBRouterAction) -> Bool {
        return true
    }
    
    func willOpenExternal(_ action: HBRouterAction) {
        
    }
    
    func openExternal(_ action: HBRouterAction, completion: ((Bool) -> Void)?) {
        if let url = action.externalURL() {
            if #available(iOS 10.0, *) {
                UIApplication.shared.open(url, options: [:]) { (success) in
                    action.openCompleteBlock?(HBRouterResponse.init(action))
                }
            } else {
                if UIApplication.shared.openURL(url) {
                    action.openCompleteBlock?(HBRouterResponse.init(action))
                }else{
                    action.openCompleteBlock?(HBRouterResponse.init(action,code: -1))
                }
            }
        }else{
            action.openCompleteBlock?(HBRouterResponse.init(action,code: -1))
        }
    }
    
    func didOpenExternal(_ action: HBRouterAction) {
        
    }
    
    func onMatchUnhandleRouterAction(_ action: HBRouterAction) {
        
    }
    
    
    
}
