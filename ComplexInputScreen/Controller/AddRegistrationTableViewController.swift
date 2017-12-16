//
//  AddRegistrationTableViewController.swift
//  ComplexInputScreen
//
//  Created by Dennis Lau on 2017-12-08.
//  Copyright © 2017 Dennis Lau. All rights reserved.
//

import UIKit

class AddRegistrationTableViewController: UITableViewController, SelectRoomTypeTableViewControllerDelegate, UITextFieldDelegate {
	// UITextFieldDelegate for textFieldShouldReturn, next button goes to another text field
	
	@IBOutlet var keyboardToolbar: UIToolbar!
	
	@IBOutlet weak var totalCostLabel: UILabel!
	
	@IBOutlet weak var firstNameTextField: UITextField!
	@IBOutlet weak var lastNameTextField: UITextField!
	@IBOutlet weak var emailTextField: UITextField!
	
	@IBOutlet weak var checkInDateLabel: UILabel!
	@IBOutlet weak var checkInDatePicker: UIDatePicker!
	@IBOutlet weak var checkOutDateLabel: UILabel!
	@IBOutlet weak var checkOutDatePicker: UIDatePicker!
	
	@IBOutlet weak var adultsCountLabel: UILabel!
	@IBOutlet weak var adultsCountStepper: UIStepper!
	@IBOutlet weak var childrenCountLabel: UILabel!
	@IBOutlet weak var childrenCountStepper: UIStepper!
	
	@IBOutlet weak var wifiSwitch: UISwitch!
	@IBOutlet weak var wifiNumDaysContentView: UIView!
	@IBOutlet weak var wifiNumDaysLabel: UILabel!
	@IBOutlet weak var wifiStepper: UIStepper!
	
	@IBOutlet weak var roomTypeLabel: UILabel!
	
	var indexPath: IndexPath?
	var registration: Registration?
	
	// index paths for text fields
	let firstNameTextFieldIndexPath = IndexPath(row: 0, section: 1)
	let lastNameTextFieldIndexPath = IndexPath(row: 1, section: 1)
	let emailTextFieldIndexPath = IndexPath(row: 2, section: 1)
	
	// trackers for hiding date pickers
	let checkInDatePickerCellIndexPath = IndexPath(row: 1, section: 2)
	let checkOutDatePickerCellIndexPath = IndexPath(row: 3, section: 2)
	var isCheckInDatePickerShown: Bool = false {
		didSet {
			checkInDatePicker.isHidden = !isCheckInDatePickerShown
		}
	}
	var isCheckOutDatePickerShown: Bool = false {
		didSet {
			checkOutDatePicker.isHidden = !isCheckOutDatePickerShown
		}
	}
	
	// trackers for hiding wifi days
	let wifiNumOfDaysIndexPath = IndexPath(row: 1, section: 4)
	var isWifiNumOfDaysStepperShown: Bool = false {
		didSet {
			wifiNumDaysContentView.isHidden = !isWifiNumOfDaysStepperShown
		}
	}
	
	// trackers for room type
	var roomType: RoomType?
	
    override func viewDidLoad() {
        super.viewDidLoad()
		
		navigationItem.rightBarButtonItem?.isEnabled = false
		let midnightToday = Calendar.current.startOfDay(for: Date())
		checkInDatePicker.minimumDate = midnightToday
		checkInDatePicker.date = midnightToday
		checkInDatePicker.maximumDate = midnightToday.addingTimeInterval(31536000)
		firstNameTextField.inputAccessoryView = keyboardToolbar
		firstNameTextField.delegate = self
		lastNameTextField.inputAccessoryView = keyboardToolbar
		lastNameTextField.delegate = self
		emailTextField.inputAccessoryView = keyboardToolbar
		emailTextField.delegate = self
		if let registration = registration {
			firstNameTextField.text = registration.firstName
			lastNameTextField.text = registration.lastName
			emailTextField.text = registration.emailAddress
			checkInDatePicker.date = Calendar.current.startOfDay(for: registration.checkInDate)
			checkOutDatePicker.date = Calendar.current.startOfDay(for: registration.checkOutDate)
			adultsCountStepper.value = Double(registration.adultCount)
			childrenCountStepper.value = Double(registration.childCount)
			wifiSwitch.isOn = registration.wantWifi
			if wifiSwitch.isOn {
				isWifiNumOfDaysStepperShown = true
				wifiStepper.value = Double(registration.wifiDayCount!)
			}
			roomType = registration.roomType
		} else {
			navigationItem.leftBarButtonItem = UIBarButtonItem(barButtonSystemItem: .cancel, target: self, action: #selector(dismissVC))
		}
		updateTotalCostView()
		updateDateViews()
		updatePeopleCountView()
		updateWifiCountView()
		updateRoomTypeView()
		saveButtonEnableStatusUpdate()
    }

	override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
		if segue.identifier == "SelectRoomType" {
			let selectRoomTypeTableViewController = segue.destination as? SelectRoomTypeTableViewController
			// Change SelectRoomTypeTableViewController's delegate
			selectRoomTypeTableViewController?.delegate = self
			selectRoomTypeTableViewController?.roomType = roomType
		} else if segue.identifier == "SaveReservationDetails" {
			guard firstNameTextField.text?.isEmpty == false &&
				lastNameTextField.text?.isEmpty == false &&
				emailTextField.text?.isEmpty == false &&
				self.roomType != nil
				else {return}
			
			let firstName: String = firstNameTextField.text!
			let lastName: String = lastNameTextField.text!
			let emailAddress: String = emailTextField.text!
			
			let checkInDate: Date = checkInDatePicker.date
			let checkOutDate: Date = checkOutDatePicker.date
			let adultCount: Int = Int(adultsCountStepper.value)
			let childCount: Int = Int(childrenCountStepper.value)
			
			let wantWifi: Bool = wifiSwitch.isOn
			let wifiDayCount: Int? = wifiSwitch.isOn ? Int(wifiStepper.value) : nil
			let roomType: RoomType = self.roomType!
			
            registration = Registration.init(firstName: firstName, lastName: lastName, emailAddress: emailAddress, checkInDate: checkInDate, checkOutDate: checkOutDate, adultCount: adultCount, childCount: childCount, wantWifi: wantWifi, wifiDayCount: wifiDayCount, roomType: roomType)
		}
	}
	
