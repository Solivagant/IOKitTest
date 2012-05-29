//
//  ViewController.m
//  IOKitTest
//
//  Created by Geraldo Nascimento on 1/25/12.
//  Copyright (c) 2012 Bold International. All rights reserved.
//

#import "ViewController.h"
#include <IOKit/hid/IOHIDEventSystem.h>
#include <stdio.h>

@implementation ViewController

void handle_event (void* target, void* refcon, IOHIDServiceRef service, IOHIDEventRef event) {
    
    if (IOHIDEventGetType(event)==kIOHIDEventTypeAmbientLightSensor){ // Ambient Light Sensor Event
        
        int luxValue=IOHIDEventGetIntegerValue(event, (IOHIDEventField)kIOHIDEventFieldAmbientLightSensorLevel); // lux Event Field
        int channel0=IOHIDEventGetIntegerValue(event, (IOHIDEventField)kIOHIDEventFieldAmbientLightSensorRawChannel0); // ch0 Event Field
        int channel1=IOHIDEventGetIntegerValue(event, (IOHIDEventField)kIOHIDEventFieldAmbientLightSensorRawChannel1); // ch1 Event Field
        
        NSLog(@"IOHID: ALS Sensor: Lux : %d  ch0 : %d   ch1 : %d",luxValue,channel0,channel1);
        // lux==0 : no light, lux==1000+ almost direct sunlight				
    } 
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Release any cached data, images, etc that aren't in use.
}

#pragma mark - View lifecycle

- (void)viewDidLoad
{
    [super viewDidLoad];
	// Do any additional setup after loading the view, typically from a nib.
    
    // Create and open an event system.
    IOHIDEventSystemRef system = IOHIDEventSystemCreate(NULL);
    
    // Set the PrimaryUsagePage and PrimaryUsage for the Ambient Light Sensor Service 
    int page = 0xff00;
    int usage = 4;
    
    // Create a dictionary to match the service with
    CFNumberRef nums[2];
    CFStringRef keys[2];
    keys[0] = CFStringCreateWithCString(0, "PrimaryUsagePage", 0);
    keys[1] = CFStringCreateWithCString(0, "PrimaryUsage", 0);
    nums[0] = CFNumberCreate(0, kCFNumberSInt32Type, &page);
    nums[1] = CFNumberCreate(0, kCFNumberSInt32Type, &usage);
    
    
    CFDictionaryRef dict = CFDictionaryCreate(0, (const void**)keys, (const void**)nums, 2, &kCFTypeDictionaryKeyCallBacks, &kCFTypeDictionaryValueCallBacks);
    
    // Get all services matching the above criteria
    CFArrayRef srvs = (CFArrayRef)IOHIDEventSystemCopyMatchingServices(system, dict, 0, 0, 0,0);
    
    NSLog(@"%@", srvs);
    
    // Get the service
    IOHIDServiceRef serv = (IOHIDServiceRef)CFArrayGetValueAtIndex(srvs, 0);
    int interval = 1 ;
    
    // set the ReportInterval of ALS service to something faster than the default (5428500)
    IOHIDServiceSetProperty((IOHIDServiceRef)serv, CFSTR("ReportInterval"), CFNumberCreate(0, kCFNumberSInt32Type, &interval));
    
    IOHIDEventSystemOpen(system, handle_event, NULL, NULL, NULL);
    printf("HID Event system should now be running. Hit enter to quit any time.\n");
    getchar();
    
    int defaultInterval=5428500;
    IOHIDServiceSetProperty((IOHIDServiceRef)serv, CFSTR("ReportInterval"), CFNumberCreate(0, kCFNumberSInt32Type, &defaultInterval));
    
    IOHIDEventSystemClose(system, NULL);
    CFRelease(system);
}

- (void)viewDidUnload
{
    [super viewDidUnload];
    // Release any retained subviews of the main view.
    // e.g. self.myOutlet = nil;
}

- (void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
}

- (void)viewDidAppear:(BOOL)animated
{
    [super viewDidAppear:animated];
}

- (void)viewWillDisappear:(BOOL)animated
{
	[super viewWillDisappear:animated];
}

- (void)viewDidDisappear:(BOOL)animated
{
	[super viewDidDisappear:animated];
}

- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation
{
    // Return YES for supported orientations
    return (interfaceOrientation != UIInterfaceOrientationPortraitUpsideDown);
}







@end
