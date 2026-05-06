//
// GameSummaryChartView.swift
//  Tichu
//
//  Created by Leon on 02.05.2026.
//

import SwiftUI
import Charts

struct ScorePoint: Identifiable {
    let id = UUID()
    let round: Int
    let value: Int
    let team: String
}

struct GameSummaryChartView: View {
    @Binding var currentGame: tichuGame
  

    // MARK: - Build cumulative score
    private func cumulativePoints(team: Team) -> [Int] {
        var list: [Int] = []
        var counter1 = 0
        var counter2 = 0
        if team == currentGame.team1 {
            list.append(counter1)
            for round in currentGame.Rounds {
                counter1 += (round.tichuPointsTeam1+round.roundPointsTeam1)
                list.append(counter1)
            }
        } else {
            list.append(counter2)
            for round in currentGame.Rounds {
                counter2 += (round.tichuPointsTeam2+round.roundPointsTeam2)
                list.append(counter2)
            }
        }

        return list
    }

    // MARK: - Chart Data
    private var chartData: [ScorePoint] {
        let team1Points = cumulativePoints(team: currentGame.team1 ?? Team())
        let team2Points = cumulativePoints(team: currentGame.team2 ?? Team())

        let team1Data = team1Points.enumerated().map {
            ScorePoint(round: $0.offset, value: $0.element, team: "Team 1")
        }

        let team2Data = team2Points.enumerated().map {
            ScorePoint(round: $0.offset, value: $0.element, team: "Team 2")
        }

        return team1Data + team2Data
    }
    
    // MARK: - Y-Axis Domain
    private var yDomain: ClosedRange<Int> {
        let values = chartData.map { $0.value }
        guard let minVal = values.min(), let maxVal = values.max() else {
            return 0...100
        }
        return minVal...maxVal
    }

    var body: some View {
        Chart(chartData) { point in

            LineMark(
                x: .value("Round", point.round),
                y: .value("Score", point.value)
            )
            .interpolationMethod(.catmullRom)
            .lineStyle(StrokeStyle(lineWidth: 3))
            .foregroundStyle(by: .value("Team", point.team))

            PointMark(
                x: .value("Round", point.round),
                y: .value("Score", point.value)
            )
            .symbolSize(40)
            .foregroundStyle(by: .value("Team", point.team))
        }
        .chartYScale(domain: yDomain)
        .chartForegroundStyleScale([
            "Team 1": .accent,
            "Team 2": .primary
        ])
        .chartXAxis {
            AxisMarks(values: .stride(by: 1)) { _ in
                AxisTick()
                AxisValueLabel()
            }
        }
        .chartYAxis {
            AxisMarks { _ in
                AxisTick()
                AxisValueLabel()
                AxisGridLine()
            }
        }
        .frame(maxWidth: .infinity, maxHeight: .infinity)
        .padding(.horizontal)
    }
}

#Preview {
    GameSummaryChartView(currentGame: .constant(exampleGame))
}
