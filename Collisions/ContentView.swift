//
//  ContentView.swift
//  Collisions
//
//  Created by Tim Mitra on 2023-12-14.
//

import SwiftUI
import RealityKit
import RealityKitContent

struct ContentView: View {
  
  @State var rotationA: Angle = .zero
  @State var rotationB: Angle = .zero
  @State var cubeA = Entity()
  @State var cubeB = Entity()
  
  var body: some View {
    
    
    
    
      RealityView { content in
        
        let floor = ModelEntity(mesh: .generatePlane(width: 50, depth: 50), materials: [OcclusionMaterial()])
        floor.components[PhysicsBodyComponent.self] = .init(
          massProperties: .default,
          mode: .static
        )
        
          if let scene = try? await Entity(named: "Scene",
                                              in: realityKitContentBundle) {
              content.add(scene)
              print(scene)
          }
        content.add(floor)
      } update: { content in
          if let scene = content.entities.first {
              Task {
                  cubeA = scene.findEntity(named: "Sphere") ?? Entity()
                  cubeA.components.set(InputTargetComponent())
                  cubeA.generateCollisionShapes(recursive: false)

                  cubeB = scene.findEntity(named: "Cube") ?? Entity()
                  cubeB.components.set(InputTargetComponent())
                  cubeB.generateCollisionShapes(recursive: false)
              }
          }
      }
      .gesture(
          DragGesture()
              .targetedToEntity(cubeA)
              .onChanged { _ in
                  rotationA.degrees += 5.0
                  let m1 = Transform(pitch: Float(rotationA.radians)).matrix
                  let m2 = Transform(yaw: Float(rotationA.radians)).matrix
                  cubeA.transform.matrix = matrix_multiply(m1, m2)
                  // Keep starting distance between models
                  cubeA.position.x = -0.25
              }
      )
      .gesture(
          DragGesture()
              .targetedToEntity(cubeB)
              .onChanged { _ in
                  rotationB.degrees += 5.0
                  cubeB.transform = Transform(roll: Float(rotationB.radians))
                  // Keep starting distance between models
                  cubeB.position.x = 0.25
              }
      )
  }
}

               
#Preview(windowStyle: .volumetric) {
  ContentView()
}
