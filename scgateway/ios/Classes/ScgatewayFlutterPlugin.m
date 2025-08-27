#import "ScgatewayFlutterPlugin.h"
#if __has_include(<scgateway_flutter_plugin/scgateway_flutter_plugin-Swift.h>)
#import <scgateway_flutter_plugin/scgateway_flutter_plugin-Swift.h>
#else
// Support project import fallback if the generated compatibility header
// is not copied when this plugin is created as a library.
// https://forums.swift.org/t/swift-static-libraries-dont-copy-generated-objective-c-header/19816
#import "scgateway_flutter_plugin-Swift.h"
#endif

@implementation ScgatewayFlutterPlugin
+ (void)registerWithRegistrar:(NSObject<FlutterPluginRegistrar>*)registrar {
  [SwiftScgatewayFlutterPlugin registerWithRegistrar:registrar];
}
@end
