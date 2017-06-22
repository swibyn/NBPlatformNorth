//
//  ViewController.m
//  NBPlatformNorthApp
//
//  Created by s on 22/05/2017.
//  Copyright © 2017 sunward. All rights reserved.
//

#import "ViewController.h"
#import "NBApisViewController.h"
#import "LogsTableViewController.h"
#import "AboutViewController.h"
@interface ViewController ()
@property (strong, nonatomic) IBOutlet UIButton *button;

@end

@implementation ViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view, typically from a nib.
}

-(void)viewWillAppear:(BOOL)animated{
    [super viewWillAppear:animated];
//    UIViewController *vc = [NBApisViewController shareNBApisViewController];
//    //    [self presentViewController:vc animated:YES completion:nil];
//    [self.navigationController showViewController:vc sender:self];
}
-(void)viewDidAppear:(BOOL)animated{
    [super viewDidAppear:animated];
//    UIViewController *vc = [NBApisViewController shareNBApisViewController];
//    //    [self presentViewController:vc animated:YES completion:nil];
//    [self.navigationController showViewController:vc sender:self];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}
- (IBAction)buttonAction:(id)sender {
    
    UIViewController *vc = [NBApisViewController shareNBApisViewController];
//    [self presentViewController:vc animated:YES completion:nil];
    [self.navigationController showViewController:vc sender:self];
}
- (IBAction)logsButtonAction:(id)sender {
    LogsTableViewController *logsTVC = [LogsTableViewController shareLogsTableViewController];
    [self.navigationController showViewController:logsTVC sender:self];
}
- (IBAction)aboutButtonAction:(id)sender {
    AboutViewController *aboutVC = [AboutViewController shareAboutViewController];
    [self.navigationController showViewController:aboutVC sender:self];
}


@end
