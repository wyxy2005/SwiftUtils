// Generated by Swift version 1.1 (swift-600.0.56.1)
#pragma clang diagnostic push

#if defined(__has_include) && __has_include(<swift/objc-prologue.h>)
# include <swift/objc-prologue.h>
#endif

#pragma clang diagnostic ignored "-Wauto-import"
#include <objc/NSObject.h>
#include <stdint.h>
#include <stddef.h>
#include <stdbool.h>

#if defined(__has_include) && __has_include(<uchar.h>)
# include <uchar.h>
#elif !defined(__cplusplus) || __cplusplus < 201103L
typedef uint_least16_t char16_t;
typedef uint_least32_t char32_t;
#endif

typedef struct _NSZone NSZone;

#if !defined(SWIFT_PASTE)
# define SWIFT_PASTE_HELPER(x, y) x##y
# define SWIFT_PASTE(x, y) SWIFT_PASTE_HELPER(x, y)
#endif
#if !defined(SWIFT_METATYPE)
# define SWIFT_METATYPE(X) Class
#endif

#if defined(__has_attribute) && __has_attribute(objc_runtime_name)
# define SWIFT_RUNTIME_NAME(X) __attribute__((objc_runtime_name(X)))
#else
# define SWIFT_RUNTIME_NAME(X)
#endif
#if !defined(SWIFT_CLASS_EXTRA)
# define SWIFT_CLASS_EXTRA
#endif
#if !defined(SWIFT_PROTOCOL_EXTRA)
# define SWIFT_PROTOCOL_EXTRA
#endif
#if !defined(SWIFT_CLASS)
# if defined(__has_attribute) && __has_attribute(objc_subclassing_restricted) 
#  define SWIFT_CLASS(SWIFT_NAME) SWIFT_RUNTIME_NAME(SWIFT_NAME) __attribute__((objc_subclassing_restricted)) SWIFT_CLASS_EXTRA
# else
#  define SWIFT_CLASS(SWIFT_NAME) SWIFT_RUNTIME_NAME(SWIFT_NAME) SWIFT_CLASS_EXTRA
# endif
#endif

#if !defined(SWIFT_PROTOCOL)
# define SWIFT_PROTOCOL(SWIFT_NAME) SWIFT_RUNTIME_NAME(SWIFT_NAME) SWIFT_PROTOCOL_EXTRA
#endif

#if !defined(SWIFT_EXTENSION)
# define SWIFT_EXTENSION(M) SWIFT_PASTE(M##_Swift_, __LINE__)
#endif

#if !defined(OBJC_DESIGNATED_INITIALIZER)
# if defined(__has_attribute) && __has_attribute(objc_designated_initializer)
#  define OBJC_DESIGNATED_INITIALIZER __attribute__((objc_designated_initializer))
# else
#  define OBJC_DESIGNATED_INITIALIZER
# endif
#endif
#if defined(__has_feature) && __has_feature(modules)
@import UIKit;
@import CoreGraphics;
@import ObjectiveC;
@import Foundation;
#endif

#pragma clang diagnostic ignored "-Wproperty-attribute-mismatch"
#pragma clang diagnostic ignored "-Wduplicate-method-arg"
@class NSDate;
@class UILabel;
@class UIDatePicker;
@class NSCoder;
@class UITableView;

SWIFT_CLASS("_TtC10SwiftUtils23DatePickerTableViewCell")
@interface DatePickerTableViewCell : UITableViewCell
@property (nonatomic, copy) void (^ dateChanged)(DatePickerTableViewCell *);
@property (nonatomic, copy) NSString * (^ dateFormatter)(DatePickerTableViewCell *, NSDate *);
@property (nonatomic, readonly) UILabel * leftLabel;
@property (nonatomic, readonly) UILabel * rightLabel;
@property (nonatomic, readonly) UIDatePicker * datePicker;
@property (nonatomic) BOOL exclusiveExpansion;
@property (nonatomic) NSDate * date;
@property (nonatomic) CGFloat unexpandedHeight;
@property (nonatomic, readonly) CGFloat cellHeight;
@property (nonatomic, readonly) BOOL expanded;
- (instancetype)initWithCoder:(NSCoder *)aDecoder OBJC_DESIGNATED_INITIALIZER;
- (void)setHighlighted:(BOOL)highlighted animated:(BOOL)animated;
- (void)setSelected:(BOOL)selected animated:(BOOL)animated;
- (void)toggleExpandedWithTableView:(UITableView *)tableView;
- (void)expandWithTableView:(UITableView *)tableView;
- (void)collapseWithTableView:(UITableView *)tableView;
@end



/// <ul><li><p>A simple class for calling a block repeatedly with defined a time interval</p></li></ul>
SWIFT_CLASS("_TtC10SwiftUtils9Heartbeat")
@interface Heartbeat : NSObject
@property (nonatomic, readonly) double timeInterval;
@property (nonatomic, readonly, copy) void (^ action)(void);

/// Instantiates with the given time interval and action
/// Does not start automatically
///
/// \param timeInterval The time interval between two calls of action
///
/// \param action The block to run
- (instancetype)initWithTimeInterval:(double)timeInterval action:(void (^)(void))action OBJC_DESIGNATED_INITIALIZER;

/// Instantiates with a time interval 1/beatsPerSecond
- (instancetype)initWithBeatsPerSecond:(double)beatsPerSecond action:(void (^)(void))action;

/// Instantiates with a time interval of one second
- (instancetype)initWithAction:(void (^)(void))action;

/// Start beating (forever)
- (void)start;

/// Stop beating
- (void)stop;
@property (nonatomic, readonly) BOOL running;
- (void)fire;
@end


@interface NSDate (SWIFT_EXTENSION(SwiftUtils))
@end


@interface NSDateComponents (SWIFT_EXTENSION(SwiftUtils))
@property (nonatomic, readonly) NSDateComponents * inverted;
+ (NSCalendarUnit)allUnits;
@end


@interface NSIndexPath (SWIFT_EXTENSION(SwiftUtils))
- (instancetype)init:(NSInteger)section :(NSInteger)row;
@end


@interface NSURL (SWIFT_EXTENSION(SwiftUtils))
@property (nonatomic, readonly, copy) NSDictionary * queryDictionary;
@end

#pragma clang diagnostic pop
