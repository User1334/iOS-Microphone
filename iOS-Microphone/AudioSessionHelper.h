#import <Foundation/Foundation.h>

@interface AudioSessionHelper : NSObject
+ (BOOL)setPlayAndRecordCategoryWithEchoCancellation:(BOOL)echoCancellation error:(NSError **)error;
@end