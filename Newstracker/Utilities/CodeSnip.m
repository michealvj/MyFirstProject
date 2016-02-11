//
//  CodeSnip.m
//  rottichennai
//
//  Created by Micheal on 01/12/15.
//  Copyright © 2015 Micheal. All rights reserved.
//

#import "CodeSnip.h"
#import "MemberIcon.h"

#define BLACKTEXTCOLOR [UIColor blackColor]
#define BLUETEXTCOLOR [UIColor colorWithRed:18.0f/255.0f green:82.0f/255.0f blue:190.0f/255.0f alpha:1.0f]
#define WHITETEXTCOLOR [UIColor whiteColor]
#define GREENTEXTCOLOR [UIColor colorWithRed:0.0f/255.0f green:154.0f/255.0f blue:112.0f/255.0f alpha:1.0f]

#define LIGHT_BLUEBGCOLOR [UIColor colorWithRed:242.0f/255.0f green:247.0f/255.0f blue:255.0f/255.0f alpha:1.0f]
#define DARK_BLUEBGCOLOR [UIColor colorWithRed:21.0f/255.0f green:88.0f/255.0f blue:200.0f/255.0f alpha:1.0f]

#define DARK_GREENBGCOLOR [UIColor colorWithRed:5.0f/255.0f green:166.0f/255.0f blue:122.0f/255.0f alpha:1.0f]
#define LIGHT_GREENBGCOLOR [UIColor colorWithRed:239.0f/255.0f green:255.0f/255.0f blue:251.0f/255.0f alpha:1.0f]

@implementation CodeSnip

+ (CodeSnip *)sharedInstance
{
    static CodeSnip *model = nil;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        model = [[CodeSnip alloc] init];
    });
    return model;
}

- (void)showAlert:(NSString *)title withMessage:(NSString *)message withTarget:(id)objname
{
    UIAlertController* alert = [UIAlertController alertControllerWithTitle:title message:message preferredStyle:UIAlertControllerStyleAlert];

    [alert addAction:[UIAlertAction actionWithTitle:@"OK" style:UIAlertActionStyleCancel handler:^(UIAlertAction * _Nonnull action) {
        
    }]];
    [objname presentViewController:alert animated:YES completion:nil];
}

- (UIAlertController *)createAlertWithAction:(NSString *)title withMessage:(NSString *)message withCancelButton:(NSString *)cancel withTarget:(id)objname
{
    UIAlertController* alert = [UIAlertController alertControllerWithTitle:title message:message preferredStyle:UIAlertControllerStyleAlert];
    if (cancel!=nil)
    {
        [alert addAction:[UIAlertAction actionWithTitle:cancel style:UIAlertActionStyleCancel handler:^(UIAlertAction * _Nonnull action) {
            
        }]];
    }
    [objname presentViewController:alert animated:YES completion:nil];
    return alert;
}


#pragma mark - Image Processing for Marker Icon

- (UIImage *)image:(UIImage*)originalImage scaledToSize:(CGSize)size
{
    //avoid redundant drawing
    if (CGSizeEqualToSize(originalImage.size, size))
    {
        return originalImage;
    }
    
    //create drawing context
    UIGraphicsBeginImageContextWithOptions(size, NO, 0.0f);
    
    //draw
    [originalImage drawInRect:CGRectMake(0.0f, 0.0f, size.width, size.height)];
    
    //capture resultant image
    UIImage *image = UIGraphicsGetImageFromCurrentImageContext();
    UIGraphicsEndImageContext();
    
    //return image
    return image;
}

- (UILabel *)customiseLabel:(UILabel *)label WithTitle:(NSString *)title WithBackground:(UIColor *)bgColor WithStroke:(UIColor *)strokeColor WithTextColor:(UIColor *)textColor
{
    label.text = [NSString stringWithFormat:@"  %@  ",title];
    [label sizeToFit];
    label.textColor = textColor;
    label.backgroundColor = bgColor;
    label.layer.cornerRadius = label.frame.size.height/2;
    label.layer.borderColor = strokeColor.CGColor;
    label.layer.borderWidth = 0.9f;
    label.layer.masksToBounds = YES;

    return label;
}

- (UILabel *)customiseCountLabel:(UILabel *)label WithTitle:(NSString *)title WithCount:(int)count WithBackground:(UIColor *)bgColor WithStroke:(UIColor *)strokeColor WithTextColor:(UIColor *)textColor
{
    label.textColor = textColor;
    label.backgroundColor = bgColor;
    label.attributedText = [self getAttributedTextWithString:title WithCount:count];
    [label sizeToFit];
    label.layer.cornerRadius = label.frame.size.height/2;
    label.layer.borderColor = strokeColor.CGColor;
    label.layer.borderWidth = 0.9f;
    label.layer.masksToBounds = YES;
    
    return label;
}

