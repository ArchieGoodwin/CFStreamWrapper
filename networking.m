//
//  networking.m
//  FieldClock
//
//  Created by Bartimeus on 08.07.10.
//  Copyright 2010 __MyCompanyName__. All rights reserved.
//

#import "networking.h"

#import "NSStreamAdditions.h"
#import "Employee.h"

@implementation myNetWorking
@synthesize iStream;
@synthesize oStream, isStreamReadyToWrite;
NSMutableData *data;
     


-(void) connectToServerUsingStream:(NSString *)urlStr 
                            portNo: (uint) portNo {
	
	isStreamReadyToWrite = NO;
    if (![urlStr isEqualToString:@""]) {
        NSURL *website = [NSURL URLWithString:urlStr];
        if (!website) {
            NSLog(@"%@ is not a valid URL", website);
            return;
        } else {
            
            if ([[[UIDevice currentDevice] systemVersion] floatValue] >= 5.0) {
                //[self disconnect];
                portNo1 = portNo;
                urlStr1 = urlStr;
                NSLog(@"valid URL");
                CFReadStreamRef readStream = NULL;
                CFWriteStreamRef writeStream = NULL;
                
                CFStreamCreatePairWithSocketToHost(kCFAllocatorDefault, (CFStringRef)urlStr, portNo, &readStream, &writeStream);
                if (readStream && writeStream) {
                    CFReadStreamSetProperty(readStream, kCFStreamPropertyShouldCloseNativeSocket, kCFBooleanTrue);
                    CFWriteStreamSetProperty(writeStream, kCFStreamPropertyShouldCloseNativeSocket, kCFBooleanTrue);
                    
                    self.iStream = objc_unretainedObject(readStream);
                    //[self.iStream retain];
                    [self.iStream setDelegate:self];
                    [self.iStream scheduleInRunLoop:[NSRunLoop currentRunLoop] forMode:NSDefaultRunLoopMode];
                    [self.iStream open];
                    
                    self.oStream = objc_unretainedObject(writeStream);
                    //[self.oStream retain];
                    [self.oStream setDelegate:self];
                    [self.oStream scheduleInRunLoop:[NSRunLoop currentRunLoop] forMode:NSDefaultRunLoopMode];
                    [self.oStream open];
                }
                
                if (readStream)
                    CFRelease(readStream);
                
                if (writeStream)
                    CFRelease(writeStream);
            }
            else
            {
                NSLog(@"valid URL");
                [NSStream getStreamsToHostNamed:urlStr 
                                           port:portNo 
                                    inputStream:&iStream
                                   outputStream:&oStream];            
                [self.iStream retain];
                [self.oStream retain];
                
                
                [self.iStream setDelegate:self];
                [self.oStream setDelegate:self];
                
                //[iStream scheduleInRunLoop:[NSRunLoop currentRunLoop] forMode:NSDefaultRunLoopMode];
                //[oStream scheduleInRunLoop:[NSRunLoop currentRunLoop] forMode:NSDefaultRunLoopMode];
                
                [self.oStream open];
                [self.iStream open]; 
            }
            
            
            
            
            
            
            
            
            
            
            
            
            
         
        }
	}    
}

//write to server sample data
-(void) writeToServer:(const uint8_t *) buf {
	NSUInteger i = strlen((char*)buf);
    int r = [self.oStream write:buf maxLength:i];    
    NSLog(@"sent real more: %i", r);

}

-(void)writeInt:(int)i
{
	unsigned int s2 = CFSwapInt32HostToBig(i);
	NSMutableData *h = [[[NSMutableData alloc] init] autorelease];
	[h appendBytes:(const void *)&s2 length:4];
	NSInteger l = [h length];
	int r = [self.oStream write:[h bytes] maxLength:l]; 
    if(r == -1)
    {
            [self connectToServerUsingStream:urlStr1 portNo:portNo1];
            for(int i = 0; i < 50; i++)
            {
                //[NSThread sleepForTimeInterval:0.1];

                r = [self.oStream write:[h bytes] maxLength:l]; 
                
                if(r != -1)
                {
                    break;
                }
            }

    }
    NSLog(@"sent real: %i", r);
	//[h release];
    //[NSThread sleepForTimeInterval:0.1];
}

