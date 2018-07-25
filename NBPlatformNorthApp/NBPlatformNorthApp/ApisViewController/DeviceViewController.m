//
//  DeviceViewController.m
//  NBPlatformNorthApp
//
//  Created by s on 12/09/2017.
//  Copyright © 2017 sunward. All rights reserved.
//

#import "DeviceViewController.h"
#import "DataDictionary.h"
#import "NSDate_Category.h"

@interface DeviceViewController ()

@end

@implementation DeviceViewController


+(instancetype)shareDeviceViewController{
    static DeviceViewController *instance = nil;
    if (!instance) {
        instance = [[DeviceViewController alloc] initWithNibName:@"ApisViewController" bundle:nil];
    }
    return instance;
}

+(instancetype)deviceViewController{
    return [[DeviceViewController alloc] initWithNibName:@"ApisViewController" bundle:nil];
}

-(NSArray *)GetFunApis{
    return funapis;
}

-(void)setFunapis:(NSArray *)newValue{
    funapis = newValue;
}


- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
//    self.dataArray = [self testArray];
}

-(void)viewWillAppear:(BOOL)animated{
    [super viewWillAppear:animated];
    self.tableViewDetail.hidden = YES;
    self.tableViewDetail.delegate = nil;
    self.tableViewDetail.dataSource = nil;
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

/*
#pragma mark - Navigation

// In a storyboard-based application, you will often want to do a little preparation before navigation
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    // Get the new view controller using [segue destinationViewController].
    // Pass the selected object to the new view controller.
}
*/

#pragma mark - Table view data source

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
    if (tableView == self.tableView) {
        return  funapis.count;
    }
    
    return 1;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    //    NSLog(@"%s section=%d",__FUNCTION__,section);
    if (tableView == self.tableView) {
        NSArray *items = [funapis itemsForSection:section];
        return items.count;
    }
    
    return 0;
}


- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    //    NSLog(@"%s indexPath=%@",__FUNCTION__,indexPath);
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:@"cell"];
    if (!cell) {
        cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleSubtitle reuseIdentifier:@"cell"];
    }
    
    //    NSDictionary *dict = nil;
    if (tableView == self.tableView) {
        NSDictionary *dict = [funapis dictionaryForIndexPath:indexPath];
        NSArray *items = dict[sItems];
        if (items.count > 0) {
            cell.accessoryType = UITableViewCellAccessoryDetailButton;
        }else{
            cell.accessoryType = UITableViewCellAccessoryNone;
        }
        
        cell.textLabel.text = dict[sTitle];
    }
    
    //    cell.detailTextLabel.text = dict[sMethod];
    // Configure the cell...
    
    return cell;
}

-(NSString *)tableView:(UITableView *)tableView titleForHeaderInSection:(NSInteger)section{
    if (tableView == self.tableView) {
        return [funapis titleForSection:section];
    }
    
    return nil;
}

-(void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath{
    [_delegate DeviceViewController:self tableView:tableView didSelectRowAtIndexPath:indexPath];
}


#pragma mark -  UIScrollViewDelegate<NSObject>
- (void)scrollViewDidScroll:(UIScrollView *)scrollView
{   
    if (scrollView == self.tableView) {
        self.tableViewDetail.hidden = YES;
    }
    
}

@end
