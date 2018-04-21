//
//  ResultsTableViewController.swift
//  TandESearchIOS
//
//  Created by Dongfang Zhao on 4/19/18.
//  Copyright © 2018 zdf. All rights reserved.
//

import UIKit
import SwiftyJSON
import Alamofire
import AlamofireSwiftyJSON

class ResultsTableViewController: UITableViewController {

    @IBOutlet weak var previousButton: UIBarButtonItem!
    @IBOutlet weak var nextButton: UIBarButtonItem!
    @IBOutlet var resultsTableView: UITableView!
    let serverUrlPrefix = "http://localhost:3000/"
    var placeResults = [[JSON]]()
    var placeResultDisplay = [JSON]()
    var page = 0
    var nextPageToken = String()
    
    override func viewDidLoad() {
        super.viewDidLoad()

        // Uncomment the following line to preserve selection between presentations
        // self.clearsSelectionOnViewWillAppear = false

        // Uncomment the following line to display an Edit button in the navigation bar for this view controller.
        // self.navigationItem.rightBarButtonItem = self.editButtonItem
        previousButton.isEnabled = false
        checkNextButtonStatus()
    }
    
    func setTable(resultsObject: JSON) {
        page = 0
        placeResults.removeAll()
        placeResultDisplay = resultsObject["results"].arrayValue
        placeResults.append(placeResultDisplay)
        if resultsObject["next_page_token"].string != nil {
            nextPageToken = resultsObject["next_page_token"].string!
        }
        if isViewLoaded {
            checkNextButtonStatus()
        }
    }
    
    func checkNextButtonStatus() {
        print(nextPageToken)
        if nextPageToken.isEmpty {
            nextButton.isEnabled = false
        }
        else {
            nextButton.isEnabled = true
        }
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }

    // MARK: - Table view data source

    override func numberOfSections(in tableView: UITableView) -> Int {
        // #warning Incomplete implementation, return the number of sections
        if (!placeResultDisplay.isEmpty) {
            return 1
        }
        else {
            let noDataLabel: UILabel = UILabel(frame: CGRect(x: 0, y: 0, width: tableView.bounds.size.width, height: tableView.bounds.size.height))
            noDataLabel.text          = "No Results"
            noDataLabel.textAlignment = .center
            tableView.backgroundView  = noDataLabel
            tableView.separatorStyle  = .none
            return 0
        }
        
    }

    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        // #warning Incomplete implementation, return the number of rows
        return placeResultDisplay.count
    }

    
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "place", for: indexPath)

        cell.textLabel?.text = placeResultDisplay[indexPath.row]["name"].string
        cell.textLabel?.numberOfLines = 0
        cell.detailTextLabel?.text = placeResultDisplay[indexPath.row]["vicinity"].string
        cell.detailTextLabel?.numberOfLines = 0
        let icon = try! Data(contentsOf: URL(string: placeResultDisplay[indexPath.row]["icon"].string!)!)
        cell.imageView?.image = UIImage(data: icon, scale: CGFloat(1.5))

        return cell
    }
    
    override func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return 80.0
    }
    
    @IBAction func touchPrevious(_ sender: Any) {
        nextButton.isEnabled = true
        page -= 1
        placeResultDisplay = placeResults[page]
        if page == 0 {
            previousButton.isEnabled = false
        }
        self.resultsTableView.reloadSections(IndexSet(arrayLiteral: 0), with: .right)
    }
    
    @IBAction func touchNext(_ sender: Any) {
        previousButton.isEnabled = true
        if page < placeResults.count - 1 {
            page += 1
            placeResultDisplay = placeResults[page]
            if page == placeResults.count - 1 {
                checkNextButtonStatus()
            }
            self.resultsTableView.reloadSections(IndexSet(arrayLiteral: 0), with: .left)
        }
        else {
            let url = URL(string: serverUrlPrefix + "moreplaces")
            let parameters: Parameters = ["next_page_token": nextPageToken]
            
            Alamofire.request(url!, parameters: parameters).responseSwiftyJSON { (response) in
                self.placeResultDisplay = response.result.value!["results"].arrayValue
                self.placeResults.append(self.placeResultDisplay)
                self.page += 1
                if response.result.value!["next_page_token"].string != nil {
                    self.nextPageToken = response.result.value!["next_page_token"].string!
                }
                else {
                    self.nextPageToken = ""
                }
                self.checkNextButtonStatus()
                self.resultsTableView.reloadSections(IndexSet(arrayLiteral: 0), with: .left)
            }
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

    /*
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        // Get the new view controller using segue.destinationViewController.
        // Pass the selected object to the new view controller.
    }
    */

}
