//
//  ContentView.swift
//  BetterRest
//
//  Created by David Ferreira on 29/10/24.
//

import CoreML
import SwiftUI

struct ContentView: View {
    @State private var wakeUp = defaultWakeTime
    @State private var sleepAmount = 8.0
    @State private var coffeeAmount = 1
    
    @State private var alertTitle = ""
    @State private var alertMessage = ""
    @State private var showingAlert = false
    
    static var defaultWakeTime: Date {
        let components = DateComponents(hour: 7, minute: 0)
        return Calendar.current.date(from: components) ?? .now
    }
    
    var body: some View {
        NavigationStack {
            Form {
                
                VStack(alignment: .leading, spacing: 10) {
                    Text("When do you want to wake up?")
                        .font(.headline)
                    HStack{
                        Spacer()
                        DatePicker("Please enter a time", selection: $wakeUp, displayedComponents: .hourAndMinute)
                            .labelsHidden()
                        Spacer()
                    }
                }
                
                
                VStack(alignment: .leading, spacing: 10) {
                    Text("Desired amount of sleep")
                        .font(.headline)
                    Stepper("\(sleepAmount.formatted()) hours", value: $sleepAmount, in: 4...12, step: 0.25)
                }
                
                Section("Daily coffee intake in cups") {
                    Picker("Quantity of coffee cups", selection: $coffeeAmount) {
                        ForEach(0..<21) {
                            Text($0.formatted())
                        }
                    }
                    .pickerStyle(.wheel)
                }
                
                Section("Your ideal bedtime is..."){
                    Text(estimateSleepTime)
                        .font(.largeTitle)
                }
            }
            .navigationTitle("BetterRest")
            .alert(alertTitle, isPresented: $showingAlert) {
                Button("Ok") {}
            } message: {
                Text(alertMessage)
            }
        }
    }
    
    var estimateSleepTime: String {
        do {
            let config = MLModelConfiguration()
            let model = try SleepCalculator(configuration: config)
            
            let components = Calendar.current.dateComponents([.hour, .minute], from: wakeUp)
            let hour = (components.hour ?? 0) * 60 * 60
            let minute = (components.minute ?? 0) * 60
            
            let prediction = try model.prediction(wake: Double(hour + minute), estimatedSleep: sleepAmount, coffee: Double(coffeeAmount))
            
            let sleepTime = wakeUp - prediction.actualSleep
            return sleepTime.formatted(date: .omitted, time: .shortened)
        } catch {
            alertTitle = "Error"
            alertMessage = "Sorry, there was a problem calculating your bedtime."
            showingAlert = true
        }
        return ""
    }
    
}

#Preview {
    ContentView()
}
