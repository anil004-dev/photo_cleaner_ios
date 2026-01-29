//
//  ChargingBucketView.swift
//  CleanerApp
//
//  Created by iMac on 08/01/26.
//

import SwiftUI
import Combine

struct ChargingBucketAnimationPreview: View {
    
    var body: some View {
        VStack(alignment: .center, spacing: 0) {
            ChargingBucketView()
                .frame(height: 500)
                .padding([.top, .leading, .trailing])
        }
        .background(Color.black.ignoresSafeArea())
    }
}

import SwiftUI
import Combine

// MARK: - 3. MAIN VIEW
struct ChargingBucketView: View {
    @StateObject var batteryMonitor = BatteryMonitor.shared
    
    // Config
    let rimHeight: CGFloat = 60
    let bottomScale: CGFloat = 0.6
    let bucketWidth: CGFloat = 200
    let bucketHeight: CGFloat = 260
    
    // State
    @State private var drops: [UUID] = []
    @State private var currentTime = Date()
    
    // Timer
    let timer = Timer.publish(every: 0.15, on: .main, in: .common).autoconnect()
    
    // Time Formatter: Just the digits (e.g., "1:45")
    private var timeDigitsFormatter: DateFormatter {
        let formatter = DateFormatter()
        formatter.dateFormat = "h:mm"
        return formatter
    }
    
    // AM/PM Formatter: Just the period (e.g., "PM")
    private var amPmFormatter: DateFormatter {
        let formatter = DateFormatter()
        formatter.dateFormat = "a"
        formatter.amSymbol = "AM"
        formatter.pmSymbol = "PM"
        return formatter
    }
    
    var body: some View {
        ZStack {
            Color.black.ignoresSafeArea()
            
            VStack {
                // --- CLOUD SECTION ---
                ZStack {
                    // Cloud Image
                    //if batteryMonitor.isCharging {
                        Image(systemName: "cloud.fill")
                            .resizable().scaledToFit().frame(width: 200)
                            .foregroundColor(.white)
                            .shadow(color: .blue, radius: 15)
                            .transition(.opacity)
                        
                        // Rain Drops
                        ForEach(drops, id: \.self) { _ in
                            Capsule().fill(Color.cyan).frame(width: 3, height: 15)
                                .modifier(RainFallMod(dist: 400))
                                .offset(x: CGFloat.random(in: -30...30))
                                .zIndex(-1)
                        }
//                    } else {
//                        // Dim cloud if not charging
//                        Image(systemName: "cloud.fill")
//                            .resizable().scaledToFit().frame(width: 200)
//                            .foregroundColor(.gray.opacity(0.5))
//                    }
                    
                    // --- TIME DISPLAY (2 Lines) ---
                    VStack(spacing: -5) { // Tight spacing between lines
                        Text(timeDigitsFormatter.string(from: currentTime))
                            .font(.system(size: 38, weight: .black, design: .rounded))
                        
                        Text(amPmFormatter.string(from: currentTime))
                            .font(.system(size: 18, weight: .bold, design: .rounded))
                    }
                    // Black text if charging (on white cloud), White text if not (on dark cloud)
                    .foregroundColor(.black)
                    .padding(.top, 15) // Push down slightly to center in the cloud body
                }
                .padding(.top)
                .zIndex(10)
                .animation(.easeInOut, value: batteryMonitor.isCharging)
                
                Spacer()
                
                // --- BUCKET SECTION ---
                TimelineView(.animation) { context in
                    let time = context.date.timeIntervalSinceReferenceDate
                    let continuousWaveOffset = Angle(degrees: time * 240)
                    
                    ZStack {
                        // 1. WATER
                        let progress = Double(batteryMonitor.level) / 100.0
                        
                        WaveShapeV2(
                            progress: progress,
                            waveOffset: continuousWaveOffset,
                            rimHeight: rimHeight
                        )
                        .fill(LinearGradient(colors: [.blue, .cyan], startPoint: .bottom, endPoint: .top))
                        .frame(width: bucketWidth, height: bucketHeight)
                        .mask(
                            BucketMask(rimHeight: rimHeight, bottomScale: bottomScale)
                                .frame(width: bucketWidth, height: bucketHeight)
                        )
                        .animation(.linear(duration: 0.5), value: batteryMonitor.level)
                        
                        // 2. OUTLINE
                        BucketOutline(rimHeight: rimHeight, bottomScale: bottomScale)
                            .stroke(Color.white, style: StrokeStyle(lineWidth: 4, lineCap: .round, lineJoin: .round))
                            .frame(width: bucketWidth, height: bucketHeight)
                        
                        // 3. HANDLE
                        Path { path in
                            path.move(to: CGPoint(x: 0, y: rimHeight/2))
                            path.addCurve(to: CGPoint(x: bucketWidth, y: rimHeight/2),
                                          control1: CGPoint(x: bucketWidth*0.3, y: bucketHeight*0.9),
                                          control2: CGPoint(x: bucketWidth*1.7, y: bucketHeight*0.4))
                        }
                        .stroke(Color.white, style: StrokeStyle(lineWidth: 4, lineCap: .round))
                        .frame(width: bucketWidth, height: bucketHeight)
                        
                        // 4. TEXT
                        Text("\(Int(batteryMonitor.level * 100))%")
                            .font(.system(size: 50, weight: .bold, design: .rounded))
                            .foregroundColor(.white)
                            .shadow(radius: 2)
                            .contentTransition(.numericText())
                    }
                }
                .padding(.bottom)
            }
        }
        .onReceive(timer) { _ in
            // Update Time
            currentTime = Date()
            
            // Generate Rain
            //if batteryMonitor.isCharging {
                let id = UUID()
                drops.append(id)
                DispatchQueue.main.asyncAfter(deadline: .now() + 1.0) {
                    drops.removeAll(where: { $0 == id })
                }
            //}
        }
    }
}

