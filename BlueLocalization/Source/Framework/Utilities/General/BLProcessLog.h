/*!
 @header
 BLProcessLog.h
 Created by Max Seelemann on 15.05.09.
 
 @copyright 2004-2009 the Localization Suite Foundation. All rights reserved.
 */

@class BLProcessLogItem;

/*!
 @abstract The severity level of a log entry.
 
 @const BLLogInfo		Informative logging, use for things like status or process annoncements.
 @const BLLogWarning	A warning, use to mark irregularities that however should not affect the whole command or process.
 @const BLLogError		A error, use for problems hindering a command or process from successful completion.
 */
typedef enum {
	BLLogInfo		= 0,
	BLLogWarning	= 1,
	BLLogError		= 2
} BLProcessLogLevel;

/*!
 @abstract Designated logging command for single line prints, will create a single log item.
 */
void BLLog(BLProcessLogLevel level, NSString *format, ...);

/*!
 @abstract Begin a log item with a pipe.
 @discussion Immediately creates an item that will be filled using a pipe. When the pipe closes, the item decides upon it's contents whether it will become a group or a single item. If it becomes a group, the passed format string will be the title of the group.
 
 The level of the resulting item will be determined heuristically from the contents of the pipe. However, if the item becomes a group afterwards, the level will automatically be determined from the contained items. If the level cannot be determined from the contents, the resulting item will have the default level BLLogInfo.
 */
NSPipe* BLLogOpenPipe(NSString *format, ...);

/*!
 @abstract Create log items from process output data.
 @discussion This features the exact same functionality as BLLogOpenPipe, except that the data that would otherwise be given through a pipe is now given directly.
 */
void BLLogData(NSData *data, NSString *format, ...);

/*!
 @abstract Begin a group of log entries.
 @discussion The group wil have the name passed with format and will have the highest level of the enclosed items.
 */
void BLLogBeginGroup(NSString *format, ...);

/*!
 @abstract End the last opened group.
 @discussion Throws an NSInternalInconsistencyException if no group has been opened before.
 */
void BLLogEndGroup(void);

/*!
 @abstract The logging facility of the BlueLocalization framework.
 @discussion Basically, the log consists of items with status information and a logging message. Items can be groups, which means that they contain other items and groups, mixed in an arbitrary order. Items will be sorted by their creation date. Use the functions BLLog, BLLogOpenPipe, BLLogBeginGroup and BLLogEndGroup to interact with the log and to create items. This class is mainly used to access the logged items or to interact with the log in rare cases.
 
 <b>Log Items</b>: As previously mentioned, items can be either single entries or groups. Both kinds have a message and a level. The level of a group is the highest level amongst it's items. The level of a item is a fixed property. Groups can be opened and closed using the according calls. However, groups need not be closed: If your process opened several groups and the thread somehow exits immediatelly, no closing is requires. Read the section "Threads" for details.
 <b>Root Groups</g>: In addition to regular log items there are root groups. As the name suggests, these are group items that are the root of a logging entry hierarchy. The framework mainly uses these for processes in the BLProcessManager. Whilst there might only exist exactly one root group at a time, there need not. Groups created using BLLogBeginGroup or BLLogOpenPipe will automatically become root groups, if no such one exists. When manually creating root groups you should make sure that they are opened and closed correctly according to your custom commands/process. No automatic closing as for regular groups exists (descriped in !
 <b>Threads</b>: Logging is thread-aware. This not only means that all operations are thread-safe. This also includes the nesting of groups and items according to threads. A group that has been created on a distinct thread will only receive items logged on that thread. Opening and closing groups works the same way. The only difference here are root groups. Root groups are thread-independent. This means once they are created and open, any newly created items that are not in a thread-local group will be added to them.
 */
@interface BLProcessLog : NSObject
{
	BLProcessLogItem	*_itemRoot;
	BLProcessLogItem	*_rootGroup;
	NSMapTable	*_threads;
}

/*!
 @abstract Returns the current log parent object.
 @discussion BLProcessLog is supposed to be used a singleton.
 */
+ (id)sharedLog;

/*!
 @abstract Returns an array of all root items.
 @discussion The accessor is KVO-aware. The objects in the array will be of class BLLogItem.
 */
- (NSArray *)items;

/*!
 @abstract Clear the current log, removing all items.
 */
- (void)clear;

/*!
 @abstract Opens a new root group.
 @discussion Throws an NSInternalInconsistencyException if a root group has been opened before. See the section "Root Groups" in the BLProcessLog class description for details.
 */
- (void)openRootGroup:(NSString *)name;

/*!
 @abstract Closes the current root group.
 @discussion Throws and NSInternalInconsistencyException if no root group has been opened beforehand.
 */
- (void)closeRootGroup;

@end

/*!
 @abstract An item in the BLProcessLog.
 @discussion See BLProcessLog class description for details about items.
 */
@interface BLProcessLogItem : NSObject
{
	NSDate				*_date;
	NSArray				*_items;
	BLProcessLogLevel	_level;
	NSString			*_message;
}

/*!
 @abstract The creation date of the item.
 */
- (NSDate *)date;

/*!
 @abstract The level of the item.
 */
- (BLProcessLogLevel)level;

/*!
 @abstract The llogged message of the item.
 */
- (NSString *)message;

/*!
 @abstract Return whether the item is a group or not.
 */
- (BOOL)isGroup;

/*!
 @abstract If the item is a group, returns the items, nil otherwise.
 */
- (NSArray *)items;

@end


