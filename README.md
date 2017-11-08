# ARDistanceMeasurement_MBXB
Virtual and realistic distance measurement

人的一生唯有学习和锻炼不可辜负
博客http://www.2bjs.com
微博https://weibo.com/u/6342211709
技术交流q群150731459
微信搜索iOS编程实战


简介:

 拿到三维坐标点,拿到相机的实时位置(两个分类),计算距离:

//        A(x1,y1,z1),B(x2,y2,z2),则A,B之间的距离为

//        d=√[(x1-x2)^2+(y1-y2)^2+(z1-z2)^2]

之后我们来记录起始点,此处写了一个Line类,在其中实现其中主要的角色以及实现的主要场景,创建SCNGeometrySource物件,创建SCNGeometryElement把创建的顶点连起来,用line的方式来画一条线(GPU操作可以减少CPU负担),然后获取到实时测试的距离,在我们的现实世界中将你所在的初始原点位置,和你结束的位置的距离来测量出来

实现思路:

1.搭建基本环境,开启全局追踪

2.拿到三维坐标点

3.拿到相机实时位置

4.初始化场景与角色

5.实时跟踪,处理事件,完善

步骤:

1.搭建基本框架

session.run方法开启全局追踪<提问:全局追踪失效?>

搭建基本框架基本控件属性

@IBOutlet weak var sceneV: ARSCNView!

@IBOutlet weak var InfoL: UILabel!//这个label的命名大家不要介意,手残了

@IBOutlet weak var targetIM: UIImageView!

var session = ARSession()

var configuration = ARWorldTrackingConfiguration()
2.代理,全局的追踪状态

func session(_ session: ARSession, didFailWithError error: Error) {

InfoL.text = "错误"

}

func sessionWasInterrupted(_ session: ARSession) {

InfoL.text = "中断～"

}

func sessionInterruptionEnded(_ session: ARSession) {

InfoL.text = "结束"

}
4.BXARSCNView+Extension类来拿三维坐标

func worldVector(for position:CGPoint) ->SCNVector3?{

//result

let results = hitTest(position, types: [.featurePoint])

guard let result = results.first else {

return nil

}

//-->返回相机的位置

return SCNVector3.positionTranform(result.worldTransform)

}
此处设置结果(let results)的时候,使用了types,这里相机与物件之间的距离,用来搜索ARSession检测到的锚点,真实世界中的对象不是view中的SceneKit里面的内容,假设找内容的话用(option)

5.BXSCNVector3 + Extension将坐标的x,y,z回传,计算距离,画线

回传xyz

static func positionTranform(_ tranform:matrix_float4x4) -> SCNVector3{

//将坐标的x,y,z轴回传出去

return SCNVector3Make(tranform.columns.3.x, tranform.columns.3.y, tranform.columns.3.z)

}
计算距离

func distance(for vector:SCNVector3) -> Float {

let distanceX = self.x-vector.x//现在的位置减去出发的位置

let distanceY = self.y-vector.y

let distanceZ = self.z-vector.z

return sqrt((distanceX * distanceX)+(distanceY * distanceY)+(distanceZ * distanceZ))

}
画线

func line(to vector:SCNVector3,color:UIColor) -> SCNNode {

let indices : [UInt32] = [0,1]//指数

let source = SCNGeometrySource(vertices: [self,vector]) // 创建一个几何容器

let element = SCNGeometryElement(indices: indices, primitiveType: .line)//用线的方式来创造一个几何元素(线)

let geomtry = SCNGeometry(sources: [source], elements: [element])//几何

geomtry.firstMaterial?.diffuse.contents = color//渲染颜色

let node = SCNNode(geometry: geomtry)//返回一个节点

return node

}
6.初始化主要角色与场景

定义

var color = UIColor.red,

var startNode : SCNNode

var endNode : SCNNode

var textNode : SCNNode

var text : SCNText

var lineNode : SCNNode?

let sceneView: ARSCNView

let startVector: SCNVector3
初始化:创建节点-添加子节点

self.sceneView = sceneView

self.startVector = startVector

self.unit = unit

let dot = SCNSphere(radius: 0.5)

dot.firstMaterial?.diffuse.contents = color

dot.firstMaterial?.lightingModel = .constant//光照,表面看起来都是一样的光亮,不会产生阴影

dot.firstMaterial?.isDoubleSided = true//两面都很亮

startNode = SCNNode(geometry: dot)

startNode.scale = SCNVector3(1/500.0,1/500.0,1/500.0)

startNode.position = startVector

sceneView.scene.rootNode.addChildNode(startNode)

endNode = SCNNode(geometry: dot)//这里只需要先创建出来,稍后添加

endNode.scale = SCNVector3(1/500.0,1/500.0,1/500.0)//这里也有坑

text = SCNText(string: "", extrusionDepth: 0.1)

text.font = .systemFont(ofSize: 5)

text.firstMaterial?.diffuse.contents = color

text.firstMaterial?.lightingModel = .constant

text.firstMaterial?.isDoubleSided = true

text.alignmentMode = kCAAlignmentCenter//位置

text.truncationMode = kCATruncationMiddle//........

let textWrapperNode = SCNNode(geometry: text)

textWrapperNode.eulerAngles = SCNVector3Make(0, .pi, 0) // 数字对着自己

textWrapperNode.scale = SCNVector3(1/500.0,1/500.0,1/500.0) 

textNode = SCNNode()

textNode.addChildNode(textWrapperNode)//添加到包装节点上

let constraint = SCNLookAtConstraint(target: sceneView.pointOfView)//来一个约数

constraint.isGimbalLockEnabled = true

textNode.constraints = [constraint]

sceneView.scene.rootNode.addChildNode(textNode)
SCNVector3(A representation of a three-component vector.

SceneKit uses three-component vectors for a variety of purposes, such as

describing node or vertex positions, surface normals, and scale or translation

transforms. The different vector components should be interpreted based on the

context in which the vector is being used.

Important

In macOS, the x, y, and z fields in this structure are CGFloat values. In iOS,

tvOS, and watchOS, these fields are Float values.)此处我们来描述节点或者是顶点的位置时候注意要用CGFloat-->否则会出现意想不到的情况(消失不见????)

7.处理更新文字

lineNode?.removeFromParentNode()//移除掉所有线

lineNode = startVector.line(to: vector, color: color)

sceneView.scene.rootNode.addChildNode(lineNode!)

//更新文字a

text.string = distance(to: vector)

//文字位置

textNode.position = SCNVector3((startVector.x + vector.x) / 2.0 , (startVector.y + vector.y) / 2.0 ,(startVector.z + vector.z) / 2.0 )

endNode.position = vector

if endNode.parent == nil {

sceneView.scene.rootNode.addChildNode(endNode)

}
8.点击屏幕的时候,进入测试状态,开始画线,记录开始点和结束点

当然我们追踪显示时间需要在主线程中

DispatchQueue.main.async {}

优化:

1.全局追踪的高级用法:在生命周期view将要显示的时候移除所有锚点，并且重新开启追中效率会大大提高,当生命周期view将要消失的时候，我们所追踪的位置并不一定还留在原来的位置，所以说我们移掉所有锚点之后在次来一次追踪，效率是不是会提高很多-->resetTracking  removeExistingAnchors

2.Equatable协议防止重复:

public static func == (lhs: SCNVector3, rhs: SCNVector3) -> Bool {

//当左边的与右边的相等

return (lhs.x == rhs.x) && (lhs.y == rhs.y) && (lhs.z == rhs.z)

}

3.移除remove

line.remove(),当点击Reset的时候进行清除
