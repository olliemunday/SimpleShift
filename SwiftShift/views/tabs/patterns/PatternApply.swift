//
//  PatternApply.swift
//  SwiftShift
//
//  Created by Ollie on 23/09/2022.
//

import SwiftUI

struct PatternApply: View {
    
    @EnvironmentObject var patternManager: PatternManager
    @EnvironmentObject var shiftManager: ShiftManager
    
    var body: some View {
        NavigationView{
            applyMenu.navigationTitle("Apply Pattern")
        }
    }
    
    var applyMenu: some View {
        
        VStack {
            Text("Pattern apply menu")
        }
        
    }
}

struct PatternApply_Previews: PreviewProvider {
    static var previews: some View {
        PatternApply()
    }
}
