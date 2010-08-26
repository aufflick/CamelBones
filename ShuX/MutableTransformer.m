//
//  MutableTransformer.m
//  ShuX3
//
//  Created by Sherm Pendley on 3/12/05.
//  Copyright 2005 Sherm Pendley. All rights reserved.
//

#import "MutableTransformer.h"


@implementation MutableTransformer

+ (Class) transformedValueClass {
	return [NSMutableArray class];
}

+ (BOOL) allowsReverseTransformation {
	return YES;
}

- (id) transformedValue:(id)value {
	id array;
	id e;
	id object;

	if (nil == value) return nil;

	array = [NSMutableArray arrayWithCapacity:[value count]];
	e = [value objectEnumerator];

	while ((object = [e nextObject])) {
		[array addObject:[[object mutableCopy] autorelease]];
	}

	return array;
}

- (id) reverseTransformedValue:(id)value {
	return value;
}

@end
