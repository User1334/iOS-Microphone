#import <Foundation/Foundation.h>

@interface AudioSessionHelper : NSObject
+ (BOOL)setPlayAndRecordCategoryWithEchoCancellation:(BOOL)echoCancellation error:(NSError **)error NS_SWIFT_NAME(setPlayAndRecordCategory(withEchoCancellation:));
@end