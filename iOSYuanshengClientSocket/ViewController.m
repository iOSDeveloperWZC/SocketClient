//
//  ViewController.m
//  iOSYuanshengClientSocket
//
//  Created by ataw on 16/9/13.
//  Copyright © 2016年 王宗成. All rights reserved.
//

#import "ViewController.h"
#import <sys/socket.h>
#import <netinet6/in6.h>
#import <arpa/inet.h>
#import <netdb.h>
@interface ViewController ()
@property (strong, nonatomic) IBOutlet UITextView *message;
@property (strong, nonatomic) IBOutlet UITextField *infoText;

@property (strong, nonatomic) IBOutlet UITextField *ipText;
@end

@implementation ViewController
{
    int clientSocketId ;
}
- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view, typically from a nib.
   
}
- (IBAction)connect:(id)sender {
    
    NSThread *thread = [[NSThread alloc]initWithTarget:self selector:@selector(creatClientSocketTCPConnect) object:nil];
    
    [thread start];
}

- (IBAction)sendInforToServe:(id)sender {
    
    send(clientSocketId, [_infoText.text UTF8String], 1024, 0);
}


-(void)showMessage:(NSString *)text
{
    dispatch_async(dispatch_get_main_queue(), ^{
        
        NSString *s = [NSString stringWithFormat:@"%@\n",_message.text];
        _message.text = [s stringByAppendingString:text];
    });
}

-(void)creatClientSocketTCPConnect
{
    ////#define BaseUrl @"http://192.168.66.3:8093"
//    NSString * host = [url host];
    
    //数据流：SOCK_STREAM 针对TCP 数据报:SOCK_DGRAM 针对UDP
    //    1、创建Socket 并配置
    int error = -1;
    //    IPPROTO_TCP <=0 默认为TCP
    clientSocketId  = socket(AF_INET, SOCK_STREAM, 0);
    
    BOOL success = clientSocketId != -1?YES:NO;
    
    struct sockaddr_in addr;
    
    if (success) {
        
        //配置要连接的远程主机的地址端口、协议
        struct sockaddr_in peerAddr;
        memset(&peerAddr, 0, sizeof(peerAddr));
        peerAddr.sin_len = sizeof(peerAddr);
        peerAddr.sin_family = AF_INET;
        peerAddr.sin_port = htons(8080);
        peerAddr.sin_addr.s_addr = inet_addr([_ipText.text UTF8String]);
        
        socklen_t addrLen;
        addrLen = sizeof(peerAddr);
        [self showMessage:@"客户端Socket创建成功:即将连接"];
        
        // 第三步：连接服务器
        error = connect(clientSocketId, (struct sockaddr *)&peerAddr, addrLen);
        
        success = (error == 0);
        
        if (success) {
            // 第四步：获取套接字信息
            error = getsockname(clientSocketId, (struct sockaddr *)&addr, &addrLen);
            success = (error == 0);
            
            if (success) {
                
                [self showMessage:[NSString stringWithFormat:@"和服务器连接成功, 本地ip:%s,端口号:%d",
                                   inet_ntoa(addr.sin_addr),
                                   ntohs(addr.sin_port)]];
                
                char buf[1024];
                size_t len = sizeof(buf);
                
                while (1) {
                    
                    recv(clientSocketId, buf, len, 0);
                    if (strlen(buf) != 0) {
                        NSString *str = [NSString stringWithCString:buf encoding:NSUTF8StringEncoding];
                        if (str.length >= 1) {
                            [self showMessage:str];
                        }
                    }
                    
                }

            }
            
            
        }
        else {
            
            [self showMessage:@"连接失败"];
            // 第六步：关闭套接字
            close(clientSocketId);
        }
    }
    else
    {
        [self showMessage:@"客户端Socket创建失败"];
    }
    
}

-(void)touchesBegan:(NSSet<UITouch *> *)touches withEvent:(UIEvent *)event
{
    [self.view endEditing:YES];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

@end