- (UILabel *)customiseGPSLabel:(UILabel *)label WithTitle:(NSString *)title WithBackground:(UIColor *)bgColor WithStroke:(UIColor *)strokeColor WithTextColor:(UIColor *)textColor
{
    label.textColor = textColor;
    label.backgroundColor = bgColor;
    label.attributedText = [self getAttributedTextWithString1:title];
    [label sizeToFit];
    label.layer.cornerRadius = label.frame.size.height/2;
    label.layer.borderColor = strokeColor.CGColor;
    label.layer.borderWidth = 0.9f;
    label.layer.masksToBounds = YES;
    
    return label;
}

- (UIImage *)convertImageFromView:(UIView *)view
{
   UIGraphicsBeginImageContextWithOptions(view.bounds.size, NO, [[UIScreen mainScreen] scale]);
    [view.layer renderInContext:UIGraphicsGetCurrentContext()];
    UIImage * icon = UIGraphicsGetImageFromCurrentImageContext();
    UIGraphicsEndImageContext();
//    icon = [[CodeSnip sharedInstance] image:icon scaledToSize:CGSizeMake(175.0, 63.0f)];
//     icon = [[CodeSnip sharedInstance] image:icon scaledToSize:CGSizeMake(54.0, 90.0f)];
    return icon;
}

- (UIImage *)getUserIconForTitle:(NSString *)title
{
    MemberIcon *memberView = [[[NSBundle mainBundle] loadNibNamed:@"MemberIcon" owner:self options:nil] objectAtIndex:1];
    
    memberView.memberNameLabel = [self customiseLabel:memberView.memberNameLabel WithTitle:title WithBackground:WHITETEXTCOLOR WithStroke:DARK_GREENBGCOLOR WithTextColor:GREENTEXTCOLOR];
    
    [self resizeMarkerFrame:memberView imageView:memberView.pinImage label:memberView.memberNameLabel];
    
    UIImage *icon = [self convertImageFromView:memberView];
    return icon;
}

- (UIImage *)getUserSelectedIconForTitle:(NSString *)title
{
    MemberIcon *memberView = [[[NSBundle mainBundle] loadNibNamed:@"MemberIcon" owner:self options:nil] objectAtIndex:1];
    
    memberView.memberNameLabel = [self customiseLabel:memberView.memberNameLabel WithTitle:title WithBackground:DARK_GREENBGCOLOR WithStroke:DARK_GREENBGCOLOR WithTextColor:WHITETEXTCOLOR];
    
    [self resizeMarkerFrame:memberView imageView:memberView.pinImage label:memberView.memberNameLabel];
    
    UIImage *icon = [self convertImageFromView:memberView];
    return icon;
}

- (void)resizeMarkerFrame:(UIView *)memberView imageView:(UIImageView *)pinImage label:(UILabel *)memberNameLabel
{
    CGRect labelFrame = memberNameLabel.frame;
    CGRect imageFrame = pinImage.frame;
    
    pinImage.frame = CGRectMake(CGRectGetMidX(labelFrame)-CGRectGetWidth(imageFrame)/2, CGRectGetMaxY(labelFrame)+5, CGRectGetWidth(imageFrame), CGRectGetHeight(imageFrame));
    memberView.frame = CGRectMake(0, 0, CGRectGetMaxX(labelFrame), CGRectGetMaxY(imageFrame));
}

- (UIImage *)getMemberIconForTitle:(NSString *)title
{
    MemberIcon *memberView = [[[NSBundle mainBundle] loadNibNamed:@"MemberIcon" owner:self options:nil] objectAtIndex:0];
    memberView.memberNameLabel = [self customiseLabel:memberView.memberNameLabel WithTitle:title WithBackground:WHITETEXTCOLOR WithStroke:DARK_BLUEBGCOLOR WithTextColor:BLUETEXTCOLOR];
    
    [self resizeMarkerFrame:memberView imageView:memberView.pinImage label:memberView.memberNameLabel];

    UIImage *icon = [self convertImageFromView:memberView];

    return icon;
}

- (UIImage *)getMemberSelectedIconForTitle:(NSString *)title
{
    MemberIcon *memberView = [[[NSBundle mainBundle] loadNibNamed:@"MemberIcon" owner:self options:nil] objectAtIndex:0];
    
    memberView.memberNameLabel = [self customiseLabel:memberView.memberNameLabel WithTitle:title WithBackground:DARK_BLUEBGCOLOR WithStroke:DARK_BLUEBGCOLOR WithTextColor:WHITETEXTCOLOR];
    
    [self resizeMarkerFrame:memberView imageView:memberView.pinImage label:memberView.memberNameLabel];
 
    UIImage *icon = [self convertImageFromView:memberView];
    return icon;
}

