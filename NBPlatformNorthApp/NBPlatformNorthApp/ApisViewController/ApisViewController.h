//
//  ApisViewController.h
//  NBPlatformNorthApp
//
//  Created by s on 22/05/2017.
//  Copyright © 2017 sunward. All rights reserved.
//

#import <UIKit/UIKit.h>


@interface ApisViewController : UIViewController
{
    NSArray *funapis;
}
@property (strong, nonatomic) IBOutlet UIScrollView *scrollView;

@property (strong, nonatomic) IBOutlet UITableView *tableView;
@property (strong, nonatomic) IBOutlet UITextView *textView;
@property (strong, nonatomic) IBOutlet UITableView *tableViewDetail;


-(void)clearlog;

-(void)addlog:(NSString *)logText;

@end
