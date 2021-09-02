//
//  HMBLECenterHandle.h
//  OBD
//
//  Created by 何可人 on 2021/6/23.
//  Copyright © 2021 TOPDON Technology Co., Ltd. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <CoreBluetooth/CoreBluetooth.h>
#import <UIKit/UIKit.h>

#define HDidDiscoverPeripheral @"HDidDiscoverPeripheral" //已发现设备
#define HDidConnectPeripheral @"HDidConnectPeripheral" //已连接设备
#define HDidDiscoverCharacteristics @"HDidDiscoverCharacteristics" //已发现特征值
#define HDidDisconnectPeripheral @"HDidDisconnectPeripheral"//已断开设备


#define HBLEManager [HMBLECenterHandle sharedHMBLECenterHandle]

@protocol HBLECenterDelegate <NSObject>

@optional
- (void)didUpdateValueForUUID:(NSString *)UUID withHexString:(NSString *)hexString;

@end

@interface HMBLECenterHandle : NSObject<CBCentralManagerDelegate,CBPeripheralDelegate>

+(HMBLECenterHandle *)sharedHMBLECenterHandle;

@property (nonatomic,strong)CBCentralManager *centralManager;
@property (nonatomic,strong)CBPeripheral *discoveredPeripheral;
@property (nonatomic,assign)BOOL isConnect;
@property (nonatomic,strong)NSMutableArray *peripheralArr;
@property (nonatomic, weak) id<HBLECenterDelegate>delegate;

-(void)scan;
-(void)stop;
-(void)cancelConnect;

- (BOOL)sendData:(NSArray *)dataStr WithUUID:(NSString *)UUID;
- (BOOL)sendhexData:(NSArray *)dataArr WithUUID:(NSString *)UUID;
- (BOOL)sendDataString:(NSString *)dataString WithUUID:(NSString *)UUID;
- (void)readValueWithUUID:(NSString *)UUID;
- (void)ConnectedDevicesWithPeripheral:(CBPeripheral *)peripheral;

@end
