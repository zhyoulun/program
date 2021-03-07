![](/static/images/2102/p007.png)

## message format

### 概述

> the format of a message that can be split into chunks to support multiplexing depends on a higher level protocol. the message format should however contain the following fields which are nescessary for creating the chunks. 

- timestamp: message的timestamp
- length: message playload的长度
- type id
- message stream id: different [message streams] multiplexed onto the same [chunk stream] are demultiplexed based on their message stream IDs.

### 详细

rtmp message format:

- message header
    - message type(1B)
    - length(3B): payload size，单位B，大端序
    - timestamp(4B)：大端序
    - message stream id(3B)：大端序
- message payload

## chunk format

- chunk header
    - basic header(1B,2B,3B)
        - chunk stream ID: id范围3~65599，0,1,2是保留的: 0代表2B格式，1代表3B格式，2是低版本的一个保留值
            - 1B: id范围2~63
            - 2B: id范围64~319(0~255,+64)
            - 3B: id范围64~65599(0~65535,+64)
        - chunk type/fmt(2bit)：用来决定message header的format
    - message header(0B,3B,7B,11B)
        - type0(11B): 用于一个chunk stream的开头，以及当stream timestamp goes backward
            - timestamp(3B)，message的绝对时间戳。如果timestamp>=16777215(0xFFFFFF)，这个字段必须是16777215，表明需要使用extended timestamp字段来编码完整的32bit timestamp
            - message length(3B): 注意这个和chunk payload的长度不一样。chunk payload length is the maximum chunk size for all but the last chunk
            - message type id(1B): message的type
            - msg stream id(4B): 小端序
        - type1(7B): 不包含message stream id；streams with variable-sized message应该发一个这种类型的chunk
            - timestamp delta: 表示当前chunk和先前的chunk的timestamp diff。如果delta大于16777215，则该字段的值是16777215，使用extended timestamp表示完整的delta
            - message length
            - message type id
        - type2(3B): 不包含stream id和message length。streams with constant-szied message应该发一个这种类型的chunk
            - timestamp delta
        - type3(0B): 没有message header。stream id, message length, timestamp delta字段
    - extended timestamp
- chunk data

### protocol control message

rtmp chunk stream使用message type IDs 1,2,3,5,6 作为协议控制消息。这些消息包含了rtmp chunk stream protocol需要的信息。

这些protocol control messages必须使用message stream ID 0(control stream)，chunk stream ID是2.

- set chunk size(1): 用于通知对端设置一个新的最大chunk size
    - 默认maximun chunk size是128B
    - maximun chunk size至少得是128B
    - 每个方向的maximun chunk size是独立维护的
- abort message(2): 用于通知对端，如果它在等chunks用于完成一个message，那么需要discard the partially received message over a chunk stream.
- acknowledgement(3): 客户端或者服务端需要在收到window size大小的bytes之后，向对端发送一个应答。
- window acknowledgement size(5): 客户端和服务端发送这个消息，用于向对端通知window size（用于发送应答消息）
- set peer bandwidth(6): 客户端和服务端发送这个消息，用于通知对端限制输出带宽。

## rtmp command message

- command message
    - message type=20 for AMF0
    - message type=17 for AMF3
- data message: 用于发送metadata或者任何用户数据到对端
    - message type=18 for AMF0
    - message type=15 for AMF3
- shared object message: a shared object is a flash object
    - message type=19 for AMF0
    - message type=16 for AMF3
- audio message
    - message type=8
- video message
    - message type=9
- aggregate message
    - message type=22
- user control message events


type of commands

- NetConnection
    - connect: 客户端发送该命令到服务端
        - command structure(from client to server):
            - command name
            - transacation
            - command object
                - app
                - flashver
                - swfUrl
                - tcUrl
                - fpad
                - audioCodecs
                    - SUPPORT_SND_NONE
                    - SUPPORT_SND_ADPCM
                    - SUPPORT_SND_MP3
                    - SUPPORT_SND_INTEL
                    - SUPPORT_SND_UNUSED
                    - SUPPORT_SND_NELLY8
                    - SUPPORT_SND_NELLY
                    - SUPPORT_SND_G711A
                    - SUPPORT_SND_G711U
                    - SUPPORT_SND_NELLY16
                    - SUPPORT_SND_AAC
                    - SUPPORT_SND_SPEEX
                    - SUPPORT_SND_ALL
                - videoCodecs
                    - SUPPORT_VID_UNUSED
                    - SUPPORT_VID_JPEG
                    - SUPPORT_VID_SORENSON
                    - SUPPORT_VID_HOMEBREW
                    - SUPPORT_VID_VP6(On2)
                    - SUPPORT_VID_VP6ALPHA
                    - SUPPORT_VID_HOMEBREWV
                    - SUPPORT_VID_H264
                    - SUPPORT_VID_ALL
                - videoFunction
                    - SUPPORT_VID_CLIENT_SEEK
                - pageUrl
                - objectEncoding
                    - AMF0
                    - AMF3
            - optional user arguments
        - command structure(from server to client):
            - command name
            - transacation id
            - properties
            - information
    - Call
        - command structure(from sender to receiver):
            - Procedure Name
            - Transacation id
            - command object
            - optional argument
        - command structure(response):
            - command name
            - transacation id
            - command object
            - response
    - createStream
        - command structure(from client to server):
            - command name
            - transacation id
            - command object
        - command structure(from server to client):
            - command name
            - transacation id
            - command object
            - stream id
- NetStream
    - from client to server:
        - play
            - command name
            - transacation id
            - command object
            - stream name
            - start
            - duration
            - reset
        - play2
            - command name
            - transacation id
            - command object
            - parameters
        - deleteStream
            - command name
            - transacation id
            - command object
            - stream id
        - closeStream
        - receiveAudio
            - command name
            - transacation id
            - command object
            - bool flag
        - receiveVideo
            - command name
            - transacation id
            - command object
            - bool flag
        - publish
            - command name
            - transacation id
            - command object
            - publishing name
            - publishing type
        - seek
            - command name
            - transacation id
            - command object
            - milliSeconds
        - pause
            - command name
            - transacation id
            - command object
            - pause/unpause flag
            - milliSeconds
    - from server to client:
        - onStatus
            - command name
            - transacation id
            - command object
            - info object