//
//  NSFileManager+TCSRealHomeFolder.h
//  Signing Manager
//
//

#import <Foundation/Foundation.h>

NS_ASSUME_NONNULL_BEGIN


@interface NSFileManager (TCSRealHomeFolder)
- (NSString *)realHomeFolder;
@end

NS_ASSUME_NONNULL_END
