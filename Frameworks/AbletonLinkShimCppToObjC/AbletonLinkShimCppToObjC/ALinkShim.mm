#import "ALinkShim.h"
#include "Link.hpp"
#include <iostream>


class LinkDelegate	{
	public:
		LinkDelegate(id inShimObject, double inStartingBPM);
		~LinkDelegate();
		bool getBeatAndBPM(double * beat, double * bpm);
		void setBeatAndBPM(double beat, double bpm, bool force);
		double getQuantum();
		void setQuantum(double n);
		void setEnabled(bool n);
		bool enabled();
		int numPeers();
	private:
		id				shimObject;	//	weak ref to the ALinkShim that created me
		ableton::Link	*link;	    //	the actual link object
		double			quantum = 4.0;
};


@interface ALinkShim ()
- (void) _setNumPeersCB:(size_t)n;
- (void) _setTempoCB:(double)n;
@end




LinkDelegate::~LinkDelegate()	{
	link->enable(false);
	delete link;
}
LinkDelegate::LinkDelegate(id inShimObject, double inStartingBPM)	{
	shimObject = inShimObject;
	link = new ableton::Link(inStartingBPM);
	quantum = 4.0;
	
	link->setNumPeersCallback([this](std::size_t inNumPeers)	{
		[shimObject _setNumPeersCB:inNumPeers];
	});
	link->setTempoCallback([this](const double inBPM)	{
		[shimObject _setTempoCB:inBPM];
	});
	
	link->enable(false);
}
bool LinkDelegate::getBeatAndBPM(double * beat, double * bpm)	{
	if (link == nullptr)
		return false;
	//if (!link->isEnabled())
	//	return false;
	//if (link->numPeers() < 1)
	//	return false;
	
	ableton::Link::Clock		theClock = link->clock();
	std::chrono::microseconds	nowTime  = theClock.micros();
	
	ableton::Link::Timeline		tmpTimeline = link->captureAppTimeline();
	
	double nowBeat = tmpTimeline.phaseAtTime(nowTime, quantum);
	double nowBPM  = tmpTimeline.tempo();
	*beat = nowBeat;
	*bpm  = nowBPM;
	return true;
}
void LinkDelegate::setBeatAndBPM(double beat, double bpm, bool force)	{
	ableton::Link::Clock			theClock = link->clock();
	std::chrono::microseconds		nowTime = theClock.micros();
	
	ableton::Link::Timeline		tmpTimeline = link->captureAppTimeline();
    if (!force) { // }(tmpTimeline.tempo() != bpm && !force)	{
		//std::cout << "\t\tbpm mismatch and not forced, requesting beat\n";
		
		double	nextDownbeat = beat + (quantum - fmod(beat, quantum));
		//std::cout << "\t\tbeat is " << beat << ", nextDownbeat is " << nextDownbeat << "\n";
		std::chrono::microseconds nextDownbeatTime = tmpTimeline.timeAtBeat(nextDownbeat, quantum);
		//tmpTimeline.requestBeatAtTime(nextDownbeat, nextDownbeatTime, quantum);
		tmpTimeline.setTempo(bpm, nowTime);
		link->commitAppTimeline(tmpTimeline);
		
		tmpTimeline = link->captureAppTimeline();
		tmpTimeline.setTempo(bpm, nextDownbeatTime);
		tmpTimeline.requestBeatAtTime(nextDownbeat, nextDownbeatTime, quantum);
	}
	else	{
		//std::cout << "\t\tbpm match or forcing beat\n";
		tmpTimeline.setTempo(bpm, nowTime);
		tmpTimeline.forceBeatAtTime(beat, nowTime, quantum);
	}
	link->commitAppTimeline(tmpTimeline);
}
double LinkDelegate::getQuantum()	{
	return quantum;
}
void LinkDelegate::setQuantum(double n)	{
	quantum = n;
}
void LinkDelegate::setEnabled(bool n)	{
	link->enable(n);
}
bool LinkDelegate::enabled()	{
	return link->isEnabled();
}
int LinkDelegate::numPeers()	{
	return (int)(link->numPeers());
}




@implementation ALinkShim
- (id) init	{
	self = [super init];
	if (self != nil)	{
		deleted = NO;
		linkObject = new LinkDelegate(self, 60.0);
        [self setEnabled:NO];
		((LinkDelegate *)linkObject)->setQuantum(4.0);
		delegate = nil;
	}
	return self;
}
- (void) dealloc	{
	if (!deleted)
		[self prepareToBeDeleted];
	delete (LinkDelegate *)linkObject;
	delegate = nil;
	//[super dealloc];
}
- (void) prepareToBeDeleted	{
	[self setEnabled:NO];
	deleted = YES;
}
@synthesize delegate;
- (void) _setNumPeersCB:(size_t)n	{
	//NSLog(@"%s ... %ld",__func__,n);
	[[self delegate] linkShimNumPeersUpdated:self];
}
- (void) _setTempoCB:(double)n	{
	//NSLog(@"%s ... %f",__func__,n);
	[[self delegate] linkShimPropertiesUpdated:self];
}
- (int) numberOfPeers	{
	int		returnMe = ((LinkDelegate *)linkObject)->numPeers();
	return returnMe;
}
- (double) beatsPerMeasure	{
	return ((LinkDelegate *)linkObject)->getQuantum();
}
- (void) setBeatsPerMeasure:(double)n	{
	//NSLog(@"%s ... %f",__func__,n);
	if (n<= 0.)
		return;
	((LinkDelegate *)linkObject)->setQuantum(n);
}
- (BOOL) getBeat:(double *)beat andBPM:(double *)bpm	{
	if (!((LinkDelegate *)linkObject)->getBeatAndBPM(beat, bpm))
		return NO;
	return YES;
}
- (void) setBeat:(double)beat andBPM:(double)bpm byForce:(BOOL)f	{
	//NSLog(@"%s ... %0.2f, %0.2f, %d",__func__,beat,bpm,f);
	((LinkDelegate *)linkObject)->setBeatAndBPM(beat, bpm, (f)?true:false);
}
- (void) setEnabled:(BOOL)n	{
	//NSLog(@"%s ... %d",__func__,n);
	BOOL		changed = (((LinkDelegate *)linkObject)->enabled()==n) ? NO : YES;
	((LinkDelegate *)linkObject)->setEnabled((n)?true:false);
	if (changed && n && [self numberOfPeers]>0)
		[[self delegate] linkShimPropertiesUpdated:self];
}
- (BOOL) enabled	{
	if (((LinkDelegate *)linkObject)->enabled())
		return YES;
	else
		return NO;
}
@end
