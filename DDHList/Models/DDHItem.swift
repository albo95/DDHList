//
//  DDHItem.swift
//  DDHList
//
//  Created by Alberto Bruno on 21/10/25.
//

import CoreTransferable

protocol DDHItem: Transferable & Identifiable & Equatable {
    var children: [Self] { get set }
}
