#import "DTCoreDataStorage.h"

using namespace Cedar::Matchers;
using namespace Cedar::Doubles;


@interface DTCoreDataStorage()
-(void)startUpdate;
-(void)finishUpdate;

@property (nonatomic, strong) DTStorageUpdate * currentUpdate;

@end

SPEC_BEGIN(CoreDataStorage)

describe(@"CoreDataStorageSpecs", ^{
    __block DTCoreDataStorage *storage;
    
    beforeEach(^{
        storage = [DTCoreDataStorage storageWithFetchResultsController:nil];
        storage.delegate = (id)storage;
    });
    
    it(@"should not call delegate that does not respond to selector", ^{
        [storage startUpdate];
        [[storage.currentUpdate insertedSectionIndexes] addIndex:5];
        ^{
            [storage finishUpdate];
        } should_not raise_exception();
    });
});

SPEC_END
