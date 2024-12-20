//
//  LSLogViewer.m
//  LSLogViewer
//
//  Created by Leszek S on 04.09.2015.
//  Copyright (c) 2015 Leszek S. All rights reserved.
//

#import "LSLogViewer.h"

#import <MessageUI/MessageUI.h>

void LSLogf(NSString *format, ...)
{
    va_list args;
    va_start(args, format);
    NSString *line = [[NSString alloc] initWithFormat:format arguments:args];
    va_end(args);
    LSLogl(line);
}

void LSLogl(NSString *line)
{
    static NSDateFormatter *formatter = nil;
    if (!formatter)
    {
        formatter = [NSDateFormatter new];
        formatter.dateFormat = @"yyyy-MM-dd";
    }
    NSString *documentsPath = NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES).firstObject;
    NSString *dateString = [formatter stringFromDate:[NSDate new]];
    NSString *log = [NSString stringWithFormat:@"%@ %@\n", [NSDate new], line];
    NSString *path = [NSString stringWithFormat:@"%@/log-%@.txt", documentsPath, dateString];
    
    if (![[NSFileManager defaultManager] fileExistsAtPath:path])
    {
        [[NSData new] writeToFile:path atomically:YES];
        [[NSURL fileURLWithPath:path] setResourceValue:@YES forKey:NSURLIsExcludedFromBackupKey error:nil];
    }
    NSFileHandle *fileHandle = [NSFileHandle fileHandleForWritingAtPath:path];
    [fileHandle seekToEndOfFile];
    [fileHandle writeData:[log dataUsingEncoding:NSUTF8StringEncoding]];
    [fileHandle closeFile];
}

@interface LSLogViewer () <MFMailComposeViewControllerDelegate>
@property (strong, nonatomic) IBOutlet UITextView *textView;
@property (strong, nonatomic) IBOutlet UIBarButtonItem *reloadButton;
@property (strong, nonatomic) IBOutlet UITextField *searchField;
@property (assign, nonatomic) BOOL loadingLogs;
@end

@implementation LSLogViewer

#pragma mark - public

+ (void)showViewer
{
    [[self sharedInstance] showInMainWindow];
}

+ (void)hideViewer
{
    [[self sharedInstance] hideMainWindow];
}

+ (void)registerThreeFingerTripleTapGesture
{
    UITapGestureRecognizer *recognizer = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(showViewer)];
    [recognizer setNumberOfTouchesRequired:3];
    [recognizer setNumberOfTapsRequired:3];
    
    UIWindow *mainWindow = [self findMainWindow];
    [mainWindow addGestureRecognizer:recognizer];
}

#pragma mark - private

+ (instancetype)sharedInstance
{
    static id sharedInstance = nil;
    
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        sharedInstance = [[LSLogViewer alloc] init];
    });
    
    return sharedInstance;
}

+ (UIWindow *)findMainWindow
{
    UIWindow *mainWindow = nil;
    if ([UIApplication.sharedApplication respondsToSelector:@selector(keyWindow)])
        mainWindow = [UIApplication.sharedApplication keyWindow];
    if (!mainWindow && [UIApplication.sharedApplication.delegate respondsToSelector:@selector(window)])
        mainWindow = [UIApplication.sharedApplication.delegate window];
    if (!mainWindow && [UIApplication.sharedApplication respondsToSelector:@selector(windows)])
        mainWindow = [UIApplication.sharedApplication windows].firstObject;
    return mainWindow;
}

- (void)showInMainWindow
{
    if (self.presentingViewController)
        return;
    
    UIWindow *mainWindow = [LSLogViewer findMainWindow];
    self.modalPresentationStyle = UIModalPresentationOverFullScreen;
    [[mainWindow rootViewController] presentViewController:self animated:NO completion:nil];
    [self refreshLogs];
}

- (void)hideMainWindow
{
    [self dismissViewControllerAnimated:NO completion:nil];
}

#pragma mark - view controller

