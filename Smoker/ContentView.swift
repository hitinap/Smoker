//
//  ContentView.swift
//  Smoker
//
//  Created by Artem Hitin on 22.02.2025.
//

import Charts
import Foundation
import SwiftUI

enum Settings {
    static let packCost = "SavedPackCost"
    static let packSize = "SavedPackSize"
    static let uiColorIdx = "SelectedUiColorIndex"
    static let isDarkMode = "DarkMode"
}

let colorOptions = [
    ("Фиолетовый", Color.purple),
    ("Синий", Color.blue),
    ("Зеленый", Color.green)
]

var currentDate: String {
    let dateFormatter = DateFormatter()
    dateFormatter.dateFormat = "yyyy-MM-dd"
    return dateFormatter.string(from: Date())
}

struct HomeView: View {
    @AppStorage(Settings.uiColorIdx) var uiColorIdx = 0
    @AppStorage(Settings.packCost) var packCost = "200"
    @AppStorage(Settings.packSize) var packSize = "20"
    @AppStorage("CounterHistory") var historyData: Data = Data()
    @AppStorage(Settings.isDarkMode) var isDarkMode = false

    private var history: [String: Int] {
        guard let decoded = try? JSONDecoder().decode([String: Int].self, from: historyData) else { return [:] }
        return decoded
    }

    private var counterValue: Int {
        return history[currentDate] ?? 0
    }

    private var todaySpentAmount: Double {
        return getCostOfOneThing() * Double(counterValue)
    }

    var body: some View {
        NavigationStack {
            VStack {
                Text("Сегодня")
                    .font(.system(size: 34, weight: .bold))
                    .foregroundColor(Color.white)
                    .padding(.trailing, UIScreen.main.bounds.width - 180)
                    .padding(.top, 45)
                    .padding(.bottom, 2)

                Text("\(currentDate)")
                    .foregroundColor(Color.white.opacity(0.6))
                    .padding(.trailing, UIScreen.main.bounds.width - 120)
                    .font(.system(size: 17))
                    .padding(.leading)

                Spacer()

                Text("\(counterValue)")
                    .font(.system(size: 114, weight: .bold, design: .rounded))
                    .foregroundColor(Color.white)
    
                Text("Сумма, которую вы потратили сегодня")
                    .font(.system(size: 17))
                    .foregroundColor(Color.white.opacity(0.6))

                Text("\(todaySpentAmount, specifier: "%.2f") руб")
                    .font(.system(size: 44, weight: .bold, design: .rounded))
                    .foregroundColor(Color.white)
                    .padding(.top, 2)

                Spacer()
                Spacer()
                Spacer()
                Spacer()
                Spacer()

                HStack {
                    Spacer()
                    Button(action: { incrementCounter() }) {
                        ZStack {
                            Circle()
                                .fill(colorOptions[uiColorIdx].1)
                                .frame(width: 115, height: 115)
                                .shadow(radius: 5)
                            Image(systemName: "plus")
                                .font(.system(size: 68))
                                .foregroundColor(.white)
                        }
                    }
                    .buttonStyle(PlainButtonStyle())
                    .shadow(color: isDarkMode ? .white.opacity(0.2) : .black.opacity(0.2), radius: 10, x: 3, y: 3)
                    .padding(.bottom, 60)
                    Spacer()
                }
            }
            .frame(minWidth: 0, maxWidth: .infinity, minHeight: 0, maxHeight: .infinity, alignment: .topLeading)
            .background(HomeBackground(), alignment: .topLeading)
        }
    }

    struct HomeBackground: View {
        @AppStorage(Settings.isDarkMode) var isDarkMode = false

        var body: some View {
            ZStack {
                LinearGradient(
                    gradient: Gradient(colors: [
                        Color.purple,
                        Color(red: 0.6, green: 0.3, blue: 0.9)
                    ]),
                    startPoint: .topLeading,
                    endPoint: .bottomTrailing
                )
                .opacity(isDarkMode ? 0.8 : 1.0)

                WaveShape()
                    .fill(Color.white.opacity(0.1))
                    .frame(height: UIScreen.main.bounds.height * 0.2)
                    .offset(y: UIScreen.main.bounds.height * 0.2)
                
                Circle()
                    .fill(Color.white.opacity(0.05))
                    .frame(width: 300)
                    .offset(x: -130, y: -50)
    
                Circle()
                    .fill(Color.white.opacity(0.05))
                    .frame(width: 200)
                    .offset(x: 180, y: 10)
            }
            .frame(height: UIScreen.main.bounds.height * 0.6)
            .frame(maxWidth: .infinity)
            .mask(
                RoundedCornersShape(
                    radius: 10,
                    corners: [.bottomLeft, .bottomRight]
                )
            )
            .shadow(color: isDarkMode ? .white.opacity(0.2) : .black.opacity(0.2), radius: 10, x: 3, y: 3)
            .ignoresSafeArea()
        }
    }
    
