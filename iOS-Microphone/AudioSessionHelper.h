#import <Foundation/Foundation.h>

@interface AudioSessionHelper : NSObject
+ (BOOL)setPlayAndRecordCategoryWithError:(NSError **)error;
@end