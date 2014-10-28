#import "NSWindow+LVContentSize.h"

@implementation NSWindow (LVContentSize)

- (void)setContentSizeAnimated:(NSSize)size
{
	if ((self.styleMask & NSFullScreenWindowMask) == 0) {
		NSRect contentRect = [self contentRectForFrameRect:self.frame];
		double const dx = contentRect.size.width - size.width;
		double const dy = contentRect.size.height - size.height;
		contentRect.origin.x += dx * 0.5f;
		contentRect.origin.y += dy;
		contentRect.size = size;
		NSRect const frame = [self frameRectForContentRect:contentRect];
		[self setFrame:frame display:YES animate:YES];
		self.contentAspectRatio = size;
	}
}

@end
