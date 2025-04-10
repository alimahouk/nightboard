//
//  SHChatBubble.m
//  Nightboard
//
//  Created by MachOSX on 8/3/13.
//
//

#import "SHChatBubble.h"

@implementation SHChatBubble

- (id)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    
    if ( self )
    {
        self.frame = frame;
        _shouldRoundImage = YES;
        isInMiniMode = NO;
        _bubbleType = SHChatBubbleTypeUser;
        _isBlocked = NO;
        _isShowingTypingIndicator = NO;
        _badgeCount = 0;
        
        [self setupView];
    }
    
    return self;
}

- (id)initWithFrame:(CGRect)frame withMiniModeEnabled:(BOOL)miniEnabled
{
    self = [super initWithFrame:frame];
    
    if ( self )
    {
        self.frame = frame;
        _shouldRoundImage = YES;
        isInMiniMode = miniEnabled;
        _isBlocked = NO;
        _isShowingTypingIndicator = NO;
        _badgeCount = 0;
        
        [self setupView];
    }
    
    return self;
}

- (id)initWithFrame:(CGRect)frame andImage:(UIImage *)theImage withMiniModeEnabled:(BOOL)miniEnabled
{
    self = [super initWithFrame:frame];
    
    if ( self )
    {
        self.frame = frame;
        _shouldRoundImage = YES;
        isInMiniMode = miniEnabled;
        _isBlocked = NO;
        _isShowingTypingIndicator = NO;
        _badgeCount = 0;
        
        [self setupView];
        
        thumbnail.image = theImage;
    }
    
    return self;
}

#pragma mark -
#pragma mark Layout the subviews.

- (void)setupView
{
    thumbnail = [[UIImageView alloc] initWithFrame:CGRectMake(0, 0, self.frame.size.width, self.frame.size.height)];
    thumbnail.opaque = YES;
    
    thumbnailFrame = [[UIImageView alloc] initWithFrame:CGRectMake(-self.frame.size.width / 4.6, -self.frame.size.width / 4.6, self.frame.size.width + self.frame.size.width / 2.3, self.frame.size.height + self.frame.size.width / 2.3)]; // Must use relativistic values here.
    thumbnailFrame.opaque = YES;
    
    statusFrame = [[UIImageView alloc] initWithFrame:thumbnailFrame.frame];
    statusFrame.alpha = 0.0;
    statusFrame.opaque = YES;
    statusFrame.hidden = YES;
    
    label = [[UILabel alloc] initWithFrame:CGRectMake(-10, self.frame.size.height + 5, self.frame.size.width + 20, 15)];
    label.backgroundColor = [UIColor clearColor];
    label.opaque = YES;
    
    notificationBadge = [[UIImageView alloc] init];
    notificationBadge.image = [[UIImage imageNamed:@"notification_badge"] stretchableImageWithLeftCapWidth:14 topCapHeight:14];
    notificationBadge.opaque = YES;
    notificationBadge.alpha = 0.0;
    notificationBadge.hidden = YES;
    
    badgeCountLabel = [[UILabel alloc] init];
    badgeCountLabel.backgroundColor = [UIColor clearColor];
    badgeCountLabel.opaque = YES;
    badgeCountLabel.textColor = [UIColor whiteColor];
    badgeCountLabel.textAlignment = NSTextAlignmentCenter;
    badgeCountLabel.minimumScaleFactor = 8.0 / MIN_MAIN_FONT_SIZE;
    badgeCountLabel.adjustsFontSizeToFitWidth = YES;
    badgeCountLabel.numberOfLines = 1;
    
    if ( isInMiniMode )
    {
        thumbnailFrame.image = [UIImage imageNamed:@"bubble_frame_small"];
        
        notificationBadge.frame = CGRectMake(self.frame.size.width + 6, -6, 21, 21);
        
        badgeCountLabel.frame = CGRectMake(0, 0, notificationBadge.frame.size.width, notificationBadge.frame.size.height);
        badgeCountLabel.font = [UIFont fontWithName:@"HelveticaNeue-Light" size:SECONDARY_FONT_SIZE];
    }
    else
    {
        blockFrame = [[UIImageView alloc] initWithFrame:thumbnailFrame.frame];
        blockFrame.image = [UIImage imageNamed:@"bubble_frame_block_big"];
        blockFrame.alpha = 0.0;
        blockFrame.opaque = YES;
        blockFrame.hidden = YES;
        
        thumbnailFrame.image = [UIImage imageNamed:@"bubble_frame_big"];
        
        notificationBadge.frame = CGRectMake(self.frame.size.width, 0, 27, 27);
        
        badgeCountLabel.frame = CGRectMake(0, -1, notificationBadge.frame.size.width, notificationBadge.frame.size.height);
        badgeCountLabel.font = [UIFont fontWithName:@"HelveticaNeue-Light" size:MIN_MAIN_FONT_SIZE];
    }
    
    [notificationBadge addSubview:badgeCountLabel];
    [self addSubview:label];
    [self addSubview:thumbnailFrame];
    [self addSubview:thumbnail];
    [self addSubview:statusFrame];
    [self addSubview:blockFrame];
    [self addSubview:notificationBadge];
    [self addTarget:self action:@selector(darkenImage) forControlEvents:UIControlEventTouchDown];
    [self addTarget:self action:@selector(didSelectBubble:) forControlEvents:UIControlEventTouchUpInside];
    [self addTarget:self action:@selector(restoreImage) forControlEvents:UIControlEventTouchCancel];
    [self addTarget:self action:@selector(restoreImage) forControlEvents:UIControlEventTouchUpOutside];
    
    gesture_longPress = [[UILongPressGestureRecognizer alloc] initWithTarget:self action:@selector(userDidTapAndHold:)];
    [self addGestureRecognizer:gesture_longPress];
}

