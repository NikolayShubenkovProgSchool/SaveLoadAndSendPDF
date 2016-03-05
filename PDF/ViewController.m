//
//  ViewController.m
//  PDF
//
//  Created by Nikolay Shubenkov on 05/03/16.
//  Copyright © 2016 Nikolay Shubenkov. All rights reserved.
//

#import "ViewController.h"

@import MessageUI;

@interface ViewController () <MFMailComposeViewControllerDelegate>

@property (weak, nonatomic) IBOutlet UIWebView *webView;
@property (nonatomic, strong) NSData *pdfFileToSave;
@property (nonatomic, strong) NSData *loadedPDFFile;

@end

@implementation ViewController

- (NSData *)pdfFileToSave {
    if (!_pdfFileToSave){
        NSString *pdfInAppBundle = [[NSBundle mainBundle] pathForResource:@"swift userguide"  ofType:@"pdf"];
        _pdfFileToSave = [[NSData alloc]initWithContentsOfFile:pdfInAppBundle];
    }
    NSParameterAssert(_pdfFileToSave);
    return _pdfFileToSave;
}

#pragma mark - UI Events

- (IBAction)save:(id)sender {
    
    NSData *data = self.pdfFileToSave;
    NSLog(@"Will save to : %@",[self pdfPathToSaveOrLoad]);
    [data writeToFile:[self pdfPathToSaveOrLoad] atomically:YES];
}

- (IBAction)load:(id)sender {
    self.loadedPDFFile = [NSData dataWithContentsOfFile:[self pdfPathToSaveOrLoad]];
    if (!self.loadedPDFFile){
        NSLog(@"Not found file to Load at path: %@",[self pdfPathToSaveOrLoad]);
        return;
    }
    //http://stackoverflow.com/questions/2832245/iphone-can-we-open-pdf-file-using-uiwebview
    [self.webView loadData:self.loadedPDFFile MIMEType:@"application/pdf" textEncodingName:@"UTF-8" baseURL:nil];
}

- (IBAction)sendPDF:(id)sender {

    if (!self.loadedPDFFile){
        NSLog(@"Not found file to send");
        return ;
    }
    // Email Subject
    NSString *emailTitle = @"Test Email";
    // Email Content
    NSString *messageBody = @"iOS programming is so fun!";
    // To address
    NSArray *toRecipents = [NSArray arrayWithObject:@"info@finetechnosoft.in"];
    
    MFMailComposeViewController *mc = [[MFMailComposeViewController alloc] init];
    mc.mailComposeDelegate = self;
    [mc setSubject:emailTitle];
    [mc setMessageBody:messageBody isHTML:NO];
    [mc setToRecipients:toRecipents];
    [mc addAttachmentData:self.loadedPDFFile mimeType:@"application/pdf" fileName:@"anynameYouWant.pdf"];
    
    // Present mail view controller on screen
    [self presentViewController:mc animated:YES completion:NULL];
}

#pragma mark - MFMailComposerDelegate

//http://stackoverflow.com/questions/17301000/how-to-send-an-e-mail-inside-of-an-app-in-xcode
- (void) mailComposeController:(MFMailComposeViewController *)controller didFinishWithResult:(MFMailComposeResult)result error:(NSError *)error
{
    switch (result)
    {
        case MFMailComposeResultCancelled:
            NSLog(@"Mail cancelled");
            break;
        case MFMailComposeResultSaved:
            NSLog(@"Mail saved");
            break;
        case MFMailComposeResultSent:
            NSLog(@"Mail sent");
            break;
        case MFMailComposeResultFailed:
            NSLog(@"Mail sent failure: %@", [error localizedDescription]);
            break;
        default:
            break;
    }
    
    
    // Close the Mail Interface
    [self dismissViewControllerAnimated:YES completion:NULL];
}

#pragma mark - Helpers

- (NSString *)pdfPathToSaveOrLoad {
    NSArray *paths = NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES);
    NSString *documentsPath = [paths objectAtIndex:0]; //Get the docs directory
    
    NSString *anyFileName = @"document.pdf";//можно дать любое расширение. не имеет значения
    NSString *filePath = [documentsPath stringByAppendingPathComponent:anyFileName];
    return filePath;
}


@end
