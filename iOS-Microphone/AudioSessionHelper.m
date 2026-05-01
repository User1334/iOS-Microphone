#import "AudioSessionHelper.h"
@import AVFoundation;

@implementation AudioSessionHelper

+ (BOOL)setPlayAndRecordCategoryWithEchoCancellation:(BOOL)echoCancellation error:(NSError **)error {
    AVAudioSession *session = [AVAudioSession sharedInstance];
    NSString *mode = echoCancellation ? AVAudioSessionModeVoiceChat : AVAudioSessionModeDefault;

    if (![session setCategory:AVAudioSessionCategoryPlayAndRecord
                  withOptions:AVAudioSessionCategoryOptionDefaultToSpeaker
                        error:error]) {
        return NO;
    }
    if (![session setMode:mode error:error]) {
        return NO;
    }
    return YES;
}

@end