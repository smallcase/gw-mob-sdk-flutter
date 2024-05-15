#import "ScLoanFlutterPlugin.h"
#if __has_include(<scloans/scloans-Swift.h>)
#import <scloans/scloans-Swift.h>
#else
// Support project import fallback if the generated compatibility header
// is not copied when this plugin is created as a library.
// https://forums.swift.org/t/swift-static-libraries-dont-copy-generated-objective-c-header/19816
#import "scloans-Swift.h"
#endif

@implementation ScLoanFlutterPlugin
+ (void)registerWithRegistrar:(NSObject<FlutterPluginRegistrar>*)registrar {
  [SwiftScLoanFlutterPlugin registerWithRegistrar:registrar];
}
@end