// Animation Modifier for Rain
struct RainFallMod: ViewModifier {
    let dist: CGFloat
    @State private var yOff: CGFloat = 0
    @State private var op: Double = 1.0
    func body(content: Content) -> some View {
        content.offset(y: yOff).opacity(op).onAppear {
            withAnimation(.linear(duration: 0.6)) { yOff = dist }
            withAnimation(.linear(duration: 0.1).delay(0.5)) { op = 0 }
        }
    }
}

// MARK: - 1. SHAPES (Unchanged)
struct BucketMask: Shape {
    let rimHeight: CGFloat
    let bottomScale: CGFloat
    
    func path(in rect: CGRect) -> Path {
        var path = Path()
        let w = rect.width
        let h = rect.height
        
        let bottomWidth = w * bottomScale
        let bottomRimHeight = rimHeight * bottomScale
        let bottomOffsetY = h - (bottomRimHeight / 3.2)
        let bottomOffsetX = (w - bottomWidth) / 2
        
        let topLeft = CGPoint(x: 0, y: rimHeight / 2)
        let topRight = CGPoint(x: w, y: rimHeight / 2)
        let bottomLeft = CGPoint(x: bottomOffsetX, y: bottomOffsetY)
        let bottomRight = CGPoint(x: bottomOffsetX + bottomWidth, y: bottomOffsetY)
        
        path.move(to: topLeft)
        path.addLine(to: bottomLeft)
        
        let bottomControlY = bottomOffsetY + (bottomRimHeight / 2)
        path.addQuadCurve(to: bottomRight, control: CGPoint(x: w / 2, y: bottomControlY))
        
        path.addLine(to: topRight)
        
        let topControlOffset = rimHeight
        let topControlY = 0.0 - topControlOffset
        path.addQuadCurve(to: topLeft, control: CGPoint(x: w / 2, y: topControlY))
        
        path.closeSubpath()
        return path
    }
}

struct WaveShapeV2: Shape {
    var progress: Double // 0.0 to 1.0
    var waveOffset: Angle
    let rimHeight: CGFloat
    
    // Only animate progress transitions
    var animatableData: Double {
        get { progress }
        set { progress = newValue }
    }
    
    func path(in rect: CGRect) -> Path {
        var path = Path()
        let w = rect.width
        let h = rect.height
        
        // Calculate Water Level
        let waterHeight = h * CGFloat(progress)
        let currentY = h - waterHeight
        
        path.move(to: CGPoint(x: 0, y: h))
        path.addLine(to: CGPoint(x: w, y: h))
        
        // Draw Wave Surface
        for x in stride(from: w, through: 0, by: -2) {
            let relativeX = x / w
            
            // Perspective Curve
            let perspectiveArch = sin(relativeX * .pi) * (rimHeight * 0.25)
            
            // Ripple
            let edgeDampener = sin(relativeX * .pi)
            let ripple = sin(relativeX * 8 + waveOffset.radians) * (5 * edgeDampener)
            
            let y = currentY + perspectiveArch + ripple
            path.addLine(to: CGPoint(x: x, y: y))
        }
        
        path.closeSubpath()
        return path
    }
}

struct BucketOutline: Shape {
    let rimHeight: CGFloat
    let bottomScale: CGFloat
    
    func path(in rect: CGRect) -> Path {
        var path = Path()
        let w = rect.width; let h = rect.height
        let bottomWidth = w * bottomScale
        let bottomRimHeight = rimHeight * bottomScale
        let bottomOffsetY = h - (bottomRimHeight / 2)
        let bottomOffsetX = (w - bottomWidth) / 2
        
        path.addEllipse(in: CGRect(x: 0, y: 0, width: w, height: rimHeight))
        path.addEllipse(in: CGRect(x: bottomOffsetX, y: bottomOffsetY - bottomRimHeight/2, width: bottomWidth, height: bottomRimHeight))
        path.move(to: CGPoint(x: 0, y: rimHeight/2))
        path.addLine(to: CGPoint(x: bottomOffsetX, y: bottomOffsetY))
        path.move(to: CGPoint(x: w, y: rimHeight/2))
        path.addLine(to: CGPoint(x: bottomOffsetX+bottomWidth, y: bottomOffsetY))
        return path
    }
}