- (void)darkenImage
{
    // Create a temporary view to act as a darkening layer
    CGRect frame = CGRectMake(0.0, 0.0, roundedImage.size.width, roundedImage.size.height);
    UIView *tempView = [[UIView alloc] initWithFrame:frame];
    tempView.backgroundColor = [UIColor blackColor];
    tempView.alpha = 0.3;
    
    // Draw the image into a new graphics context
    UIGraphicsBeginImageContext(frame.size);
    CGContextRef context = UIGraphicsGetCurrentContext();
    [roundedImage drawInRect:frame];
    
    // Flip the context vertically so we can draw the dark layer via a mask that
    // aligns with the image's alpha pixels (Quartz uses flipped coordinates)
    CGContextTranslateCTM(context, 0, frame.size.height);
    CGContextScaleCTM(context, 1.0, -1.0);
    CGContextClipToMask(context, frame, roundedImage.CGImage);
    [tempView.layer renderInContext:context];
    
    // Produce a new image from this context
    CGImageRef imageRef = CGBitmapContextCreateImage(context);
    UIImage *toReturn = [UIImage imageWithCGImage:imageRef];
    CGImageRelease(imageRef);
    UIGraphicsEndImageContext();
    
    [UIView animateWithDuration:0.25 delay:0 options:UIViewAnimationOptionBeginFromCurrentState animations:^{
        self.transform = CGAffineTransformMakeScale(0.9, 0.9);
    } completion:^(BOOL finished){
        
    }];
    
    thumbnail.image = toReturn;
}

- (void)restoreImage
{
    thumbnail.image = roundedImage;
    
    [UIView animateWithDuration:0.25 delay:0 options:UIViewAnimationOptionBeginFromCurrentState animations:^{
        self.transform = CGAffineTransformIdentity;
    } completion:^(BOOL finished){
        
    }];
}

- (void)enableMiniMode
{
    // Enable Mini Mode when the bubble is small to use smaller images & reduce overhead.
    isInMiniMode = YES;
    
    thumbnailFrame.image = [UIImage imageNamed:@"bubble_frame_small"];
}

- (void)setImage:(UIImage *)theImage
{
    if ( thumbnail.image && !isInMiniMode ) // If an image already exists, fade it out first. This only happens when not in mini mode.
    {
        [UIView animateWithDuration:0.15 delay:0 options:UIViewAnimationOptionCurveLinear animations:^{
            thumbnail.alpha = 0.0;
        } completion:^(BOOL finished){
            thumbnail.image = theImage;
            
            [self setNeedsDisplay]; // Redraw.
            
            [UIView animateWithDuration:0.15 delay:0 options:UIViewAnimationOptionCurveLinear animations:^{
                thumbnail.alpha = 1.0;
            } completion:^(BOOL finished){
                
            }];
        }];
    }
    else
    {
        thumbnail.image = theImage;
        
        [self setNeedsDisplay]; // Redraw.
    }
}

- (void)setBubbleMetadata:(NSMutableDictionary *)theMetadata
{
    if ( [theMetadata objectForKey:@"bubble_type"] )
    {
        _bubbleType = [[theMetadata objectForKey:@"bubble_type"] intValue];
        
        if ( _bubbleType == SHChatBubbleTypeBoard )
        {
            thumbnailFrame.image = [UIImage imageNamed:@"bubble_frame_rect_big"];
        }
        else
        {
            thumbnailFrame.image = [UIImage imageNamed:@"bubble_frame_big"];
        }
    }
    else
    {
        // Default type is a user.
        [theMetadata setObject:@"1" forKey:@"bubble_type"];
        _bubbleType = SHChatBubbleTypeUser;
    }
    
    _metadata = theMetadata;
}

