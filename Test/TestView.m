//
//  TestView.m
//  Test
//
//  Created by IOS-Sun on 16/5/17.
//  Copyright © 2016年 IOS-Sun. All rights reserved.
//

#import "TestView.h"

#import <CoreText/CoreText.h>

@implementation TestView

/**
 *  coreText的使用说明
 *  富文本的使用——>图文混排
 *
 */

-(void)drawRect:(CGRect)rect
{
    [super drawRect:rect];
    /*
     coreText 起初是为OSX设计的，而OSX得坐标原点是左下角，y轴正方向朝上。iOS中坐标原点是左上角，y轴正方向向下。
     若不进行坐标转换，则文字从下开始，还是倒着的
     coreText使用的是系统坐标，然而我们平时所接触的iOS的都是屏幕坐标，所以要将屏幕坐标系转换系统坐标系
     */
    CGContextRef context = UIGraphicsGetCurrentContext();//获取当前绘制上下文 所有的绘制操作都是在上下文上进行绘制的
    CGContextSetTextMatrix(context, CGAffineTransformIdentity);//设置字形的变换矩阵为不做图形变换
    CGContextTranslateCTM(context, 0, self.bounds.size.height);//平移方法，将画布向上平移一个屏幕高
    CGContextScaleCTM(context, 1.0, -1.0);//缩放方法，x轴缩放系数为1，则不变，y轴缩放系数为-1，则相当于以x轴为轴旋转180度
    
    /*
     事实上，图文混排就是在要插入图片的位置插入一个富文本类型的占位符。通过CTRunDelegate设置图片
     */
    NSMutableAttributedString * attributeStr = [[NSMutableAttributedString alloc]
                                                initWithString:@"\n这里在测试图文混排，我是一个富文本"];
    /*
     设置一个回调结构体，告诉代理该回调那些方法
     为什么要设置一个回调结构体呢？
     因为coreText中大量的调用c的方法。事实上你会发现大部分跟系统底层有关的都需要调c的方法。
     */
    /**
     *  绘制图片的时候实际上实在一个CTRun中绘制这个图片
     *  CTRun绘制的坐标系中，他会以origin点作为原点进行绘制。
     *  基线为过原点的x轴，ascent即为CTRun顶线距基线的距离，descent即为底线距基线的距离
     *  通过代理设置CTRun的尺寸间接设置图片的尺寸
     */
    CTRunDelegateCallbacks callBacks;//创建一个回调结构体，设置相关参数
    callBacks.version = kCTRunDelegateVersion1;//设置回调版本，默认这个
    callBacks.getAscent = ascentCallBacks;//设置图片顶部距离基线的距离
    callBacks.getDescent = descentCallBacks;//设置图片底部距离基线的距离
    callBacks.getWidth = widthCallBacks;//设置图片宽度
    
    /*
     *  创建一个代理
     *  设置代理的时候绑定了一个返回图片尺寸的字典。
     *  事实上此处你可以绑定任意对象。此处你绑定的对象既是回调方法中的参数ref
     */
    NSDictionary * dicPic = @{@"height":@40,@"width":@40};//创建一个图片尺寸的字典，初始化代理对象需要
    CTRunDelegateRef delegate = CTRunDelegateCreate(& callBacks, (__bridge void *)dicPic);//创建代理
    
    /**
     *  首先创建一个富文本类型的图片占位符，绑定我们的代理
     */
    unichar placeHolder = 0xFFFC;//创建空白字符
    NSString * placeHolderStr = [NSString stringWithCharacters:&placeHolder length:1];//已空白字符生成字符串
    NSMutableAttributedString * placeHolderAttrStr = [[NSMutableAttributedString alloc]
                                                      initWithString:placeHolderStr];//用字符串初始化占位符的富文本
    CFAttributedStringSetAttribute((CFMutableAttributedStringRef)placeHolderAttrStr, CFRangeMake(0, 1), kCTRunDelegateAttributeName, delegate);//给字符串中的范围中字符串设置代理
    //进行了类型转换之后就不属于对象了，也不再归自动引用计数机制管理了，所以你得手动管理
    CFRelease(delegate);//释放（__bridge进行C与OC数据类型的转换，C为非ARC，需要手动管理）
    
    [attributeStr insertAttributedString:placeHolderAttrStr atIndex:11];//将占位符插入原富文本
    
    /**
     *  至此，已经生成好了带有图片信息的富文本了，接下来只要在画布上绘制出来这个富文本就好了。
     *
     *  绘制文本和绘制图片
     *  富文本中你添加的图片只是一个带有图片尺寸的空白占位符，在占位符的地方绘制相应大小的图片
     */
    
//    绘制文本
    //frameSetter是根据富文本生成的一个frame生成的工厂，你可以通过framesetter以及你想要绘制的富文本的范围获取该CTRun的frame
    //frame是仅绘制你所需要的那部分富文本的frame
    CTFramesetterRef frameSetter = CTFramesetterCreateWithAttributedString((CFAttributedStringRef)attributeStr);//一个frame的工厂，负责生成frame
    CGMutablePathRef path = CGPathCreateMutable();//创建绘制区域
    CGPathAddRect(path, NULL, self.bounds);//添加绘制尺寸
    NSInteger length = attributeStr.length;
    CTFrameRef frame = CTFramesetterCreateFrame(frameSetter, CFRangeMake(0,length), path, NULL);//工厂根据绘制区域及富文本（可选范围，多次设置）设置frame
    CTFrameDraw(frame, context);//根据frame绘制文字
    
//    绘制图片
    //绘制图片用下面这个方法，通用的哦
    UIImage * image = [UIImage imageNamed:@"logo"];
    //frame的获取  单独用frameSetter求出的image的frame是不正确的，那是只绘制image而得的坐标，所以那种方法不能用
    CGRect imgFrm = [self calculateImageRectWithFrame:frame];
    //三个参数，分别是context，frame，以及image
    CGContextDrawImage(context,imgFrm, image.CGImage);//绘制图片
    CFRelease(frame);
    CFRelease(path);
//    CFRelease(frameSetter);
}

