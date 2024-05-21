//
//  LedgerLineView.swift
//  FrenchHornApp
//
//  Created by Lorenzo Brown on 9/13/22.
//

import SwiftUI

struct LedgerLineView: View {
	let offset:CGFloat
	var body: some View {


		Rectangle()
			.fill(Color.black)
			.frame(width: 24, height: 1,  alignment: .center)
			.offset(y: offset)
	}

}

struct LedgerLineView_Previews: PreviewProvider {
	static var previews: some View {
		LedgerLineView(offset:-45)
			.previewLayout(.sizeThatFits)
			.padding()
	}
}
