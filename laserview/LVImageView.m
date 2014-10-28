#import "LVImageView.h"
#import "NSWindow+LVContentSize.h"

@implementation LVImageView

- (BOOL)mouseDownCanMoveWindow
{
    return YES;
}

- (void)mouseUp:(NSEvent *)event
{
	if (event.buttonNumber == 0 && event.clickCount == 2)
		[self.window setContentSizeAnimated:self.image.size];
}

- (void)drawRect:(NSRect)dirtyRect
{
	[[NSGraphicsContext currentContext] setImageInterpolation:NSImageInterpolationNone];
    [super drawRect:dirtyRect];
}

@end
