//
//  NSError+EasyError.h
//  Winclone
//
//

#import <Foundation/Foundation.h>

NS_ASSUME_NONNULL_BEGIN

@interface NSError (EasyError)
+(NSError *)easyErrorWithTitle:(NSString *)title
                          body:(NSString *)body
                          line:(int)line
                          file:(NSString *)file;
@end

NS_ASSUME_NONNULL_END
