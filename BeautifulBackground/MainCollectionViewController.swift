//
//  MainCollectionViewController.swift
//  BeautifulBackground
//
//

import UIKit
import Alamofire
import SwiftyJSON
import Kingfisher

private let reuseIdentifier = "mainCell"

class MainCollectionViewController: UICollectionViewController {
    
    let Url : String = "https://api.unsplash.com/photos/search"
    let key : String = "29a307bccd8555abb09dcd36bbc3e014bad09e75e18c18ae369eb338b2a01f4a"
    
    var query:String?
    let perPage:String = "6"
    var themeLists:[ThemeList] = []
    var selectedRow:Int?

    var page: Int = 1
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.getImages(page)
    }
    
    override func viewWillAppear(animated: Bool) {
        self.navigationController?.navigationBarHidden = false
    }
    
    func getImages(page: Int) {
        dispatch_async(dispatch_get_main_queue(), {

            var jsonData:JSON?
            Alamofire.request(.GET, self.Url, parameters: ["client_id":self.key, "per_page":self.perPage, "query":self.query!, "page":self.page])
                .responseJSON(completionHandler: { req, _, result in
                    print(req)
                    UIApplication.sharedApplication().networkActivityIndicatorVisible = false
                    if result.value != nil {
                        jsonData = JSON(result.value!)
                        print(jsonData)
                        for (_, subJson):(String, JSON) in jsonData! {
                            let themeList:ThemeList = ThemeList()
                            themeList.id = subJson["id"].stringValue
                            themeList.keyword = self.query
                            themeList.width = subJson["width"].intValue
                            themeList.height = subJson["height"].intValue
                            themeList.smallUrl = subJson["urls"]["small"].stringValue
                            Alamofire.request(.GET, "https://api.unsplash.com/photos/\(themeList.id!)/", parameters: ["client_id":self.key,"w":"750"]).responseJSON(completionHandler: { req, _, result in
                                print(req)
                                if result.value != nil {
                                    jsonData = JSON(result.value!)
                                    themeList.fullsizeUrl = jsonData!["urls"]["custom"].stringValue
                                }
                            })
                            
                            self.themeLists.append(themeList)
                            
                            self.collectionView?.insertItemsAtIndexPaths([NSIndexPath(forRow: self.themeLists.count-1, inSection: 0)])
                            self.collectionView?.reloadItemsAtIndexPaths([NSIndexPath(forRow: self.themeLists.count-1, inSection: 0)])
                        }
     
                    }
                })
        })
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }

    override func scrollViewDidEndDecelerating(scrollView: UIScrollView) {
//        let bottomEdge = scrollView.contentOffset.y + scrollView.frame.size.height
//        if bottomEdge >= scrollView.contentSize.height {
//            getImages(++page)
//        }
    }

    // MARK: UICollectionViewDataSource

    override func numberOfSectionsInCollectionView(collectionView: UICollectionView) -> Int {
        // #warning Incomplete implementation, return the number of sections
        return 1
    }

    override func collectionView(collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        // #warning Incomplete implementation, return the number of items
        return self.themeLists.count
    }

    override func collectionView(collectionView: UICollectionView, cellForItemAtIndexPath indexPath: NSIndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCellWithReuseIdentifier(reuseIdentifier, forIndexPath: indexPath) as! MainCollectionViewCell
    
        // Configure the cell
        cell.imageViewThumbnail.contentMode = .ScaleToFill
//        cell.imageViewThumbnail.layer.borderWidth = 3
//        cell.imageViewThumbnail.layer.borderColor = UIColor.redColor().CGColor.Transition(ImageTransition.Fade(0.2)
        if let thumbUrl = self.themeLists[indexPath.row].smallUrl {
            cell.imageViewThumbnail.kf_showIndicatorWhenLoading = true
            cell.imageViewThumbnail.kf_setImageWithURL(NSURL(string: thumbUrl)!, placeholderImage: nil, optionsInfo: [.Transition(ImageTransition.Fade(0.2))]) {
                (image, error, cacheType, imageURL) -> () in
//                print("imageSize:\(image?.size.width) & viewSize:\(self.view.frame.size.width/2)")

//                cell.frame = CGRectMake(cell.frame.origin.x, cell.frame.origin.y, cell.frame.size.width, ((image?.size.height)! * cell.frame.size.width)/(image?.size.width)!)
            }
            
        }
        return cell
    }
    
    override func collectionView(collectionView: UICollectionView, shouldSelectItemAtIndexPath indexPath: NSIndexPath) -> Bool {
        self.selectedRow = indexPath.row
        return true
    }
    
    override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
        let targetVC = segue.destinationViewController as? DetailViewController
        
        if let sel = self.selectedRow {
            targetVC?.url = self.themeLists[sel].fullsizeUrl
        }
        
    }
    // MARK: UICollectionViewDelegate

    /*
    // Uncomment this method to specify if the specified item should be highlighted during tracking
    override func collectionView(collectionView: UICollectionView, shouldHighlightItemAtIndexPath indexPath: NSIndexPath) -> Bool {
        return true
    }
    */

    /*
    // Uncomment this method to specify if the specified item should be selected
    override func collectionView(collectionView: UICollectionView, shouldSelectItemAtIndexPath indexPath: NSIndexPath) -> Bool {
        return true
    }
    */

    /*
    // Uncomment these methods to specify if an action menu should be displayed for the specified item, and react to actions performed on the item
    override func collectionView(collectionView: UICollectionView, shouldShowMenuForItemAtIndexPath indexPath: NSIndexPath) -> Bool {
        return false
    }

    override func collectionView(collectionView: UICollectionView, canPerformAction action: Selector, forItemAtIndexPath indexPath: NSIndexPath, withSender sender: AnyObject?) -> Bool {
        return false
    }

    override func collectionView(collectionView: UICollectionView, performAction action: Selector, forItemAtIndexPath indexPath: NSIndexPath, withSender sender: AnyObject?) {
    
    }
    */

}

extension MainCollectionViewController: UICollectionViewDelegateFlowLayout {

    func collectionView(collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAtIndexPath indexPath: NSIndexPath) -> CGSize {

        return CGSize(width: self.view.frame.size.width/2, height: self.view.frame.size.height/4)
    }

    func collectionView(collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, insetForSectionAtIndex section: Int) -> UIEdgeInsets {
        return UIEdgeInsets(top: 0, left: 0, bottom: 0, right: 0)
    }
    
    func collectionView(collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, minimumLineSpacingForSectionAtIndex section: Int) -> CGFloat {
        return 0
    }

    func collectionView(collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, minimumInteritemSpacingForSectionAtIndex section: Int) -> CGFloat {
        return 0
    }

}
