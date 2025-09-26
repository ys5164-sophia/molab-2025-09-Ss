//
//  ContentView.swift
//  Canvas-Explore
//
//  Created by jht2 on 1/26/25.
//

import SwiftUI

// Exploring drawing shapes with Canvas

struct ContentView: View {
  var body: some View {
    Canvas { context, size in
      // print("size", size)
      let lineWidth = 10.0
      
      // Create a 1/4 size height size
      let nsize = CGSize(width: size.width, height: size.height/4)
      
      // rect start to top left
      var arect = CGRect(origin: .zero, size: nsize)

      // Draw an ellipse
      let ellipsePath = Path(ellipseIn: arect)
      context.stroke(ellipsePath, with: .color(.red), lineWidth: lineWidth)
      
      // Draw a rectangle
      arect.origin.y += nsize.height; // move down canvas in y
      let rectPath = Rectangle().path(in: arect)
      context.stroke(rectPath, with: .color(.green), lineWidth: lineWidth)
      
      // Draw a Capsule
      arect.origin.y += nsize.height; // move down canvas in y
      let capsule = Capsule().path(in: arect)
      context.stroke(capsule, with: .color(.yellow), lineWidth: lineWidth)
      
      // Draw a diagonal line, top left to bottom right
      arect.origin.y += nsize.height;
      var path = Path()
      path.move(to: arect.origin)
      arect.origin.y += nsize.height; // move down canvas in y
      var apoint = arect.origin;
      apoint.x += arect.size.width;
      path.addLine(to: apoint)
      context.stroke(path, with: .color(.yellow), lineWidth: lineWidth)

    }
  }
}

#Preview {
  ContentView()
}
