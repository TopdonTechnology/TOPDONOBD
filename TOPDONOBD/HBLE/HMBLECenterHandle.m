//
//  HMBLECenterHandle.m
//  OBD
//
//  Created by 何可人 on 2021/6/23.
//  Copyright © 2021 TOPDON Technology Co., Ltd. All rights reserved.
//

#import "HMBLECenterHandle.h"
#import "HBLETools.h"

#define HBLEUUID @"HBLEUUID"//设备UUID

@interface HMBLECenterHandle ()

@property (nonatomic, strong) CBService * myService;

@end

@implementation HMBLECenterHandle

#pragma mark 创建单例
+(HMBLECenterHandle *)sharedHMBLECenterHandle {
    static HMBLECenterHandle *sharedCenter = nil;
    static dispatch_once_t onecToken;
    dispatch_once(&onecToken,^{
        sharedCenter = [[self alloc] init];
        [sharedCenter initObject];
    });
    return  sharedCenter;
}

#pragma mark 初始化
-(void)initObject {
    //CBCentralManagerOptionRestoreIdentifierKey : @"BTMobile BLE"  //后台模式
    NSDictionary *options = @{CBCentralManagerOptionShowPowerAlertKey:@YES};
    _centralManager = [[CBCentralManager alloc] initWithDelegate:self queue:nil options:options];
    _centralManager.delegate = self;
    
    _isConnect = NO;
}

//===================================蓝牙=====================================//
#pragma mark - 蓝牙代理
#pragma mark 蓝牙状态更新
-(void)centralManagerDidUpdateState:(CBCentralManager *)central{
    
    if (central.state != CBManagerStatePoweredOn) {
        NSLog(@"蓝牙未打开,请在设置中打开蓝牙");
        _isConnect = NO;
        [_peripheralArr removeAllObjects];
        [[NSNotificationCenter defaultCenter] postNotificationName:HDidDisconnectPeripheral object:self userInfo:nil];
        return;
    }

    NSLog(@"蓝牙OK~!");
    [self scan];
}

#pragma mark 获取蓝牙恢复时的各种状态
//在蓝牙于后台被杀掉时，重连之后会首先调用此方法，可以获取蓝牙恢复时的各种状态
- (void)centralManager:(CBCentralManager *)central willRestoreState:(NSDictionary<NSString *,id> *)dict{
    
}

#pragma mark 蓝牙扫描到设备回调
// 2 当扫描到4.0的设备后，系统会通过回调函数告诉我们设备的信息，然后我们就可以连接相应的设备
-(void)centralManager:(CBCentralManager *)central didDiscoverPeripheral:(CBPeripheral *)peripheral advertisementData:(NSDictionary *)advertisementData RSSI:(NSNumber *)RSSI {
    
    if (peripheral.state == CBPeripheralStateConnecting || peripheral.state == CBPeripheralStateConnected) {
        return;
    }
    
    if (peripheral.name.length > 0) {
        if (![self.peripheralArr containsObject:peripheral]) {
            [self.peripheralArr addObject:peripheral];
            [[NSNotificationCenter defaultCenter] postNotificationName:HDidDiscoverPeripheral object:nil];
        }
        
        NSString * uuid = [[NSUserDefaults standardUserDefaults] valueForKey:HBLEUUID];
        
        NSString * newUUID = [NSString stringWithFormat:@"%@", peripheral.identifier];
        
        //自动重连
        if ([newUUID isEqualToString:uuid]) {
            [self ConnectedDevicesWithPeripheral:peripheral];
            return;
        }
    }
}

#pragma mark 蓝牙自动重连
- (void)ConnectedDevicesWithPeripheral:(CBPeripheral *)peripheral
{
    if (_discoveredPeripheral) {
        [self cancelConnect];
        [self stop];
    }
    
    if (_discoveredPeripheral != peripheral || !_isConnect) {
        self.discoveredPeripheral = peripheral;
        if (self.discoveredPeripheral) {
            [_centralManager connectPeripheral:peripheral options:nil];
            NSLog(@"正在连接");
        }else{
            NSLog(@"连接无效");
            [self scan];
            return;
        }
    }
}

#pragma mark 蓝牙连接失败回调
-(void)centralManager:(CBCentralManager *)central didFailToConnectPeripheral:(CBPeripheral *)peripheral error:(NSError *)error{
    NSLog(@"连接失败 ： %@，  %@",peripheral,error.localizedDescription);
    
    _isConnect = NO;
    
    if (_discoveredPeripheral) {
        _discoveredPeripheral.delegate = nil;
        _discoveredPeripheral = nil;
    }
    
    [self scan];
    
    [[NSNotificationCenter defaultCenter] postNotificationName:HDidDisconnectPeripheral object:self userInfo:nil];
}