/**
 *  三个回调方法
 *
 *  @param ref 回调方法中的参数ref，任意对象(指针类型的数据)
 *
 *  @return 从字典中分别取出图片的宽和高
 */
//通过类型转换获得oc中的字典
//__bridge既是C的结构体转换成OC对象时需要的一个修饰词
//事实上不是所有数据转换的时候都需要__bridge。你要问我怎么区分？那好我告诉你，C中就是传递指针的数据就不用。比如说字符串，数组
static CGFloat ascentCallBacks(void * ref)
{
    return [(NSNumber *)[(__bridge NSDictionary *)ref valueForKey:@"height"] floatValue];
}
static CGFloat descentCallBacks(void * ref)
{
    return 0;
}
static CGFloat widthCallBacks(void * ref)
{
    return [(NSNumber *)[(__bridge NSDictionary *)ref valueForKey:@"width"] floatValue];
}

//这部分代码到哪里都能用，达到复用效果
-(CGRect)calculateImageRectWithFrame:(CTFrameRef)frame
{
    NSArray * arrLines = (NSArray *)CTFrameGetLines(frame);//根据frame获取需要绘制的线的数组
    NSInteger count = [arrLines count];//获取线的数量
    CGPoint points[count];//建立起点的数组（cgpoint类型为结构体，故用C语言的数组）
    CTFrameGetLineOrigins(frame, CFRangeMake(0, 0), points);//获取起点
    
    //计算frame
    /**
     *  思路呢，就是遍历我们的frame中的所有CTRun，检查他是不是我们绑定图片的那个，如果是，根据该CTRun所在CTLine的origin以及CTRun在CTLine中的横向偏移量计算出CTRun的原点，加上其尺寸即为该CTRun的尺寸。
     */
    for (int i = 0; i < count; i ++) {//遍历线的数组  取到所有的CTLine
        CTLineRef line = (__bridge CTLineRef)arrLines[i];
        NSArray * arrGlyphRun = (NSArray *)CTLineGetGlyphRuns(line);//获取GlyphRun数组（GlyphRun：高效的字符绘制方案）
        for (int j = 0; j < arrGlyphRun.count; j ++) {//遍历CTRun数组
            CTRunRef run = (__bridge CTRunRef)arrGlyphRun[j];//获取CTRun
            NSDictionary * attributes = (NSDictionary *)CTRunGetAttributes(run);//获取CTRun的属性
            CTRunDelegateRef delegate = (__bridge CTRunDelegateRef)[attributes valueForKey:(id)kCTRunDelegateAttributeName];//获取代理
            //图片的占位符我们是绑定了代理的，而文字没有,以此区分文字和图片
            if (delegate == nil) {//非空
                continue;
            }
            //如果代理不为空，通过CTRunDelegateGetRefCon取得生成代理时绑定的对象
            
            //判断类型是否是我们绑定的类型，防止取得我们之前为其他的富文本绑定过代理
            NSDictionary * dic = CTRunDelegateGetRefCon(delegate);//判断代理字典
            if (![dic isKindOfClass:[NSDictionary class]]) {
                continue;
            }
            
            CGPoint point = points[i];//获取一个起点
            CGFloat ascent;//获取上距
            CGFloat descent;//获取下距
            CGRect boundsRun;//创建一个frame
            boundsRun.size.width = CTRunGetTypographicBounds(run, CFRangeMake(0, 0), &ascent, &descent, NULL);
            boundsRun.size.height = ascent + descent;//取得高
            CGFloat xOffset = CTLineGetOffsetForStringIndex(line, CTRunGetStringRange(run).location, NULL);//获取x偏移量
            boundsRun.origin.x = point.x + xOffset;//point是行起点位置，加上每个字的偏移量得到每个字的x
            boundsRun.origin.y = point.y - descent;//计算原点
            CGPathRef path = CTFrameGetPath(frame);//获取绘制区域
            CGRect colRect = CGPathGetBoundingBox(path);//获取剪裁区域边框
            CGRect imageBounds = CGRectOffset(boundsRun, colRect.origin.x, colRect.origin.y);
            //如果多张图片可以继续遍历返回数组
            return imageBounds;
        }
    }
    return CGRectZero;
}
/**
 *  上面呢，我们能看到一个CTFrame绘制的原理。
 
 CTLine 可以看做Core Text绘制中的一行的对象 通过它可以获得当前行的line ascent,line descent ,line leading,还可以获得Line下的所有Glyph Runs
 CTRun 或者叫做 Glyph Run，是一组共享想相同attributes（属性）的字形的集合体
 一个CTFrame有几个CTLine组成，有几行文字就有几行CTLine。一个CTLine有包含多个CTRun，一个CTRun是所有属性都相同的那部分富文本的绘制单元。所以CTRun是CTFrame的基本绘制单元。
 接着说我们的代码。
 为什么我获取的数组需要进行类型转换呢？因为CTFrameGetLines（）返回值是CFArrayRef类型的数据。就是一个c的数组类型吧，暂且先这么理解，所以需要转换。
 
 那为什么不用__bridge呢？记得么，我说过，本身就传地址的数据是不用桥接的。就是这样。
 然后获取数组的元素个数。有什么用呢，因为我们要用到每个CTLine的原点坐标进行计算。每个CTLine都有自己的origin。所以要生成一个相同元素个数的数组去盛放origin对象。
 然后用CTFrameGetLineOrigins获取所有原点。
 到此，我们计算frame的准备工作完成了。才完成准备工作。
 
 */

@end
