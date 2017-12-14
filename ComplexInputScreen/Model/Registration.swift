//
//  Registration.swift
//  ComplexInputScreen
//
//  Created by Dennis Lau on 2017-12-07.
//  Copyright © 2017 Dennis Lau. All rights reserved.
//

import Foundation

class Registration: NSObject, NSCoding {
	
	let firstName: String
	let lastName: String
	var emailAddress: String
	var checkInDate: Date
	var checkOutDate: Date
	var adultCount: Int
	var childCount: Int
	var wantWifi: Bool
	var wifiDayCount: Int?
	var roomType: RoomType
	
	init(firstName: String, lastName: String, emailAddress: String, checkInDate: Date, checkOutDate: Date, adultCount: Int, childCount: Int, wantWifi: Bool, wifiDayCount: Int?, roomType: RoomType) {
		self.firstName = firstName
		self.lastName = lastName
		self.emailAddress = emailAddress
		self.checkInDate = checkInDate
		self.checkOutDate = checkOutDate
		self.adultCount = adultCount
		self.childCount = childCount
		self.wantWifi = wantWifi
		self.wifiDayCount = wifiDayCount
		self.roomType = roomType
	}
	
	override var description: String {
		return "Registration(firstName: \(firstName), lastName: \(lastName), emailAddress: \(emailAddress), checkInDate: \(checkInDate), checkOutDate: \(checkOutDate), adultCount: \(adultCount), childCount: \(childCount), wantWifi: \(wantWifi), wifiDayCount: \(String(describing: wifiDayCount)), roomType: \(roomType.id)"
	}
	
	var totalCost: Int {
		let nightsOfStay = Int(checkOutDate.timeIntervalSince(checkInDate) / 86400)
		let perRoomTotalWifiCost = Int(wantWifi ? 10 * wifiDayCount! : 0)
		let totalNumOfRooms = Int((Double(adultCount + childCount) / 2).rounded(.up))
		let totalCost = ( roomType.price * nightsOfStay  + perRoomTotalWifiCost ) * totalNumOfRooms
		return totalCost
	}
	
	static let documentsDirectory = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask).first!
	static let archiveURL = documentsDirectory.appendingPathComponent("registrations")
	
	static func saveToFile(registrationList: [Registration]) {
		NSKeyedArchiver.archiveRootObject(registrationList, toFile: archiveURL.path)
	}
	
	static func loadFromFile() -> [Registration]? {
		guard let unarchivedRegistrationList = NSKeyedUnarchiver.unarchiveObject(withFile: archiveURL.path) as? [Registration]
			else {return nil}
		return unarchivedRegistrationList
	}
	
	struct PropertyKeys {
		static let firstName = "firstName"
		static let lastName = "lastName"
		static let emailAddress = "emailAddress"
		static let checkInDate = "checkInDate"
		static let checkOutDate = "checkOutDate"
		static let adultCount = "adultCount"
		static let childCount = "childCount"
		static let wantWifi = "wantWifi"
		static let wifiDayCount = "wifiDayCount"
		static let roomType = "roomType"
	}
	
	// Must cast Int as NSNumber or NSValue into objects
	// Must encode enum raw value
	func encode(with aCoder: NSCoder) {
		aCoder.encode(firstName, forKey: PropertyKeys.firstName)
		aCoder.encode(lastName, forKey: PropertyKeys.lastName)
		aCoder.encode(emailAddress, forKey: PropertyKeys.emailAddress)
		aCoder.encode(checkInDate, forKey: PropertyKeys.checkInDate)
		aCoder.encode(checkOutDate, forKey: PropertyKeys.checkOutDate)
		aCoder.encode(adultCount as NSValue, forKey: PropertyKeys.adultCount)
		aCoder.encode(childCount as NSNumber, forKey: PropertyKeys.childCount)
		aCoder.encode(wantWifi as NSNumber, forKey: PropertyKeys.wantWifi)
		aCoder.encode(wifiDayCount, forKey: PropertyKeys.wifiDayCount)
		aCoder.encode(roomType.id.rawValue, forKey: PropertyKeys.roomType)
	}
	
	// decode enum rawValue as String, then EnumType(rawValue: String)
	convenience required init?(coder aDecoder: NSCoder) {
		guard let firstName = aDecoder.decodeObject(forKey: PropertyKeys.firstName)  as? String,
			let lastName = aDecoder.decodeObject(forKey: PropertyKeys.lastName) as? String,
			let emailAddress = aDecoder.decodeObject(forKey: PropertyKeys.emailAddress) as? String,
			let checkInDate = aDecoder.decodeObject(forKey: PropertyKeys.checkInDate) as? Date,
			let checkOutDate = aDecoder.decodeObject(forKey: PropertyKeys.checkOutDate) as? Date,
			let adultCount = aDecoder.decodeObject(forKey: PropertyKeys.adultCount) as? Int,
			let childCount = aDecoder.decodeObject(forKey: PropertyKeys.childCount) as? Int,
			let wantWifi = aDecoder.decodeObject(forKey: PropertyKeys.wantWifi) as? Bool,
			let wifiDayCount = aDecoder.decodeObject(forKey: PropertyKeys.wifiDayCount) as? Int?,
			let idRaw = aDecoder.decodeObject(forKey: PropertyKeys.roomType) as? String,
			let idEnum = RoomType.RoomTypeID(rawValue: idRaw)
			else { return nil }
		let roomType = RoomType(id: idEnum)
		
		self.init(firstName: firstName, lastName: lastName, emailAddress: emailAddress, checkInDate: checkInDate, checkOutDate: checkOutDate, adultCount: adultCount, childCount: childCount, wantWifi: wantWifi, wifiDayCount: wifiDayCount, roomType: roomType)
	}
}


