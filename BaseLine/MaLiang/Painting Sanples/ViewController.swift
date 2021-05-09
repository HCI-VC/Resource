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

class ViewController: UIViewController {
    
    @IBOutlet weak var strokeSizeLabel: UILabel!
    @IBOutlet weak var brushSegement: UISegmentedControl!
    @IBOutlet weak var sizeSlider: UISlider!
    @IBOutlet weak var undoButton: UIButton!
    @IBOutlet weak var redoButton: UIButton!

    @IBOutlet weak var canvas: Canvas!

    @IBOutlet weak var modelImage: UIImageView!
    var filePath: String?
    
    var brushes: [Brush] = [] //数组
    var chartlets: [MLTexture] = []
    var img:[String]=[]
    var img_tex: [MLTexture] = []
    private var imageCache: ChartletImageCache!
    var color: UIColor {
        return UIColor(red: r, green: g, blue: b, alpha: 1)
    }
    
    private func registerBrush(with imageName: String) throws -> Brush {
        let texture = try canvas.makeTexture(with: UIImage(named: imageName)!.pngData()!)
        return try canvas.registerBrush(name: imageName, textureID: texture.id)
    }
    

    override func viewDidLoad() {
        super.viewDidLoad()
        imageCache = ChartletImageCache(textures: chartlets)
       
        
        self.navigationController?.isNavigationBarHidden=false  //打开顶部菜单栏
        // Do any additional setup after loading the view, typically from a nib.
        
        navigationController?.interactivePopGestureRecognizer?.isEnabled = false
        img = ["chartlet-1", "chartlet-2", "chartlet-3"]
        img_tex=img.compactMap(
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
        canvas.backgroundColor = .clear
        canvas.data.addObserver(self)
        
        
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
        
        registerBrushes()
        readDataIfNeeds()
        
    }
    
    func registerBrushes() {
        do {
            let pen = canvas.defaultBrush!
            pen.name = "钢笔"
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
            brush.name="笔刷"
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
            claw.name="痕迹"
            claw.rotation = .ahead
            claw.pointSize = 30
            claw.pointStep = 5
            claw.forceSensitive = 0.1
            claw.color = color
            
            /// make a chartlet brush
            let chartletBrush = try ChartletBrush(name: "Chartlet", imageNames: ["rect-1", "rect-2", "rect-3"], target: canvas)
            chartletBrush.name="点点图"
            chartletBrush.renderStyle = .ordered
            chartletBrush.rotation = .random
            
            // make eraser with a texture for claw
//            let eraser = try canvas.registerBrush(name: "Eraser", textureID: claw.textureID) as Eraser
//            eraser.rotation = .ahead
            
            /// make eraser with default round point
            let eraser = try! canvas.registerBrush(name: "Eraser") as Eraser
            eraser.name="橡皮擦"
            eraser.opacity = 1
            
            brushes = [pen, pencil, brush, glow, claw, chartletBrush, eraser]
            
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
    
    private var currentScale: CGFloat = 1
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
    
    @objc private func handlePanGesture(_ gesture: UIPanGestureRecognizer) {
        let location = gesture.location(in: canvas)
        
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
        let scale = scale.valueBetween(min: 0.2, max: 5)
        let newSize = modelImage.image!.size * scale
        modelImage.snp.updateConstraints {
            $0.width.equalTo(newSize.width)
            $0.height.equalTo(newSize.height)
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
    
    func picPicAction(cq:Bool){
        PicPicker.present(from: self, textures: img_tex,canQ: cq) { [unowned self] (index) in
            self.setModelImage(img:self.img[index])
        }
    }
    
    func setModelImage(img:String){
        canvas.defaultImg=img
        modelImage.image=UIImage.init(named : img)!
    }
    func show(for texture: MLTexture)   {
    }
    
    func showEditor(for texture: MLTexture) {
        ChartletEditor.present(from: self, for: texture) { [unowned self] (editor) in
            let result = editor.convertCoordinate(to: self.canvas)
            self.canvas.renderChartlet(at: result.center, size: result.size, textureID: texture.id, rotation: result.angle)
        }
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
                let filename = "\(Date().string(format: "yyyyMMddHHmmss")+"_"+self.canvas.defaultImg).lmz"
                
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
                let str = path.url.lastPathComponent.substring(from: 15)
                self.canvas.defaultImg=str.substring(to: (str.count-4))
                print("path:",self.canvas.defaultImg)
                self.setModelImage(img:self.canvas.defaultImg)
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
    
    
    

    
    
}

extension ViewController: DataObserver {
    /// called when a line strip is begin
    func lineStrip(_ strip: LineStrip, didBeginOn data: CanvasData) {
        self.redoButton.isEnabled = false
    }
    
    /// called when a element is finished
    func element(_ element: CanvasElement, didFinishOn data: CanvasData) {
        self.undoButton.isEnabled = true
    }
    
    /// callen when clear the canvas
    func dataDidClear(_ data: CanvasData) {
        
    }
    
    /// callen when undo
    func dataDidUndo(_ data: CanvasData) {
        self.undoButton.isEnabled = true
        self.redoButton.isEnabled = data.canRedo
    }
    
    /// callen when redo
    func dataDidRedo(_ data: CanvasData) {
        self.undoButton.isEnabled = true
        self.redoButton.isEnabled = data.canRedo
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






class PicItemCell: UICollectionViewCell {
    
    @IBOutlet weak var pic: UIImageView!
}
