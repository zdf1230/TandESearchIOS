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
import SwiftSpinner

class ResultsTableViewController: UITableViewController {

    @IBOutlet weak var previousButton: UIBarButtonItem!
    @IBOutlet weak var nextButton: UIBarButtonItem!
    @IBOutlet var resultsTableView: UITableView!
    var placeResults = [[JSON]]()
    var placeResultDisplay = [JSON]()
    var page = 0
    var nextPageToken = String()
    var detailsObject: JSON!
    
    override func viewDidLoad() {
        super.viewDidLoad()

        // Uncomment the following line to preserve selection between presentations
        // self.clearsSelectionOnViewWillAppear = false

        // Uncomment the following line to display an Edit button in the navigation bar for this view controller.
        // self.navigationItem.rightBarButtonItem = self.editButtonItem
        previousButton.isEnabled = false
        checkNextButtonStatus()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        self.navigationController?.isToolbarHidden = false
        
        resultsTableView.reloadData()
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        self.navigationController?.isToolbarHidden = true
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
        let cell = tableView.dequeueReusableCell(withIdentifier: "place", for: indexPath) as! ResultTableViewCell
        
        cell.textLabel?.text = placeResultDisplay[indexPath.row]["name"].string
        cell.textLabel?.numberOfLines = 0
        cell.detailTextLabel?.text = placeResultDisplay[indexPath.row]["vicinity"].string
        cell.detailTextLabel?.numberOfLines = 0
        let icon = try! Data(contentsOf: URL(string: placeResultDisplay[indexPath.row]["icon"].string!)!)
        cell.imageView?.image = UIImage(data: icon, scale: CGFloat(1.5))
        
        if UserDefaults.standard.value(forKey: placeResultDisplay[indexPath.row]["place_id"].stringValue) != nil {
            cell.favoriteEmptyButton.isHidden = true
            cell.favoriteFilledButton.isHidden = false
        }
        else {
            cell.favoriteEmptyButton.isHidden = false
            cell.favoriteFilledButton.isHidden = true
        }
        
        cell.favoriteFilledButton.tag = indexPath.row
        cell.favoriteEmptyButton.tag = indexPath.row
        
        cell.favoriteFilledButton.addTarget(self, action: #selector(touchFavoriteFilledButton), for: .touchUpInside)
        cell.favoriteEmptyButton.addTarget(self, action: #selector(touchFavoriteEmptyButton), for: .touchUpInside)

        return cell
    }
    
    override func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return 80.0
    }
    
    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        SwiftSpinner.show("Fetching place details...")
        let placeid = placeResultDisplay[indexPath.row]["place_id"].stringValue
        let url = URL(string: Constants.serverUrlPrefix + "placedetails")
        let parameters: Parameters = ["placeid": placeid]
        
        Alamofire.request(url!, parameters: parameters).responseSwiftyJSON { (response) in
            self.detailsObject = response.result.value
            SwiftSpinner.hide()
            self.performSegue(withIdentifier: "details", sender: nil)
        }
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
            SwiftSpinner.show("Loading next page...")
            let url = URL(string: Constants.serverUrlPrefix + "moreplaces")
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
                SwiftSpinner.hide()
                self.resultsTableView.reloadSections(IndexSet(arrayLiteral: 0), with: .left)
            }
        }
        
    }
    
    @IBAction func touchFavoriteFilledButton(sender: UIButton) {
        let placeId = placeResultDisplay[sender.tag]["place_id"].stringValue
        let cell = resultsTableView.cellForRow(at: IndexPath(row: sender.tag, section: 0)) as! ResultTableViewCell
        cell.favoriteEmptyButton.isHidden = false
        cell.favoriteFilledButton.isHidden = true
        UserDefaults.standard.removeObject(forKey: placeId)
        var favoriteList = UserDefaults.standard.array(forKey: "favorite") as! [String]
        if let index = favoriteList.index(of: placeId) {
            favoriteList.remove(at: index)
        }
        UserDefaults.standard.set(favoriteList, forKey: "favorite")
        
        let name = placeResultDisplay[sender.tag]["name"].stringValue
        self.view.showToast("\(name) was removed to favorites", position: .bottom, popTime: 2, dismissOnTap: true)
    }
    
    @IBAction func touchFavoriteEmptyButton(sender: UIButton) {
        let placeId = placeResultDisplay[sender.tag]["place_id"].stringValue
        let cell = resultsTableView.cellForRow(at: IndexPath(row: sender.tag, section: 0)) as! ResultTableViewCell
        cell.favoriteEmptyButton.isHidden = true
        cell.favoriteFilledButton.isHidden = false
        UserDefaults.standard.set(createFavoriteItem(placeResults: placeResultDisplay[sender.tag]), forKey: placeId)
        var favoriteList = UserDefaults.standard.array(forKey: "favorite") as! [String]
        favoriteList.append(placeId)
        UserDefaults.standard.set(favoriteList, forKey: "favorite")
        
        let name = placeResultDisplay[sender.tag]["name"].stringValue
        self.view.showToast("\(name) was added from favorites", position: .bottom, popTime: 2, dismissOnTap: true)
    }
    
    func createFavoriteItem(placeResults: JSON) -> [String: String] {
        return ["name": placeResults["name"].stringValue,
                "icon": placeResults["icon"].stringValue,
                "vicinity": placeResults["vicinity"].stringValue,
                "place_id": placeResults["place_id"].stringValue]
    }

    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        let detailsView: DetailsViewController = segue.destination as! DetailsViewController
        if detailsObject != nil {
            detailsView.setDetails(detailsObject: detailsObject)
        }
    }
    

}
