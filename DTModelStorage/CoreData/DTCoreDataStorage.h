//
//  DTCoreDataStorage.h
//  DTModelStorage
//
//  Created by Denys Telezhkin on 07.12.13.
//  Copyright (c) 2013 Denys Telezhkin. All rights reserved.
//
// Permission is hereby granted, free of charge, to any person obtaining a copy
// of this software and associated documentation files (the "Software"), to deal
// in the Software without restriction, including without limitation the rights
// to use, copy, modify, merge, publish, distribute, sublicense, and/or sell
// copies of the Software, and to permit persons to whom the Software is
// furnished to do so, subject to the following conditions:
//
// The above copyright notice and this permission notice shall be included in
// all copies or substantial portions of the Software.
//
// THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR
// IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY,
// FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE
// AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER
// LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM,
// OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN
// THE SOFTWARE.

#import "DTBaseStorage.h"
#import <CoreData/CoreData.h>

#pragma clang assume_nonnull begin

/**
 This class is used to provide CoreData storage. Storage object will automatically react to NSFetchResultsController changes and will call delegate with appropriate DTStorageUpdate object.
 */

@interface DTCoreDataStorage : DTBaseStorage <NSFetchedResultsControllerDelegate,DTStorageProtocol>

/**
 Use this method to create `DTCoreDataStorage` object with your NSFetchedResultsController.
 
 @param controller NSFetchedResultsController instance, that will be used as datasource.
 
 @return `DTCoreDataStorage` object.
 */

+(instancetype)storageWithFetchResultsController:(NSFetchedResultsController *)controller;

/**
 NSFetchedResultsController of current `DTCoreDataStorage` object.
 */
@property (nonatomic, strong, readonly) NSFetchedResultsController * fetchedResultsController;

@end

#pragma clang assume_nonnull end
