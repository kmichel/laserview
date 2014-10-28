#import "LVDocument.h"
#import "LVImageView.h"
#import "LVWindowController.h"
#import "NSWindow+LVContentSize.h"

@interface LVDocument ()

@property (nonatomic,assign) BOOL resizeWindowAfterFullscreen;

@end

@implementation LVDocument

@synthesize image;
@synthesize imageView;
@synthesize resizeWindowAfterFullscreen;

- (void)loadImage:(LVDirection)direction
{
	NSURL * const directoryURL = self.fileURL.URLByDeletingLastPathComponent;
	NSError * contentListingError;
	NSArray * fileURLs = [[NSFileManager defaultManager]
		contentsOfDirectoryAtURL:directoryURL
		includingPropertiesForKeys:[NSArray arrayWithObject:NSURLTypeIdentifierKey]
		options:NSDirectoryEnumerationSkipsHiddenFiles
		error:&contentListingError];
	if (contentListingError) {
		NSLog(@"Error: %@", contentListingError);
		return;
	}
	fileURLs = [fileURLs sortedArrayUsingComparator:^
		(NSURL * const lhs, NSURL * const rhs) {
			return [lhs.lastPathComponent localizedCompare:rhs.lastPathComponent];
		}
	];
	NSIndexSet * const fileIndexes = [fileURLs indexesOfObjectsPassingTest:^
		(NSURL *fileURL, NSUInteger __attribute__((unused)) index, BOOL * __attribute__((unused)) stop) {
		NSError * typeIdentifierError;
		NSString * typeIdentifier;
		[fileURL getResourceValue:&typeIdentifier forKey:NSURLTypeIdentifierKey error:&typeIdentifierError];
		if (typeIdentifierError) {
			NSLog(@"Error: %@", typeIdentifierError);
			return NO;
		}
		return [typeIdentifier isEqual:@"public.png"];
	}];
	[fileIndexes enumerateIndexesUsingBlock:^
		(NSUInteger const index, BOOL * stop) {
			NSError * readURLError;
			NSURL * fileURL = [fileURLs objectAtIndex:index];
			if ([fileURL isEqual:self.fileURL]) {
				NSUInteger newIndex;
				if (direction == LVPrevious) {
					newIndex = [fileIndexes indexLessThanIndex:index];
					if (newIndex == NSNotFound)
						newIndex = fileIndexes.lastIndex;
				} else {
					newIndex = [fileIndexes indexGreaterThanIndex:index];
					if (newIndex == NSNotFound)
						newIndex = fileIndexes.firstIndex;
				}
				if (newIndex != index) {
					NSURL * newURL = [fileURLs objectAtIndex:newIndex];
					[self readFromURL:newURL ofType:@"public.png" error:&readURLError];
					if (readURLError)
						NSLog(@"Error: %@", readURLError);
					else
						self.fileURL = newURL;
				}
				*stop = YES;
			}
		}
	];
}

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
