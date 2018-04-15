#import <Foundation/Foundation.h>




@protocol ALinkShimDelegate
- (void) linkShimPropertiesUpdated:(id)linkShim;
- (void) linkShimNumPeersUpdated:(id)linkShim;
@end




@interface ALinkShim : NSObject	{
	BOOL                     deleted;
    __weak id<ALinkShimDelegate>    delegate;   // was __unsafe_unretained
    void                    *linkObject; // really an instance of "LinkDelegate"
}

- (void) prepareToBeDeleted;

- (BOOL) getBeat:(double *)beat andBPM:(double *)bpm;
- (void) setBeat:(double)beat andBPM:(double)bpm byForce:(BOOL)f;

- (int) numberOfPeers;
- (double) beatsPerMeasure;
- (void) setBeatsPerMeasure:(double)n;
@property (weak,readwrite) id<ALinkShimDelegate> delegate;
- (void) setEnabled:(BOOL)n;
- (BOOL) enabled;


@end
