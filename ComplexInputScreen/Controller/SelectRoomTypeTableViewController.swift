//
//  SelectRoomTypeTableViewController.swift
//  ComplexInputScreen
//
//  Created by Dennis Lau on 2017-12-11.
//  Copyright © 2017 Dennis Lau. All rights reserved.
//

import UIKit

class SelectRoomTypeTableViewController: UITableViewController {

	var roomType: RoomType?
	// Define delegate, must have func didSelect(roomType: RoomType)
	var delegate: SelectRoomTypeTableViewControllerDelegate?
	
    override func viewDidLoad() {
        super.viewDidLoad()

        // Uncomment the following line to preserve selection between presentations
        // self.clearsSelectionOnViewWillAppear = false

        // Uncomment the following line to display an Edit button in the navigation bar for this view controller.
        // self.navigationItem.rightBarButtonItem = self.editButtonItem
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
        return RoomType.all.count
    }
	
	// define prototype cells
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "RoomTypeCell", for: indexPath)
		let roomType = RoomType.all[indexPath.row]
		cell.textLabel?.text = roomType.name
		cell.detailTextLabel?.text = "$ \(roomType.price)"
		
		// from didSelectRowAt, add checkmark
		if roomType == self.roomType {
			cell.accessoryType = .checkmark
		} else {
			cell.accessoryType = .none
		}
		
		return cell
    }

	// make selection and update
	override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
		roomType = RoomType.all[indexPath.row]
		tableView.deselectRow(at: indexPath, animated: true)
		// the following passes info to the main VC, i.e. the delegate
		delegate?.didSelect(roomType: roomType!)
		tableView.reloadData()
		if let currentNC = self.navigationController {
			DispatchQueue.main.asyncAfter(deadline: .now() + 0.1) {
				currentNC.popViewController(animated: true)
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
    override func tableView(_ tableView: UITableView, commit editingStyle: UITableViewCellEditingStyle, forRowAt indexPath: IndexPath){
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
