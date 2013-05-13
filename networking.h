//
//  networking.h
//  FieldClock
//
//  Created by Bartimeus on 08.07.10.
//  Copyright 2010 __MyCompanyName__. All rights reserved.
//

#import <Foundation/Foundation.h>


@interface myNetWorking : NSObject <NSStreamDelegate>{
	NSInputStream *iStream;
	NSOutputStream *oStream;
    BOOL isStreamReadyToWrite;
    
    NSString *urlStr1 ;
    uint portNo1;
    
}
@property (nonatomic, retain) NSInputStream *iStream;
@property (nonatomic, retain) NSOutputStream *oStream;
@property (assign) BOOL isStreamReadyToWrite;
-(void) connectToServerUsingStream:(NSString *)urlStr portNo: (uint) portNo;
-(void) writeToServer:(const uint8_t *) buf;
-(void)stream:(NSStream *)stream handleEvent:(NSStreamEvent)eventCode;
-(void) disconnect;
-(uint32_t)readIntFromServer;
-(unsigned short)readShortFromServer;
-(NSString *)readStringFromServer:(int)l;
-(double)readDoubleFromServer;
-(void)writeInt:(int)i;
-(void)writeLong:(uint64_t)i;
-(float)readFloatFromServer;

- (BOOL)writeDouble:(double)d;

-(BOOL)writeShort:(short)i;
-(void)writeString32:(NSString *)str2;
-(void)writeString:(NSString *)str;
@end
