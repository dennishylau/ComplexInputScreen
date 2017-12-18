//
//  Registration.swift
//  ComplexInputScreen
//
//  Created by Dennis Lau on 2017-12-07.
//  Copyright © 2017 Dennis Lau. All rights reserved.
//

import Foundation

struct Registration: Codable {
	
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
	
	var totalCost: Int {
		let nightsOfStay = Int(checkOutDate.timeIntervalSince(checkInDate) / 86400)
		let perRoomTotalWifiCost = Int(wantWifi ? 10 * wifiDayCount! : 0)
		let totalNumOfRooms = Int((Double(adultCount + childCount) / 2).rounded(.up))
		let totalCost = ( roomType.price * nightsOfStay  + perRoomTotalWifiCost ) * totalNumOfRooms
		return totalCost
	}
	
	static let documentsDirectory = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask).first!
	static let archiveURL = documentsDirectory.appendingPathComponent("registrations")
	static var encodedRegistrationData: Data? = Data()
	
	static func saveToFile(registrationList: [Registration]) {
		let propertyListEncoder = PropertyListEncoder()
		encodedRegistrationData = try? propertyListEncoder.encode(registrationList)
		do {
			try encodedRegistrationData?.write(to: Registration.archiveURL, options: .noFileProtection)
		} catch {
			print(error.localizedDescription)
		}
	}
	
	static func loadFromFile() -> [Registration]? {
		let propertyListDecoder = PropertyListDecoder()
		do {
			let encodedRegistrationData = try Data.init(contentsOf: Registration.archiveURL)
			let decodedRegistrationList = try propertyListDecoder.decode(Array<Registration>.self, from: encodedRegistrationData)
			print(decodedRegistrationList)
			return decodedRegistrationList
		} catch {
			print(error.localizedDescription)
			return nil
		}
	}
}