	@IBAction func saveButtonEnableStatusUpdate() {
		if firstNameTextField.text?.isEmpty == false &&
			lastNameTextField.text?.isEmpty == false &&
			emailTextField.text?.isEmpty == false &&
			roomType != nil {
			navigationItem.rightBarButtonItem?.isEnabled = true
		} else {
			navigationItem.rightBarButtonItem?.isEnabled = false
		}
	}

	// Cancel button
	@objc func dismissVC() {
		view.endEditing(true)
		self.dismiss(animated: true, completion: nil)
	}
	
	func updateTotalCostView() {
		guard let roomType = roomType else {return}
		let nightsOfStay = Int(checkOutDatePicker.date.timeIntervalSince(checkInDatePicker.date) / 86400)
		let perRoomTotalWifiCost = Int(wifiSwitch.isOn ? 10 * wifiStepper.value : 0)
		let totalNumOfRooms = Int(((adultsCountStepper.value + childrenCountStepper.value) / 2).rounded(.up))
		let totalCost = ( roomType.price * nightsOfStay  + perRoomTotalWifiCost ) * totalNumOfRooms
		totalCostLabel.text = "$ \(totalCost)"
	}
	
	// keyboardToolbar & keyboard stuff, uses FirstResponder.swift UIView extension
	// tag the views to be jumped to
	
	func getPreviousResponderFor(tag: Int) -> UITextField? {
		return self.view.viewWithTag(tag - 1) as? UITextField
	}
	
	func getNextResponderFor(tag: Int) -> UITextField? {
		return self.view.viewWithTag(tag + 1) as? UITextField
	}
	
	@IBAction func keyboardPreviousButtonTapped(_ sender: UIBarButtonItem) {
		guard let currentFirstResponder = self.view.currentFirstResponder() as? UITextField else {return}
		if let previousResponder = getPreviousResponderFor(tag: currentFirstResponder.tag)  {
			previousResponder.becomeFirstResponder()
		} else {
			view.endEditing(true)
		}
	}
	
	@IBAction func keyboardNextButtonTapped(_ sender: UIBarButtonItem) {
		guard let currentFirstResponder = self.view.currentFirstResponder() as? UITextField else {return}
		if let nextResponder = getNextResponderFor(tag: currentFirstResponder.tag) {
			nextResponder.becomeFirstResponder()
		} else {
			view.endEditing(true)
		}
	}
	
	@IBAction func keyboardCloseButtonTapped(_ sender: Any) {
		view.endEditing(true)
	}

	func textFieldShouldReturn(_ textField: UITextField) -> Bool {
		guard let currentFirstResponder = self.view.currentFirstResponder() as? UITextField else {return true}
		if let nextResponder = getNextResponderFor(tag: currentFirstResponder.tag) {
			nextResponder.becomeFirstResponder()
		} else {
			view.endEditing(true)
		}
		return true
	}
	
	// date ppicker stuff
	@IBAction func datePickerValueChanged(_ sender: UIDatePicker) {
		updateDateViews()
		updateTotalCostView()
	}
	
	// update date limit and UILabel
	func updateDateViews() {
		let dateFormatter = DateFormatter()
		dateFormatter.dateStyle = .medium
		checkInDateLabel.text = dateFormatter.string(from: checkInDatePicker.date)
		checkOutDatePicker.minimumDate = checkInDatePicker.date.addingTimeInterval(86400)
		checkOutDatePicker.maximumDate = checkInDatePicker.maximumDate?.addingTimeInterval(86400)
		checkOutDateLabel.text = dateFormatter.string(from: checkOutDatePicker.date)
		
		// update wifi days
		let daysOfStay = checkOutDatePicker.date.timeIntervalSince(checkInDatePicker.date) / 86400 + 1
		wifiStepper.maximumValue = daysOfStay
		if wifiStepper.value > daysOfStay {
			wifiStepper.value = daysOfStay
		}
		updateWifiCountView()
	}
	