- (void)viewDidLoad
{
    [super viewDidLoad];
    
    self.view.backgroundColor = [UIColor blackColor];
    self.view.alpha = 0.85;
    
    UITextField *searchField = [[UITextField alloc] init];
    searchField.textColor = [UIColor greenColor];
    searchField.tintColor = [UIColor greenColor];
    searchField.translatesAutoresizingMaskIntoConstraints = NO;
    searchField.returnKeyType = UIReturnKeySearch;
    [searchField addTarget:self action:@selector(searchAction:) forControlEvents:UIControlEventEditingDidEndOnExit];
    [searchField addTarget:self action:@selector(searchEditingDidBegin:) forControlEvents:UIControlEventEditingDidBegin];
    [searchField addTarget:self action:@selector(searchEditingDidEnd:) forControlEvents:UIControlEventEditingDidEnd];
    self.searchField = searchField;
    
    UIToolbar *topToolbar = [[UIToolbar alloc] init];
    topToolbar.translucent = NO;
    topToolbar.translatesAutoresizingMaskIntoConstraints = NO;
    topToolbar.backgroundColor = [UIColor blackColor];
    topToolbar.barTintColor = [UIColor blackColor];
    
    UIBarButtonItem *ti1 = [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemSearch target:self action:@selector(searchAction:)];
    ti1.tintColor = [UIColor greenColor];
    UIBarButtonItem *ti2 = [[UIBarButtonItem alloc] initWithCustomView:self.searchField];
    UIBarButtonItem *ti3 = [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemFlexibleSpace target:nil action:nil];
    UIBarButtonItem *ti4 = [[UIBarButtonItem alloc] initWithTitle:@" ◄ " style:UIBarButtonItemStylePlain target:self action:@selector(searchBackwardAction:)];
    ti4.tintColor = [UIColor greenColor];
    UIBarButtonItem *ti5 = [[UIBarButtonItem alloc] initWithTitle:@" ► " style:UIBarButtonItemStylePlain target:self action:@selector(searchAction:)];
    ti5.tintColor = [UIColor greenColor];
    
    [topToolbar setItems:@[ti1, ti2, ti3, ti4, ti5]];
    
    UIView *topLine = [UIView new];
    topLine.translatesAutoresizingMaskIntoConstraints = NO;
    topLine.backgroundColor = [UIColor greenColor];
    
    UITextView *textView = [[UITextView alloc] init];
    textView.clipsToBounds = YES;
    textView.editable = NO;
    textView.translatesAutoresizingMaskIntoConstraints = NO;
    textView.backgroundColor = [UIColor clearColor];
    textView.textColor = [UIColor greenColor];
    textView.tintColor = [UIColor greenColor];
    textView.font = [UIFont fontWithName:@"Courier" size:12];
    self.textView = textView;
    
    UIView *bottomLine = [UIView new];
    bottomLine.translatesAutoresizingMaskIntoConstraints = NO;
    bottomLine.backgroundColor = [UIColor greenColor];
    
    UIToolbar *bottomToolbar = [[UIToolbar alloc] init];
    bottomToolbar.translucent = NO;
    bottomToolbar.translatesAutoresizingMaskIntoConstraints = NO;
    bottomToolbar.backgroundColor = [UIColor blackColor];
    bottomToolbar.barTintColor = [UIColor blackColor];

    UIBarButtonItem *bi1 = [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemCompose target:self action:@selector(emailAction:)];
    bi1.tintColor = [UIColor greenColor];
    UIBarButtonItem *bi2 = [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemRefresh target:self action:@selector(refreshAction:)];
    bi2.tintColor = [UIColor greenColor];
    UIBarButtonItem *bi3 = [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemFlexibleSpace target:nil action:nil];
    UIBarButtonItem *bi4 = [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemStop target:self action:@selector(closeAction:)];
    bi4.tintColor = [UIColor greenColor];
    self.reloadButton = bi2;
    
    [bottomToolbar setItems:@[bi1, bi2, bi3, bi4]];
    
    UIStackView *stackView = [[UIStackView alloc] initWithArrangedSubviews:@[topToolbar, topLine, self.textView, bottomLine, bottomToolbar]];
    stackView.axis = UILayoutConstraintAxisVertical;
    stackView.translatesAutoresizingMaskIntoConstraints = NO;
    stackView.backgroundColor = [UIColor clearColor];
    
    [self.view addSubview:stackView];
    [NSLayoutConstraint activateConstraints:@[
        [stackView.topAnchor constraintEqualToAnchor:self.view.safeAreaLayoutGuide.topAnchor],
        [stackView.bottomAnchor constraintEqualToAnchor:self.view.safeAreaLayoutGuide.bottomAnchor],
        [stackView.leadingAnchor constraintEqualToAnchor:self.view.safeAreaLayoutGuide.leadingAnchor],
        [stackView.trailingAnchor constraintEqualToAnchor:self.view.safeAreaLayoutGuide.trailingAnchor],
        [searchField.widthAnchor constraintGreaterThanOrEqualToConstant:150],
        [topLine.heightAnchor constraintEqualToConstant:1],
        [bottomLine.heightAnchor constraintEqualToConstant:1]
    ]];
    
    self.textView.text = @"LOADING...";
    self.searchField.attributedPlaceholder = [[NSAttributedString alloc] initWithString:@"SEARCH" attributes:@{ NSForegroundColorAttributeName: [UIColor greenColor] }];
    UITapGestureRecognizer *tapGesture = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(hideKeyboard)];
    [self.view addGestureRecognizer:tapGesture];
    
    [self refreshLogs];
}

- (void)hideKeyboard
{
    [self.view endEditing:YES];
}

- (void)refreshLogs
{
    if (self.loadingLogs)
        return;
    
    self.loadingLogs = YES;
    self.reloadButton.enabled = NO;
    [self asyncReadDeviceLogsWithCompletionBlock:^(NSString *logs) {
        self.textView.text = logs;
        self.reloadButton.enabled = YES;
        self.loadingLogs = NO;
        [self scrollToBottom];
    }];
}

