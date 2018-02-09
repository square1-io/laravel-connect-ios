//
//  ModelListTableViewController.swift
//  LaravelConnect
//
//  Created by Roberto Prato on 04/02/2018.
//

import UIKit

class ModelListTableViewController: UITableViewController {

    private var list: ModelList?
    private var modelInfo: ModelInfo?
    private var subtitleLabel: UILabel?
    
    @IBAction func cancel(sender: AnyObject) {
        if((self.presentingViewController) != nil){
            self.dismiss(animated: true, completion: nil)
            
        }
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()

        let navController:ModelNavigationController = self.navigationController as! ModelNavigationController
    
        self.modelInfo = navController.modelInfo
    
        let md:ConnectModel.Type = (self.modelInfo?.modelType)!
        self.navigationItem.titleView = setTitle(title: String(describing:md), subtitle: "                     ")
        
        // Uncomment the following line to preserve selection between presentations
        // self.clearsSelectionOnViewWillAppear = false

        // Uncomment the following line to display an Edit button in the navigation bar for this view controller.
        // self.navigationItem.rightBarButtonItem = self.editButtonItem
        guard let ctype:ModelInfo = self.modelInfo else { return}
        
        self.list = ctype.modelType.list()
        
        self.loadNextPage()
    }


    func setTitle(title:String, subtitle:String) -> UIView {
        //x: CGFloat, y: CGFloat, width: CGFloat, height:
        let titleLabel = UILabel(frame: CGRect(x:0, y:-2,width:0,height:0))
        
        titleLabel.backgroundColor = UIColor.clear
        titleLabel.textColor = UIColor.gray
        titleLabel.font = UIFont.boldSystemFont(ofSize: 17)
        titleLabel.text = title
        titleLabel.sizeToFit()
        
        let subtitleLabel = UILabel(frame: CGRect(x:0, y:18, width:0, height:0))
        subtitleLabel.backgroundColor = UIColor.clear
        subtitleLabel.textColor = UIColor.black
        subtitleLabel.font = UIFont.systemFont(ofSize: 12)
        subtitleLabel.text = subtitle
        subtitleLabel.sizeToFit()
        self.subtitleLabel = subtitleLabel
        
        let titleView = UIView(frame: CGRect(x:0, y:0,
                                             width:max(titleLabel.frame.size.width, subtitleLabel.frame.size.width), height:30))
        titleView.addSubview(titleLabel)
        titleView.addSubview(subtitleLabel)
        
        let widthDiff = subtitleLabel.frame.size.width - titleLabel.frame.size.width
        
        if widthDiff < 0 {
            let newX = widthDiff / 2
            subtitleLabel.frame.origin.x = abs(newX)
        } else {
            let newX = widthDiff / 2
            titleLabel.frame.origin.x = newX
        }
        
        return titleView
    }
    
    private func loadNextPage(){
        self.list?.nextPage(done:{(newIds:[ModelId]?, error:Error?) in
            self.updateSubTitle()
            self.tableView.reloadData()
        });
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }

    // MARK: - Table view data source

    override func numberOfSections(in tableView: UITableView) -> Int {
    
        return 1
    }

    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        
        guard  let list = self.list  else {
            return 0
        }
        
        return list.count
    }

    
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "modelSummaryCell", for: indexPath)
        
        let currentItem:ConnectModel = self.list![indexPath.row]!
        cell.textLabel?.text = self.modelInfo?.modelTitle(currentItem)
        cell.detailTextLabel?.text = self.modelInfo?.modelSubtitle(currentItem)
        return cell
    }
    

    /*
    // Override to support conditional editing of the table view.
    override func tableView(_ tableView: UITableView, canEditRowAt indexPath: IndexPath) -> Bool {
        // Return false if you do not want the specified item to be editable.
        return true
    }
    */

    /*
    // Override to support editing the table view.
    override func tableView(_ tableView: UITableView, commit editingStyle: UITableViewCellEditingStyle, forRowAt indexPath: IndexPath) {
        if editingStyle == .delete {
            // Delete the row from the data source
            tableView.deleteRows(at: [indexPath], with: .fade)
        } else if editingStyle == .insert {
            // Create a new instance of the appropriate class, insert it into the array, and add a new row to the table view
        }    
    }
    */

    /*
    // Override to support rearranging the table view.
    override func tableView(_ tableView: UITableView, moveRowAt fromIndexPath: IndexPath, to: IndexPath) {

    }
    */

    /*
    // Override to support conditional rearranging of the table view.
    override func tableView(_ tableView: UITableView, canMoveRowAt indexPath: IndexPath) -> Bool {
        // Return false if you do not want the item to be re-orderable.
        return true
    }
    */

    
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {

        let indexPath = self.tableView.indexPathForSelectedRow
        
        let controller:ModelDetailsTableViewController? = segue.destination as? ModelDetailsTableViewController
        
        if(controller != nil && indexPath != nil){
            controller?.model = self.list?[(indexPath?.row)!]
        }

        //controller.model = 
        // Get the new view controller using segue.destinationViewController.
        // Pass the selected object to the new view controller.
    }
    
     func updateSubTitle(){
        let total:Int = (self.list?.currentPage.total)!
        let count:Int = (self.list?.count)!
        self.subtitleLabel?.text = "\(count) of \(total)"
    }
    
    override func scrollViewDidScroll(_ scrollView: UIScrollView) {
        
        // calculates where the user is in the y-axis
        let offsetY = scrollView.contentOffset.y
        let contentHeight = scrollView.contentSize.height
        
        if offsetY > contentHeight - scrollView.frame.size.height {
            
            // call your API for more data
            self.loadNextPage()
            
 
        }
    }

}
