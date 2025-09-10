import SwiftUI
import UIKit

struct MainView: View {
    @EnvironmentObject var photoStore: PhotoStore
    @State private var currentDate = Date()
    @State private var selectedDate: Date? = nil
    @State private var showDetail = false
    @State private var showAddPhoto = false
    
    // 월/년 선택 관련 상태
    @State private var showMonthPicker = false
    @State private var selectedMonth = Calendar.current.component(.month, from: Date())
    @State private var selectedYear = Calendar.current.component(.year, from: Date())
    private let availableYears = Array(1980...2080)

    var body: some View {
        TabView {
            NavigationStack {
                ZStack(alignment: .bottomTrailing) {
                    VStack(spacing: 16) {
                        
                        // 상단: 월 선택 & 이동
                        HStack {
                            // 캘린더 아이콘 → Picker 열기
                            Button(action: {
                                showMonthPicker = true
                            }) {
                                Image(systemName: "calendar")
                            }
                            
                            Spacer()
                            
                            // 현재 월 텍스트 (클릭 시 오늘로)
                            Button(action: {
                                let now = Date()
                                currentDate = now
                                selectedMonth = Calendar.current.component(.month, from: now)
                                selectedYear = Calendar.current.component(.year, from: now)
                            }) {
                                Text(formattedMonth(currentDate))
                                    .font(.title2)
                                    .bold()
                                    .foregroundColor(.blue)
                            }
                            
                            Spacer()
                            
                            // 좌우 월 이동 버튼
                            HStack(spacing: 16) {
                                Button(action: {
                                    changeMonth(by: -1)
                                }) {
                                    Image(systemName: "chevron.left")
                                }
                                
                                Button(action: {
                                    changeMonth(by: 1)
                                }) {
                                    Image(systemName: "chevron.right")
                                }
                            }
                        }
                        .padding(.horizontal)
                        
                        // 요일 헤더
                        calendarHeader()
                        
                        // 날짜 셀
                        GeometryReader { geo in
                            let cellWidth = geo.size.width / 7 - 2
                            let cellHeight = cellWidth * 5 / 3
                            
                            LazyVGrid(columns: Array(repeating: GridItem(.flexible(), spacing: 2), count: 7), spacing: 2) {
                                ForEach(generateDays(), id: \.self) { date in
                                    if let date = date {
                                        VStack(spacing: 0) {
                                            // 상단 날짜 숫자
                                            Text(dayString(from: date))
                                                .font(.caption2)
                                                .frame(height: 16)
                                                .frame(maxWidth: .infinity, alignment: .leading)
                                                .padding(.leading, 4)
                                            
                                            // 하단 이미지
                                            ZStack {
                                                if let image = photoStore.getImage(for: date) {
                                                    Image(uiImage: image)
                                                        .resizable()
                                                        .scaledToFill()
                                                        .frame(width: cellWidth, height: cellHeight - 16)
                                                        .clipped()
                                                } else {
                                                    Rectangle()
                                                        .fill(Color.gray.opacity(0.15))
                                                        .frame(width: cellWidth, height: cellHeight - 16)
                                                }
                                            }
                                        }
                                        .frame(width: cellWidth, height: cellHeight)
                                        .clipShape(RoundedRectangle(cornerRadius: 4))
                                        .onTapGesture {
                                            selectedDate = date
                                            if photoStore.getImage(for: date) != nil {
                                                showDetail = true
                                            } else {
                                                showAddPhoto = true
                                            }
                                        }
                                    } else {
                                        Rectangle()
                                            .fill(Color.clear)
                                            .frame(width: cellWidth, height: cellHeight)
                                    }
                                }
                            }
                        }
                        
                        Spacer()
                    }
                    
                    // + 버튼 (오늘 날짜에 추가)
                    Button(action: {
                        selectedDate = Date()
                        showAddPhoto = true
                    }) {
                        Image(systemName: "plus.circle.fill")
                            .resizable()
                            .frame(width: 60, height: 60)
                            .foregroundColor(.blue)
                            .shadow(radius: 4)
                            .padding()
                    }
                }
                
                // 상세화면 전환
                .navigationDestination(isPresented: $showDetail) {
                    if let date = selectedDate {
                        DetailView(date: date)
                    }
                }
                .navigationDestination(isPresented: $showAddPhoto) {
                    if let date = selectedDate {
                        AddView(date: date)
                    }
                }
                
                // 월/년도 Picker 시트
                .sheet(isPresented: $showMonthPicker) {
                    VStack {
                        Text("날짜 이동")
                            .font(.headline)
                            .padding(.top)
                        
                        HStack {
                            // 월 Picker
                            Picker("월", selection: $selectedMonth) {
                                ForEach(1...12, id: \.self) { month in
                                    Text("\(month)월").tag(month)
                                }
                            }
                            .pickerStyle(WheelPickerStyle())
                            .frame(maxWidth: .infinity)
                            .clipped()
                            
                            // 년도 Picker
                            Picker("년", selection: $selectedYear) {
                                ForEach(availableYears, id: \.self) { year in
                                    Text("\(year)년").tag(year)
                                }
                            }
                            .pickerStyle(WheelPickerStyle())
                            .frame(maxWidth: .infinity)
                            .clipped()
                        }
                        .frame(height: 150)
                        
                        Button("확인") {
                            if let newDate = Calendar.current.date(from: DateComponents(year: selectedYear, month: selectedMonth, day: 1)) {
                                currentDate = newDate
                            }
                            showMonthPicker = false
                        }
                        .padding()
                    }
                    .presentationDetents([.height(300)])
                }
            }
            .tabItem {
                Label("캘린더", systemImage: "calendar")
            }
            
            // 향후 다른 탭 추가 (갤러리, 설정 등)
        }
    }
    
    // 월 이동
    func changeMonth(by value: Int) {
        if let newDate = Calendar.current.date(byAdding: .month, value: value, to: currentDate) {
            currentDate = newDate
            selectedMonth = Calendar.current.component(.month, from: newDate)
            selectedYear = Calendar.current.component(.year, from: newDate)
        }
    }
    
    // "8월 2025" 형식
    func formattedMonth(_ date: Date) -> String {
        let formatter = DateFormatter()
        formatter.locale = Locale(identifier: "ko_KR")
        formatter.dateFormat = "MMMM yyyy"
        return formatter.string(from: date)
    }
    
    // 요일 헤더
    func calendarHeader() -> some View {
        let days = ["일", "월", "화", "수", "목", "금", "토"]
        return HStack(spacing: 2) {
            ForEach(days, id: \.self) { day in
                Text(day)
                    .frame(maxWidth: .infinity)
                    .font(.caption)
                    .foregroundColor(.secondary)
            }
        }
        .padding(.horizontal, 2)
    }
    
    // 해당 월의 날짜 배열 생성
    func generateDays() -> [Date?] {
        let calendar = Calendar.current
        let startOfMonth = calendar.date(from: DateComponents(year: selectedYear, month: selectedMonth))!
        let weekday = calendar.component(.weekday, from: startOfMonth)
        let numDays = calendar.range(of: .day, in: .month, for: startOfMonth)!.count
        
        var days: [Date?] = Array(repeating: nil, count: weekday - 1)
        for day in 1...numDays {
            if let date = calendar.date(byAdding: .day, value: day - 1, to: startOfMonth) {
                days.append(date)
            }
        }
        return days
    }
    
    // 숫자만 추출
    func dayString(from date: Date) -> String {
        let day = Calendar.current.component(.day, from: date)
        return "\(day)"
    }
}
