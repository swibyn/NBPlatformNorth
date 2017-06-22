//
//  LogsTableViewController.m
//  CaSimDemo
//
//  Created by s on 16/4/12.
//  Copyright © 2016年 Sunward. All rights reserved.
//

#import "LogsTableViewController.h"
#import "KKLog.h"
#import "NSDictionary+FileExtend.h"
#import "LogViewController.h"

@interface LogsTableViewController ()

@property (nonatomic, strong) NSMutableArray *logFilesAttrs;

@end

@implementation LogsTableViewController

+(instancetype)shareLogsTableViewController
{
    static LogsTableViewController *instance = nil;
    if (!instance) {
        instance = [[LogsTableViewController alloc] initWithNibName:@"LogsTableViewController" bundle:nil];
    }
    return instance;
    
}


-(instancetype)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    self.title = @"LogFiles";
    return self;
}

- (void)viewDidLoad {
    [super viewDidLoad];
    self.navigationItem.rightBarButtonItem = [self editButtonItem];// barButtonItemForEdit];
    // Uncomment the following line to preserve selection between presentations.
    // self.clearsSelectionOnViewWillAppear = NO;
    
    // Uncomment the following line to display an Edit button in the navigation bar for this view controller.
    // self.navigationItem.rightBarButtonItem = self.editButtonItem;

}

-(void)viewDidAppear:(BOOL)animated
{
    [super viewDidAppear:animated];
    self.logFilesAttrs = [self getLogFilesAttrs];
    [self.tableView reloadData];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}
#pragma mark utils
-(NSMutableArray *)getLogFilesAttrs
{
    NSString *dict = [KKLog logDictionary];
    NSArray<NSString *> *subPaths = [[NSFileManager defaultManager] subpathsOfDirectoryAtPath:dict error:nil];
    NSMutableArray *result = [NSMutableArray array];
    for (NSString *subPath in subPaths) {
        NSString *path = [NSString stringWithFormat:@"%@%@",dict,subPath];
        
        NSDictionary *attrDict = [[NSFileManager defaultManager] attributesOfItemAtPath:path error:nil];
        NSMutableDictionary *mutableDict = [NSMutableDictionary dictionaryWithDictionary:attrDict];
//        mutableDict[@"fullPath"] = path;
        mutableDict.filePath = path;
        [result addObject:mutableDict];
    }
    return  result;
}

-(UIBarButtonItem *)barButtonItemForEdit{
    UIBarButtonItem *button = [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemEdit target:self action:@selector(barButtonItemForEditAction:)];
    return button;
}

-(void)barButtonItemForEditAction:(id)sender{
    self.tableView.editing = !self.tableView.editing;
}

#pragma mark - Table view data source

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
    return 1;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    return self.logFilesAttrs.count;
}


- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:@"cell"];
    if (!cell) {
        cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleSubtitle reuseIdentifier:@"cell"];
    }
    
    // Configure the cell...
    NSDictionary *dict = self.logFilesAttrs[indexPath.row];
    cell.textLabel.text = [dict.filePath lastPathComponent];
    cell.detailTextLabel.text = dict.fileDetail;
    
    return cell;
}



// Override to support conditional editing of the table view.
- (BOOL)tableView:(UITableView *)tableView canEditRowAtIndexPath:(NSIndexPath *)indexPath {
    // Return NO if you do not want the specified item to be editable.
    return YES;
}



// Override to support editing the table view.
- (void)tableView:(UITableView *)tableView commitEditingStyle:(UITableViewCellEditingStyle)editingStyle forRowAtIndexPath:(NSIndexPath *)indexPath {
    if (editingStyle == UITableViewCellEditingStyleDelete) {
        // Delete the row from the data source
        NSDictionary * dict = self.logFilesAttrs[indexPath.row];
        NSError *error;
//        BOOL removed =
        [[NSFileManager defaultManager] removeItemAtPath:dict.filePath error:&error];
        
        [self.logFilesAttrs removeObjectAtIndex:indexPath.row];
        [tableView deleteRowsAtIndexPaths:@[indexPath] withRowAnimation:UITableViewRowAnimationFade];
    } else if (editingStyle == UITableViewCellEditingStyleInsert) {
        // Create a new instance of the appropriate class, insert it into the array, and add a new row to the table view
    }   
}


/*
// Override to support rearranging the table view.
- (void)tableView:(UITableView *)tableView moveRowAtIndexPath:(NSIndexPath *)fromIndexPath toIndexPath:(NSIndexPath *)toIndexPath {
}
*/

/*
// Override to support conditional rearranging of the table view.
- (BOOL)tableView:(UITableView *)tableView canMoveRowAtIndexPath:(NSIndexPath *)indexPath {
    // Return NO if you do not want the item to be re-orderable.
    return YES;
}
*/


#pragma mark - Table view delegate

// In a xib-based application, navigation from a table can be handled in -tableView:didSelectRowAtIndexPath:
- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    // Navigation logic may go here, for example:
    // Create the next view controller.
    LogViewController *detailViewController = [[LogViewController alloc] initWithNibName:@"LogViewController" bundle:nil];
    
    // Pass the selected object to the new view controller.
    detailViewController.fileDict = self.logFilesAttrs[indexPath.row];
    
    // Push the view controller.
    [self.navigationController pushViewController:detailViewController animated:YES];
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
