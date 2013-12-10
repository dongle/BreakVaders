//
//  SettingsManager.h
//  Comet3DGame
//
//  Created by Cole Krumbholz on 6/27/10.
//  Copyright 2010 Koduco. All rights reserved.
//

#import <Foundation/Foundation.h>



@interface SettingsManager : NSObject {
	NSMutableDictionary *_settings;
}

- (void) addStringFor: (NSString *) key init: (NSString *) value;
- (void) addIntFor: (NSString *) key init: (int) value;
- (void) addFloatFor: (NSString *) key init: (float) value;
- (void) addOptionsFor: (NSString *) key with: (NSArray *) options init: (int) value;

- (void) remove: (NSString *) key;

- (BOOL) exists: (NSString *) key;

- (NSString *) get: (NSString *) key;
- (int) getInt: (NSString *) key;
- (float) getFloat: (NSString *) key;

- (void) set: (NSString *) key to: (NSString *) value;
- (void) set: (NSString *) key toInt: (int) value;
- (void) set: (NSString *) key toFloat: (float) value;

- (void) inc: (NSString *) key;
- (void) dec: (NSString *) key;
- (void) inc: (NSString *) key by: (float) num;
- (void) dec: (NSString *) key by: (float) num;

/* metastuff: a dictionary of meta key-object pairs for each setting */
- (void) setMetaFor: (NSString *) key to: (NSDictionary *) value;
- (id) get: (NSString *) key meta: (NSString *) metakey;

/* metalookup: finds a meta object based on a format string. (example "label-%@" 
   which will substitute this setting's current value into %@. always use %@)
   Also if the meta key has a wildcard "*" it will match if and only if no
   other match exists for the setting's current value. 

 Examples:
   setting=0; meta: ["ver0"="Version Zero", "ver1"="Version One"]; metalookup("ver%@")="Version Zero"
   setting=5; meta: ["ver0"="Version Zero", "ver*"="Big Version"]; metalookup("ver%@")="Big Version"
 */
- (id) get: (NSString *) key metaLookup: (NSString *) format;

/* metareplace: returns a string by substituting this setting's current value into 
   the meta object. In order to work, meta objects should be strings of the form
   "blabla-%@" 

 Example:
   setting=50; meta: ["label"="%@ kilos"]; metareplace("label")="50 kilos"
 */
- (NSString *) get: (NSString *) key metaReplace: (NSString *) metakey;

/* metalookupandreplace: does both of the above 
 
 Examples:
   setting="YES"; meta: ["ifNO"="say %@","ifYES"="say hell %@"]; metalookupandreplace("if%@")="say hell YES"
   setting=5; meta: ["label*"="%@ moves","label1"="%@ move"]; metalookupandreplace("label%@")="5 moves"
   setting=1; meta: ["label*"="%@ moves","label1"="%@ move"]; metalookupandreplace("label%@")="1 move"
 */
- (NSString *) get: (NSString *) key metaLookupAndReplace: (NSString *) format;


/* serialization/ deserialization */
- (void) addSettingsFromPlistDict: (NSDictionary *) pdict;
- (NSDictionary*) toPlistDict;
	
@end

@interface SettingsObject : NSObject {
	NSString *_sval;
	NSNumber *_nval;
	NSArray *_options;
	int _curopt;
	NSDictionary *_meta;
	int _type;
}

@property (nonatomic, retain) NSString *sval;
@property (nonatomic, retain) NSNumber *nval;
@property (nonatomic, retain) NSArray *options;
@property (readwrite, assign) int curopt;
@property (nonatomic, retain) NSDictionary *meta;
@property (readwrite, assign) int type;

- (id) initWithPlistArray: (NSArray *) parray;
- (NSArray *) toPlistArray;
@end