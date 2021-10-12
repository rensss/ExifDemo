# ExifDemo
iOS 获取 Exif 信息的 Demo



##### EXIF信息

是可交换图像文件的缩写，是专门为数码相机的照片设定的，可以记录数码照片的属性信息和拍摄数据。EXIF可以附加于JPEG、TIFF、RIFF等文件之中，为其增加有关数码相机拍摄信息的内容和索引图或图像处理软件的版本信息。



##### EXIF 以下为可能包含的信息:

| **项目**         | **资讯（举例）**             |
| ---------------- | ---------------------------- |
| 制造厂商         | Canon                        |
| 相机型号         | Canon EOS-1Ds Mark III       |
| 影像方向         | 正常（upper-left）           |
| 影像解析度 X     | 300                          |
| 影像解析度 Y     | 300                          |
| 解析度单位       | dpi                          |
| 软件             | Adobe Photoshop CS Macintosh |
| 最后异动时间     | 2005:10:06 12:53:19          |
| YCbCrPositioning | 2                            |
| 曝光时间         | 0.00800 (1/125) sec          |
| 光圈值           | F22                          |
| 拍摄模式         | 光圈优先                     |
| ISO感光值        | 100                          |
| Exif资讯版本     | 30,32,32,31                  |
| 影像拍摄时间     | 2005:09:25 15:00:18          |
| 影像存入时间     | 2005:09:25 15:00:18          |
| 曝光补偿（EV+-） | 0                            |
| 测光模式         | 点测光（Spot）               |
| 闪光灯           | 关闭                         |
| 镜头实体焦长     | 12 mm                        |
| Flashpix版本     | 30,31,30,30                  |
| 影像色域空间     | sRGB                         |
| 影像尺寸X        | 5616 pixel                   |
| 影像尺寸Y        | 3744 pixel                   |

在 iOS 当中, 使用 UIImagePickerController 选择单张图片的方法获取的 image 并非是原始图片, 所以不包含原始的 Exif 信息



##### UIImagePickerController 解析到的 Exif 信息如下:

```
[{TIFF}: {
    Orientation = 6;
    ResolutionUnit = 2;
    XResolution = 72;
    YResolution = 72;
}, {Exif}: {
    ColorSpace = 1;
    ComponentsConfiguration =     (
        1,
        2,
        3,
        0
    );
    ExifVersion =     (
        2,
        2,
        1
    );
    FlashPixVersion =     (
        1,
        0
    );
    PixelXDimension = 4032;
    PixelYDimension = 3024;
    SceneCaptureType = 0;
}, PixelWidth: 4032, PixelHeight: 3024, {JFIF}: {
    DensityUnit = 1;
    JFIFVersion =     (
        1,
        0,
        2
    );
    XDensity = 72;
    YDensity = 72;
}, ProfileName: Display P3, DPIWidth: 72, DPIHeight: 72, ColorModel: RGB, Orientation: 6, Depth: 8]
```

经过调研发现, 使用 PHImageManager 的 requestImageDataAndOrientation 方法获取到的 imagedata 包含原始的信息



##### PHImageManager 获取 asset 拿到原始 data 后经过解析可以得到如下信息:

```
[{TIFF}: {
    DateTime = "2021:10:11 11:09:47";
    HostComputer = "iPhone XS Max";
    Make = Apple;
    Model = "iPhone XS Max";
    Orientation = 6;
    ResolutionUnit = 2;
    Software = "15.0.1";
    TileLength = 512;
    TileWidth = 512;
    XResolution = 72;
    YResolution = 72;
}, Orientation: 6, PixelWidth: 4032, PixelHeight: 3024, {Exif}: {
    ApertureValue = "1.69599381283836";
    BrightnessValue = "6.159757029988956";
    ColorSpace = 65535;
    CompositeImage = 2;
    DateTimeDigitized = "2021:10:11 11:09:47";
    DateTimeOriginal = "2021:10:11 11:09:47";
    ExifVersion =     (
        2,
        3,
        2
    );
    ExposureBiasValue = 0;
    ExposureMode = 0;
    ExposureProgram = 2;
    ExposureTime = "0.00909090909090909";
    FNumber = "1.8";
    Flash = 16;
    FocalLenIn35mmFilm = 26;
    FocalLength = "4.25";
    ISOSpeedRatings =     (
        25
    );
    LensMake = Apple;
    LensModel = "iPhone XS Max back dual camera 4.25mm f/1.8";
    LensSpecification =     (
        "4.25",
        6,
        "1.8",
        "2.4"
    );
    MeteringMode = 5;
    OffsetTime = "+08:00";
    OffsetTimeDigitized = "+08:00";
    OffsetTimeOriginal = "+08:00";
    PixelXDimension = 4032;
    PixelYDimension = 3024;
    SceneType = 1;
    SensingMethod = 2;
    ShutterSpeedValue = "6.786114009295267";
    SubjectArea =     (
        2013,
        1511,
        2217,
        1330
    );
    SubsecTimeDigitized = 440;
    SubsecTimeOriginal = 440;
    WhiteBalance = 0;
}, {GPS}: {
    Altitude = "5111.43158627087198";
    AltitudeRef = 0;
    DestBearing = "3111.85987089833244";
    DestBearingRef = T;
    HPositioningError = 35;
    ImgDirection = "3111.85987089833244";
    ImgDirectionRef = T;
    Latitude = "4111.02616383333334";
    LatitudeRef = N;
    Longitude = "111111.41185";
    LongitudeRef = E;
    Speed = 0;
    SpeedRef = K;
}, PrimaryImage: 1, ProfileName: Display P3, DPIWidth: 72, DPIHeight: 72, ColorModel: RGB, {MakerApple}: {
    1 = 14;
    12 =     (
        "0.7695312",
        "1.242188"
    );
    13 = 5;
    14 = 0;
    16 = 1;
    17 = "07250F0C-D055-4E2C-9290-7A002339A7F4";
    2 = {length = 512, bytes = 0x63006a00 6b006e00 74007f00 9300a800 ... fb007500 4e005100 };
    20 = 10;
    23 = 13639680;
    25 = 2;
    26 = q900n;
    3 =     {
        epoch = 0;
        flags = 1;
        timescale = 1000000000;
        value = 190422196502791;
    };
    31 = 0;
    32 = "50778780-F3AB-48F9-8C74-D070CC6A633F";
    33 = 0;
    35 =     (
        15,
        268435608
    );
    37 = 394;
    38 = 3;
    39 = "47.02333";
    4 = 1;
    40 = 1;
    43 = "06DFDAB5-59F3-47D4-AC2F-04FAFA9118F2";
    45 = 4898;
    46 = 1;
    47 = 162;
    5 = 184;
    54 = 5167;
    55 = 4;
    59 = 0;
    6 = 191;
    60 = 4;
    65 = 0;
    7 = 1;
    74 = 2;
    8 =     (
        "0.0132227",
        "-0.3723191",
        "-0.9368563"
    );
}, Depth: 8]
```



具体到每个字段对应的信息还需要继续查找和调研

详细内容见 Demo


>
[Apple](https://developer.apple.com/documentation/imageio/cgimageproperties) 对于 CGImageProperties 信息的文档
>
[Apple](https://developer.apple.com/documentation/imageio/cgimageproperties/exif_dictionary_keys) 对于 Exif 信息的文档
>
[Maker Apple](https://photoinvestigator.co/blog/the-mystery-of-maker-apple-metadata/) 字段的相关信息的猜测
