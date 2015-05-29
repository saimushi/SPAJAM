
#import "MProductAgent.h"


#pragma mark - ProductAgent
#pragma mark -
@interface MProductAgent ()
{
    //SKProductsRequest用
    NSSet               *_productIdentifiers;
    SKProductsRequest   *_productsRequest;
    void (^_completeBlock) (SKProductsResponse *response);
    void (^_errorBlock) (NSError *error);
    
}
@end

@implementation MProductAgent

static NSMutableArray *_productDelegates;

#pragma mark - プロダクトに関する情報のリクエスト(SKProductsRequest)

+ (void)initialize{
    if (!_productDelegates) {
        _productDelegates = [[NSMutableArray alloc]init];
    }
}

//複数のプロダクトを検索する場合
+ (id)productsWithProductIdentifiers:(NSSet *)productIdentifiers
                       completeBlock:(void (^)(SKProductsResponse *))cBlock
                          errorBlock:(void (^)(NSError *))eBlock
{
    return [[MProductAgent alloc] initWithProductIdentifiers:productIdentifiers
                                              completeBlock:[cBlock copy]
                                                 errorBlock:[eBlock copy]];
}

//1つのプロダクトを検索する場合
+ (id)productWithProductIdentifier:(NSString *)productIdentifier
                     completeBlock:(void (^)(SKProductsResponse *response, SKProduct *))cBlock
                        errorBlock:(void (^)(NSError *))eBlock
{
    if (!productIdentifier) {
        NSError *error = [NSError errorWithDomain:@"ProductErrorDomain" code:__LINE__
                                         userInfo:@{NSLocalizedDescriptionKey: @"プロダクトが指定されていません。"}];
        if (eBlock)
        {
            eBlock(error);
        }
        return nil;
    }
    
    return [[MProductAgent alloc]initWithProductIdentifiers:[NSSet setWithObject:productIdentifier]
                                              completeBlock:^(SKProductsResponse *response)
            {
                //ProductIDが有効な物かチェック
                SKProduct *valiedProduct = nil;
                for (SKProduct *product in response.products)
                {
                    NSLog(@"ALL Products -------------------------------");
                    NSLog(@"%@",product.productIdentifier);
                    NSLog(@"%@",product.localizedTitle);
                    NSLog(@"%@",product.localizedDescription);
                    NSLog(@"%@",product.price);
                    NSLog(@"%@",product.debugDescription);
                    NSLog(@"%@",[product.priceLocale localeIdentifier]);
                    NSLog(@"-------------------------------");
                    if ([product.productIdentifier isEqualToString:productIdentifier])
                    {
                        NSLog(@"-------------------------------");
                        NSLog(@"%@",product.productIdentifier);
                        NSLog(@"%@",product.localizedTitle);
                        NSLog(@"%@",product.localizedDescription);
                        NSLog(@"%@",product.price);
                        NSLog(@"%@",product.debugDescription);
                        NSLog(@"%@",[product.priceLocale localeIdentifier]);
                        NSLog(@"-------------------------------");
                        valiedProduct = product;
                        break;
                    }
                }
                //
//                for (NSString *invalidProductIdentifier in response.invalidProductIdentifiers)
//                {
//                    NSLog(@"invalidProductIdentifier %@",invalidProductIdentifier);
//                }
                
                if (valiedProduct)
                {
                    //有効なプロダクトあり
                    if (cBlock)
                    {
                        cBlock(response, valiedProduct);
                    }
                }
                else{
                    //有効なプロダクトなし
                    if (eBlock)
                    {
                        NSError *error = [NSError errorWithDomain:@"ProductErrorDomain"
                                                             code:__LINE__
                                                         userInfo:@{NSLocalizedDescriptionKey : @"対象のアイテムが存在しませんでした。"}];
                        eBlock(error);
                    }
                }
            } errorBlock:^(NSError *error)
            {
                if (eBlock)
                {
                    eBlock(error);
                }
            }];
}

- (id)initWithProductIdentifiers:(NSSet *)productIdentifiers
                   completeBlock:(void (^)(SKProductsResponse *))cBlock
                      errorBlock:(void (^)(NSError *))eBlock
{
    self = [super init];
    if (self) {
        //SKProductsRequest用
        _productIdentifiers = [productIdentifiers copy];
        _completeBlock = [cBlock copy];
        _errorBlock = [eBlock copy];
        
        //SKProductsRequestを開始
        if (productIdentifiers)
        {
            //開放されないように登録
            [_productDelegates addObject:self];
            
            //開始
            _productsRequest = [[SKProductsRequest alloc]initWithProductIdentifiers:_productIdentifiers];
            _productsRequest.delegate = self;
            [_productsRequest start];
        }
    }
    return self;
}


#pragma mark --- request doing

- (void)productsRequest:(SKProductsRequest *)request didReceiveResponse:(SKProductsResponse *)response
{
    if ([request isEqual:_productsRequest])
    {
        if (_completeBlock)
        {
            _completeBlock(response);
        }
    }
}

- (void)requestDidFinish:(SKRequest *)request
{
    if ([request isEqual:_productsRequest])
    {
        _productsRequest.delegate = nil;
        [_productDelegates removeObject:self];
    }
}

- (void)request:(SKRequest *)request didFailWithError:(NSError *)error
{
    if ([request isEqual:_productsRequest])
    {
        if (_errorBlock)
        {
            NSError *error = [NSError errorWithDomain:@"ProductErrorDomain"
                                                 code:__LINE__
                                             userInfo:@{NSLocalizedDescriptionKey : NSLocalizedString(STORE_GET_ITEM_ERROR_KEY, @"アイテムを取得できませんでした。")}];
            _errorBlock(error);
        }
        _productsRequest.delegate = nil;
        [_productDelegates removeObject:self];
    }
}

@end
