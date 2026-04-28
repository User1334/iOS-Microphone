#import "AudioSessionHelper.h"
@import AVFoundation;

@implementation AudioSessionHelper

+ (BOOL)setPlayAndRecordCategoryWithEchoCancellation:(BOOL)echoCancellation error:(NSError **)error {
    AVAudioSession *session = [AVAudioSession sharedInstance];
    NSString *mode = echoCancellation ? AVAudioSessionModeVoiceChat : AVAudioSessionModeDefault;
    return [session setCategory:AVAudioSessionCategoryPlayAndRecord
                           mode:mode
                        options:AVAudioSessionCategoryOptionDefaultToSpeaker
                          error:error];
}

@end