#pragma mark 蓝牙连接成功回调
// 3 当连接成功后，系统会通过回调函数告诉我们，然后我们就在这个回调里去扫描设备下所有的服务和特征
-(void)centralManager:(CBCentralManager *)central didConnectPeripheral:(CBPeripheral *)peripheral {
    
    NSLog(@"%@",[NSString stringWithFormat:@"成功连接 peripheral: %@ with UUID: %@  \n",peripheral,peripheral.identifier]);
    
    [self stop];
    
    NSString * uuid = [NSString stringWithFormat:@"%@", peripheral.identifier];
    [[NSUserDefaults standardUserDefaults] setValue:uuid forKey:HBLEUUID];
    [[NSUserDefaults standardUserDefaults] synchronize];
    
    _isConnect = YES;
    
    peripheral.delegate = self;
    
    //指定服务
    [peripheral discoverServices:nil];
    
    [[NSNotificationCenter defaultCenter] postNotificationName:HDidConnectPeripheral object:self userInfo:nil];
    
}

#pragma mark 蓝牙连接断开回调
//掉线时调用
-(void)centralManager:(CBCentralManager *)central didDisconnectPeripheral:(CBPeripheral *)peripheral error:(NSError *)error{
    NSLog(@"外设已经断开：%@", peripheral);
    
    if (_discoveredPeripheral == peripheral) {
        
        _isConnect = NO;
        
        if (_discoveredPeripheral) {
            _discoveredPeripheral.delegate = nil;
            _discoveredPeripheral = nil;
        }
        
        [self scan];
        
        [[NSNotificationCenter defaultCenter] postNotificationName:HDidDisconnectPeripheral object:self userInfo:nil];
    }
}

#pragma mark 蓝牙已发现服务回调
// 4 已发现服务
-(void)peripheral:(CBPeripheral *)peripheral didDiscoverServices:(NSError *)error{
    if (error != nil) {
        NSLog(@"蓝牙服务错误: %@",error.localizedDescription);
    }

    NSLog(@"发现服务： %@",peripheral.services);
    
    //处理我们需要的特征
    for (CBService *service in peripheral.services) {
        [peripheral discoverCharacteristics:nil forService:service];
        NSLog(@"特征值处理完了");
    }
}

#pragma mark 蓝牙已发现特征值回调
// 5 已搜索到Characteristics
-(void)peripheral:(CBPeripheral *)peripheral didDiscoverCharacteristicsForService:(CBService *)service error:(NSError *)error {
    if (error != nil) {
        NSLog(@"发现特征错误:  %@",error.localizedDescription);
//        return;
    }

    self.myService = service;
    
    //根据不同的特征执行不同的命令
    for (CBCharacteristic *characteristic in service.characteristics) {
        if ([characteristic.UUID isEqual:[CBUUID UUIDWithString:@"FFF1"]] && characteristic.properties & CBCharacteristicPropertyNotify) {
            
            [peripheral setNotifyValue:YES forCharacteristic:characteristic];
        }
    }
    
    
}

#pragma mark 蓝牙获取数据回调
//获取外设发来的数据，不论是read和notify,获取数据都是从这个方法中读取。
- (void)peripheral:(CBPeripheral *)peripheral didUpdateValueForCharacteristic:(CBCharacteristic *)characteristic error:(NSError *)error {
    if (error != nil) {
        NSLog(@"获取数据错误:  %@",error.localizedDescription);
        return;
    }
    
    NSString *stringFromData = [[NSString alloc] initWithData:characteristic.value encoding:NSUTF8StringEncoding];
    
    if (stringFromData.length == 0) {
        NSLog(@"蓝牙接收到的数据为空！");
        return;
    }
    
    NSLog(@"\n接收:\n原始数据:%@\nData:%@",characteristic.value,stringFromData);
    
    if ([self.delegate respondsToSelector:@selector(didUpdateValueForUUID:withHexString:)]) {
        [self.delegate didUpdateValueForUUID:characteristic.UUID.UUIDString withHexString:stringFromData];
    }
}


#pragma mark 发送数据回调
- (void)peripheral:(CBPeripheral *)peripheral didWriteValueForCharacteristic:(CBCharacteristic *)characteristic error:(NSError *)error{
    if (error) {
        NSLog(@"写入失败：%@", error);
    }else{
        NSLog(@"写入成功");
    }
    
}

#pragma mark - 数据处理
#pragma mark 发送10进制数据
- (BOOL)sendData:(NSArray *)dataArr WithUUID:(NSString *)UUID{
    if (!self.myService.characteristics) {
        return NO;
    }
    
    for (CBCharacteristic *characteristic in self.myService.characteristics) {
        if ([characteristic.UUID isEqual:[CBUUID UUIDWithString:UUID]]) {
            
            NSMutableString * mStr = @"".mutableCopy;
            
            for (NSNumber * nub in dataArr) {
                NSString * hexStr = [HBLETools getHexByDecimal:[nub intValue]];
                
                if (hexStr.length == 1) {
                    hexStr = [NSString stringWithFormat:@"0%@", hexStr];
                }
                
                [mStr appendString:hexStr];
            }
            
            NSData *data = [HBLETools convertHexStrToData:mStr];
            NSLog(@"\nsend:\nUUID:%@\nData:%@", UUID,data);
            [self.discoveredPeripheral writeValue:data forCharacteristic:characteristic type:0];
            
            return YES;
        }
    }
    
    return NO;
}

