//
//  ViewController.swift
//  ARDistanceMeasurement_MBXB
//
//  Created by Oboe_b on 2017/9/16.
//  Copyright © 2017年 MBXB-bifujian. All rights reserved.
//
//简书地址:http://www.jianshu.com/u/a437e8f87a81
//微博https://weibo.com/u/6342211709
import UIKit
import SceneKit
import ARKit


class ViewController: UIViewController {
    @IBOutlet weak var sceneV: ARSCNView!
    @IBOutlet weak var InfoL: UILabel!//这个label的命名大家不要介意,手残了
    @IBOutlet weak var targetIM: UIImageView!
    var session = ARSession()
    var configuration = ARWorldTrackingConfiguration()
    var isMeasuring = false//默认状态为非测量状态
    
    var vectorZero = SCNVector3() // 0,0,0
    var vectorStart = SCNVector3()
    var vectorEnd = SCNVector3()
    var lines = [Line]()
    var currentLine: Line?
    var unit = LengthUnit.cenitMeter // 默认单位 cm
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        session.run(configuration, options:[.resetTracking,.removeExistingAnchors])
    }
    override func viewDidDisappear(_ animated: Bool) {
        super.viewWillAppear(animated)
        session.pause()
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view, typically from a nib.
        self.setUp()
        
    }
    func setUp()  {
        sceneV.delegate = self
        sceneV.session = session
        InfoL.text = "环境初始化中"
        
    }

   
    @IBOutlet weak var restB: UIButton!
    
    @IBAction func ResetClick(_ sender: UIButton) {
        
        for line in lines {
            line.remove()
        }
        lines.removeAll()
        
    }
    func reset(){
        isMeasuring = true
        vectorStart = SCNVector3()
        vectorEnd = SCNVector3()
    }
    func scanWorld(){
        //相机位置
        guard let worldPosition = sceneV.worldVector(for: view.center) else {
            return
        }
        if  lines.isEmpty {
            InfoL.text = "点击画面试试看"
        }
        if isMeasuring {
            //            开始点
            if  vectorStart == vectorZero {
                vectorStart = worldPosition //  把现在的位置何止为开始
                currentLine = Line(sceneView: sceneV, startVector: vectorStart, unit: unit)
            }
            //            设置结束
            vectorEnd = worldPosition
            currentLine?.update(to: vectorEnd)
            InfoL.text = currentLine?.distance(to: vectorEnd) ?? "..."
        }
    }
    
    @IBAction func UnitClick(_ sender: Any) {
    }
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    //点击屏幕开始测试
    override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
        if !isMeasuring {
            reset()
            isMeasuring = true
            targetIM.image = UIImage(named: "GreenTarget")
        }else{
            isMeasuring = false
            if let line = currentLine {
                lines.append(line)
                currentLine = nil
                targetIM.image = UIImage(named: "WhiteTarget")
            }
        }
    }
   
}
extension ViewController:ARSCNViewDelegate{
    
    func renderer(_ renderer: SCNSceneRenderer, updateAtTime time: TimeInterval) {
        
        DispatchQueue.main.async {
            self.scanWorld()
        }
        
    }
    
    func session(_ session: ARSession, didFailWithError error: Error) {
        
        InfoL.text = "错误"
    }
    
    func sessionWasInterrupted(_ session: ARSession) {
        
        InfoL.text = "中断～"
    }
    
    func sessionInterruptionEnded(_ session: ARSession) {
        
        InfoL.text = "结束"
    }
}
