//
//  ContentView.swift
//  BetterRest
//
//  Created by Chien Lee on 2024/7/8.
//

import CoreML
import SwiftUI

struct ContentView: View {
    @State private var wakeUp = defaultWakeTime
    @State private var sleepAmount = 8.0
    @State private var coffeeAmount = 1
    
    private var stringifyData: String {
        "\(wakeUp)" + "\(sleepAmount)" + "\(coffeeAmount)"
    }

    @State private var alertTitle = ""
    @State private var alertMessage = ""
    @State private var showingAlert = false

    static var defaultWakeTime: Date {
        var components = DateComponents()
        components.hour = 7
        components.minute = 0
        return Calendar.current.date(from: components) ?? .now
    }

    var body: some View {
        NavigationStack {
            Form {
                Section {
                    VStack(alignment: .center) {
                        Text("When do you want to wake up?")
                            .font(.headline)

                        DatePicker("Please enter a time", selection: $wakeUp, displayedComponents: .hourAndMinute)
                            .labelsHidden()
                    }
                }
                .frame(maxWidth: .infinity)
                VStack {
                    Text("Desired amount of sleep")
                        .font(.headline)

                    Stepper("\(sleepAmount.formatted()) hours", value: $sleepAmount, in: 4 ... 12, step: 0.25)
                }
                VStack {
                    Text("Daily coffee intake")
                        .font(.headline)

                    Picker("^[\(coffeeAmount) cup](inflect: true)", selection: $coffeeAmount) {
                        ForEach(1 ... 20, id: \.self) { cup in
                            Text("\(cup)")
                        }
                    }
                }

                Section {
                    VStack(alignment: .center) {
                        Text("\(alertTitle)")
                            .font(.headline)
                        Text("\(alertMessage)")
                            .font(.title)
                            .padding(.vertical)
                    }
                }
                .frame(maxWidth: .infinity)
                .onChange(of: stringifyData, initial: true){
                    calculateBedtime()
                }
            }
            .navigationTitle("BetterRest")
        }
        .frame(alignment: .center)
    }

    func calculateBedtime() {
        do {
            let config = MLModelConfiguration()
            let model = try SleepCalculator(configuration: config)

            let components = Calendar.current.dateComponents([.hour, .minute], from: wakeUp)
            let hour = (components.hour ?? 0) * 60 * 60
            let minute = (components.minute ?? 0) * 60

            let prediction = try model.prediction(wake: Double(hour + minute), estimatedSleep: sleepAmount, coffee: Double(coffeeAmount))

            let sleepTime = wakeUp - prediction.actualSleep // Date - double is possible

            alertTitle = "Your ideal bedtime is…"
            alertMessage = sleepTime.formatted(date: .omitted, time: .shortened)

        } catch {
            alertTitle = "Error"
            alertMessage = "Sorry, there was a problem calculating your bedtime."
        }

        showingAlert = true
    }
}

#Preview {
    ContentView()
}
