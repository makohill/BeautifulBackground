import UIKit
import Alamofire
import SwiftyJSON
import Kingfisher

class ThemeViewController: UIViewController, UITableViewDelegate, UITableViewDataSource, UITextFieldDelegate {

    @IBOutlet weak var labelTheme: UILabel!
    @IBOutlet weak var tableView: UITableView!
    
    let Url : String = "https://api.unsplash.com/photos/search"
    let key : String = "29a307bccd8555abb09dcd36bbc3e014bad09e75e18c18ae369eb338b2a01f4a"
    
    var queries:[String?] = []
    let perPage:String = "1"
    var themeLists:[ThemeList] = []
    var selectedRow:Int?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        tableView.delegate = self
        tableView.dataSource = self
                
        queries = self.getQuery()
        self.setBackground(queries)
    }
    
    override func viewWillAppear(animated: Bool) {
        self.navigationController?.navigationBarHidden = true
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
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
    
    func tableView(tableView: UITableView, didSelectRowAtIndexPath indexPath: NSIndexPath) {
        
        self.selectedRow = indexPath.row
        
        self.performSegueWithIdentifier("segueThemeList", sender: self)
    }
    
    func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCellWithIdentifier("cell") as! ThemeViewCell
        
        if let backgroundUrl = self.themeLists[indexPath.row].smallUrl {
            let testImageView = UIImageView()
            UIApplication.sharedApplication().networkActivityIndicatorVisible = true
            
            testImageView.kf_showIndicatorWhenLoading = true

            testImageView.kf_setImageWithURL(NSURL(string: backgroundUrl)!, placeholderImage: nil)
            cell.backgroundView = testImageView
            cell.labelThemeName.text = self.themeLists[indexPath.row].keyword
        }
        return cell
    }
    
    func getQuery() -> [String?] {
        return ["sunset", "rain", "mountain", "sky"]
    }
    
    func setBackground(queries:[String?]) {
        var jsonData:JSON?
        UIApplication.sharedApplication().networkActivityIndicatorVisible = true
        for query in queries {
            
            
            
            Alamofire.request(.GET, self.Url, parameters: ["client_id":self.key, "per_page":self.perPage, "query":query!])
                .responseJSON(completionHandler: { req, _, result in
                    print(req)
                    UIApplication.sharedApplication().networkActivityIndicatorVisible = false
                    if result.value != nil {
                        jsonData = JSON(result.value!)
                        print(jsonData)
                        for (_, subJson):(String, JSON) in jsonData! {
                            let themeList:ThemeList = ThemeList()
                            
                            themeList.keyword = query
                            themeList.width = subJson["width"].intValue
                            themeList.height = subJson["height"].intValue
                            themeList.smallUrl = subJson["urls"]["small"].stringValue
                            themeList.fullsizeUrl = subJson["urls"]["full"].stringValue
                            self.themeLists.append(themeList)
                            
                            self.tableView.insertRowsAtIndexPaths([NSIndexPath(forRow: self.themeLists.count-1, inSection: 0)], withRowAnimation: UITableViewRowAnimation.None)
                            self.tableView.reloadRowsAtIndexPaths([NSIndexPath(forRow: self.themeLists.count-1, inSection: 0)], withRowAnimation: UITableViewRowAnimation.Left)
                            
                        }
                    }
                })
        }
        
    }

    override func shouldPerformSegueWithIdentifier(identifier: String, sender: AnyObject?) -> Bool {
        if identifier == "segueThemeList" {
            if let _ = self.selectedRow {
                return true
            }
        }
        return false
    }
    
    override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
        // Get the new view controller using segue.destinationViewController.
        // Pass the selected object to the new view controller.
        if segue.identifier == "segueThemeList" {
            let listVC = segue.destinationViewController as? MainCollectionViewController
            if let sel = self.selectedRow {
                listVC?.query = self.themeLists[sel].keyword
                print(self.themeLists[sel].fullsizeUrl)
                self.selectedRow = nil
            }
            
        }
        
    }


}
