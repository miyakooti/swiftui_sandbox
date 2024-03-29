//
//  ContentView.swift
//  sony_prac
//
//  Created by arai kousuke on 2023/08/30.
//

import SwiftUI
import CoreMotion

struct ContentView: View {
    
    @State var count = 0
    @State var isPresented = false
    
    @ObservedObject var deviceManagerSample = DeviceManagerExample()
    
    var body: some View {
        VStack {
            
            ForEach (deviceManagerSample.deviceParameters) { deviceParameter in
                HStack {
                    Text(deviceParameter.name)
                    Text("\(deviceParameter.hp)")
                    
                }
            }
            
            Button("\(count)") {
                count -= 1
                //                isPresented = true
                if let minHPDevice = deviceManagerSample.deviceParameters.min(by: { $0.hp < $1.hp }) {
                    // HPを-1する
                    var updatedDeviceParameters = deviceManagerSample.deviceParameters
                    if let index = updatedDeviceParameters.firstIndex(where: { $0.id == minHPDevice.id }) {
                        updatedDeviceParameters[index].hp -= 1
                        deviceManagerSample.deviceParameters = updatedDeviceParameters
                    }
                }
                
            }
        }
        .padding()
        .onAppear {
            deviceManagerSample.startAccelerometerUpdates()
        }
        //        .sheet(isPresented: $isPresented) {
        //            ContentView2()
        //        }
        
    }
}

struct ContentView2: View {
    var body: some View {
        Text("hoge")
    }
}

class DeviceManagerExample: NSObject, ObservableObject {
    
    @Published var deviceParameters: [DeviceParameter] = []
    private let motionManager = CMMotionManager()
    
    
    override init() {
        super.init()
        
        deviceParameters = [
            DeviceParameter(hp: 100, name: "あああ"),
            DeviceParameter(hp: 200, name: "いいい"),
            DeviceParameter(hp: 300, name: "ううう"),
        ]
        
    }
    
    func startAccelerometerUpdates() {
        if motionManager.isAccelerometerAvailable {
            motionManager.accelerometerUpdateInterval = 0.1
            motionManager.startAccelerometerUpdates(to: .main) { [weak self] accelerometerData, error in
                guard let accelerometerData = accelerometerData else { return }
                
                let acceleration = sqrt(accelerometerData.acceleration.x * accelerometerData.acceleration.x +
                                        accelerometerData.acceleration.y * accelerometerData.acceleration.y +
                                        accelerometerData.acceleration.z * accelerometerData.acceleration.z)
                
                if acceleration > 2.0 { // 調整が必要かもしれません
                    self?.decreaseLowestHP()
                }
            }
        }
    }
    
    func decreaseLowestHP() {
        if let minHPDevice = deviceParameters.min(by: { $0.hp < $1.hp }) {
            var updatedDeviceParameters = deviceParameters
            if let index = updatedDeviceParameters.firstIndex(where: { $0.id == minHPDevice.id }) {
                updatedDeviceParameters[index].hp -= 1
                deviceParameters = updatedDeviceParameters
            }
        }
    }
    
}

struct ContentView_Previews: PreviewProvider {
    static var previews: some View {
        ContentView()
    }
}

struct DeviceParameter: Identifiable {
    let id = UUID()
    var hp: Int
    var name: String
    
    init(hp: Int, name: String) {
        self.hp = hp
        self.name = name
    }
}
