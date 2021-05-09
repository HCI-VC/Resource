//
//  ChartletPicker.swift
//  MaLiang
//
//  Created by Harley-xk on 2019/4/26.
//

import UIKit
import MaLiang

open class PicPicker: UIViewController ,UICollectionViewDataSource, UICollectionViewDelegateFlowLayout{
    
    public struct Options {
        public var itemSize = CGSize(width: 200, height: 200)
        public static var `default` = Options()
    }
    
    public typealias ResultHandler = (Int) -> ()
    
    public static func present(from source: UIViewController, textures: [MLTexture], canQ:Bool ,options: Options = .default, result: ResultHandler?) {

        let picker = PicPicker.createInitial(from: UIStoryboard("PicPicker"))
        picker.source = source
        picker.textures = textures
        picker.options = options
        picker.canQuit=canQ
        picker.resultHandler = result
        picker.modalPresentationStyle = .overCurrentContext
        picker.modalTransitionStyle = .crossDissolve //交叉溶解跳转动画
        source.present(picker, animated: true, completion: nil)

    }

    private weak var source: UIViewController!
    private var textures: [MLTexture]!
    private var options: Options!
    private var resultHandler: ResultHandler?
    private var canQuit:Bool=false
    private var imageCache: ChartletImageCache!
    
    @IBOutlet private weak var backgroundView: UIView!
    @IBOutlet private weak var collectionView: UICollectionView!
    
    override open func viewDidLoad() {
        super.viewDidLoad()
        
        
        if(canQuit) {
            let tap = UITapGestureRecognizer(target: self, action: #selector(cancelAction))
            backgroundView.addGestureRecognizer(tap)
        }
        imageCache = ChartletImageCache(textures: textures)
    }
    
    override open func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        collectionView.dataSource=self;
        collectionView.delegate=self;
       // collectionView.reloadData()
        runAppearAnimations()
        print("end willappear")
    }

    @objc func cancelAction() {
        runDisappearAnimations { (_) in
            self.dismiss(animated: false, completion: nil)
        }
    }

    // MARK: - Animations
    private func runAppearAnimations() {
        let transform = CGAffineTransform(translationX: 0, y: view.bounds.height - collectionView.frame.origin.y + 200)
        //The fucking guy is very clever. Tranform to transform and then transform to .identity.
        collectionView.transform = transform
        UIView.animate(withDuration: 0.2) {
            self.backgroundView.backgroundColor = UIColor.black.withAlphaComponent(0.35)
            self.collectionView.transform = .identity
        }
    }
    
    private func runDisappearAnimations(completion: ((Bool) -> Void)? = nil) {
        let endTransform = view.bounds.height - collectionView.frame.origin.y + 20
    
        UIView.animate(withDuration: 0.2, animations: {
            self.backgroundView.backgroundColor = .clear
            self.collectionView.transform = CGAffineTransform(translationX: 0, y: endTransform)
            
        }, completion: completion)
    }
    
    
    public func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return textures.count
    }
    
    public func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "PicPickerItemCell", for: indexPath) as! PicPickerItemCell
        cell.imageView.loadImage(for: textures[indexPath.item], from: imageCache)
        return cell
    }
    
    public func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        runDisappearAnimations { (_) in
            self.dismiss(animated: false, completion: {
                print(2222)
                self.resultHandler?(indexPath.item)
            })
        }
    }

}

//extension PicPicker: UICollectionViewDataSource, UICollectionViewDelegateFlowLayout {
//    public func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
//        return textures.count
//    }
//
//    public func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
//        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "PicPickerItemCell", for: indexPath) as! PicPickerItemCell
//        cell.imageView.loadImage(for: textures[indexPath.item], from: imageCache)
//        return cell
//    }
//
//    public func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
//        runDisappearAnimations { (_) in
//            self.dismiss(animated: false, completion: {
//                self.resultHandler?(self.textures[indexPath.item])
//            })
//        }
//    }
//}

class PicPickerItemCell: UICollectionViewCell {
    @IBOutlet weak var imageView: UIImageView!
}
