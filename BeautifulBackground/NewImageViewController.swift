import UIKit
import Alamofire
import SwiftyJSON
import Kingfisher

class ThemeList {
    var id:String!
    var keyword:String?
    var smallUrl:String?
    var fullsizeUrl:String?
    var width:Int?
    var height:Int?
    var color:String!
    var downloads:Int!
    var likes:Int!
}

class NewImageViewController: UIViewController, UITableViewDelegate, UITableViewDataSource, UIScrollViewDelegate {

    @IBOutlet weak var tableView: UITableView!
    
    let Url : String = "https://api.unsplash.com/photos/"
    let key : String = "29a307bccd8555abb09dcd36bbc3e014bad09e75e18c18ae369eb338b2a01f4a"

    let perPage:String = "5"
    var themeLists:[ThemeList] = []
    var selectedRow:Int?
    var page:Int = 1
    
    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
        tableView.delegate = self
        tableView.dataSource = self
        setBackground(page)
        
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return self.themeLists.count
    }
    
    func tableView(tableView: UITableView, heightForRowAtIndexPath indexPath: NSIndexPath) -> CGFloat {
        let width = CGFloat(self.themeLists[indexPath.row].width!)
        let height = CGFloat(self.themeLists[indexPath.row].height!)
        
        let newWidth = self.view.bounds.width
        let newHeight = (height / width)*newWidth
        
        if height > 0 {
            return CGFloat(newHeight)
        } else {
            return 150.0
        }
    }
    
    func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCellWithIdentifier("cell")!
        
        if let backgroundUrl = self.themeLists[indexPath.row].smallUrl {
            let imageView = NSBundle.mainBundle().loadNibNamed("ImageList", owner: self, options: nil)[0] as! ImageList

            imageView.frame = cell.bounds
            imageView.imageViewDetail.kf_setImageWithURL(NSURL(string: backgroundUrl)!, placeholderImage: nil, optionsInfo: [.Transition(ImageTransition.Fade(0.2))], completionHandler: { action in
                UIApplication.sharedApplication().networkActivityIndicatorVisible = false
            })


            cell.addSubview(imageView)
            
        }
        
        return cell
    }
    
    func tableView(tableView: UITableView, didSelectRowAtIndexPath indexPath: NSIndexPath) {
        self.selectedRow = indexPath.row
        self.performSegueWithIdentifier("segueDetail", sender: self)
    }

    func setBackground(page: Int) {
        var jsonData:JSON?
        UIApplication.sharedApplication().networkActivityIndicatorVisible = true
        Alamofire.request(.GET, self.Url, parameters: ["client_id":self.key, "per_page":self.perPage, "page": page])
            .responseJSON(completionHandler: { req, _, result in
                print(req)
                UIApplication.sharedApplication().networkActivityIndicatorVisible = false
                if result.value != nil {
                    jsonData = JSON(result.value!)
                    for (_, subJson):(String, JSON) in jsonData! {
                        let themeList:ThemeList = ThemeList()
                        
                        themeList.id = subJson["id"].stringValue
                        themeList.width = subJson["width"].intValue
                        themeList.height = subJson["height"].intValue
                        themeList.smallUrl = subJson["urls"]["small"].stringValue
                       
                        
                        Alamofire.request(.GET, "https://api.unsplash.com/photos/\(themeList.id!)/", parameters: ["client_id":self.key,"w":"750","h":"750"]).responseJSON(completionHandler: { req, _, result in
                            if result.value != nil {
                                jsonData = JSON(result.value!)
                                themeList.fullsizeUrl = jsonData!["urls"]["custom"].stringValue
                                themeList.color = jsonData!["color"].stringValue
                                themeList.downloads = jsonData!["downloads"].intValue
                                themeList.likes = jsonData!["likes"].intValue
                                
                                self.themeLists.append(themeList)
                                
                                self.tableView.insertRowsAtIndexPaths([NSIndexPath(forRow: self.themeLists.count-1, inSection: 0)], withRowAnimation: UITableViewRowAnimation.None)
                                self.tableView.reloadRowsAtIndexPaths([NSIndexPath(forRow: self.themeLists.count-1, inSection: 0)], withRowAnimation: UITableViewRowAnimation.Left)
                                
                            }
                        })
                    }
                }
            })
    }
    
    func scrollViewDidEndDecelerating(scrollView: UIScrollView) {
//        let bottomEdge = scrollView.contentOffset.y + scrollView.frame.size.height
//        if bottomEdge >= scrollView.contentSize.height {
//            setBackground(++page)
//        }
    }
    
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func shouldPerformSegueWithIdentifier(identifier: String, sender: AnyObject?) -> Bool {
        if identifier == "segueDetail" {
            if let _ = self.selectedRow {
                return true
            }
        }
        return false
    }
    
    override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
        // Get the new view controller using segue.destinationViewController.
        // Pass the selected object to the new view controller.
        if segue.identifier == "segueDetail" {
            let listVC = segue.destinationViewController as? DetailViewController
            
            if let sel = self.selectedRow {
                listVC?.url = self.themeLists[sel].fullsizeUrl
                
                self.selectedRow = nil
            }
            
        }
        
    }


}