- (void)setLabelText:(NSString *)theText
{
    labelText = theText;
    
    label.textColor = [UIColor whiteColor];
    label.textAlignment = NSTextAlignmentCenter;
    label.font = [UIFont fontWithName:@"HelveticaNeue-Light" size:SECONDARY_FONT_SIZE];
    label.minimumScaleFactor = 8.0 / SECONDARY_FONT_SIZE;
    label.adjustsFontSizeToFitWidth = YES;
    label.numberOfLines = 1;
    label.text = labelText;
}

- (void)setLabelText:(NSString *)theText withFont:(UIFont *)font
{
    [self setLabelText:theText];
    
    label.font = font;
    label.minimumScaleFactor = 8.0 / font.pointSize;
}

/*
- (void)setPresence:(SHUserPresence)thePresence animated:(BOOL)animated
{
    presence = thePresence;
    [_metadata setObject:[NSNumber numberWithInt:presence] forKey:@"status"];
    
    if ( thePresence == SHUserPresenceOffline || thePresence == SHUserPresenceOfflineMasked )
    {
        if ( animated )
        {
            [UIView animateWithDuration:0.3 delay:0 options:UIViewAnimationOptionCurveLinear animations:^{
                statusFrame.alpha = 0.0;
            } completion:^(BOOL finished){
                statusFrame.hidden = YES;
            }];
        }
        else
        {
            statusFrame.alpha = 0.0;
            statusFrame.hidden = YES;
        }
    }
    else if ( thePresence == SHUserPresenceAway )
    {
        statusFrame.hidden = NO;
        
        if ( animated )
        {
            [UIView animateWithDuration:0.3 delay:0 options:UIViewAnimationOptionCurveLinear animations:^{
                statusFrame.alpha = 0.5;
            } completion:^(BOOL finished){
                if ( isInMiniMode )
                {
                    statusFrame.image = [UIImage imageNamed:@"bubble_frame_away_small"];
                }
                else
                {
                    statusFrame.image = [UIImage imageNamed:@"bubble_frame_away_big"];
                }
                
                [UIView animateWithDuration:0.3 delay:0 options:UIViewAnimationOptionCurveLinear animations:^{
                    statusFrame.alpha = 1.0;
                } completion:^(BOOL finished){
                    
                }];
            }];
        }
        else
        {
            statusFrame.alpha = 1.0;
            
            if ( isInMiniMode )
            {
                statusFrame.image = [UIImage imageNamed:@"bubble_frame_away_small"];
            }
            else
            {
                statusFrame.image = [UIImage imageNamed:@"bubble_frame_away_big"];
            }
        }
    }
    else
    {
        statusFrame.hidden = NO;
        
        if ( animated )
        {
            [UIView animateWithDuration:0.3 delay:0 options:UIViewAnimationOptionCurveLinear animations:^{
                statusFrame.alpha = 0.5;
            } completion:^(BOOL finished){
                if ( isInMiniMode )
                {
                    statusFrame.image = [UIImage imageNamed:@"bubble_frame_online_small"];
                }
                else
                {
                    statusFrame.image = [UIImage imageNamed:@"bubble_frame_online_big"];
                }
                
                [UIView animateWithDuration:0.3 delay:0 options:UIViewAnimationOptionCurveLinear animations:^{
                    statusFrame.alpha = 1.0;
                } completion:^(BOOL finished){
                    
                }];
            }];
        }
        else
        {
            statusFrame.alpha = 1.0;
            
            if ( isInMiniMode )
            {
                statusFrame.image = [UIImage imageNamed:@"bubble_frame_online_small"];
            }
            else
            {
                statusFrame.image = [UIImage imageNamed:@"bubble_frame_online_big"];
            }
        }
    }
}*/

- (void)setBlocked:(BOOL)blocked
{
    if ( blocked )
    {
        blockFrame.hidden = NO;
        
        [UIView animateWithDuration:0.3 delay:0 options:UIViewAnimationOptionCurveLinear animations:^{
            blockFrame.alpha = 1.0;
        } completion:^(BOOL finished){
            
        }];
    }
    else
    {
        [UIView animateWithDuration:0.3 delay:0 options:UIViewAnimationOptionCurveLinear animations:^{
            blockFrame.alpha = 0.0;
        } completion:^(BOOL finished){
            blockFrame.hidden = YES;
        }];
    }
    
    _isBlocked = blocked;
}

#pragma mark -
#pragma mark Gesture handling.

