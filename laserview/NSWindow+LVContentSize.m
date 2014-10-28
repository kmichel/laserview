#import "NSWindow+LVContentSize.h"

@implementation NSWindow (LVContentSize)

- (void)setContentSizeAnimated:(NSSize)size
{
	if ((self.styleMask & NSFullScreenWindowMask) == 0) {
		NSRect const screenFrame = self.screen.visibleFrame;
		NSRect const screenContent = [self contentRectForFrameRect:screenFrame];
		// First ensure our window will not be larger than the available space on screen.
		// The OS will enforce this but we must take it in account for our alignment logic.
		if (size.width > screenContent.size.width || size.height > screenContent.size.height) {
			CGFloat const contentRatio = size.width / size.height;
			CGFloat const screenContentRatio = screenContent.size.width / screenContent.size.height;
			if (contentRatio > screenContentRatio) {
				size.width = screenContent.size.width;
				size.height = size.width / contentRatio;
			} else {
				size.height = screenContent.size.height;
				size.width = size.height * contentRatio;
			}
		}
		// Then prepare and align our new frame.
		// We stay horizontally centered but keep the title bar at the same previous height.
		NSRect contentRect = [self contentRectForFrameRect:self.frame];
		CGFloat const dx = contentRect.size.width - size.width;
		CGFloat const dy = contentRect.size.height - size.height;
		// If we dont give integral coordinates we sometimes end up with
		// off-by-one errors in the final size of the window.
		contentRect.origin.x += floor(dx * 0.5f);
		contentRect.origin.y += dy;
		contentRect.size = size;
		NSRect frame = [self frameRectForContentRect:contentRect];
		// Then we ensure our window stays entirely inside the screen.
		// Beware, screen frames have non-zero origins in multi-screen environments.
		CGFloat const screenRight = screenFrame.origin.x + screenFrame.size.width;
		CGFloat const leftOffset = frame.origin.x - screenFrame.origin.x;
		CGFloat const rightOffset = screenRight - (frame.origin.x + frame.size.width);
		if (leftOffset < 0 && leftOffset + rightOffset >= 0)
			frame.origin.x = screenFrame.origin.x;
		if (rightOffset < 0 && rightOffset + leftOffset >= 0)
			frame.origin.x = screenRight- frame.size.width;
		CGFloat const screenTop = screenFrame.origin.y + screenFrame.size.height;
		CGFloat const bottomOffset = frame.origin.y - screenFrame.origin.y;
		CGFloat const topOffset = screenTop - (frame.origin.y + frame.size.height);
		if (bottomOffset < 0 && topOffset + bottomOffset >= 0)
			frame.origin.y = screenFrame.origin.y;
		if (topOffset < 0 && bottomOffset + topOffset >= 0)
			frame.origin.y = screenTop - frame.size.height;
		// And now we can commit our result.
		// ContentAspectRatio must be sent before the new frame since we don't want
		// the new frame size to be constrained by the old contentAspectRatio.
		self.contentAspectRatio = size;
		[self setFrame:frame display:YES animate:YES];
	}
}

@end
