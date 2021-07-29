//
//  BRouterManager.m
//  Business_Pod_test
//
//  Created by flywithbug on 2021/7/27.
//

#import "BRouterManager.h"
#import <HBRouter/HBRouter-Swift.h>

@interface BRouterManager ()<HBRouterDelegate>

@end

@implementation BRouterManager


static BRouterManager *manager = nil;

+ (instancetype)shared{
    if(!manager){
        manager = [BRouterManager new];
    }
    return  manager;
}
- (instancetype)init{
    self = [super init];
    if (self) {
        [HBRouter router].deleage = self;
    }
    return  self;
}

+ (void)registRouter{
    [BRouterManager shared];
    [[HBRouter router]registRouter:@{} bundle:self.class];
}


- (void)didOpenExternal:(HBRouterAction * _Nonnull)action completion:(void (^ _Nullable)(BOOL))completion {
    
}

- (void)didOpenRouter:(HBRouterAction * _Nonnull)action {
    
}

//
- (BOOL)loginStatus:(HBRouterAction * _Nonnull)action completion:(void (^ _Nullable)(BOOL))completion {
    
    return  YES;
}

- (void)onMatchRouterAction:(HBRouterAction * _Nonnull)action viewController:(UIViewController * _Nonnull)viewController {
    
}

- (void)onMatchUnhandleRouterAction:(HBRouterAction * _Nonnull)action {
    
}

- (BOOL)shouldOpenExternal:(HBRouterAction * _Nonnull)action {
    return  YES;
}

- (BOOL)shouldOpenRouter:(HBRouterAction * _Nonnull)action {
    return  YES;
}

- (void)willOpenExternal:(HBRouterAction * _Nonnull)action {
    
}

- (void)willOpenRouter:(HBRouterAction * _Nonnull)action {
    
}

@end