- (void)userDidTapAndHold:(UILongPressGestureRecognizer *)longPress
{
    if ( longPress.state == UIGestureRecognizerStateBegan )
    {
        [self didTapAndHoldBubble:self];
        
        if ( !isInMiniMode )
        {
            [UIView animateWithDuration:0.18 delay:0 options:UIViewAnimationOptionBeginFromCurrentState animations:^{
                self.transform = CGAffineTransformMakeScale(1.4, 1.4);
            } completion:^(BOOL finished){
                [UIView animateWithDuration:0.2 delay:0 options:UIViewAnimationOptionBeginFromCurrentState animations:^{
                    self.transform = CGAffineTransformMakeScale(0.9, 0.9);
                } completion:^(BOOL finished){
                    [UIView animateWithDuration:0.25 delay:0 options:UIViewAnimationOptionBeginFromCurrentState animations:^{
                        self.transform = CGAffineTransformIdentity;
                    } completion:^(BOOL finished){
                        [self restoreImage]; // Restore the darkened thumbnail.
                    }];
                }];
            }];
        }
    }
    else
    {
        [self restoreImage]; // Restore the darkened thumbnail.
    }
}

#pragma mark -
#pragma mark SHChatBubbleDelegate methods.

- (void)didSelectBubble:(SHChatBubble *)bubble
{
    [self restoreImage]; // Restore the darkened thumbnail.
    
    if ( [_delegate respondsToSelector:@selector(didSelectBubble:)] )
    {
        [_delegate didSelectBubble:self];
    }
}

- (void)didTapAndHoldBubble:(SHChatBubble *)bubble
{
    if ( [_delegate respondsToSelector:@selector(didTapAndHoldBubble:)] )
    {
        [_delegate didTapAndHoldBubble:self];
    }
}

#pragma mark -
#pragma mark Drawing the round image mask.

- (void)drawRect:(CGRect)rect
{
    UIBezierPath *bezierPath;
    UIImage *workingCopy = thumbnail.image;
    
    if ( _bubbleType == SHChatBubbleTypeBoard )
    {
        UIView *container = [[UIView alloc] initWithFrame:CGRectMake(0, 0, 320, 320)];
        //container.backgroundColor = [UIColor blackColor];
        container.clipsToBounds = YES;
        
        UIImageView *preview = [[UIImageView alloc] initWithImage:workingCopy];
        //preview.backgroundColor = [UIColor blackColor];
        preview.contentMode = UIViewContentModeScaleAspectFill;
        preview.frame = CGRectMake(0, 0, 320, 320);
        
        // Center the preview inside the container.
        float oldWidth = workingCopy.size.width;
        float scaleFactor = container.frame.size.width / oldWidth;
        
        float newHeight = workingCopy.size.height * scaleFactor;
        
        if ( newHeight > container.frame.size.height )
        {
            int delta = fabs(newHeight - container.frame.size.height);
            preview.frame = CGRectMake(0, -delta / 2, preview.frame.size.width, preview.frame.size.height);
        }
        else
        {
            preview.frame = CGRectMake(0, 0, preview.frame.size.width, preview.frame.size.height);
        }
        
        [container addSubview:preview];
        
        // Next, we basically take a screenshot of it again.
        UIGraphicsBeginImageContext(container.bounds.size);
        [container.layer renderInContext:UIGraphicsGetCurrentContext()];
        UIImage *finalThumbnail = UIGraphicsGetImageFromCurrentImageContext();
        UIGraphicsEndImageContext();
        
        workingCopy = finalThumbnail;
        bezierPath = [UIBezierPath bezierPathWithRoundedRect:CGRectMake(0, 0, workingCopy.size.width, workingCopy.size.height) cornerRadius:50];
    }
    else
    {
        bezierPath = [UIBezierPath bezierPathWithOvalInRect:CGRectMake(0, 0, workingCopy.size.width, workingCopy.size.height)];
    }
    
    // Create an image context containing the original UIImage.
    UIGraphicsBeginImageContextWithOptions(workingCopy.size, NO, 0.0);
    
    // Clip to the bezier path and clear that portion of the image.
    CGContextRef context = UIGraphicsGetCurrentContext();
    
    CGContextAddPath(context, bezierPath.CGPath);
    CGContextClip(context);
    
    // Draw here when the context is clipped.
    [workingCopy drawAtPoint:CGPointZero];
    
    // Build a new UIImage from the image context.
    UIImage *newImage = UIGraphicsGetImageFromCurrentImageContext();
    UIGraphicsEndImageContext();
    roundedImage = newImage;
    thumbnail.image = roundedImage;
    
    [super drawRect:rect];
}

@end
