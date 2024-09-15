import SwiftUI

struct LineGraph: View {
    var data: [Double]               // Data points for the graph
    var profit: Bool = false         // Whether the graph indicates a profit (affects color)

    @State var currentPlot = ""      // Holds the current plot data
    @State var offset: CGPoint = .zero // Tracks the drag offset
    @State var showPlot = false      // Whether to show the plot on drag
    @State var translation: CGFloat = 0 // Translation value for drag gesture
    @State var graphProgress: CGFloat = 0 // Animation progress for the graph

    var body: some View {
        GeometryReader { proxy in
            let height = proxy.size.height
            let width = proxy.size.width / CGFloat(data.count - 1)
            let maxPoint = data.max() ?? 0
            let minPoint = data.min() ?? 0

            // Generate Points for the Line Graph
            let points = data.enumerated().compactMap { (index, value) -> CGPoint in
                let progress = (value - minPoint) / (maxPoint - minPoint)
                let xPos = width * CGFloat(index)
                let yPos = (1 - progress) * height
                return CGPoint(x: xPos, y: yPos)
            }

            ZStack {
                // MARK: - Background Gradient Under the Line Graph
                LinearGradient(gradient: Gradient(colors: [profit ? Color.green.opacity(0.4) : Color.red.opacity(0.4), Color.clear]),
                               startPoint: .top, endPoint: .bottom)
                    .mask(
                        Path { path in
                            path.move(to: CGPoint(x: 0, y: height))
                            path.addLines(points)
                            path.addLine(to: CGPoint(x: proxy.size.width, y: height))
                        }
                    )
                    .animation(.easeInOut(duration: 1.0))

                // MARK: - Line Path for the Graph
                Path { path in
                    path.addLines(points)
                }
                .strokedPath(StrokeStyle(lineWidth: 2, lineCap: .round, lineJoin: .round))
                .fill(LinearGradient(gradient: Gradient(colors: [profit ? Color.green : Color.red, Color.blue]),
                                     startPoint: .leading, endPoint: .trailing))
                .animation(.easeInOut(duration: 1.5), value: graphProgress)

                // MARK: - Show Interactive Plot on Drag
                if showPlot {
                    InteractivePlot(points: points, width: width, height: height, proxy: proxy, offset: $offset)
                }
            }
            .gesture(
                DragGesture()
                    .onChanged { value in
                        showPlot = true
                        offset = value.location // Track drag location
                    }
                    .onEnded { _ in
                        showPlot = false
                    }
            )
            .onAppear {
                withAnimation(.easeInOut(duration: 1.2)) {
                    graphProgress = 1 // Animate the graph when it appears
                }
            }
        }
    }

    // MARK: - Interactive Plot View That Shows Price Points on Drag
    @ViewBuilder
    func InteractivePlot(points: [CGPoint], width: CGFloat, height: CGFloat, proxy: GeometryProxy, offset: Binding<CGPoint>) -> some View {
        // Find the nearest point on the graph to the drag location
        let nearestPoint = nearestPoint(from: offset.wrappedValue, points: points)
        let selectedValue = data[Int(nearestPoint.x / width)]

        ZStack(alignment: .center) {
            
            // MARK: - Indicator Circle for the Closest Point
            Circle()
                .fill(Color.white)
                .frame(width: 12, height: 12)
                .position(x: nearestPoint.x, y: nearestPoint.y)
                .shadow(radius: 5)

            
            // MARK: - Label for the Price at the Selected Point
            Text(String(format: "$%.2f", selectedValue))
                .font(.caption.bold())
                .padding(8)
                .background(Capsule().fill(Color.blue))
                .foregroundColor(.white)
                .position(x: nearestPoint.x, y: nearestPoint.y - 40)
                .shadow(radius: 5)
        }
    }

    // MARK: - Helper Function to Find the Nearest Point on the Graph
    func nearestPoint(from location: CGPoint, points: [CGPoint]) -> CGPoint {
        var nearest = points[0]
        var minDistance = CGFloat.greatestFiniteMagnitude

        for point in points {
            let distance = abs(location.x - point.x)
            if distance < minDistance {
                minDistance = distance
                nearest = point
            }
        }
        return nearest
    }
}

// MARK: - Custom Animated Graph Path
struct AnimatedGraphPath: Shape {
    var progress: CGFloat
    var points: [CGPoint]

    var animatableData: CGFloat {
        get { return progress }
        set { progress = newValue }
    }

    func path(in rect: CGRect) -> Path {
        Path { path in
            path.move(to: CGPoint(x: 0, y: 0))
            path.addLines(points)
        }
        .trimmedPath(from: 0, to: progress)
        .strokedPath(StrokeStyle(lineWidth: 3, lineCap: .round, lineJoin: .round))
    }
}
