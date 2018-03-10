//
//  ModelListTableViewController.swift
//  LaravelConnect
//
//  Created by Roberto Prato on 04/02/2018.
//

import UIKit
import CoreData

protocol ModelListTableViewDelegate {
    
    func onItemsSelected(selected:Array<ConnectModel>, selectionMetaData:Any)
    
}

class ModelListTableViewController: UITableViewController, ModelListOptionsDelegate, UISearchBarDelegate {

    enum ListMode {
        case Browse
        case SingleSelect
        case MultiSelect
    }

    public var mode:ListMode = .Browse
    public  var list: ModelList?
    private var presenter:ModelPresenter?
    
    public var selectionMetaData:Any?
    public var modelListDelegate:ModelListTableViewDelegate?
    
    private var searchTerm:String!
    private var searchableAttributes:[String:NSAttributeDescription]!
    private var selectedSearchableAttributes:[String:NSAttributeDescription]!
    
    private var subtitleLabel: UILabel?
    
    @IBAction func cancel(sender: AnyObject) {
        if((self.presentingViewController) != nil){
            self.dismiss(animated: true, completion: nil)
            
        }
    }
    

    
    override func viewDidLoad() {
        super.viewDidLoad()

        self.searchTerm = ""
        self.searchableAttributes = Dictionary()
        self.selectedSearchableAttributes = Dictionary()

        if let attrs = self.list?.entity.attributesByName {
 
            for (name,a) in attrs {
                if let type:String = a.attributeValueClassName,
                    type.elementsEqual("NSString"){// only let the search operate on NSString fields for now
                    self.searchableAttributes[name] = a
                    self.selectedSearchableAttributes[name] = a
                }
            }
        }
        
        if let name = self.list?.entity.name {
            self.presenter = LaravelConnect.shared().presenterForClass(className: name)
            let action = self.mode == .Browse ? "" : "Select"
            self.navigationItem.titleView = setTitle(title: "\(action) \(name)", subtitle: "                     ")
        }
        
       
        
        let control = UIRefreshControl()
        control.backgroundColor = UIColor.lightGray
        control.tintColor = UIColor.darkGray
        control.addTarget(self,action: #selector(refreshList), for: UIControlEvents.valueChanged)
        
        self.refreshControl = control
        
        if(self.mode != .Browse) {
            self.navigationItem.leftBarButtonItem = nil
            self.navigationItem.rightBarButtonItem = nil
        }
        
        self.loadNextPage()
    }

    @objc private func refreshList(){
        
        UIApplication.shared.isNetworkActivityIndicatorVisible = true
        self.refreshControl?.beginRefreshing()
        self.list?.cancel()
        self.list?.refresh(done:{(newIds:[ModelId]?, error:Error?) in
            guard error == nil else {return;}
            self.updateSubTitle()
            self.tableView.reloadData()
            self.tableView.setContentOffset(CGPoint.zero, animated: false)
            self.refreshControl?.endRefreshing()
            UIApplication.shared.isNetworkActivityIndicatorVisible = false
        });
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
        let cell = tableView.dequeueReusableCell(withIdentifier: "ModelSummaryTableViewCell", for: indexPath)
        
        if let currentItem:ConnectModel = self.list![indexPath.row],
            let c:ModelSummaryTableViewCell = cell as? ModelSummaryTableViewCell{
            c.labelMain.text = self.presenter?.modelTitle(model: currentItem)
            c.labelSubText.text = self.presenter?.modelSubtitle(model:currentItem)
        }
        return cell
    }
    
    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        
        switch self.mode {
        case .SingleSelect:
            if let delegate = self.modelListDelegate,
                let currentItem:ConnectModel = self.list![indexPath.row] {
                var selected = Array<ConnectModel>()
                selected.append(currentItem)
                delegate.onItemsSelected(selected: selected, selectionMetaData: selectionMetaData)
                self.navigationController?.popViewController(animated: true)
            }
        //case .MultiSelect:
        default:
            return
        }
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
    
    override func shouldPerformSegue(withIdentifier identifier: String, sender: Any?) -> Bool {
        return self.mode == .Browse
    }

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        
        if let identified = segue.identifier,
            identified.elementsEqual("OptionsSegue") {
            if let controller:ModelOptionsNavigationController = segue.destination as? ModelOptionsNavigationController {
                    controller.listDelegate = self
                    controller.list = self.list
                    controller.selectedSearchableAttributes = self.selectedSearchableAttributes
                    controller.searchableAttributes = self.searchableAttributes
            }
        }else {

        let indexPath = self.tableView.indexPathForSelectedRow
        
        let controller:ModelDetailsTableViewController? = segue.destination as? ModelDetailsTableViewController
        
        if(controller != nil && indexPath != nil){
            controller?.model = self.list?[(indexPath?.row)!]
        }

        //controller.model = 
        // Get the new view controller using segue.destinationViewController.
        // Pass the selected object to the new view controller.
        }
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

    func onNewListAvailable(newList:ModelList, selectedSearchableAttributes: [String : NSAttributeDescription]) {
        self.list = newList
        self.selectedSearchableAttributes = selectedSearchableAttributes
        self.list = self.applyFilterIfNeeded()
        refreshList()
    }
    
    private func applyFilterIfNeeded() -> ModelList {
        
        let filter = Filter()
        
        if self.searchTerm.isEmpty == false,
            let l:ModelList = self.list {

            if let attrs = self.selectedSearchableAttributes {
                
                for (_,a) in attrs {
                    filter.or().contains(param: a.jsonKey, value: self.searchTerm)
                }
            }
            
            let res = filter.serialize()
            print(" ================================ ")
            print("FILTER = \(res)")
            print(" ================================ ")
            return l.clone(newFilter:filter, newSort: nil)
        }
        
        return self.list!.clone(newFilter: filter, newSort: nil)
        
    }
    
    public func searchBar(_ searchBar: UISearchBar, textDidChange searchText: String) {
        self.searchTerm = searchText
        self.list = self.applyFilterIfNeeded()
        refreshList()
    }
    

    
    public func searchBarSearchButtonClicked(_ searchBar:UISearchBar){
        searchBar.resignFirstResponder()
        self.searchTerm = searchBar.text
        self.list = self.applyFilterIfNeeded()
        refreshList()
    }

}
