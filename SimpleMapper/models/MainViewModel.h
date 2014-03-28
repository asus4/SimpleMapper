//
//  MainViewModel.h
//  SimpleMapper
//
//  Created by Koki Ibukuro on 2014/03/23.
//  Copyright (c) 2014年 Koki Ibukuro. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <Syphon/Syphon.h>
#import "BaseGLView.h"
#import "RectEditView.h"

@interface MainViewModel : NSObject
@property (weak) IBOutlet NSArrayController *syphonServersController;
@property (weak) IBOutlet BaseGLView *glView;
@property (weak) IBOutlet RectEditView *inEditView;
@property (weak) IBOutlet RectEditView *outEditView;

@property (nonatomic, strong) NSArray *selectedServerDescriptions;
@property (nonatomic, strong, readonly) SyphonClient* syphonClient;

- (void) reset;
- (void) finalize;

- (void) load;
- (void) save;

@end