-(void)writeString32:(NSString *)str2
{
    NSMutableData *h = [[[NSMutableData alloc] init] autorelease];

    NSMutableString *str = [NSMutableString stringWithString:@""];
		if([str2 length] < 32)
		{
			[str appendString:str2];
			for(int i = 0; i < (32 - [str2 length]); i++)
			{
				[str appendString:@" "];
			}
		}
		else 
		{
			NSMutableString *a = [NSMutableString stringWithString:str2];
			NSRange range;
			range.location = 32;
			range.length = [str2 length] - 32;
			[a deleteCharactersInRange:range];
			str = [NSMutableString stringWithString:a];
            
		}
        
    NSLog(@"%i", [str length]);
	const uint8_t *strs = (uint8_t *) [str cStringUsingEncoding:NSASCIIStringEncoding];
	[h appendBytes:strs length:32];
    int r = [self.oStream write:[h bytes] maxLength:[h length]];
    if(r == -1)
    {
        
        [self connectToServerUsingStream:urlStr1 portNo:portNo1];
        for(int i = 0; i < 10; i++)
        {
            r = [self.oStream write:[h bytes] maxLength:[h length]];
            
            if(r != -1)
            {
                break;
            }
        }
        
    }
    NSLog(@"sent real: %i", r);
   // [NSThread sleepForTimeInterval:0.1];
}

-(void)writeString:(NSString *)str
{
    NSMutableData *h = [[[NSMutableData alloc] init] autorelease];
    
	const uint8_t *strs = (uint8_t *) [str cStringUsingEncoding:NSUTF8StringEncoding];
	[h appendBytes:strs length:[str length]];
    int r = [self.oStream write:[h bytes] maxLength:[h length]]; 
    if(r == -1)
    {
        
        [self connectToServerUsingStream:urlStr1 portNo:portNo1];
        for(int i = 0; i < 10; i++)
        {
            r = [self.oStream write:[h bytes] maxLength:[h length]]; 
            
            if(r != -1)
            {
                break;
            }
        }
        
    }
    NSLog(@"sent string real: %i", r);
      //  [NSThread sleepForTimeInterval:0.1];
}

-(BOOL)writeDouble:(double)d
{
    NSMutableData *h = [[[NSMutableData alloc] init] autorelease];
    CFSwappedFloat64 p = CFConvertDoubleHostToSwapped(d);
    [h appendBytes:(const void *) &p length:8];
    NSInteger l = [h length];

    int r = [self.oStream write:[h bytes] maxLength:l];
    if (r == -1) {
        [self connectToServerUsingStream:urlStr1 portNo:portNo1];
        for (int i = 0; i < 10; i++) {
            r = [self.oStream write:[h bytes] maxLength:l];

            if (r != -1) {
                break;
            }
        }
    }
    NSLog(@"sent double real: %i", r);

    return YES;
}

-(BOOL)writeShort:(short)i
{
    short s2 = CFSwapInt16HostToBig(i);
	NSMutableData *h = [[NSMutableData alloc] init];
	[h appendBytes:(const void *)&s2 length:2];
	NSInteger l = [h length];
    int r = -1;
   // NSLog(@"status: %i", [self.oStream streamStatus])     ;

    r = [self.oStream write:[h bytes] maxLength:l];

    if(r == -1)
    {
         
        //r = [self.oStream write:[h bytes] maxLength:l]; 
        [self connectToServerUsingStream:urlStr1 portNo:portNo1];
        for(int i = 0; i < 50; i++)
        {
            //[NSThread sleepForTimeInterval:0.1];
            r = [self.oStream write:[h bytes] maxLength:l]; 
            if(r != -1)
            {
                break;
            }
        }
    }
    NSLog(@"sent real: %i", r);
	[h release];
    return YES;
}

-(void)writeLong:(uint64_t)i
{
	uint64_t s2 = CFSwapInt64HostToBig(i);
	//CFSwappedFloat64 s2 = CFConvertDoubleHostToSwapped(i);
	//uint64_t t = s2.v;
	
	NSMutableData *h = [[[NSMutableData alloc] init] autorelease];
	[h appendBytes:(const void *)&s2 length:8];
	NSInteger l = [h length];
	int r = [self.oStream write:[h bytes] maxLength:l]; 
    if(r == -1)
    {
        [self connectToServerUsingStream:urlStr1 portNo:portNo1];
        for(int i = 0; i < 10; i++)
        {
            r = [self.oStream write:[h bytes] maxLength:l]; 

            if(r != -1)
            {
                break;
            }
        }
    }
    NSLog(@"sent real: %i", r);
    //[NSThread sleepForTimeInterval:0.1];
    
	//[h release];
}