    struct RoundedCornersShape: Shape {
        var radius: CGFloat
        var corners: UIRectCorner

        func path(in rect: CGRect) -> Path {
            let path = UIBezierPath(
                roundedRect: rect,
                byRoundingCorners: corners,
                cornerRadii: CGSize(width: radius + 10, height: radius)
            )
            return Path(path.cgPath)
        }
    }

    struct WaveShape: Shape {
        func path(in rect: CGRect) -> Path {
            var path = Path()
            let amplitude: CGFloat = 25
            let wavelength = rect.width / 2

            path.move(to: CGPoint(x: 0, y: rect.midY))

            for x in stride(from: 0, through: rect.width, by: 10) {
                let y = amplitude * sin((CGFloat(x) * .pi * 2) / wavelength) + rect.midY
                path.addLine(to: CGPoint(x: x, y: y))
            }

            path.addLine(to: CGPoint(x: rect.width, y: rect.height))
            path.addLine(to: CGPoint(x: 0, y: rect.height))
            path.closeSubpath()

            return path
        }
    }

    private func getCostOfOneThing() -> Double {
        return Double(packCost)! / Double(packSize)!
    }

    private func incrementCounter() {
        var historyCopy = history
        historyCopy[currentDate] = counterValue + 1

        guard let encoded = try? JSONEncoder().encode(historyCopy) else { return }
        historyData = encoded
    }
}

struct AnalyticsView: View {
    @AppStorage("CounterHistory") var historyData: Data = Data()
    @AppStorage(Settings.packCost) var packCost = "200"
    @AppStorage(Settings.packSize) var packSize = "20"
    @AppStorage(Settings.uiColorIdx) var uiColorIdx = 0

    @State private var period: PeriodOptions = .week
    @State private var dimension: DimensionOptions = .count

    enum PeriodOptions: String, CaseIterable {
        case week = "Неделя"
        case month = "Месяц"
        case year = "Год"
    }

    enum DimensionOptions: String, CaseIterable {
        case count = "Количество"
        case amount = "Сумма"
    }

    private var history: [String: Int] {
        guard let decoded = try? JSONDecoder().decode([String: Int].self, from: historyData) else { return [:] }
        return decoded
    }

    struct ChartData: Identifiable {
        let date: Date
        let counter: Int
        let amount: Double
        var id: Date { date }
    }

    private var costOfOneThing: Double {
        return Double(packCost)! / Double(packSize)!
    }

    private var startDate: Date {
        let calendar = Calendar.current
        switch period {
        case .week:
            return calendar.date(byAdding: .weekOfYear, value: -1, to: Date())!
        case .month:
            return calendar.date(byAdding: .month, value: -1, to: Date())!
        case .year:
            return calendar.date(byAdding: .year, value: -1, to: Date())!
        }
    }

    private var filteredData: [ChartData] {
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = "yyyy-MM-dd"

        return history
            .filter { dateFormatter.date(from: $0.key)! >= startDate }
            .map { ChartData(date: dateFormatter.date(from: $0.key)!, counter: $0.value, amount: getAmount(counterValue: $0.value)) }
            .sorted { $0.date < $1.date }
    }

    private var totalCounterValue: Int {
        return filteredData.reduce(0) { (total, next) in
            return total + next.counter
        }
    }

    private var totalAmount: Double {
        return Double(totalCounterValue) * costOfOneThing
    }

    private var avgCounterValue: Double {
        return Double(totalCounterValue) / Double(filteredData.count)
    }

    private var avgAmount: Double {
        return totalAmount / Double(filteredData.count)
    }

