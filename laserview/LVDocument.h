#import "LVDirection.h"

@import Cocoa;

@interface LVDocument : NSDocument<NSWindowDelegate>

@property (nonatomic,copy) NSImage* image;

@property (atomic,assign) IBOutlet NSImageView* imageView;

@property (nonatomic,assign) BOOL resizeWindowAfterFullscreen;

- (void)loadImage:(LVDirection)direction;

@end
