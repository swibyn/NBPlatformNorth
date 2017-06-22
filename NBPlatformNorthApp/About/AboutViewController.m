//
//  AboutViewController.m
//  CaSimDemo
//
//  Created by s on 16/4/26.
//  Copyright © 2016年 Sunward. All rights reserved.
//

#import "AboutViewController.h"

@interface AboutViewController ()
@property (strong, nonatomic) IBOutlet UIWebView *webView;

@end

@implementation AboutViewController

+(instancetype)shareAboutViewController
{
    static AboutViewController *instance = nil;
    if (!instance) {
        instance = [[AboutViewController alloc] initWithNibName:@"AboutViewController" bundle:nil];
    }
    return instance;
}

-(instancetype)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    self.title = @"About";
    return self;
}

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view from its nib.
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

-(void)viewDidAppear:(BOOL)animated
{
    NSString *filePath = [[NSBundle mainBundle] pathForResource:@"about" ofType:@"html"];
    NSData *fileData = [NSData dataWithContentsOfFile:filePath];
    NSMutableString *mutableStr = [[NSMutableString alloc] initWithData:fileData encoding:NSUTF8StringEncoding];
//    [mutableStr replaceOccurrencesOfString:@"@app_Version" withString:_DEVELOP_CODE_VERSON options:NSCaseInsensitiveSearch range:NSMakeRange(0, mutableStr.length)];
    
    [self.webView loadHTMLString:mutableStr baseURL:nil];
}
/*
#pragma mark - Navigation

// In a storyboard-based application, you will often want to do a little preparation before navigation
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    // Get the new view controller using [segue destinationViewController].
    // Pass the selected object to the new view controller.
}
*/

@end
