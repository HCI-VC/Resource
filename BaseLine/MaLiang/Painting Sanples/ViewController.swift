//
//  ViewController.swift
//  MaLiang
///绘图板视图
//

import UIKit
import MaLiang
import Comet
import Chrysan
import Zip


class ViewController: UIViewController,UICollectionViewDataSource, UICollectionViewDelegateFlowLayout {
    
    @IBOutlet weak var strokeSizeLabel: UILabel!
    @IBOutlet weak var brushSegement: UISegmentedControl!
    @IBOutlet weak var Font: UILabel!
    @IBOutlet weak var sizeSlider: UISlider!
    @IBOutlet weak var undoButton: UIButton!
    @IBOutlet weak var redoButton: UIButton!

    @IBOutlet weak var CanvasView: UIView!
    @IBOutlet weak var canvas: Canvas!

    @IBOutlet weak var modelImage: UIImageView!
    @IBOutlet weak var ColorPicker: UIButton!

    @IBOutlet weak var toolBarBack: UILabel!
    @IBOutlet weak var ColorPannel: UICollectionView!
    var filePath: String?
    @IBOutlet weak var AddTex: UIButton!
    @IBOutlet weak var Confirm: UIButton!
    @IBOutlet weak var Store: UIButton!
    
    @IBOutlet weak var Help: UIButton!
    @IBOutlet weak var HideUI: UIButton!
    @IBOutlet weak var Plus: UIButton!
    @IBOutlet weak var Trans: UIButton!
    @IBOutlet weak var Quit: UIButton!
    @IBOutlet weak var helpDoc: UIView!
    @IBOutlet weak var RGBPannel: UIView!
    @IBOutlet weak var outputImage: UIImageView!
    @IBOutlet weak var star1: UIImageView!
    @IBOutlet weak var star2: UIImageView!
    @IBOutlet weak var star3: UIImageView!
    
    
    
    var brushes: [Brush] = [] //数组
    var chartlets: [MLTexture] = []
    var img:[String]=[]
    var img_tex: [MLTexture] = []
    var style:[String]=[]
    var style_tex:[MLTexture] = []
    private var imageCache: ChartletImageCache!
    private var http:HTTPREquest!
    private var ObjectName:String?
    private var OutPutFrame:UIImage?
    private var OutPutImage:UIImage?
    private var LastLevel:String = "0"
    private var CurrLevel:String = "0"
    var color: UIColor {
        return UIColor(red: r, green: g, blue: b, alpha: 1)
    }
    
    private var needSave=false;
    private var shouldSave=false;
    private var colorMode:Bool = false;
    private var ID:Int = 0;
    
    private var FixedHeight=600;
    private var FixedWidth=800;
  
    
    
    private func changeStar(level:String){
        self.star1.isHidden=true;
        self.star2.isHidden=true;
        self.star3.isHidden=true;
        switch level {
        case "3":
            self.star3.isHidden=false
            self.star2.isHidden=false
            self.star1.isHidden=false
        case "2":
            self.star2.isHidden=false
            self.star1.isHidden=false
        case "1":
            self.star1.isHidden=false
        case "0":
            break
            
        default:
            break
        }
    }
    
  //  var colorP:ColorPicker!
    
    func base64StringToUIImage(base64String:String)->UIImage? {
        var str = base64String

        // 1、判断用户传过来的base64的字符串是否是以data开口的，如果是以data开头的，那么就获取字符串中的base代码，然后在转换，如果不是以data开头的，那么就直接转换
        if str.hasPrefix("data:image") {
            guard let newBase64String = str.split(separator: ",").last else {
                return nil
            }
            str = "\(newBase64String)"
        }
        // 2、将处理好的base64String代码转换成NSData
        guard let imgNSData = NSData(base64Encoded: str, options: NSData.Base64DecodingOptions()) else {
            return nil
        }
        // 3、将NSData的图片，转换成UIImage
        guard let codeImage = UIImage(data: imgNSData as Data) else {
            return nil
        }
        return codeImage
    }

    
    
    private func registerBrush(with imageName: String) throws -> Brush {
        let texture = try canvas.makeTexture(with: UIImage(named: imageName)!.pngData()!)
        return try canvas.registerBrush(name: imageName, textureID: texture.id)
    }
    
    
    @objc func saveimage(image: UIImage, didFinishSavingWithError: NSError?, contextInfo: AnyObject) {
        print("---")

        if didFinishSavingWithError != nil {
            print("错误")
            return
        }
        print("OK")
    }
    
    @objc private func ADDTEX_tapped(){
        
        //切换mode
        self.CurrLevel="0"
        self.LastLevel="0"
        self.colorMode = !self.colorMode
        self.canvas.isHidden=false
        self.outputImage.isHidden=true
        if self.colorMode {
            self.AddTex.setTitle("色", for: .normal)
            self.HideUI.isEnabled=false
            self.Plus.isEnabled=false
            self.chrysan.show(.succeed,message: "已切换至颜色匹配，请重新匹配",hideDelay: 1)
            
        }
        else {
            self.AddTex.setTitle("稿", for: .normal)
            self.HideUI.isEnabled=false
            self.Plus.isEnabled=false
            self.chrysan.show(.succeed,message: "已切换至线稿匹配，请重新匹配",hideDelay: 1)
            
        }
    }
    
