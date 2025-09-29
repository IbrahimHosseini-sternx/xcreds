//
//  NSData+HexString.h
//  Identity Manager
//
//



#import <Foundation/Foundation.h>

NS_ASSUME_NONNULL_BEGIN

@interface NSData (HexString)
+(id)dataWithHexString:(NSString *)hex;
- (NSString *)hexString;
@end

NS_ASSUME_NONNULL_END
