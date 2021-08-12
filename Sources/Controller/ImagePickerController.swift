// The MIT License (MIT)
//
// Copyright (c) 2019 Joakim Gyllström
//
// Permission is hereby granted, free of charge, to any person obtaining a copy
// of this software and associated documentation files (the "Software"), to deal
// in the Software without restriction, including without limitation the rights
// to use, copy, modify, merge, publish, distribute, sublicense, and/or sell
// copies of the Software, and to permit persons to whom the Software is
// furnished to do so, subject to the following conditions:
//
// The above copyright notice and this permission notice shall be included in all
// copies or substantial portions of the Software.
//
// THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR
// IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY,
// FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE
// AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER
// LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM,
// OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN THE
// SOFTWARE.

import UIKit
import Photos

// MARK: ImagePickerController
@objc(BSImagePickerController)
@objcMembers open class ImagePickerController: UINavigationController {
  // MARK: Public properties
  public weak var imagePickerDelegate: ImagePickerControllerDelegate?
  public var settings: Settings = Settings()
  public var albumButton: UIButton = UIButton(type: .custom)
  public var selectedAssets: [PHAsset] {
    get {
      return assetStore.assets
    }
  }
  public var isAlbumExist: Bool = true
  public var isImageExist: Bool = true
  
  
  // MARK: Internal properties
  var assetStore: AssetStore
  var onSelection: ((_ asset: PHAsset) -> Void)?
  var onDeselection: ((_ asset: PHAsset) -> Void)?
  var onCancel: ((_ assets: [PHAsset]) -> Void)?
  var onFinish: ((_ assets: [PHAsset]) -> Void)?
  
  let assetsViewController: AssetsViewController
  let albumsViewController = AlbumsViewController()
  lazy var dropdownTransitionDelegate = DropdownTransitionDelegate(albumCount: self.albums.count)
  let zoomTransitionDelegate = ZoomTransitionDelegate()
  
  lazy var albums: [PHAssetCollection] = {
    // We don't want collections without assets.
    // I would like to do that with PHFetchOptions: fetchOptions.predicate = NSPredicate(format: "estimatedAssetCount > 0")
    // But that doesn't work...
    // This seems suuuuuper ineffective...
    let fetchOptions = settings.fetch.assets.options.copy() as! PHFetchOptions
    fetchOptions.fetchLimit = 1
    
    return settings.fetch.album.fetchResults.filter {
      $0.count > 0
    }.flatMap {
      $0.objects(at: IndexSet(integersIn: 0..<$0.count))
    }.filter {
      // We can't use estimatedAssetCount on the collection
      // It returns NSNotFound. So actually fetch the assets...
      let assetsFetchResult = PHAsset.fetchAssets(in: $0, options: fetchOptions)
      return assetsFetchResult.count > 0
    }
  }()
  
  public init(selectedAssets: [PHAsset] = []) {
    assetStore = AssetStore(assets: selectedAssets)
    assetsViewController = AssetsViewController(store: assetStore)
    super.init(nibName: nil, bundle: nil)
    
    self.navigationBar.shadowImage = UIColor(hex: "#2C2C2E")!.image(CGSize(width: self.view.frame.width, height: 1))
  }
  
  public required init?(coder aDecoder: NSCoder) {
    fatalError("init(coder:) has not been implemented")
  }
  
  public override func viewDidLoad() {
    super.viewDidLoad()
    
    // Sync settings
    albumsViewController.settings = settings
    assetsViewController.settings = settings
    
    // Setup view controllers
    albumsViewController.delegate = self
    assetsViewController.delegate = self
    
    viewControllers = [assetsViewController]
    view.backgroundColor = settings.theme.backgroundColor
    
    // Setup delegates
    delegate = zoomTransitionDelegate
    presentationController?.delegate = self
    
    // Turn off translucency so drop down can match its color
    navigationBar.isTranslucent = false
    navigationBar.isOpaque = true
    
    // Setup buttons
    let firstViewController = viewControllers.first
    albumButton.tintColor = .white
    albumButton.setTitleColor(albumButton.tintColor, for: .normal)
    albumButton.titleLabel?.font = .systemFont(ofSize: 16)
    albumButton.titleLabel?.adjustsFontSizeToFitWidth = true
    
    let arrowView = ArrowView(frame: CGRect(x: 0, y: 0, width: 8, height: 8))
    arrowView.backgroundColor = .clear
    arrowView.strokeColor = albumButton.tintColor
    let image = arrowView.asImage
    
    albumButton.setImage(image, for: .normal)
    albumButton.semanticContentAttribute = .forceRightToLeft // To set image to the right without having to calculate insets/constraints.
    albumButton.addTarget(self, action: #selector(ImagePickerController.albumsButtonPressed(_:)), for: .touchUpInside)
    firstViewController?.navigationItem.titleView = albumButton
    
    let backimage = UIImageView()
    backimage.image = UIImage(named: "Close")
    backimage.frame = CGRect(x: 0, y: 0, width: 44, height: 44)
    let gesture = UITapGestureRecognizer(target: self, action: #selector(closeButtonPressed(_:)))
    backimage.addGestureRecognizer(gesture)
    firstViewController?.navigationItem.leftBarButtonItem = UIBarButtonItem(customView: backimage)
    
    updateAlbumButton()
    
    self.navigationBar.barTintColor = UIColor(hex: "#1C1C1E")!
    
    if let firstAlbum = albums.first {
      select(album: firstAlbum)
    } else {
      self.isAlbumExist = false
      self.isImageExist = self.assetsViewController.isImageExist
    }
  }
  
  public func deselect(asset: PHAsset) {
    assetsViewController.unselect(asset: asset)
    assetStore.remove(asset)
  }
  
  func updateAlbumButton() {
    albumButton.isHidden = albums.count < 2
  }
}
