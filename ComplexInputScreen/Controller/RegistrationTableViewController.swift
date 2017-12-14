//
//  RegistrationTableViewController.swift
//  ComplexInputScreen
//
//  Created by Dennis Lau on 2017-12-13.
//  Copyright © 2017 Dennis Lau. All rights reserved.
//

import UIKit

class RegistrationTableViewController: UITableViewController {

	var registrationList: [Registration] = []

    override func viewDidLoad() {
        super.viewDidLoad()
        registrationList = Registration.loadFromFile() ?? []
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }

    // MARK: - Table view data source

    override func numberOfSections(in tableView: UITableView) -> Int {
        // #warning Incomplete implementation, return the number of sections
        return 1
    }

    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        // #warning Incomplete implementation, return the number of rows
        return registrationList.count
    }
	
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "RegistrationCell", for: indexPath)
		let registration = registrationList[indexPath.row]
		let dateFormatter = DateFormatter()
		
		dateFormatter.dateStyle = .medium
		cell.textLabel?.text = "\(registration.firstName) \(registration.lastName)"
        cell.detailTextLabel?.text = "\(registration.adultCount + registration.childCount) Person(s), \(dateFormatter.string(from: registration.checkInDate)) - \(dateFormatter.string(from: registration.checkOutDate))"

        return cell
    }
	
	override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
		tableView.deselectRow(at: indexPath, animated: true)
	}
	
    // Segues
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if segue.identifier == "EditReservation" {
            guard let cell = sender as? UITableViewCell else {return}
            let indexPath = tableView.indexPath(for: cell)
            guard let addRegistrationTableViewController = segue.destination as? AddRegistrationTableViewController
                else {return}
            addRegistrationTableViewController.indexPath = indexPath
            addRegistrationTableViewController.registration = registrationList[indexPath!.row]
        }
    }
    
	@IBAction func unwindToRegistrationTableViewController(segue: UIStoryboardSegue) {
		guard segue.identifier == "SaveReservationDetails" else {return}
		guard let addRegistrationTableViewController = segue.source as? AddRegistrationTableViewController,
			let newRegistration = addRegistrationTableViewController.registration
			else {return}
		if let indexPath = addRegistrationTableViewController.indexPath {
			registrationList.remove(at: indexPath.row)
			registrationList.insert(newRegistration, at: indexPath.row)
			tableView.reloadData()
		} else {
			registrationList.insert(newRegistration, at: 0)
			let updatedIndexPath = IndexPath(row: 0, section: 0)
			tableView.insertRows(at: [updatedIndexPath], with: .automatic)
		}
		
		Registration.saveToFile(registrationList: registrationList)
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
