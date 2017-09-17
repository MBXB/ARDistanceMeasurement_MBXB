//
//  Line.swift
//  ARDistanceMeasurement_MBXB
//
//  Created by Oboe_b on 2017/9/16.
//  Copyright © 2017年 MBXB-bifujian. All rights reserved.
//简书地址:http://www.jianshu.com/u/a437e8f87a81
//微博https://weibo.com/u/6342211709

import ARKit
enum LengthUnit {
    case meter, cenitMeter, inch
    var factor: Float{
        switch self {
        case .meter:
            return 1.0
        case .cenitMeter:
            return 100.0
        case .inch:
            return 39.3700787
        }
    }
    var name: String {
        switch self {
        case .meter:
            return "m"
        case .cenitMeter:
            return "cm"
        case .inch:
            return "inch"
        }
    }
}
class Line{
    var color = UIColor.red
    var startNode : SCNNode
    var endNode : SCNNode
    var textNode : SCNNode
    var text : SCNText
    var lineNode : SCNNode?
    let sceneView: ARSCNView
    let startVector: SCNVector3
    let unit: LengthUnit
    init(sceneView: ARSCNView, startVector: SCNVector3, unit: LengthUnit) {
        //创建节点(开始,结束,线,数字,单位)
        self.sceneView = sceneView
        self.startVector = startVector
        self.unit = unit
        let dot = SCNSphere(radius: 0.5)
        dot.firstMaterial?.diffuse.contents = color
        dot.firstMaterial?.lightingModel = .constant//光照,表面看起来都是一样的光亮,不会产生阴影
        dot.firstMaterial?.isDoubleSided = true//两面都很亮哦
        
        startNode = SCNNode(geometry: dot)
        startNode.scale = SCNVector3(1/500.0,1/500.0,1/500.0)//看看效果这里有坑,设置位置一定要注意
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
        textWrapperNode.scale = SCNVector3(1/500.0,1/500.0,1/500.0) // 坑来了
        
        textNode = SCNNode()
        textNode.addChildNode(textWrapperNode)//添加到包装节点上
        let constraint = SCNLookAtConstraint(target: sceneView.pointOfView)//来一个约数
        constraint.isGimbalLockEnabled = true
        textNode.constraints = [constraint]
        sceneView.scene.rootNode.addChildNode(textNode)
    }
    func update(to vector:SCNVector3 ) {
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
    }
    func distance(to vector: SCNVector3) -> String {
        
        return String(format:"%0.2f %@", startVector.distance(for: vector)*unit.factor, unit.name)//乘以单位
    }
    func remove(){
        startNode.removeFromParentNode()
        endNode.removeFromParentNode()
        textNode.removeFromParentNode()
        lineNode?.removeFromParentNode()
    }


    
    
    
}