    @objc private func CONFIRM_tapped(){

//        UIImageWriteToSavedPhotosAlbum(canvas.snapshot()!, self, #selector(saveimage(image:didFinishSavingWithError:contextInfo:)), nil)

//        let alertController = UIAlertController(title: "选择模式",message: nil,preferredStyle: .alert)
//        let cancelAction = UIAlertAction(title: "取消", style: .cancel, handler: nil)
//        let directMessagesAction1 = UIAlertAction(title: "线稿比对", style: .default) { (action: UIAlertAction!) -> Void in
//
//        }
//        let directMessagesAction2 = UIAlertAction(title: "颜色比对", style: .default) { (action: UIAlertAction!) -> Void in
//
//        }
//        alertController.addAction(directMessagesAction1)
//        alertController.addAction(directMessagesAction2)
//        alertController.addAction(cancelAction)

//        if let popoverPresentationController = alertController.popoverPresentationController {
//            popoverPresentationController.sourceView = self.canvas.view
//            popoverPresentationController.sourceRect = self.canvas.view.bounds
//        }
//        alertController.popoverPresentationController?.sourceRect = self.headerV.nameLb.frame //箭头指向哪里
//        self.present(alertController, animated: true, completion: nil)
        
        
        
        
        
        chrysan.showMessage("比对中...")
        let session: URLSession = URLSession.shared
        let url: NSURL = self.colorMode ? NSURL.init(string: "\(httpURL)/matchColor")! :  NSURL.init(string: "\(httpURL)/matchSkeleton")!
//        let url: NSURL = NSURL.init(string: "http://192.168.233.158:5000/test2")!
        var request: NSMutableURLRequest = NSMutableURLRequest.init(url: url as URL)

        let pngI:String=canvas.snapshot()!.jpegData(compressionQuality: 1)!.base64EncodedString()
        request.httpMethod = "POST"
        request.httpBody = "img=\(pngI)&id=\(self.ID)".data(using: String.Encoding.utf8)
        print(self.ID)
        let task:URLSessionDataTask  = session.dataTask(with: request as URLRequest) { (data, res, error) in
        
        if(error == nil){
            
            let str:String=String(data: data!, encoding: .utf8)!
            
            
            
            
            
           
            DispatchQueue.main.async {
                print(str)
                self.LastLevel=self.CurrLevel
                self.OutPutImage=self.base64StringToUIImage(base64String: "\(str.split(separator: "@")[1])")
                self.OutPutFrame=self.base64StringToUIImage(base64String: "\(str.split(separator: "@")[0])")
                self.CurrLevel="\(str.split(separator: "@")[2])"
                print(self.CurrLevel)
                self.changeStar(level: self.CurrLevel)
                self.outputImage.image=self.OutPutFrame
                self.outputImage.isHidden=false
                self.HideUI.isEnabled=true
                self.Plus.isEnabled=true
                self.chrysan.hide()
                if(self.CurrLevel>self.LastLevel){
                    print(self.CurrLevel,self.LastLevel)
                    self.chrysan.show(.succeed,message: "恭喜您，有进步！" ,hideDelay:  1)
                }
                if(self.CurrLevel<self.LastLevel){
                    print(self.CurrLevel,self.LastLevel)
                    self.chrysan.show(.succeed,message: "啊,退步啦" ,hideDelay:  1)
                }
                if(self.CurrLevel==self.LastLevel){
                    print(self.CurrLevel,self.LastLevel)
                    if(self.CurrLevel=="0"){
                        self.chrysan.show(.succeed,message: "请先着墨！" ,hideDelay:  1)
                    }else{
                        self.chrysan.show(.succeed,message: "发挥稳定，继续保持！" ,hideDelay:  1)
                    }
                    
                }
                
                
            }
//            self.chrysan.showMessage("比对成功",hideDelay: 1)

        }else{
            DispatchQueue.main.async {
                self.chrysan.hide()
                self.chrysan.show(.error,message: "网络故障" ,hideDelay:  1)
            }
            print("error:error")
//            self.chrysan.showMessage("网络故障!",hideDelay: 1)
        }

    }

        task.resume()//开始执行
        
        
        
        

        
    }


        
    
