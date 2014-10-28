#import "LVDocument.h"
#import "LVImageView.h"
#import "LVWindowController.h"
#import "NSWindow+LVContentSize.h"

@implementation LVDocument

@synthesize image;
@synthesize imageView;
@synthesize resizeWindowAfterFullscreen;

- (NSString *)windowNibName
{
	return @"LVDocument";
}

- (void)makeWindowControllers
{
	LVWindowController * const controller = [[LVWindowController alloc] initWithWindowNibName:self.windowNibName owner:self];
	[self addWindowController:controller];
}

- (void)windowControllerDidLoadNib:(NSWindowController *)controller
{
	[super windowControllerDidLoadNib:controller];
	self.imageView.image = self.image;
	NSWindow * const window = controller.window;
	window.contentSize = self.image.size;
	window.contentAspectRatio = self.image.size;
	window.movableByWindowBackground = YES;
	window.backgroundColor = [NSColor colorWithCalibratedWhite:0.391f alpha:1.0f];
	[window setDelegate:self];
}

- (void)windowDidResize:(NSNotification *) __attribute__((unused)) notification
{
	for (NSWindowController * const controller in self.windowControllers)
		[controller synchronizeWindowTitleWithDocumentName];
}

- (void)windowWillEnterFullScreen:(NSNotification *) notification
{
	NSWindow * const window = (NSWindow *) notification.object;
	window.contentAspectRatio = window.screen.frame.size;
	self.imageView.imageScaling = NSImageScaleProportionallyUpOrDown;
}

- (void)windowWillExitFullScreen:(NSNotification *) notification
{
	NSWindow * const window = (NSWindow *) notification.object;
	window.contentAspectRatio = self.image.size;
	self.imageView.imageScaling = NSImageScaleAxesIndependently;
}

- (void)windowDidExitFullScreen:(NSNotification *) notification
{
	NSWindow * const window = (NSWindow *) notification.object;
	if (self.resizeWindowAfterFullscreen) {
		self.resizeWindowAfterFullscreen = NO;
		[window setContentSizeAnimated:self.image.size];
	}
}

- (void)setImage:(NSImage *)newImage {
	image = newImage;
	self.imageView.image = newImage;
	for (NSWindowController * const controller in self.windowControllers) {
		NSWindow * const window = controller.window;
		[window setContentSizeAnimated:newImage.size];
		if ((window.styleMask & NSFullScreenWindowMask) != 0)
			self.resizeWindowAfterFullscreen = YES;
	}
}

- (void)presentedItemDidChange {
	NSLog(@"Presented item did change");
	self.image = [[NSImage alloc] initWithContentsOfURL:self.fileURL];
}

- (BOOL)readFromData:(NSData *)data
	ofType:(NSString *) __attribute__((unused)) typeName
	error:(NSError * __autoreleasing *) __attribute__((unused)) outError
{
	NSLog(@"Read from data");
	self.image = [[NSImage alloc] initWithData:data];
	return YES;
}

- (NSPrintOperation *)printOperationWithSettings:(NSDictionary *)printSettings
	error:(NSError * __autoreleasing *) __attribute__((unused)) outError
{
	NSPrintInfo * const printInfo = [[NSPrintInfo alloc] initWithDictionary:printSettings];
	return [NSPrintOperation printOperationWithView:self.imageView printInfo:printInfo];
}

@end
