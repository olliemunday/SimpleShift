//
//  TabViewItem.swift
//  SwiftShift
//
//  Created by Ollie on 23/09/2022.
//

import SwiftUI

struct TabViewItem: View {
    let systemName: String
    let text: String
    
    var body: some View {
        item
    }
    
    @ViewBuilder var item: some View {
        Image(systemName: systemName)
        Text(text)
    }
}
