//
//  ReviewsViewController.swift
//  TandESearchIOS
//
//  Created by Dongfang Zhao on 4/22/18.
//  Copyright © 2018 zdf. All rights reserved.
//

import UIKit
import SwiftyJSON

class ReviewsViewController: UIViewController, UITableViewDelegate, UITableViewDataSource {
    
    @IBOutlet weak var reviewsSelectedSegmentedControl: UISegmentedControl!
    @IBOutlet weak var sortBySegmentedControl: UISegmentedControl!
    @IBOutlet weak var orderSegmentedControl: UISegmentedControl!
    @IBOutlet weak var reviewTableView: UITableView!
    var reviews = [ReviewModel]()
    
    override func viewDidLoad() {
        super.viewDidLoad()

        reviewTableView.dataSource = self
        reviewTableView.delegate = self
        
        loadGoogleReviews()
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        
        return reviews.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "review", for: indexPath) as! ReviewsTableViewCell
        
        cell.author_name.text = reviews[indexPath.row].name
        cell.reviewRating.rating = reviews[indexPath.row].rating
        cell.reviewTime.text = reviews[indexPath.row].time
        cell.reviewText.text = reviews[indexPath.row].text
        let icon = try! Data(contentsOf: URL(string: reviews[indexPath.row].photoUrl)!)
        cell.reviewPhoto?.image = UIImage(data: icon, scale: CGFloat(1.5))
        
        return cell
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        UIApplication.shared.open(URL(string: reviews[indexPath.row].url)!)
    }
    
    @IBAction func reviewsSelectedChanged(_ sender: Any) {
        switch reviewsSelectedSegmentedControl.selectedSegmentIndex {
        case 0:
            loadGoogleReviews()
        case 1:
            loadYelpReviews()
        default:
            break
        }
    }
    
    private func loadGoogleReviews() {
        let placeDetails = (tabBarController as! DetailsViewController).placeDetails
        if let rev = placeDetails["reviews"]?.arrayValue {
            reviews = [ReviewModel]()
            var num = 0
            for r in rev {
                reviews.append(ReviewModel(index: num, review: r, isYelp: false))
                num += 1
            }
            reviewTableView.backgroundView  = nil
            reviewTableView.separatorStyle  = .singleLine
        }
        else {
            let noDataLabel: UILabel = UILabel(frame: CGRect(x: 0, y: 0, width: reviewTableView.bounds.size.width, height: reviewTableView.bounds.size.height))
            noDataLabel.text          = "No Reviews"
            noDataLabel.textAlignment = .center
            reviewTableView.backgroundView  = noDataLabel
            reviewTableView.separatorStyle  = .none
        }
        reviewTableView.reloadData()
        orderSegmentedControl.selectedSegmentIndex = 0;
        sortBySegmentedControl.selectedSegmentIndex = 0;
        orderSegmentedControl.isEnabled = false;
    }
    
    private func loadYelpReviews() {
        let rev = (tabBarController as! DetailsViewController).yelpReviews
        reviews = [ReviewModel]()
        if !rev.isEmpty {
            var num = 0
            for r in rev {
                reviews.append(ReviewModel(index: num, review: r, isYelp: true))
                num += 1
            }
            reviewTableView.backgroundView  = nil
            reviewTableView.separatorStyle  = .singleLine
        }
        else {
            let noDataLabel: UILabel = UILabel(frame: CGRect(x: 0, y: 0, width: reviewTableView.bounds.size.width, height: reviewTableView.bounds.size.height))
            noDataLabel.text          = "No Reviews"
            noDataLabel.textAlignment = .center
            reviewTableView.backgroundView  = noDataLabel
            reviewTableView.separatorStyle  = .none
        }
        reviewTableView.reloadData()
        orderSegmentedControl.selectedSegmentIndex = 0;
        sortBySegmentedControl.selectedSegmentIndex = 0;
        orderSegmentedControl.isEnabled = false;
    }
    
    @IBAction func sortByChanged(_ sender: Any) {
        switch sortBySegmentedControl.selectedSegmentIndex {
        case 0:
            orderSegmentedControl.isEnabled = false;
            orderSegmentedControl.selectedSegmentIndex = 0;
            reviews.sort { $0.num < $1.num }
            reviewTableView.reloadData()
        case 1:
            orderSegmentedControl.isEnabled = true;
            orderSegmentedControl.selectedSegmentIndex = 0;
            reviews.sort { $0.rating < $1.rating }
            reviewTableView.reloadData()
        case 2:
            orderSegmentedControl.isEnabled = true;
            orderSegmentedControl.selectedSegmentIndex = 0;
            reviews.sort { $0.time < $1.time }
            reviewTableView.reloadData()
        default:
            break
        }
    }
    
    @IBAction func orderChanged(_ sender: Any) {
        switch orderSegmentedControl.selectedSegmentIndex {
        case 0:
            if sortBySegmentedControl.selectedSegmentIndex == 1 {
                reviews.sort { $0.rating < $1.rating }
                reviewTableView.reloadData()
            }
            if sortBySegmentedControl.selectedSegmentIndex == 2 {
                reviews.sort { $0.time < $1.time }
                reviewTableView.reloadData()
            }
        case 1:
            if sortBySegmentedControl.selectedSegmentIndex == 1 {
                reviews.sort { $0.rating > $1.rating }
                reviewTableView.reloadData()
            }
            if sortBySegmentedControl.selectedSegmentIndex == 2 {
                reviews.sort { $0.time > $1.time }
                reviewTableView.reloadData()
            }
        default:
            break
        }
    }

}