#pragma mark 发送16进制数据
- (BOOL)sendhexData:(NSArray *)dataArr WithUUID:(NSString *)UUID{
    if (!self.myService.characteristics) {
        return NO;
    }
    
    for (CBCharacteristic *characteristic in self.myService.characteristics) {
        if ([characteristic.UUID isEqual:[CBUUID UUIDWithString:UUID]]) {
            
            NSMutableString * mStr = @"".mutableCopy;
            
            for (NSString * hexStr in dataArr) {
                [mStr appendString:hexStr];
            }
            
            NSMutableData *data = [HBLETools convertHexStrToData:mStr].mutableCopy;
            
            NSLog(@"\nsend:\nUUID:%@\nData:%@", UUID,data);
            [self.discoveredPeripheral writeValue:data forCharacteristic:characteristic type:CBCharacteristicWriteWithoutResponse];
            
            return YES;
        }
    }
    
    return NO;
}

#pragma mark 发送字符串数据
- (BOOL)sendDataString:(NSString *)dataString WithUUID:(NSString *)UUID{
    if (!self.myService.characteristics) {
        return NO;
    }
    
    for (CBCharacteristic *characteristic in self.myService.characteristics) {
        if ([characteristic.UUID isEqual:[CBUUID UUIDWithString:UUID]]) {
            
            NSData *data =[dataString dataUsingEncoding:NSUTF8StringEncoding];

            NSLog(@"\n发送:\nUUID:%@\n原始数据:%@\nData:%@", UUID,dataString,data);
            
            [self.discoveredPeripheral writeValue:data forCharacteristic:characteristic type:CBCharacteristicWriteWithoutResponse];
            
            return YES;
        }
    }
    
    return NO;
}

#pragma mark 读UUID的值
- (void)readValueWithUUID:(NSString *)UUID{
    for (CBCharacteristic *characteristic in self.myService.characteristics) {
        if ([characteristic.UUID isEqual:[CBUUID UUIDWithString:UUID]]) {
            [self.discoveredPeripheral readValueForCharacteristic:characteristic];
        }
    }
}

#pragma mark 中心读取外设实时数据
//中心读取外设实时数据
//这个方法一般不怎么用
-(void)peripheral:(CBPeripheral *)peripheral didUpdateNotificationStateForCharacteristic:(CBCharacteristic *)characteristic error:(NSError *)error{
    
    //测试
    if (error != nil) {
        NSLog(@"特征通知状态变化错误:%@",error.localizedDescription);
        
    } else {
        
        // Notification has started
        if (characteristic.isNotifying) {
            NSLog(@"特征通知已经开始：%@",characteristic);
            [peripheral readValueForCharacteristic:characteristic];
            
            [[NSNotificationCenter defaultCenter] postNotificationName:HDidDiscoverCharacteristics object:self userInfo:nil];
        } else {// Notification has stopped
            NSLog(@"特征通知已经停止： %@",characteristic);
            [_centralManager cancelPeripheralConnection:peripheral];
        }
    }
}


#pragma mark 扫描外设备
//通过制定的128的UUID，扫描外设备
-(void)scan{
    [_peripheralArr removeAllObjects];
    
    //不重复扫描已发现设备
    //CBCentralManagerScanOptionAllowDuplicatesKey设置为NO表示不重复扫瞄已发现设备，为YES就是允许。
    //CBCentralManagerOptionShowPowerAlertKey设置为YES就是在蓝牙未打开的时候显示弹框
    NSDictionary *option = @{CBCentralManagerScanOptionAllowDuplicatesKey : [NSNumber numberWithBool:NO],CBCentralManagerOptionShowPowerAlertKey:[NSNumber numberWithBool:YES]};
    
    [_centralManager scanForPeripheralsWithServices:nil options:option];
        
    NSLog(@"开始扫描");
}

#pragma mark 停止扫描外设备
-(void)stop{
    [_centralManager stopScan];
    [_peripheralArr removeAllObjects];
    NSLog(@"停止扫描");
}

#pragma mark 断开设备
-(void)cancelConnect {
    //主动断开设备
    NSLog(@"主动断开设备:%@", _discoveredPeripheral);
    if (_discoveredPeripheral) {
        [_centralManager cancelPeripheralConnection:_discoveredPeripheral];
    }
}

#pragma mark - 懒加载
- (NSMutableArray *)peripheralArr{
    if (!_peripheralArr) {
        _peripheralArr = [[NSMutableArray alloc] init];
        
    }
    return _peripheralArr;
}

@end

