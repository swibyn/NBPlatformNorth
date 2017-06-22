//
//  LogViewController.m
//  CaSimDemo
//
//  Created by s on 16/4/12.
//  Copyright © 2016年 Sunward. All rights reserved.
//

#import "LogViewController.h"
#import "NSDictionary+FileExtend.h"

@interface LogViewController ()<UITextViewDelegate>
{
    NSUInteger previewTextLength;
    NSUInteger showTextLength;
    BOOL reloadLog;
}

@property (strong, nonatomic) IBOutlet UITextView *textView;
@property (strong, nonatomic) IBOutlet UISlider *slider;


@end

@implementation LogViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    
    previewTextLength = 1024*2;
    showTextLength = 1024*100;
    // Do any additional setup after loading the view from its nib.
    self.title = [self.fileDict.filePath lastPathComponent];
    
    NSArray *buttons = @[[self barButtonItemForLocation],[self barButtonItemForFastForward],[self barButtonItemForFastBackward]];
    self.navigationItem.rightBarButtonItems = buttons;
    self.slider.hidden = YES;
}

-(void)viewDidAppear:(BOOL)animated
{
    [super viewDidAppear:animated];
    

    self.slider.maximumValue = self.fileDict.fileSize;
    self.slider.value = self.slider.maximumValue;
    NSString *text = [self showTextForSliderLocation:self.slider];
    self.textView.text = text;
//    NSLog(@"%@",text);
//    [self.textView scrollRangeToVisible:NSMakeRange(self.textView.text.length - 1, 1)];
    
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}
#pragma mark - IBAction
- (IBAction)sliderValueChanged:(UISlider *)sender {
    self.textView.text = [self previewTextForSliderLocation:sender];
}

- (IBAction)sliderTouchUpInside:(id)sender {
    self.textView.text = [self showTextForSliderLocation:sender];
}


#pragma mark - utils
-(UIBarButtonItem *)barButtonItemForLocation
{
    UIBarButtonItem *button = [[UIBarButtonItem alloc] initWithTitle:@" 定位 " style:UIBarButtonItemStylePlain target:self action:@selector(barButtonItemForLocationAction:)];
    return button;
}

-(void)barButtonItemForLocationAction:(UIBarButtonItem *)sender
{
    self.slider.hidden = !self.slider.hidden;
}

-(UIBarButtonItem *)barButtonItemForFastForward
{
    UIBarButtonItem *button = [[UIBarButtonItem alloc] initWithTitle:@" >> " style:UIBarButtonItemStylePlain target:self action:@selector(barButtonItemForFastForwardAction:)];
    return button;
}

-(void)barButtonItemForFastForwardAction:(UIBarButtonItem *)sender{
    self.slider.value += showTextLength*0.8;
    self.textView.text = [self showTextForSliderLocation:self.slider];
}

-(UIBarButtonItem *)barButtonItemForFastBackward
{
    UIBarButtonItem *button = [[UIBarButtonItem alloc] initWithTitle:@" << " style:UIBarButtonItemStylePlain target:self action:@selector(barButtonItemForFastBackwardAction:)];
    return button;
}

-(void)barButtonItemForFastBackwardAction:(UIBarButtonItem *)sender{
    self.slider.value -= showTextLength*0.8;
    self.textView.text = [self showTextForSliderLocation:self.slider];
}

-(NSString *)previewTextForSliderLocation:(UISlider *)slider
{
    float value = slider.value;
    if (value + previewTextLength > slider.maximumValue) {
        value = slider.maximumValue - previewTextLength;
    }
    NSData *data = [self dataForSliderLocation:value length:previewTextLength];
    return [[NSString alloc] initWithData:data encoding:NSUTF8StringEncoding];
}

-(NSString *)showTextForSliderLocation:(UISlider *)slider
{
    float value = slider.value;
    if (value + 2 * previewTextLength > slider.maximumValue) {
        value = slider.maximumValue - 2 * previewTextLength;
    }
    NSData *data = [self dataForSliderLocation:value length:showTextLength];
    return [[NSString alloc] initWithData:data encoding:NSUTF8StringEncoding];
    
}

-(NSData *)dataForSliderLocation:(float)value length:(NSUInteger)length
{
//    NSLog(@"value=%f length=%lu",value,(unsigned long)length);
    NSFileHandle *fileHandle = [NSFileHandle fileHandleForReadingAtPath:self.fileDict.filePath];
    [fileHandle seekToFileOffset:value];
    
    NSData *data = [fileHandle readDataOfLength:length];
    [fileHandle closeFile];
    return data;
}

#pragma mark - UITextViewDelegate
-(void)scrollViewDidEndDragging:(UIScrollView *)scrollView willDecelerate:(BOOL)decelerate
{
    if (scrollView.contentOffset.y < -120) {
        self.slider.value = self.slider.value - showTextLength/2;
        reloadLog = YES;
    }else if (scrollView.contentOffset.y + scrollView.bounds.size.height - 50 > scrollView.contentSize.height){
        self.slider.value = self.slider.value + showTextLength/2;
        reloadLog = YES;
    }
}
- (void)scrollViewDidEndDecelerating:(UIScrollView *)scrollView
{
    if (reloadLog) {
        reloadLog = NO;
        self.textView.text = [self showTextForSliderLocation:self.slider];
    }
}


/*
#pragma mark - Navigation

// In a storyboard-based application, you will often want to do a little preparation before navigation
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    // Get the new view controller using [segue destinationViewController].
    // Pass the selected object to the new view controller.
}
*/

-(UIInterfaceOrientationMask)supportedInterfaceOrientations
{
    return UIInterfaceOrientationMaskAll;
}

@end