-(uint32_t)readIntFromServer
{
	//NSLog(@"Data received");
    //[NSThread sleepForTimeInterval:0.05];  

	NSMutableData *data = [[[NSMutableData alloc] init] autorelease];
	
	//uint8_t buf[4];
	int len = 1;

    for(int j = 0; j < 4; j++)
    {
        //NSLog(@"read int: %@", [NSDate date]);
        uint8_t buffff[1];
        [self.iStream read:buffff maxLength:1];
        [data appendBytes:(const void *)buffff length:1];
        len++;

    }
	//len = [self.iStream read:buf maxLength:4];

	/*if(len > 0 && len == 4) {
        //NSLog(@"if(len > 0 && len == 4)");

		[data appendBytes:(const void *)buf length:len];
		
	} */
	/*else {

			if(len > 0)
			{
                NSLog(@"if(len > 0)");

				[data appendBytes:(const void *)buf length:len];
				int len2 = 4 - len;
				uint8_t buf2[len2];
				int len3 = [self.iStream read:buf2 maxLength:len2];
				if(len3 > 0 && len3 == len2){
					[data appendBytes:(const void *)buf2 length:len3];
				} 
				else{
					if(len3 > 0){
						[data appendBytes:(const void *)buf2 length:len3];
						int len4 = len2 - len3;
						uint8_t buf3[len4];
						int len5 = [self.iStream read:buf3 maxLength:len4];
						[data appendBytes:(const void *)buf3 length:len5];
					}
				}
				
			}
			else {
                
                
				NSLog(@"int No data. len = %d", len);
				
				@throw [NSException
						exceptionWithName:@"readIntFromServer error"
						reason:@"Can't read from server"
						userInfo:nil];
			}


		
		
	}     */
	uint32_t p = 0;
	[data getBytes:&p length:sizeof(uint32_t)];
	uint32_t i = CFSwapInt32BigToHost(p);
	return i;
	
}

-(double)readDoubleFromServer
{
	//NSLog(@"Data received");
	
	NSMutableData *data = [[[NSMutableData alloc] init] autorelease];
	
	uint8_t buf[8];
	unsigned int len = 0;
	len = [self.iStream read:buf maxLength:8];
	if(len > 0 && len == 8) {    
		[data appendBytes:(const void *)buf length:len];
	}
	else {
		if(len > 0)
		{
			[data appendBytes:(const void *)buf length:len];
			int len2 = 8 - len;
			uint8_t buf2[len2];
			int len3 = [self.iStream read:buf2 maxLength:len2];
			[data appendBytes:(const void *)buf2 length:len3];
		}
		else {
			//NSLog(@" double No data. len = %d", len);
			@throw [NSException
					exceptionWithName:@"readDoubleFromServer error"
					reason:@"Can't read from server"
					userInfo:nil];
			return 0;
		}
	}
	
	CFSwappedFloat64 p;
	[data getBytes:&p length:sizeof(double)];
    
	double i = CFConvertDoubleSwappedToHost(p);
	//[data release];
	return i;
	
}

-(float)readFloatFromServer
{
	//NSLog(@"Data received");
	
	NSMutableData *data = [[[NSMutableData alloc] init] autorelease];
	
	uint8_t buf[8];
	unsigned int len = 0;
	len = [self.iStream read:buf maxLength:8];
	if(len > 0 && len == 8) {    
		[data appendBytes:(const void *)buf length:len];
	}
	else {
		if(len > 0)
		{
			[data appendBytes:(const void *)buf length:len];
			int len2 = 8 - len;
			uint8_t buf2[len2];
			int len3 = [self.iStream read:buf2 maxLength:len2];
			[data appendBytes:(const void *)buf2 length:len3];
		}
		else {
			//NSLog(@" double No data. len = %d", len);
			@throw [NSException
					exceptionWithName:@"readDoubleFromServer error"
					reason:@"Can't read from server"
					userInfo:nil];
			return 0;
		}
	}
	
	CFSwappedFloat64 p;
	[data getBytes:&p length:sizeof(double)];
    
	float i = CFConvertDoubleSwappedToHost(p);
	//[data release];
	return i;
	
}

-(uint16_t)readShortFromServer
{
	//NSLog(@"Data received");
	
	NSMutableData *data = [[[NSMutableData alloc] init] autorelease];
	
	uint8_t buf[2];
	unsigned int len = 0;
	len = [self.iStream read:buf maxLength:2];
	if(len > 0 && len == 2) {    
		[data appendBytes:(const void *)buf length:len];
		
	} else {
		if(len > 0)
		{
			[data appendBytes:(const void *)buf length:len];
			int len2 = 2 - len;
			uint8_t buf2[len2];
			int len3 = [self.iStream read:buf2 maxLength:len2];
			[data appendBytes:(const void *)buf2 length:len3];
		}
		else {
			NSLog(@"short No data. len = %d", len);
			@throw [NSException
					exceptionWithName:@"readShortFromServer error"
					reason:@"Can't read from server"
					userInfo:nil];
			return 0;
		}
		
		
	}
	
	uint16_t p;
	[data getBytes:&p length:sizeof(unsigned short)];
	uint16_t i = CFSwapInt16BigToHost(p);
	//NSLog(@"len = %d", len);
	//NSLog(@"number = %d", i);
	//[data release];
	return i;
	
}

