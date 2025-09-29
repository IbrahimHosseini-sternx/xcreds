//
//  NSFileManager+TCSRealHomeFolder.m
//  Signing Manager
//
//

#import "NSFileManager+TCSRealHomeFolder.h"
#include <pwd.h>


@implementation NSFileManager (TCSRealHomeFolder)
- (NSString *)realHomeFolder
{
    struct passwd *pw = getpwuid(getuid());
    assert(pw);
    return [NSString stringWithUTF8String:pw->pw_dir];
}

@end
