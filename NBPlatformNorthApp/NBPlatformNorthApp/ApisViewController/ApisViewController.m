//
//  ApisViewController.m
//  NBPlatformNorthApp
//
//  Created by s on 22/05/2017.
//  Copyright © 2017 sunward. All rights reserved.
//

#import "ApisViewController.h"


@interface ApisViewController ()
{
}

@end



@implementation ApisViewController



- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view from its nib.
    self.tableViewDetail.hidden = YES;
   
}

-(void)viewDidAppear:(BOOL)animated{
    [super viewDidAppear:animated];
    CGRect rect = self.tableView.frame;
    int width_3 = rect.size.width /3;
    rect.origin.x = width_3;
    rect.size.width -= width_3;
    self.tableViewDetail.frame = rect;
    CGSize size = self.scrollView.contentSize;
    size.height = self.tableView.frame.size.height + self.textView.frame.size.height;
    self.scrollView.contentSize = size;
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

#pragma mark - utiles

-(void)clearlog{
    self.textView.text = nil;
}
-(void)addlog:(NSString *)logText{
    NSLog(@"%@",logText);
    self.textView.text = [NSString stringWithFormat:@"%@\n%@",self.textView.text, logText];
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
