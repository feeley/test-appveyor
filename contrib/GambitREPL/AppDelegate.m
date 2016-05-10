//
//  AppDelegate.m
//
//  Created by Marc Feeley on 11-03-06.
//  Copyright 2011-2014 Université de Montréal. All rights reserved.
//

#import "AppDelegate.h"
#import "ViewController.h"


@implementation AppDelegate

@synthesize window, viewController;


#pragma mark -
#pragma mark Application lifecycle

- (BOOL)application:(UIApplication *)application didFinishLaunchingWithOptions:(NSDictionary *)launchOptions {
 
#if 0
  UINavigationController *rootNavigationController = (UINavigationController *)self.window.rootViewController;
  ViewController *myViewController = (ViewController *)[rootNavigationController topViewController];
    // Configure myViewController.
#endif

#if 0
  [[UITabBar appearance] setShadowImage:[[UIImage alloc] init]];

  [[UINavigationBar appearance] setTranslucent:NO];
  [[UINavigationBar appearance] setBackgroundImage:[[UIImage alloc] init] forBarMetrics:UIBarMetricsDefault];
  [[UINavigationBar appearance] setShadowImage:[[UIImage alloc] init]];

  //[[UINavigationBar appearance] setShadowImage:[[UIImage alloc] init]];
#endif

  return YES;

#if 0

#if 1

  // Add the view controller's view to the window and display.
  [window addSubview:viewController.view];
  [window makeKeyAndVisible];

  return YES;

#else

    self.window = [[UIWindow alloc] initWithFrame:[[UIScreen mainScreen] bounds]];
    // Override point for customization after application launch.
	self.viewController = [[KOViewController alloc] init];
	self.window.rootViewController = self.viewController;
    [self.window makeKeyAndVisible];
    return YES;

#endif
#endif
}


- (void)applicationWillResignActive:(UIApplication *)application {
  /*
    Sent when the application is about to move from active to
    inactive state. This can occur for certain types of temporary
    interruptions (such as an incoming phone call or SMS message) or
    when the user quits the application and it begins the transition
    to the background state.

    Use this method to pause ongoing tasks, disable timers, and
    throttle down OpenGL ES frame rates. Games should use this method
    to pause the game.
  */
}


- (void)applicationDidEnterBackground:(UIApplication *)application {
  /*
    Use this method to release shared resources, save user data,
    invalidate timers, and store enough application state information
    to restore your application to its current state in case it is
    terminated later.

    If your application supports background execution, called instead
    of applicationWillTerminate: when the user quits.
  */
}


- (void)applicationWillEnterForeground:(UIApplication *)application {
  /*
    Called as part of transition from the background to the inactive
    state: here you can undo many of the changes made on entering the
    background.
  */
}


- (void)applicationDidBecomeActive:(UIApplication *)application {
  /*
    Restart any tasks that were paused (or not yet started) while the
    application was inactive. If the application was previously in
    the background, optionally refresh the user interface.
  */

  [viewController app_become_active];
}


- (void)applicationWillTerminate:(UIApplication *)application {
  /*
    Called when the application is about to terminate.

    See also applicationDidEnterBackground:.
  */
}


#pragma mark -
#pragma mark Memory management

- (void)applicationDidReceiveMemoryWarning:(UIApplication *)application {
  /*
    Free up as much memory as possible by purging cached data objects
    that can be recreated (or reloaded from disk) later.
  */
}


- (void)dealloc {

#if !__has_feature(objc_arc)
  [viewController release];
  [window release];
  [super dealloc];
#endif
}


@end
