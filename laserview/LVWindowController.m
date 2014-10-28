#import "LVWindowController.h"
#import "LVWindow.h"
#import "LVDocument.h"

@implementation LVWindowController

- (void)windowDidLoad
{
	LVWindow * const lvWindow = (LVWindow *) self.window;
	lvWindow.document = (LVDocument *)self.document;
}

- (NSString *)windowTitleForDocumentDisplayName:(NSString *)displayName
{
	LVDocument * const document = (LVDocument *)self.document;
	CGFloat const zoom = document.imageView.frame.size.width / document.image.size.width * 100;
	return [displayName stringByAppendingFormat:@" — %.0f×%.0f — %.1f%%", document.image.size.width, document.image.size.height, zoom];
}

@end
