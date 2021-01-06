//
//  ContentView.swift
//  Loop
//
//  Created by Eric Rabil on 7/28/20.
//

import SwiftUI

struct ContentView: View {
    @State var showImagePicker: Bool = false
    
    var body: some View {
        VStack {
            Button("Pick image") {
                self.showImagePicker.toggle()
            }
        }
        .sheet(isPresented: $showImagePicker) {
            ImagePickerView(sourceType: .photoLibrary) { image in
                print(image)
            }
        }
    }
}

struct ContentView_Previews: PreviewProvider {
    static var previews: some View {
        ContentView()
    }
}