	// hiding rows by 0 row height
	override func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
		// date pickers
		switch (indexPath.section, indexPath.row) {
		case (checkInDatePickerCellIndexPath.section,checkInDatePickerCellIndexPath.row):
			if isCheckInDatePickerShown {
				return 162
			} else {
				return 0
			}
		case (checkOutDatePickerCellIndexPath.section, checkOutDatePickerCellIndexPath.row):
			if isCheckOutDatePickerShown {
				return 162
			} else {
				return 0
			}
		
		// wifi stepper
		case (wifiNumOfDaysIndexPath.section,wifiNumOfDaysIndexPath.row):
			if isWifiNumOfDaysStepperShown {
				return 44
			} else {
				return 0
			}
		default: return 44
		}
	}
	
	// didSelectRow actions
	override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
		
		// change textfield firstResponder
		switch (indexPath.section,indexPath.row) {
			case (firstNameTextFieldIndexPath.section,firstNameTextFieldIndexPath.row):
				firstNameTextField.becomeFirstResponder()
			case (lastNameTextFieldIndexPath.section,lastNameTextFieldIndexPath.row):
				lastNameTextField.becomeFirstResponder()
			case (emailTextFieldIndexPath.section,emailTextFieldIndexPath.row):
				emailTextField.becomeFirstResponder()
			default: break
		}
		
		// showing & hiding date picker
		if indexPath.section == checkInDatePickerCellIndexPath.section &&
			indexPath.row == checkInDatePickerCellIndexPath.row - 1 {
			isCheckOutDatePickerShown = false
			if isCheckInDatePickerShown == true {
				isCheckInDatePickerShown = false
			} else {
				isCheckInDatePickerShown = true
			}
		}
		
		if indexPath.section == checkOutDatePickerCellIndexPath.section &&
			indexPath.row == checkOutDatePickerCellIndexPath.row - 1 {
			isCheckInDatePickerShown = false
			if isCheckOutDatePickerShown == true {
				isCheckOutDatePickerShown = false
			} else {
				isCheckOutDatePickerShown = true
			}
		}
		
		// showing & hiding wifiDays
		if indexPath.section == wifiNumOfDaysIndexPath.section &&
			indexPath.row == wifiNumOfDaysIndexPath.row - 1 {
			wifiSwitch.isOn = !wifiSwitch.isOn
			wifiSwitchTapped(wifiSwitch)
		}
		
		updateTotalCostView()
		tableView.deselectRow(at: indexPath, animated: true)
		tableView.beginUpdates()
		tableView.endUpdates()
	}
	
	// head count stuff
	func updatePeopleCountView() {
		adultsCountLabel.text = "\(Int(adultsCountStepper.value))"
		childrenCountLabel.text = "\(Int(childrenCountStepper.value))"
	}
	
	@IBAction func stepperValueChanged(_ sender: UIStepper) {
		updatePeopleCountView()
		updateTotalCostView()
	}
	
	// wifi stuff
	@IBAction func wifiSwitchTapped(_ sender: UISwitch) {
		if wifiSwitch.isOn {
			let daysOfStay = checkOutDatePicker.date.timeIntervalSince(checkInDatePicker.date) / 86400 + 1
			isWifiNumOfDaysStepperShown = true
			wifiStepper.maximumValue = daysOfStay
			wifiStepper.value = daysOfStay
			updateWifiCountView()
			tableView.beginUpdates()
			tableView.endUpdates()
		} else {
			isWifiNumOfDaysStepperShown = false
			tableView.beginUpdates()
			tableView.endUpdates()
		}
		updateTotalCostView()
	}
	
	func updateWifiCountView() {
		wifiNumDaysLabel.text = "\(Int(wifiStepper.value))"
	}
	
	@IBAction func wifiStepperValueChanged(_ sender: UIStepper) {
		updateWifiCountView()
		if sender.value == 0 {
			wifiSwitch.setOn(false, animated: true)
			isWifiNumOfDaysStepperShown = false
			tableView.beginUpdates()
			tableView.endUpdates()
		}
		updateTotalCostView()
	}
	
	// room type
	func updateRoomTypeView() {
		guard let roomType = roomType else {
			roomTypeLabel.text = "Not Selected"
			return
		}
		roomTypeLabel.text = roomType.name
	}
	
	func didSelect(roomType: RoomType) {
		// pass in roomType from delegate?.didSelect(roomType: roomType!)
		self.roomType = roomType
		updateRoomTypeView()
		saveButtonEnableStatusUpdate()
		updateTotalCostView()
	}
	
	// hide keyboard and date pickers when scroll
	override func scrollViewWillBeginDragging(_ scrollView: UIScrollView) {
		view.endEditing(true)
		isCheckInDatePickerShown = false
		isCheckOutDatePickerShown = false
		tableView.beginUpdates()
		tableView.endUpdates()
	}
	
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
}
