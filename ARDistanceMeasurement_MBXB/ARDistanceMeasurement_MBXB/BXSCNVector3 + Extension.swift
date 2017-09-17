//
//  SCNVector3 + Extension.swift
//  ARDistanceMeasurement_MBXB
//
//  Created by Oboe_b on 2017/9/16.
//  Copyright © 2017年 MBXB-bifujian. All rights reserved.
//简书地址:http://www.jianshu.com/u/a437e8f87a81
//微博https://weibo.com/u/6342211709

import ARKit
extension SCNVector3{
    static func positionTranform(_ tranform:matrix_float4x4) -> SCNVector3{
        
        //将坐标的x,y,z轴回传出去 
        return SCNVector3Make(tranform.columns.3.x, tranform.columns.3.y, tranform.columns.3.z)
    }
    //计算局里
    //也就是计算向量的一个公示
    func distance(for vector:SCNVector3) -> Float {
        let distanceX = self.x-vector.x//现在的位置减去出发的位置
        let distanceY = self.y-vector.y
        let distanceZ = self.z-vector.z
        
        return sqrt((distanceX * distanceX)+(distanceY * distanceY)+(distanceZ * distanceZ))
    }
    
    //画线
    func line(to vector:SCNVector3,color:UIColor) -> SCNNode {
        let indices : [UInt32] = [0,1]//指数
        let source = SCNGeometrySource(vertices: [self,vector]) // 创建一个几何容器

        let element = SCNGeometryElement(indices: indices, primitiveType: .line)//用线的方式来创造一个几何元素(线)
        let geomtry = SCNGeometry(sources: [source], elements: [element])//几何
        geomtry.firstMaterial?.diffuse.contents = color//渲染颜色
        let node = SCNNode(geometry: geomtry)//返回一个节点
        return node
        
    }
    
}
extension SCNVector3: Equatable {//Equatable协议
    
    public static func == (lhs: SCNVector3, rhs: SCNVector3) -> Bool {
        //当左边的与右边的相等
        return (lhs.x == rhs.x) && (lhs.y == rhs.y) && (lhs.z == rhs.z)
    }
}

