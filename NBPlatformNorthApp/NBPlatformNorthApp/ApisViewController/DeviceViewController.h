//
//  DeviceViewController.h
//  NBPlatformNorthApp
//
//  Created by s on 12/09/2017.
//  Copyright © 2017 sunward. All rights reserved.
//

#import "ApisViewController.h"


@class  DeviceViewController;

@protocol DeviceViewControllerDelegate <NSObject>

-(void)DeviceViewController:(DeviceViewController *)deviceViewController tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath;
-(void)DeviceViewController:(DeviceViewController *)deviceViewController AlertController:(UIAlertController *)alertController AlertAction:(UIAlertAction *)alertAction forItem:(NSDictionary *)item;
-(void)DeviceViewController:(DeviceViewController *)deviceViewController  viewDidAppear:(BOOL)animated;
-(void)DeviceViewController:(DeviceViewController *)deviceViewController  viewDidDisappear:(BOOL)animated;

@end

@interface DeviceViewController : ApisViewController

+(instancetype)shareDeviceViewController;
+(instancetype)deviceViewController;

@property (getter=GetFunApis) NSArray *funapis;
@property id<DeviceViewControllerDelegate> delegate;

@end
