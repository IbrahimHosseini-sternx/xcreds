//
//  TCSUnifiedLogger.h
//
//

#import <Foundation/Foundation.h>
typedef enum : NSUInteger {
    LOGLEVELERROR,
    LOGLEVELINFO,
    LOGLEVELDEBUG,
} LogLevel;

#undef os_log_debug
#undef os_log_info
#undef os_log_error

#define os_log_debug(log, ...)                                                                                      \
    ;                                                                                                               \
    {                                                                                                               \
        char *log_string = malloc(1024);                                                                            \
        snprintf(log_string, 1024, ##__VA_ARGS__);                                                                  \
        TCSLog([NSString stringWithUTF8String:log_string]); \
        free(log_string);                                                                                           \
    }
#define os_log_info(log, ...)                                                                                      \
    ;                                                                                                              \
    {                                                                                                              \
        char *log_string = malloc(1024);                                                                           \
        snprintf(log_string, 1024, ##__VA_ARGS__);                                                                 \
        TCSLog([NSString stringWithUTF8String:log_string] level:LOGLEVELINFO]; \
        free(log_string);                                                                                          \
    }
#define os_log_error(log, ...)                                                                                      \
    ;                                                                                                               \
    {                                                                                                               \
        char *log_string = malloc(1024);                                                                            \
        snprintf(log_string, 1024, ##__VA_ARGS__);                                                                  \
        TCSLog([NSString stringWithUTF8String:log_string] level:LOGLEVELERROR]; \
        free(log_string);                                                                                           \
    }
#define NSLog(fmt, ...)                                                                                                 \
    ;                                                                                                                   \
    {                                                                                                                   \
        TCSLog([NSString stringWithFormat:fmt, ##__VA_ARGS__]); \
    }


NS_ASSUME_NONNULL_BEGIN
#undef TCSLog
void TCSLog(NSString *str);
void TCSLogInfo(NSString *str);
void TCSLogError(NSString *string);

@interface TCSUnifiedLogger : NSObject
+ (TCSUnifiedLogger *)sharedLogger;
//-(void)setLogFilePath:(NSString *)logFilePath;
@property (strong, readwrite) NSURL *logFileURL;
@property (strong, readwrite) NSString *logFolderName;
@property (strong, readwrite) NSString *logFileName;
@property bool suppressDebug;

- (void)logString:(NSString *)inStr level:(LogLevel)level;

@end

NS_ASSUME_NONNULL_END
