#import "LVWindow.h"

@implementation LVWindow

@synthesize document;

- (BOOL) acceptsFirstResponder
{
	return YES;
}

- (void)keyDown:(NSEvent *)event
{
	unsigned short const LEFT = 123;
	unsigned short const RIGHT = 124;
	if (event.keyCode == LEFT)
		[self.document loadImage:LVPrevious];
	else if (event.keyCode == RIGHT)
		[self.document loadImage:LVNext];
}

@end
