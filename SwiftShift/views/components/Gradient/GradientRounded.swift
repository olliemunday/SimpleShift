//
//  GradientRounded.swift
//  SwiftShift
//
//  Created by Ollie on 16/09/2022.
//

import SwiftUI

struct GradientRounded: View {
    var cornerRadius: CGFloat = 0
    let colors: [Color]
    let direction: GradientTypes
    
    var body: some View {
        gradient
            .cornerRadius(cornerRadius)
    }
    
    private var gradient: some View {
        LinearGradient(colors: colors,
                       startPoint: startPoint,
                       endPoint: endPoint)
    }
    
    private var startPoint: UnitPoint {
        direction.gradients.first ?? UnitPoint.top
    }
    
    private var endPoint: UnitPoint {
        direction.gradients.last ?? UnitPoint.bottom
    }
    

}

struct GradientRounded_Previews: PreviewProvider {
    static var previews: some View {
        
        GradientRounded(cornerRadius: 20, colors: [.blue, .red], direction: .vertical)
            .frame(width: 200, height: 200)
            
    }
}