-(NSString *)readStringFromServer:(int)l
{
	NSMutableData *data = [[[NSMutableData alloc] init] autorelease];
	uint8_t buf[l];
	unsigned int len = 0;
    if([self.iStream respondsToSelector:@selector(read:maxLength:)])
    {
        len = [self.iStream read:buf maxLength:l];
        if(len == l && len > 0) {
            [data appendBytes:(const void *)buf length:len];

        } else {
            if(len > 0)
            {
                [data appendBytes:(const void *)buf length:len];
                int len2 = l - len;
                uint8_t buf2[len2];
                int len3 = [self.iStream read:buf2 maxLength:len2];
                [data appendBytes:(const void *)buf2 length:len3];
            }
            else {
                NSLog(@"short No data. len = %d", len);
                @throw [NSException
                        exceptionWithName:@"readStringFromServer error"
                                   reason:@"Can't read from server"
                                 userInfo:nil];
                return @"";
            }
        }
        NSString *str = [[NSString alloc] initWithData:data encoding:NSASCIIStringEncoding];
        return [str autorelease];
    }

    return @"";

	

}

/*[
//handle stream events
- (void)stream:(NSStream *)stream handleEvent:(NSStreamEvent)eventCode {
    NSLog(@"handleEvent in networking");
    switch(eventCode) {
		case NSStreamEventHasSpaceAvailable:
		{
			NSLog(@"NSStreamEventHasSpaceAvailable");
		} break;
		case NSStreamEventErrorOccurred:
		{
			NSLog(@"NSStreamEventErrorOccurred");
		} break;
		case NSStreamEventEndEncountered:
		{
			NSLog(@"NSStreamEventEndEncountered");
		} break;	
        case NSStreamEventHasBytesAvailable:
        {
			NSLog(@"Data received");
            if (data == nil) {
                data = [[NSMutableData alloc] init];
            }
            uint8_t buf[8];
            unsigned int len = 0;
            len = [(NSInputStream *)stream read:buf maxLength:8];
            if(len) {    
                [data appendBytes:(const void *)buf length:len];
                int bytesRead;
                bytesRead += len;
            } else {
                NSLog(@"No data.");
            }
            
            NSString *str = [[NSString alloc] initWithData:data 
												  encoding:NSUTF8StringEncoding];
            NSLog(str);
            UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"From server" 
                                                            message:str 
                                                           delegate:self 
                                                  cancelButtonTitle:@"OK" 
                                                  otherButtonTitles:nil];
            [alert show];
            [alert release];
			
            [str release];
            [data release];        
            data = nil;
        } break;
    }
}
*/
//disconnect from server

- (void)stream:(NSStream *)stream handleEvent:(NSStreamEvent)eventCode {
    NSLog(@"stream:handleEvent: is invoked...");
	
    switch(eventCode) {
        case NSStreamEventErrorOccurred:
        {
            NSError *theError = [stream streamError];
            /*NSAlert *theAlert = [[NSAlert alloc] init]; // modal delegate releases
            [theAlert setMessageText:@"Error reading stream!"];
            [theAlert setInformativeText:[NSString stringWithFormat:@"Error %i: %@",
										  [theError code], [theError localizedDescription]]];
            [theAlert addButtonWithTitle:@"OK"];
            [theAlert beginSheetModalForWindow:[NSApp mainWindow]
								 modalDelegate:self
								didEndSelector:@selector(alertDidEnd:returnCode:contextInfo:)
								   contextInfo:nil];*/
			NSLog(@"Error %i: %@",[theError code], [theError localizedDescription]);
			isStreamReadyToWrite = NO;
            [stream close];
            [stream release];
            break;
        }
        case NSStreamEventHasSpaceAvailable:
        {
            NSLog(@"NSStreamEventHasSpaceAvailable");
            isStreamReadyToWrite = YES;
            break;
        }
        case NSStreamEventEndEncountered:
        {
            NSLog(@"stream ended; will be closed") ;
            [stream close];
            [stream removeFromRunLoop:[NSRunLoop currentRunLoop]
                              forMode:NSDefaultRunLoopMode];
            [stream release];
            stream = nil; // stream is ivar, so reinit it
            break;
        }
			// continued ....
    }
}

-(void) disconnect {
    [self.iStream close];
    [self.oStream close];
    [iStream release];
	[oStream release];
    iStream = nil;
    oStream = nil;
    //[self.iStream removeFromRunLoop:[NSRunLoop currentRunLoop] forMode:NSDefaultRunLoopMode];
    //[self.oStream removeFromRunLoop:[NSRunLoop currentRunLoop] forMode:NSDefaultRunLoopMode];


}

- (void)dealloc {

	[iStream release];
	[oStream release];
    [super dealloc];
}
@end
