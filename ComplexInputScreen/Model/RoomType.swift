//
//  RoomType.swift
//  ComplexInputScreen
//
//  Created by Dennis Lau on 2017-12-07.
//  Copyright © 2017 Dennis Lau. All rights reserved.
//

import Foundation

struct RoomType: Equatable, Codable {

	let id: RoomTypeID
	var name: String {
		switch id {
		case .a: return "Two Queens"
		case .b: return "One King"
		case .c: return "Penthouse Suite"
		}
	}
	var shortName: String {
		switch id {
		case .a: return "2QB"
		case .b: return "1KB"
		case .c: return "2KB"
		}
	}
	var price: Int {
		switch id {
		case .a: return 100
		case .b: return 200
		case .c: return 300
		}
	}
    
	enum RoomTypeID: String, Codable {
		case  a, b, c
	}
	
	static var all: [RoomType] {
		return [RoomType(id: .a),RoomType(id: .b),RoomType(id: .c)]
	}
	
	static func == (lhs:RoomType, rhs:RoomType) -> Bool {
		return lhs.id == rhs.id
	}
}