- (void)scrollToBottom
{
    if (self.textView.text.length > 0)
    {
        NSRange range = NSMakeRange(self.textView.text.length - 1, 1);
        [self.textView scrollRangeToVisible:range];
    }
}

- (IBAction)searchAction:(id)sender
{
    NSString *search = self.searchField.text;
    NSString *text = self.textView.text;
    
    NSRange currentRange = self.textView.selectedRange;
    NSRange range = [text rangeOfString:search options:NSCaseInsensitiveSearch];
    
    if (currentRange.location != NSNotFound && currentRange.location + 1 <= [text length])
    {
        range = [text rangeOfString:search options:NSCaseInsensitiveSearch range:NSMakeRange(currentRange.location + 1, [text length] - currentRange.location - 1)];
    }
    
    if (range.location == NSNotFound)
    {
        range = [text rangeOfString:search options:NSCaseInsensitiveSearch];
    }
    
    if (range.location != NSNotFound)
    {
        [self.textView select:self.textView];
        self.textView.selectedRange = range;
        [self.textView scrollRangeToVisible:range];
    }
}

- (IBAction)searchBackwardAction:(id)sender
{
    NSString *search = self.searchField.text;
    NSString *text = self.textView.text;
    
    NSRange currentRange = self.textView.selectedRange;
    NSRange range = [text rangeOfString:search options:NSCaseInsensitiveSearch | NSBackwardsSearch];
    
    if (currentRange.location != NSNotFound && (NSInteger)currentRange.location - 1 >= 0)
    {
        range = [text rangeOfString:search options:NSCaseInsensitiveSearch | NSBackwardsSearch range:NSMakeRange(0, currentRange.location - 1)];
    }
    
    if (range.location == NSNotFound)
    {
        range = [text rangeOfString:search options:NSCaseInsensitiveSearch | NSBackwardsSearch];
    }
    
    if (range.location != NSNotFound)
    {
        [self.textView select:self.textView];
        self.textView.selectedRange = range;
        [self.textView scrollRangeToVisible:range];
    }
}

- (IBAction)refreshAction:(id)sender
{
    [self refreshLogs];
}

- (IBAction)emailAction:(id)sender
{
    NSString *name = [[[NSBundle mainBundle] infoDictionary] objectForKey:@"CFBundleName"];
    NSString *title = [NSString stringWithFormat:@"Logs - %@", name];
    NSString *message = [NSString stringWithFormat:@"<pre>%@</pre>", self.textView.text];
    [self composeEmailWithTitle:title message:message];
}

- (IBAction)closeAction:(id)sender
{
    [self hideMainWindow];
}

- (IBAction)searchEditingDidBegin:(id)sender
{
    self.searchField.attributedPlaceholder = nil;
}

- (IBAction)searchEditingDidEnd:(id)sender
{
    self.searchField.attributedPlaceholder = [[NSAttributedString alloc] initWithString:@"SEARCH" attributes:@{ NSForegroundColorAttributeName: [UIColor greenColor] }];
}

#pragma mark - sending email

- (void)composeEmailWithTitle:(NSString *)title message:(NSString *)message
{
    if ([MFMailComposeViewController canSendMail])
    {
        MFMailComposeViewController *mailViewController = [MFMailComposeViewController new];
        mailViewController.mailComposeDelegate = self;
        [mailViewController setSubject:title];
        [mailViewController setMessageBody:message isHTML:YES];
        [self presentViewController:mailViewController animated:YES completion:nil];
    }
    else
    {
        [[[UIAlertView alloc] initWithTitle:@"Error!" message:@"Can't send email." delegate:nil cancelButtonTitle:@"OK" otherButtonTitles:nil] show];
    }
}

- (void)mailComposeController:(MFMailComposeViewController *)controller didFinishWithResult:(MFMailComposeResult)result error:(NSError *)error
{
    if (result == MFMailComposeResultFailed)
    {
        [[[UIAlertView alloc] initWithTitle:@"Error!" message:@"Failed to send email!" delegate:nil cancelButtonTitle:@"OK" otherButtonTitles:nil] show];
    }
    
    [controller dismissViewControllerAnimated:YES completion:nil];
}

#pragma mark - logs reading

- (void)asyncReadDeviceLogsWithCompletionBlock:(void (^)(NSString *logs))completionBlock
{
    dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^{
        NSString *logs = [self readDeviceLogs];
        dispatch_async(dispatch_get_main_queue(), ^{
            if (completionBlock)
                completionBlock(logs);
        });
    });
}

- (NSString *)readDeviceLogs
{
    static NSDateFormatter *formatter = nil;
    if (!formatter)
    {
        formatter = [NSDateFormatter new];
        formatter.dateFormat = @"yyyy-MM-dd";
    }
    NSString *documentsPath = NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES).firstObject;
    NSString *dateString = [formatter stringFromDate:[NSDate new]];
    NSString *path = [NSString stringWithFormat:@"%@/log-%@.txt", documentsPath, dateString];
    
    NSString *logs = [NSString stringWithContentsOfFile:path encoding:NSUTF8StringEncoding error:nil];
    
    return logs;
}

@end
