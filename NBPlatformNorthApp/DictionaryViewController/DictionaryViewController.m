//
//  DictionaryViewController.m
//  NBPlatformNorthApp
//
//  Created by s on 20/06/2017.
//  Copyright © 2017 sunward. All rights reserved.
//

#import "DictionaryViewController.h"
#import "DataDictionary.h"
//NSString *sTitle = @"Title";
//NSString *sMethod = @"Method";
//NSString *sItems = @"Items";
//NSString *sDefaultValue = @"DefaultValue";


@interface DictionaryViewController ()<UITableViewDelegate,UITableViewDataSource>

@end

@implementation DictionaryViewController

+(instancetype)shareDictionaryViewController{
    static DictionaryViewController *instance = nil;
    if (!instance) {
        instance = [[DictionaryViewController alloc] initWithNibName:@"DictionaryViewController" bundle:nil];
    }
    return instance;
}

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view from its nib.
}

-(void)dealloc{
    if (self.timer) {
        [self.timer invalidate];
    }
}

-(void)viewDidAppear:(BOOL)animated{
    [super viewDidAppear:animated];
    [self.delegate DictionaryViewController:self viewDidAppear:animated];
}

-(void)viewDidDisappear:(BOOL)animated{
    [super viewDidDisappear:animated];
    [self.delegate DictionaryViewController:self viewDidDisappear:animated];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

#pragma mark util
-(NSString *)textForIndexPath:(NSIndexPath *)indexPath{
    NSDictionary *item = (NSDictionary *)[self.showArray objectForIndexPath:indexPath];//[indexPath.section][sItems][indexPath.row];
    NSObject *value = [item valueFromDictionary:self.showData];
    NSObject *mapvalue = [item mapValueFromDictionary:self.showData];

    return [NSString stringWithFormat:@"%@: %@ %@", item[sName], value, mapvalue];
}

#pragma mark UITableViewDelegate
-(void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath{
    
    [self.delegate DictionaryViewController:self tableView:tableView didSelectRowAtIndexPath:indexPath];
    
    NSDictionary *item = (NSDictionary *)[self.showArray objectForIndexPath:indexPath];
    NSArray *options = item[sOptions];
    if (options) {
        UIAlertController *alertC = [UIAlertController alertControllerWithTitle:nil message:nil preferredStyle:UIAlertControllerStyleAlert];
        for (NSString *option in options) {
            [alertC addAction:[UIAlertAction actionWithTitle:option style:UIAlertActionStyleDefault handler:^(UIAlertAction * _Nonnull action) {
                [self.delegate DictionaryViewController:self AlertController:alertC AlertAction:action forItem:item];
            }]];
        }
        [alertC addAction:[UIAlertAction actionWithTitle:@"Cancel" style:UIAlertActionStyleCancel handler:nil]];
        [self presentViewController:alertC animated:YES completion:nil];
    }
    
}

#pragma mark UITableViewDataSource
-(NSInteger)numberOfSectionsInTableView:(UITableView *)tableView{
    return  self.showArray.count;
}

-(NSString *)tableView:(UITableView *)tableView titleForHeaderInSection:(NSInteger)section{
    return self.showArray[section][sTitle];
}
-(NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section{
    return [self.showArray[section][sItems] count];
}

-(UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath{
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:@"cell"];
    if (!cell) {
        cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleSubtitle reuseIdentifier:@"cell"];
    }
    cell.textLabel.text = [self textForIndexPath:indexPath];
    return cell;
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



@implementation NSArray (IndexPath)

-(NSObject *)objectForIndexPath:(NSIndexPath *)indexPath{
    
    return self[indexPath.section][sItems][indexPath.row];
}




@end