    @objc  private func STORE_tapped(){
        self.outputImage.isHidden=true
        self.canvas.isHidden=false
        if self.ObjectName==nil{
            let alertController = UIAlertController(title: "输入项目名称(10字以内)", message: nil, preferredStyle: .alert)
            alertController.addTextField(configurationHandler: { (textField: UITextField!) -> Void in
                        textField.placeholder = "输入项目名称(10字以内)"
                        // 添加监听代码，监听文本框变化时要做的操作
                        NotificationCenter.default.addObserver(self, selector: #selector(self.alertTextFieldDidChange), name: UITextField.textDidChangeNotification, object: textField)
            })
            alertController.addAction( UIAlertAction(title: "取消", style: .cancel, handler: { (action: UIAlertAction!) -> Void in
            alertController.dismiss(animated: true, completion: nil)
                }))
            let ok = UIAlertAction(title: "确认", style: .default , handler: { (action: UIAlertAction!) -> Void in
                self.ObjectName = alertController.textFields?.first?.text
                alertController.dismiss(animated: true, completion: nil)
                
                self.saveData()
                self.needSave=false
                })
            ok.isEnabled = false
            alertController.addAction(ok)
            self.present(alertController, animated: true, completion: nil)
        }else{
            self.needSave=false;
            self.saveData()
        }
    }
    @objc private func HELP_tapped(){
        if self.helpDoc.isHidden {
            self.helpDoc.isHidden=false
        }else{
            self.helpDoc.isHidden=true
        }
    }
    @objc private func HIDE_tapped(){
        

        self.outputImage.isHidden = !self.outputImage.isHidden
        if(self.OutPutFrame==nil){
            self.outputImage.image=self.OutPutImage
            self.canvas.isHidden = !self.outputImage.isHidden
        }else{
            self.outputImage.image=self.OutPutFrame
        }
        
        if((!self.outputImage.isHidden) && (self.OutPutFrame != nil)){
            self.Plus.isEnabled=true
        }else{
            self.Plus.isEnabled=false
        }
       

    }
    
    
    @objc func PLUS_tapped(){
        if self.outputImage.image==self.OutPutFrame {
            self.outputImage.image=self.OutPutImage
        }else{
            self.outputImage.image=self.OutPutFrame
        }
    }
    
    @objc func TRANS_tapped(){
        
        
        PicPicker.present(from: self, textures: style_tex,canQ: true ,title:"请选择一种风格") { [unowned self] (index) in
            self.canvas.isHidden=false
            chrysan.showMessage("风格迁移中...")
            let session: URLSession = URLSession.shared
            let url: NSURL = NSURL.init(string: "\(httpURL)/styleTransfer")!
    //        let url: NSURL = NSURL.init(string: "http://192.168.233.158:5000/test2")!
            var request: NSMutableURLRequest = NSMutableURLRequest.init(url: url as URL)

            let pngI:String=canvas.snapshot()!.jpegData(compressionQuality: 1)!.base64EncodedString()
            request.httpMethod = "POST"
            request.httpBody = "img=\(pngI)&stylename=\(self.style[index])".data(using: String.Encoding.utf8)
            let task:URLSessionDataTask  = session.dataTask(with: request as URLRequest) { (data, res, error) in
            
            if(error == nil){
                
                let str:String=String(data: data!, encoding: .utf8)!
                
                
                
                
                
               
                DispatchQueue.main.async {
                    self.OutPutImage=self.base64StringToUIImage(base64String:str)
                    self.OutPutFrame=nil
                    self.outputImage.image=self.OutPutImage
                    self.outputImage.isHidden=false
                    self.canvas.isHidden=true
                    self.HideUI.isEnabled=true
                    self.Plus.isEnabled=false
                    self.chrysan.hide()
                    self.chrysan.show(.succeed,message: "迁移成功,长按保存可存入相册!" ,hideDelay:  1)
                }
    //            self.chrysan.showMessage("比对成功",hideDelay: 1)

            }else{
                DispatchQueue.main.async {
                    self.chrysan.hide()
                    self.chrysan.show(.error,message: "网络故障" ,hideDelay:  1)
                }
                print("error:error")
    //            self.chrysan.showMessage("网络故障!",hideDelay: 1)
            }

        }

            task.resume()//开始执行
        }
    }
    @objc func STORE_long_tapped(_ sender : UILongPressGestureRecognizer){
        print("NO")
        if(sender.state == .ended){
            if(self.outputImage.isHidden){
                UIImageWriteToSavedPhotosAlbum(canvas.snapshot()!, self, #selector(saveimage(image:didFinishSavingWithError:contextInfo:)), nil)
            }else{
                UIImageWriteToSavedPhotosAlbum(OutPutImage!, self, #selector(saveimage(image:didFinishSavingWithError:contextInfo:)), nil)

            }
            self.chrysan.show(.succeed,message: "已保存到相册",hideDelay: 1)
        }
        
    }
    @objc private func alertTextFieldDidChange(){
        let alertController = self.presentedViewController as! UIAlertController?
        if (alertController != nil) {
            let objname = (alertController!.textFields?.first)! as UITextField
            let okAction = alertController!.actions.last! as UIAlertAction
            if (!(objname.text?.isEmpty)!) {
                okAction.isEnabled = true
            } else {
                okAction.isEnabled = false
            }
        }
    }
    
    
    @objc private func QUIT_tapped(){
        
        if self.needSave{
            let alert=UIAlertController(title: "提示", message: "项目还未保存，是否暂存", preferredStyle: .alert)
            alert.addAction(UIAlertAction(title: "保存", style: .default, handler: {
                action in
                if self.ObjectName==nil{
                    let alertController = UIAlertController(title: "输入项目名称(10字以内)", message: nil, preferredStyle: .alert)
                            alertController.addTextField(configurationHandler: { (textField: UITextField!) -> Void in
                                textField.placeholder = "输入项目名称(10字以内)"
                                // 添加监听代码，监听文本框变化时要做的操作
                                NotificationCenter.default.addObserver(self, selector: #selector(self.alertTextFieldDidChange), name: UITextField.textDidChangeNotification, object: textField)
                            })
                    alertController.addAction( UIAlertAction(title: "取消", style: .cancel, handler: { (action: UIAlertAction!) -> Void in
                        alertController.dismiss(animated: true, completion: nil)
                    }))
                    let ok = UIAlertAction(title: "确认", style: .default , handler: { (action: UIAlertAction!) -> Void in
                        self.ObjectName = alertController.textFields?.first?.text
                        alertController.dismiss(animated: true, completion: nil)
                        alert.dismiss(animated: true, completion: nil)
                        self.saveData()
                        self.needSave=false
                    })
                    ok.isEnabled = false
                    alertController.addAction(ok)
                    self.present(alertController, animated: true, completion: nil)
                }else{
                    self.saveData()
                    self.needSave=false
                    self.navigationController?.popToRootViewController(animated: true)
                }
                

            }))
            alert.addAction(UIAlertAction(title: "不保存", style: .destructive, handler: {
                action in
                alert.dismiss(animated: true, completion: nil)
                self.navigationController?.popToRootViewController(animated: true)
                
            }))
            self.present(alert, animated: true, completion:nil)
        }
        
        else{
            self.navigationController?.popToRootViewController(animated: true)
        }
       
    }
    
    private func BindButton(){
        
        helpDoc.isHidden=true
        
        self.AddTex.addTarget(self, action: #selector(ADDTEX_tapped), for: .touchUpInside)
        self.Confirm.addTarget(self, action: #selector(CONFIRM_tapped), for: .touchUpInside)
        self.Store.addTarget(self, action: #selector(STORE_tapped), for: .touchUpInside)
        self.Help.addTarget(self, action: #selector(HELP_tapped), for: .touchUpInside)
        self.HideUI.addTarget(self, action: #selector(HIDE_tapped), for: .touchUpInside)
        self.Trans.addTarget(self, action: #selector(TRANS_tapped), for: .touchUpInside)
        self.Quit.addTarget(self, action: #selector(QUIT_tapped), for: .touchUpInside)
        self.Plus.addTarget(self, action: #selector(PLUS_tapped), for: .touchUpInside)
        
        
        
        
        
        let longPressGes = UILongPressGestureRecognizer(target: self, action: #selector(STORE_long_tapped))
                // 长按手势最小触发时间
        longPressGes.minimumPressDuration = 1
        // 需要点击的次数
        //        longPressGes.numberOfTapsRequired = 1
        // 长按手势需要的同时敲击触碰数（手指数）
        longPressGes.numberOfTouchesRequired = 1
        // 长按有效移动范围（从点击开始，长按移动的允许范围 单位 px
        longPressGes.allowableMovement = 15

        self.Store.isUserInteractionEnabled = true
        self.Store.addGestureRecognizer(longPressGes)

    }
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(true)
        modelImage.borderWidth=0;

    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        imageCache = ChartletImageCache(textures: chartlets)
       
        
        self.navigationController?.isNavigationBarHidden=true  //关闭顶部菜单栏
        // Do any additional setup after loading the view, typically from a nib.
        
         navigationController?.interactivePopGestureRecognizer?.isEnabled = false
        img = ["1", "2","3","4","5"]
        img_tex=img.compactMap(
            { (name) -> MLTexture? in  //输入为name，输出为MLTexture类型
            return try? canvas.makeTexture(with: UIImage(named: name)!.pngData()!)
            }
        )
        
        style=["boat","chinese","dusk","muse","starry_night"]
        style_tex=style.compactMap(
            { (name) -> MLTexture? in  //输入为name，输出为MLTexture类型
            return try? canvas.makeTexture(with: UIImage(named: name)!.pngData()!)
            }
        )
    
        chartlets = ["chartlet-1", "chartlet-2", "chartlet-3"].compactMap(
            { (name) -> MLTexture? in  //输入为name，输出为MLTexture类型
            return try? canvas.makeTexture(with: UIImage(named: name)!.pngData()!)
            }//compactMap对每一个元素适用括号内函数变换
        )

        
      //  picCollection.reloadData()
//        canvas.backgroundColor = UIColor(displayP3Red:(CGFloat)(0.01), green: 1.0, blue: 1.0, alpha: 1.0)
        canvas.data.addObserver(self)
        
        
        /*
            设置画板在屏幕中央
         */
        CanvasView.frame.size=CGSize(width: 800, height: 600)
        CanvasView.center=CGPoint(x: UIScreen.main.bounds.width/2, y: UIScreen.main.bounds.height/2)
        canvas.frame.size=CGSize(width: 800, height: 600)
        
        canvas.center=CGPoint(x: UIScreen.main.bounds.width/2, y: UIScreen.main.bounds.height/2)
        /*
            设置画板大小
         */
        
        
        self.changeStar(level: self.CurrLevel)
        self.HideUI.isEnabled=false
        self.Plus.isEnabled=false
        
        ColorPannel.isHidden=true
        helpDoc.isHidden=false
        
        modelImage.translatesAutoresizingMaskIntoConstraints=false;
        let pan = UIPanGestureRecognizer(target: self, action: #selector(handlePanGesture(_:)))
        modelImage.addGestureRecognizer(pan)
        
        let pinch = UIPinchGestureRecognizer(target: self, action: #selector(handlePinchGesture(_:)))
        modelImage.addGestureRecognizer(pinch)
        let tap   = UITapGestureRecognizer(target: self, action: #selector(handleTapGesture(_:)))
        modelImage.addGestureRecognizer(tap)
        modelImage.snp.makeConstraints {
            $0.centerX.equalTo(self.view.center.x)
            $0.centerY.equalTo(self.view.center.x)
            $0.size.equalTo(200)
        }
        
        ColorPannel.dataSource=self;
        ColorPannel.delegate=self;
        ColorPicker.addTarget(self, action: #selector(CPtapped), for: .touchUpInside)
        
        self.BindButton()
        registerBrushes()
        readDataIfNeeds()
//        modelImage.borderWidth=3
    }
    
    
    func resizeCanvas(){
        let width=modelImage.image!.size.width;
        let height = modelImage.image!.size.height;
        if width.isLessThanOrEqualTo(height)==true {
            CanvasView.frame.size=CGSize(width: width*(600/height), height: 600)
            canvas.frame.size=CGSize(width: width*(600/height), height: 600)
            outputImage.frame.size=CGSize(width: width*(600/height), height: 600)
        }else{
            CanvasView.frame.size=CGSize(width: 600, height: height*(600/width))
            canvas.frame.size=CGSize(width: 600,height: height*(600/width))
            outputImage.frame.size=CGSize(width: 600,height: height*(600/width))
        }
        CanvasView.center=CGPoint(x: UIScreen.main.bounds.width/2, y: UIScreen.main.bounds.height/2)
        canvas.center=CGPoint(x: UIScreen.main.bounds.width/2, y: UIScreen.main.bounds.height/2)
        outputImage.center=CGPoint(x: UIScreen.main.bounds.width/2, y: UIScreen.main.bounds.height/2)
    }
    
    func registerBrushes() {
        do {
            let pen = canvas.defaultBrush!
            pen.name = "马克笔"
            pen.pointSize = 5
            pen.pointStep = 0.5
            pen.color = color
            
            let pencil = try registerBrush(with: "pencil")
            pencil.name="铅笔"
            pencil.rotation = .random
            pencil.pointSize = 3
            pencil.pointStep = 2
            pencil.forceSensitive = 0.3
            pencil.opacity = 1
            
            let brush = try registerBrush(with: "brush")
            brush.name="毛笔"
            brush.opacity = 1
            brush.rotation = .ahead
            brush.pointSize = 15
            brush.pointStep = 1
            brush.forceSensitive = 1
            brush.color = color
            brush.forceOnTap = 0.5
            
            let texture = try canvas.makeTexture(with: UIImage(named: "glow")!.pngData()!)
            let glow: GlowingBrush = try canvas.registerBrush(name: "glow", textureID: texture.id)
            glow.name="荧光"
            glow.opacity = 0.5
            glow.coreProportion = 0.2
            glow.pointSize = 20
            glow.rotation = .ahead
            
            let claw = try registerBrush(with: "claw")
            claw.name="水痕"
            claw.rotation = .ahead
            claw.pointSize = 30
            claw.pointStep = 5
            claw.forceSensitive = 0.1
            claw.color = color
            
            /// make a chartlet brush
//            let chartletBrush = try ChartletBrush(name: "Chartlet", imageNames: ["rect-1", "rect-2", "rect-3"], target: canvas)
//            chartletBrush.name="点点图"
//            chartletBrush.renderStyle = .ordered
//            chartletBrush.rotation = .random
            
            // make eraser with a texture for claw
//            let eraser = try canvas.registerBrush(name: "Eraser", textureID: claw.textureID) as Eraser
//            eraser.rotation = .ahead
            
            /// make eraser with default round point
            let eraser = try! canvas.registerBrush(name: "Eraser") as Eraser
            eraser.name="橡皮擦"
            eraser.opacity = 1
            
            brushes = [pen, pencil, brush, glow, claw, eraser]
            
        } catch MLError.simulatorUnsupported {
            let alert = UIAlertController(title: "Attension", message: "You are running MaLiang on a Simulator, whitch is not supported by Metal. So painting is not alvaliable now. But you can go on testing your other businesses which are not relative with MaLiang. Or you can also runs MaLiang on your Mac with Catalyst enabled now.", preferredStyle: .alert)
            alert.addAction(title: "确定", style: .cancel)
            self.present(alert, animated: true, completion: nil)
        } catch {
            let alert = UIAlertController(title: "错误", message: error.localizedDescription, preferredStyle: .alert)
            alert.addAction(title: "确定", style: .cancel)
            self.present(alert, animated: true, completion: nil)
        }
        
        brushSegement.removeAllSegments()
        for i in 0 ..< brushes.count {
            let name = brushes[i].name
            brushSegement.insertSegment(withTitle: name, at: i, animated: false)
        }
        
        if brushes.count > 0 {
            brushSegement.selectedSegmentIndex = 0
            styleChanged(brushSegement)
        }
    }
    
//    @IBAction func switchBackground(_ sender: UIButton) {
//        sender.isSelected.toggle()
//        backgroundView.isHidden = !sender.isSelected
//    }//没有这个按钮，这个触发函数也没用
//
    @IBAction func changeSizeAction(_ sender: UISlider) {
        let size = Int(sender.value)
        canvas.currentBrush.pointSize = CGFloat(size)
        strokeSizeLabel.text = "\(size)"
    }
    
    
    @IBAction func styleChanged(_ sender: UISegmentedControl) {
        let index = sender.selectedSegmentIndex
        let brush = brushes[index]
        brush.color = color
        brush.use()
        strokeSizeLabel.text = "\(brush.pointSize)"
        sizeSlider.value = Float(brush.pointSize)
    }
    
    private func togglePencilMode() {
        canvas.isPencilMode = !canvas.isPencilMode
    }  //这东西被我删了  没用！
    
    @IBAction func undoAction(_ sender: Any) {
        canvas.undo()
    }
    
    @IBAction func redoAction(_ sender: Any) {
        canvas.redo()
    }
    
    @IBAction func clearAction(_ sender: Any) {
        canvas.clear()
    }
    
    
    
    @IBAction func moreAction(_ sender: UIBarButtonItem) {
        let actionSheet = UIAlertController(title: "选项", message: nil, preferredStyle: .actionSheet)
        actionSheet.addAction(title: "贴图", style: .default) { [unowned self] (_) in
            self.addChartletAction()
        }
        actionSheet.addAction(title: "预览", style: .default) { [unowned self] (_) in
            self.snapshotAction(sender)
        }
        actionSheet.addAction(title: "暂存", style: .default) { [unowned self] (_) in
            self.saveData()
        }
        actionSheet.addAction(title: "取消", style: .cancel)
        actionSheet.popoverPresentationController?.barButtonItem = sender
        present(actionSheet, animated: true, completion: nil)
    }
    
    private var currentScale: CGFloat = 0.5
    var panOffset = CGPoint.zero
    @objc private func handlePinchGesture(_ gesture: UIPinchGestureRecognizer) {
        let scale = currentScale * gesture.scale * gesture.scale
        if gesture.state == .ended {
            scaleContent(to: scale)
            currentScale = scale
        }
        if gesture.state == .changed {
            scaleContent(to: scale)
        }
    }//缩放手势
    
    @objc func CPtapped(sender: UIButton){
        if ColorPannel.isHidden == true {
            ColorPannel.isHidden=false;
        }else {
            ColorPannel.isHidden=true;
        }
    }
    
    @objc private func handlePanGesture(_ gesture: UIPanGestureRecognizer) {
        let location = gesture.location(in: self.view)
        
//        if gesture.state == .began {
//            canvas.isMultipleTouchEnabled=false;
//        }
        if gesture.state == .changed {
            moveContent(to: location)
        }
    }  //平移手势
    
    @objc private func handleTapGesture(_ gesture: UITapGestureRecognizer){
        self.canvas.isMultipleTouchEnabled=false;
        picPicAction(cq:true)
    }
    private func scaleContent(to scale: CGFloat) {
        let scale = scale.valueBetween(min: 0.8, max: 5)
        let newW=200*scale
        let newH=200*scale
        modelImage.snp.updateConstraints {
            $0.width.equalTo(newW)
            $0.height.equalTo(newH)
        }
    }
    
    private func moveContent(to location: CGPoint) {
        modelImage.snp.updateConstraints {
            $0.centerX.equalTo(location.x)
            $0.centerY.equalTo(location.y)
        }
    }
    
    func addChartletAction() {
        ChartletPicker.present(from: self, textures: chartlets) { [unowned self] (texture) in
            self.showEditor(for: texture)
        }
    }
    
    
    
    //选择临摹图片
    func picPicAction(cq:Bool){
        PicPicker.present(from: self, textures: img_tex,canQ: cq ,title:"请选择图片") { [unowned self] (index) in
            self.ID = Int(self.img[index])!
            self.setModelImage(img:self.img[index])
            self.modelImage.borderWidth=2
            resizeCanvas()
        }
    }
    
    func setModelImage(img:String){
        canvas.defaultImg=img
        modelImage.image=UIImage.init(named : img)!
//
//        modelImage.image=canvas.snapshot()
//        print(canvas.snapshot()?.size)
        
//        let img=getImage(size: CGSize(width: 500, height: 500), currentView: CanvasView)
    }
    func show(for texture: MLTexture)   {
    }
    
    func showEditor(for texture: MLTexture) {
        ChartletEditor.present(from: self, for: texture) { [unowned self] (editor) in
            let result = editor.convertCoordinate(to: self.canvas)
            self.canvas.renderChartlet(at: result.center, size: result.size, textureID: texture.id, rotation: result.angle)
        }
    }
    func getImage(size:CGSize , currentView:UIView) -> UIImage {
            UIGraphicsBeginImageContextWithOptions( size, true, 1.0)
            currentView.layer.render(in: UIGraphicsGetCurrentContext()!)
            let image = UIGraphicsGetImageFromCurrentImageContext();
            UIGraphicsEndImageContext();
            return image!;
        }

    func snapshotAction(_ sender: Any) {
        let preview = PaintingPreview.create(from: .main)
        preview.image = canvas.snapshot()
        navigationController?.pushViewController(preview, animated: true)
    }
    
    func saveData() {
        self.chrysan.showMessage("暂存中...")
        let exporter = DataExporter(canvas: canvas)
        let path = Path.temp().resource(Date().string())
        path.createDirectory()
        exporter.save(to: path.url, progress: { (progress) in
            self.chrysan.show(progress: progress, message: "暂存中...")
        }) { (result) in
            if case let .failure(error) = result {
                self.chrysan.hide()
                let alert = UIAlertController(title: "暂存失败", message: error.localizedDescription, preferredStyle: .alert)
                alert.addAction(title: "完成", style: .cancel)
                self.present(alert, animated: true, completion: nil)
            } else {
                let filename = "1_\(self.ObjectName!)_\(self.canvas.defaultImg)"
                
                let contents = try! FileManager.default.contentsOfDirectory(at: path.url, includingPropertiesForKeys: [], options: .init(rawValue: 0))
                try? Zip.zipFiles(paths: contents, zipFilePath: Path.documents().resource(filename).url, password: nil, progress: nil)
                try? FileManager.default.removeItem(at: path.url)
                self.chrysan.show(.succeed, message: "暂存成功!", hideDelay: 1)
            }
        }
    }
    
    func readDataIfNeeds() {
        guard let file = filePath else {
            picPicAction(cq:false)
            return
        }
        chrysan.showMessage("读取中...")
        
        let path = Path(file)
        let temp = Path.temp().resource("temp.zip")
        let contents = Path.temp().resource("contents")
        
        do {
            try? FileManager.default.removeItem(at: temp.url)
            try FileManager.default.copyItem(at: path.url, to: temp.url)
            try Zip.unzipFile(temp.url, destination: contents.url, overwrite: true, password: nil)
        } catch {
            self.chrysan.hide()
            let alert = UIAlertController(title: "解压失败", message: error.localizedDescription, preferredStyle: .alert)
            alert.addAction(title: "完成", style: .cancel)
            self.present(alert, animated: true, completion: nil)
            return
        }
        
        
        DataImporter.importData(from: contents.url, to: canvas, progress: { (progress) in
            
        }) { (result) in
            if case let .failure(error) = result {
                self.chrysan.hide()
                let alert = UIAlertController(title: "读取失败", message: error.localizedDescription, preferredStyle: .alert)
                alert.addAction(title: "完成", style: .cancel)
                self.present(alert, animated: true, completion: nil)
            } else {
                self.chrysan.show(.succeed, message: "读取成功!", hideDelay: 1)
                self.canvas.defaultImg="\(path.url.lastPathComponent.split(separator: "_")[2])"
                self.ObjectName="\(path.url.lastPathComponent.split(separator: "_")[1])"
                print("path:",self.canvas.defaultImg)
                self.ID=Int(self.canvas.defaultImg)!
                self.setModelImage(img:self.canvas.defaultImg)
                self.resizeCanvas()
                self.modelImage.borderWidth=2
            }
            
        }
        
    }
    
    // MARK: - color
    @IBOutlet weak var colorSampleView: UIView!
    @IBOutlet weak var redSlider: UISlider!
    @IBOutlet weak var greenSlider: UISlider!
    @IBOutlet weak var blueSlider: UISlider!
    @IBOutlet weak var rl: UILabel!
    @IBOutlet weak var gl: UILabel!
    @IBOutlet weak var bl: UILabel!
    
    var r: CGFloat = 0
    var g: CGFloat = 0
    var b: CGFloat = 0
    
    @IBAction func colorChanged(_ sender: UISlider) {
        let value = Int(sender.value)
        let colorv = CGFloat(value) / 255
        switch sender.tag {
        case 0:
            r = colorv
            rl.text = "\(value)"
        case 1:
            g = colorv
            gl.text = "\(value)"
        case 2:
            b = colorv
            bl.text = "\(value)"
        default: break
        }
        
        colorSampleView.backgroundColor = color
        canvas.currentBrush.color = color
    }
    
    var index:IndexPath = []
    
    public func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return  colors.count
    }
    
    public func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "PicCoCell", for: indexPath) as! PicCoCell
        cell.color.backgroundColor=UIColor(red:(CGFloat)(colors[indexPath.item].R)/255.0,green:(CGFloat)(colors[indexPath.item].G)/255.0,blue:(CGFloat)(colors[indexPath.item].B)/255.0,alpha: 1.0);
        cell.name.text=colors[indexPath.item].name
        return  cell
    }
    
    public func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        let cell=ColorPannel.cellForItem(at: indexPath)
        cell?.borderColor=UIColor(red:0,green:1.0,blue:0,alpha: 1.0)
        if !index.isEmpty && index != indexPath {
            let cell2=ColorPannel.cellForItem(at: index)
            cell2?.borderColor=UIColor(red:1.0,green: 1.0,blue: 1.0,alpha: 1.0)
            self.index=indexPath
        }
        index=indexPath
        
        let re=(CGFloat)(colors[indexPath.item].R)/255.0
        let gr=(CGFloat)(colors[indexPath.item].G)/255.0
        let blu=(CGFloat)(colors[indexPath.item].B)/255.0
        
        colorSampleView.backgroundColor = UIColor(red: re, green: gr, blue: blu, alpha: 1.0)
    
        canvas.currentBrush.color = UIColor(red: re, green: gr, blue: blu, alpha: 1.0)
        redSlider.value=(Float)(colors[indexPath.item].R);
        greenSlider.value=(Float)(colors[indexPath.item].G);
        blueSlider.value=(Float)(colors[indexPath.item].B);
        r=re
        g=gr
        b=blu
        rl.text=redSlider.value.string()
        gl.text=greenSlider.value.string()
        bl.text=blueSlider.value.string()
        
        
        
        
    }
    

    
    
}

extension UIColor{
    func UIColorFromRGB(R:Int,G:Int,B:Int)->UIColor{
        return UIColor(red:CGFloat(R),green: CGFloat(G),blue: CGFloat(B),alpha: CGFloat(1));
    }
}

extension ViewController: DataObserver {
    /// called when a line strip is begin
    func lineStrip(_ strip: LineStrip, didBeginOn data: CanvasData) {
        self.redoButton.isEnabled = false
        self.needSave=true
    }
    
    /// called when a element is finished
    func element(_ element: CanvasElement, didFinishOn data: CanvasData) {
        self.undoButton.isEnabled = true
        self.needSave=true
    }
    
    /// callen when clear the canvas
    func dataDidClear(_ data: CanvasData) {
        self.needSave=true
    }
    
    /// callen when undo
    func dataDidUndo(_ data: CanvasData) {
        self.undoButton.isEnabled = true
        self.redoButton.isEnabled = data.canRedo
        self.needSave=true
    }
    
    /// callen when redo
    func dataDidRedo(_ data: CanvasData) {
        self.undoButton.isEnabled = true
        self.redoButton.isEnabled = data.canRedo
        self.needSave=true
    }
}

extension String {
    var floatValue: CGFloat {
        let db = Double(self) ?? 0
        return CGFloat(db)
    }
    func substring(from index:Int)->String{
        guard let start_index=validStartIndex(original:index) else{
            return self
        }
        return String(self[start_index..<endIndex])
    }
    func substring(to index:Int)->String{
        guard let end_index=validStartIndex(original:index) else{
            return self
        }
        return String(self[startIndex..<end_index])
    }
    
    private func validStartIndex(original:Int)->String.Index?{
        guard original<=endIndex.encodedOffset else{return nil}
        return validIndex(original:original)
    }
    private func validIndex(original:Int)->String.Index{
        switch original {
        case ...startIndex.encodedOffset:return startIndex
        case endIndex.encodedOffset...:return endIndex
            
        default:return index(startIndex,offsetBy: original)
        }
    }
}




extension UIView{
    func asImage()->UIImage{
        let format = UIGraphicsImageRendererFormat()
                format.prefersExtendedRange = true
                let renderer = UIGraphicsImageRenderer.init(bounds: bounds, format: format)
        let image = renderer.image {
                    context in
//                    context.cgContext.concatenate(CGAffineTransform.identity.scaledBy(x: 1, y: 1))
                    return layer.render(in: context.cgContext)
                }
        return image
    }
}


class PicCoCell: UICollectionViewCell {
    
    @IBOutlet weak var color: UILabel!
    @IBOutlet weak var name: UILabel!
}

struct color {
    var R:Int;
    var G:Int;
    var B:Int;
    var name:String;
}
var colors:[color]=[
    
    color(R:188,G:230,B:114,name:"松花色"),
    color(R:201,G:221,B:34,name:"柳黄"),
    color(R:189,G:221,B:34,name:"嫩绿"),
    color(R:175,G:221,B:34,name:"柳绿"),
    color(R:158,G:217,B:0,name:"葱绿"),
    color(R:147,G:208,B:72,name:"豆绿"),
    
    color(R:150,G:206,B:84,name:"豆青"),
    color(R:0,G:188,B:18,name:"油绿"),
    color(R:0,G:224,B:121,name:"青翠"),
    color(R:0,G:224,B:158,name:"青色"),
    color(R:61,G:225,B:173,name:"翡翠色"),
    color(R:123,G:207,B:166,name:"石青"),
    
    color(R:68,G:206,B:246,name:"蓝色"),
    color(R:62,G:237,B:231,name:"碧蓝"),
    color(R:23,G:124,B:176,name:"靛青"),
    color(R:6,G:82,B:121,name:"靛蓝"),
    color(R:0,G:52,B:114,name:"花青"),
    color(R:0,G:51,B:113,name:"绀青"),
    
    color(R:86,G:0,B:79,name:"紫棠"),
    color(R:128,G:29,B:174,name:"青莲"),
    color(R:176,G:164,B:227,name:"血青"),
    color(R:204,G:164,B:227,name:"丁香"),
    color(R:237,G:206,B:216,name:"藕色"),
    color(R:161,G:175,B:201,name:"蓝灰色"),
    
    color(R:234,G:255,B:86,name:"樱草色"),
    color(R:255,G:231,B:67,name:"鹅黄"),
    color(R:250,G:255,B:114,name:"鸭黄"),
    color(R:255,G:166,B:49,name:"杏黄"),
    color(R:255,G:164,B:0,name:"橙黄"),
    color(R:255,G:117,B:0,name:"橘红"),
    
    color(R:211,G:177,B:125,name:"枯黄"),
    color(R:226,G:156,B:69,name:"黄栌"),
    color(R:167,G:142,B:68,name:"乌金"),
    color(R:202,G:105,B:36,name:"琥珀"),
    color(R:179,G:92,B:68,name:"茶色"),
    color(R:155,G:68,B:0,name:"棕红"),
    
    color(R:255,G:70,B:31,name:"朱砂"),
    color(R:237,G:87,B:54,name:"妃色"),
    color(R:255,G:179,B:167,name:"粉红"),
    color(R:244,G:121,B:131,name:"桃红"),
    color(R:219,G:90,B:107,name:"海棠红"),
    color(R:255,G:45,B:81,name:"火红"),
    
    color(R:233,G:231,B:239,name:"银白"),
    color(R:240,G:240,B:244,name:"铅白"),
    color(R:233,G:241,B:246,name:"霜色"),
    color(R:240,G:252,B:255,name:"雪白"),
    color(R:255,G:251,B:240,name:"象牙白"),
    color(R:242,G:236,B:222,name:"缟"),
    
    
    
    
]




var httpURL:String = "http:192.168.172.228:5000"
