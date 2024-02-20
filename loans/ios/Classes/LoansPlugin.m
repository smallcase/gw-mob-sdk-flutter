#import "LoansPlugin.h"
#if __has_include(<loans/loans-Swift.h>)
#import <loans/loans-Swift.h>
#else
// Support project import fallback if the generated compatibility header
// is not copied when this plugin is created as a library.
// https://forums.swift.org/t/swift-static-libraries-dont-copy-generated-objective-c-header/19816
#import "loans-Swift.h"
#endif

@implementation LoansPlugin
+ (void)registerWithRegistrar:(NSObject<FlutterPluginRegistrar>*)registrar {
  [SwiftLoansPlugin registerWithRegistrar:registrar];
}
@end
