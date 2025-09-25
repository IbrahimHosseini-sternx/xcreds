//
//  TCTaskHelper.h
//
//

#import <Foundation/Foundation.h>

@interface TCTaskHelper : NSObject

+(TCTaskHelper *)sharedTaskHelper;
-(NSString *)runCommand:(NSString *)command withOptions:(NSArray *)inOptions;

@end