    var body: some View {
        NavigationStack {
            VStack(alignment: .leading, spacing: 0) {
                Picker("Измерение", selection: $dimension) {
                    ForEach(DimensionOptions.allCases, id: \.self) { option in Text(option.rawValue)
                    }
                }
                .pickerStyle(.segmented)
                .padding()

                if dimension == .count {
                    Text("\(totalCounterValue) \(getNoun(number: totalCounterValue))")
                        .font(.system(size: 36, weight: .bold))
                        .padding(.leading)
                        .padding(.bottom, 5)
                    Text("Столько раз вы курили за указанный период")
                        .font(.system(size: 15))
                        .foregroundColor(Color.gray)
                        .padding(.leading)
                        .padding(.trailing)
                        .padding(.bottom, 10)

                    Text("\(avgCounterValue, specifier: "%.1f") \(getNoun(number: Int(avgCounterValue)))")
                        .font(.system(size: 36, weight: .bold))
                        .padding(.leading)
                        .padding(.bottom, 5)
                    Text("В среднем вы курите за день")
                        .font(.system(size: 15))
                        .foregroundColor(Color.gray)
                        .padding(.leading)
                        .padding(.trailing)
                        .padding(.bottom, 5)
                } else if dimension == .amount {
                    Text("\(totalAmount, specifier: "%.2f") руб")
                        .font(.system(size: 36, weight: .bold))
                        .padding(.leading)
                        .padding(.bottom, 5)
                    Text("Общая сумма, которую вы потратили за период")
                        .font(.system(size: 15))
                        .foregroundColor(Color.gray)
                        .padding(.leading)
                        .padding(.trailing)
                        .padding(.bottom, 5)
    
                    Text("\(avgAmount, specifier: "%.2f") руб")
                        .font(.system(size: 36, weight: .bold))
                        .padding(.leading)
                        .padding(.bottom, 5)
                    Text("Сумма, которую вы тратите в среднем в день")
                        .font(.system(size: 15))
                        .foregroundColor(Color.gray)
                        .padding(.leading)
                        .padding(.trailing)
                        .padding(.bottom, 5)
                }

                Picker("Период", selection: $period) {
                    ForEach(PeriodOptions.allCases, id: \.self) { period in Text(period.rawValue)
                    }
                }
                .pickerStyle(.segmented)
                .padding()

                Chart(filteredData, id: \.id) { point in
                    LineMark(
                        x: .value("Дата", point.date, unit: .day),
                        y: .value(dimension.rawValue, getChartPointValue(point: point))
                    )
                    .interpolationMethod(.catmullRom)
                    .lineStyle(StrokeStyle(lineWidth: 2))
                    .symbol(Circle().strokeBorder(lineWidth: 2))
                    .foregroundStyle(colorOptions[uiColorIdx].1)
                    .annotation(position: .top, alignment: .center) {
                        Text(verbatim: getChartPointValue(point: point).formatted())
                            .font(.caption)
                    }

                    AreaMark(
                        x: .value("Дата", point.date, unit: .day),
                        y: .value(dimension.rawValue, getChartPointValue(point: point))
                    )
                    .interpolationMethod(.catmullRom)
                    .foregroundStyle(
                        LinearGradient(
                            gradient: Gradient (
                                colors: [
                                    colorOptions[uiColorIdx].1.opacity(0.5),
                                    colorOptions[uiColorIdx].1.opacity(0.2),
                                    colorOptions[uiColorIdx].1.opacity(0.05),
                                ]
                            ),
                            startPoint: .top,
                            endPoint: .bottom
                        )
                    )
                }
                .chartYAxis {
                   AxisMarks(position: .leading)
                }
                .frame(height: 200)
                .padding()

                if dimension == .count {
                    Text("На графике отображены данные, сколько раз вы курили за каждый день в последнее время.")
                        .font(.system(size: 15))
                        .foregroundColor(Color.gray)
                        .padding(.leading)
                        .padding(.trailing)
                } else if dimension == .amount {
                    Text("На графике отображены данные, сколько денег вы потратили на сигареты за каждый день в последнее время.")
                        .font(.system(size: 15))
                        .foregroundColor(Color.gray)
                        .padding(.leading)
                        .padding(.trailing)
                }
            }
            .frame(minWidth: 0, maxWidth: .infinity, minHeight: 0, maxHeight: .infinity, alignment: .topLeading)
            .navigationTitle("Аналитика")
        }
    }

