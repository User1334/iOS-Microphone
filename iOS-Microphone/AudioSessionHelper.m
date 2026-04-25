#import "AudioSessionHelper.h"
@import AVFoundation;

@implementation AudioSessionHelper

+ (BOOL)setPlayAndRecordCategoryWithError:(NSError **)error {
    AVAudioSession *session = [AVAudioSession sharedInstance];
    return [session setCategory:AVAudioSessionCategoryPlayAndRecord
                    withOptions:AVAudioSessionCategoryOptionDefaultToSpeaker
                          error:error];
}

@end