- (UIImage *)getUnreachMemberIconForTitle:(NSString *)title
{
    MemberIcon *memberView = [[[NSBundle mainBundle] loadNibNamed:@"MemberIcon" owner:self options:nil] objectAtIndex:2];
    
    memberView.memberNameLabel = [self customiseGPSLabel:memberView.memberNameLabel WithTitle:title WithBackground:WHITETEXTCOLOR  WithStroke:BLACKTEXTCOLOR WithTextColor:BLACKTEXTCOLOR];
    
    [self resizeMarkerFrame:memberView imageView:memberView.pinImage label:memberView.memberNameLabel];

    UIImage *icon = [self convertImageFromView:memberView];
    
    return icon;
}

- (UIImage *)getUnreachMemberSelectedIconForTitle:(NSString *)title
{
    MemberIcon *memberView = [[[NSBundle mainBundle] loadNibNamed:@"MemberIcon" owner:self options:nil] objectAtIndex:2];
    
     memberView.memberNameLabel = [self customiseGPSLabel:memberView.memberNameLabel WithTitle:title WithBackground:BLACKTEXTCOLOR WithStroke:BLACKTEXTCOLOR WithTextColor:WHITETEXTCOLOR];
    
    [self resizeMarkerFrame:memberView imageView:memberView.pinImage label:memberView.memberNameLabel];

    UIImage *icon = [self convertImageFromView:memberView];
    return icon;
}


- (UIImage *)getGroupMemberIconForTitle:(NSString *)title WithCount:(int)count
{
    MemberIcon *memberView = [[[NSBundle mainBundle] loadNibNamed:@"MemberIcon" owner:self options:nil] objectAtIndex:0];
    
    
    memberView.memberNameLabel = [self customiseCountLabel:memberView.memberNameLabel WithTitle:title WithCount:count WithBackground:WHITETEXTCOLOR WithStroke:DARK_BLUEBGCOLOR WithTextColor:BLUETEXTCOLOR];
    
    
    [self resizeMarkerFrame:memberView imageView:memberView.pinImage label:memberView.memberNameLabel];

    UIImage *icon = [self convertImageFromView:memberView];
    return icon;
}

- (UIImage *)getGroupMemberSelectedIconForTitle:(NSString *)title WithCount:(int)count
{
    MemberIcon *memberView = [[[NSBundle mainBundle] loadNibNamed:@"MemberIcon" owner:self options:nil] objectAtIndex:0];
    
    
    memberView.memberNameLabel = [self customiseCountLabel:memberView.memberNameLabel WithTitle:title WithCount:count WithBackground:DARK_BLUEBGCOLOR WithStroke:DARK_BLUEBGCOLOR WithTextColor:WHITETEXTCOLOR];
   
    [self resizeMarkerFrame:memberView imageView:memberView.pinImage label:memberView.memberNameLabel];

    UIImage *icon = [self convertImageFromView:memberView];
    return icon;
}

- (NSAttributedString *)getAttributedTextWithString:(NSString *)title WithCount:(int)count
{
    NSString *paddingSpace = @"  ";
    NSString *countText = [NSString stringWithFormat:@"+%i",count-1];
    NSString *titleText = [NSString stringWithFormat:@"%@%@  %@%@", paddingSpace, title, countText,paddingSpace];

    
    NSMutableAttributedString *attributedString = [[NSMutableAttributedString alloc] initWithString:titleText];
    [attributedString addAttribute:NSBackgroundColorAttributeName value:DARK_BLUEBGCOLOR range:NSMakeRange(title.length+paddingSpace.length+1, countText.length+paddingSpace.length+1)];
    [attributedString addAttribute:NSForegroundColorAttributeName value:WHITETEXTCOLOR range:NSMakeRange(title.length+paddingSpace.length+1, countText.length+paddingSpace.length+1)];
       
    return attributedString;
}

- (NSAttributedString *)getAttributedTextWithString1:(NSString *)title
{
    NSString *paddingSpace = @"  ";
    NSString *statusText = [NSString stringWithFormat:@"no GPS"];
    NSString *titleText = [NSString stringWithFormat:@"%@%@  %@%@", paddingSpace, title, statusText,paddingSpace];
    
    
    NSMutableAttributedString *attributedString = [[NSMutableAttributedString alloc] initWithString:titleText];
    [attributedString addAttribute:NSBackgroundColorAttributeName value:BLACKTEXTCOLOR range:NSMakeRange(title.length+paddingSpace.length+1, statusText.length+paddingSpace.length+1)];
    [attributedString addAttribute:NSForegroundColorAttributeName value:WHITETEXTCOLOR range:NSMakeRange(title.length+paddingSpace.length+1, statusText.length+paddingSpace.length+1)];
    [attributedString addAttribute:NSFontAttributeName value:[UIFont fontWithName:@"Roboto" size:10.0] range:NSMakeRange(title.length+paddingSpace.length+1, statusText.length+paddingSpace.length+1)];
    
    return attributedString;
}

@end
