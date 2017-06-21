//
//  DictionaryViewController.h
//  NBPlatformNorthApp
//
//  Created by s on 20/06/2017.
//  Copyright © 2017 sunward. All rights reserved.
//

#import <UIKit/UIKit.h>





@class  DictionaryViewController;

@protocol DictionaryViewControllerDelegate <NSObject>

-(void)DictionaryViewController:(DictionaryViewController *)dictionaryViewController tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath;
-(void)DictionaryViewController:(DictionaryViewController *)dictionaryViewController AlertController:(UIAlertController *)alertController AlertAction:(UIAlertAction *)alertAction forItem:(NSDictionary *)item;
-(void)DictionaryViewController:(DictionaryViewController *)dictionaryViewController  viewDidAppear:(BOOL)animated;
-(void)DictionaryViewController:(DictionaryViewController *)dictionaryViewController  viewDidDisappear:(BOOL)animated;

@end

@interface DictionaryViewController : UIViewController

+(instancetype)shareDictionaryViewController;

@property (strong, nonatomic) IBOutlet UITableView *tableView;

@property NSDictionary *showInfo;
@property NSDictionary *showData;
@property NSArray *showArray;
@property NSTimer *timer;

@property id<DictionaryViewControllerDelegate> delegate;

@end


@interface NSArray (IndexPath)

-(NSObject *)objectForIndexPath:(NSIndexPath *)indexPath;

@end
