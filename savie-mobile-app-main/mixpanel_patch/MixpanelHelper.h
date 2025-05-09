//
//  MixpanelHelper.h
//  mixpanel_flutter
//

#ifndef MixpanelHelper_h
#define MixpanelHelper_h

#if __has_include(<Mixpanel-swift/Mixpanel-Swift.h>)
#import <Mixpanel-swift/Mixpanel-Swift.h>
#elif __has_include("Mixpanel-Swift.h")
#import "Mixpanel-Swift.h"
#endif

#endif /* MixpanelHelper_h */ 