    private func getNoun(number: Int) -> String {
        var n = number % 100
        if n >= 5 && n <= 20 {
            return "раз"
        }

        n = n % 10
        if n == 1 {
            return "раз"
        }

        return "раза"
    }

    private func getChartPointValue(point: ChartData) -> Double {
        switch dimension {
        case .count:
            return Double(point.counter)
        case .amount:
            return point.amount
        }
    }

    private func getAmount(counterValue: Int) -> Double {
        return Double(counterValue) * costOfOneThing
    }
}

struct SettingsView: View {
    @AppStorage(Settings.packCost) var packCost = "200"
    @AppStorage(Settings.packSize) var packSize = "20"
    @AppStorage(Settings.uiColorIdx) var uiColorIdx = 0
    @AppStorage(Settings.isDarkMode) var isDarkMode = false
    @AppStorage("CounterHistory") var historyData: Data = Data()

    @State private var lastValidPackCost = "200"
    @State private var lastValidPackSize = "20"
    @State private var localCounterValue = 0

    private var history: [String: Int] {
        guard let decoded = try? JSONDecoder().decode([String: Int].self, from: historyData) else { return [:] }
        return decoded
    }

    private var counterValue: Int {
        return history[currentDate] ?? 0
    }

    var body: some View {
        NavigationStack {
            Form {
                Section(footer: Text("Стоимость 1 пачки")) {
                    TextField("Введите сумму", text: $lastValidPackCost)
                        .keyboardType(.decimalPad)
                        .onChange(of: lastValidPackCost) { inputValue in
                            validatePackCost(inputValue)
                        }
                }
                Section(footer: Text("Кол-во сигарет в 1 пачке")) {
                    TextField("Введите количество", text: $lastValidPackSize)
                    .keyboardType(.numberPad)
                    .onChange(of: lastValidPackSize) { inputValue in
                        validatePackSize(inputValue)
                    }
                }
                
                Section(footer: Text("Отредактировать счетчик за сегодня")) {
                    Stepper(value: $localCounterValue, in: 0...10000) {
                        Text("\(localCounterValue)")
                    }
                    .onChange(of: localCounterValue) {
                        newValue in updateTodayHistory(newValue)
                    }
                }

                Section {
                    Picker("Цвет интерфейса", selection: $uiColorIdx) {
                        ForEach(colorOptions.indices, id: \.self) { index in
                            Text(colorOptions[index].0)
                                .tag(index)
                        }
                    }
                }

                Section {
                    Toggle("Включить темную тему", isOn: $isDarkMode)
                        .toggleStyle(SwitchToggleStyle(tint: colorOptions[uiColorIdx].1))
                }
            }
            .navigationTitle("Настройки")
            .onAppear {
                lastValidPackCost = packCost
                lastValidPackSize = packSize
                localCounterValue = counterValue
            }
        }
    }

    private func updateTodayHistory(_ value: Int) {
        var historyCopy = history
        historyCopy[currentDate] = value

        guard let encoded = try? JSONEncoder().encode(historyCopy) else { return }
        historyData = encoded
    }

    private func validatePackCost(_ value: String) {
        if !value.isEmpty {
            if Double(value) != nil {
                packSize = value
                return
            }
        }
        lastValidPackCost = "1"
    }

    private func validatePackSize(_ value: String) {
        if !value.isEmpty {
            if Int(value) != nil {
                packSize = value
                return
            }
        }
        lastValidPackSize = "1"
    }
}

struct ContentView: View {
    @AppStorage(Settings.uiColorIdx) var uiColorIdx = 0
    @AppStorage(Settings.isDarkMode) var isDarkMode = false

    var body: some View {
        TabView {
            Group {
                HomeView()
                    .tabItem {
                        Image(systemName: "house.fill")
                        Text("Главная")
                }.tag(1)
                AnalyticsView()
                    .tabItem {
                        Image(systemName: "chart.bar.xaxis.ascending")
                        Text("Аналитика")
                }.tag(2)
                SettingsView()
                    .tabItem {
                        Image(systemName: "gearshape.2.fill")
                        Text("Настройки")
                }.tag(3)
            }
        }
        .accentColor(colorOptions[uiColorIdx].1)
        .preferredColorScheme(isDarkMode ? .dark : .light)
    }
}

#Preview {
    ContentView()
}
