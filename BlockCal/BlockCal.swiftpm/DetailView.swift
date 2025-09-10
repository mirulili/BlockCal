import SwiftUI
import UIKit

struct DetailView: View {
    let date: Date
    @EnvironmentObject var photoStore: PhotoStore
    @State private var image: UIImage? = nil
    @State private var descriptionText: String = ""
    @State private var showImagePicker = false
    @FocusState private var isFocused: Bool
    @State private var isEditing: Bool = false
    
    var body: some View {
        VStack {
            Text(formattedDate(date))
                .font(.title2)
                .padding(.top)
            
            // 이미지 뷰
            if let image = image {
                Image(uiImage: image)
                    .resizable()
                    .scaledToFit()
                    .frame(maxHeight: 300)
                    .padding(.horizontal)
            } else {
                Rectangle()
                    .fill(Color.gray.opacity(0.2))
                    .frame(height: 300)
                    .overlay(Text("사진 없음"))
                    .padding(.horizontal)
            }
            
            // 설명 입력 칸 (편집 가능 여부에 따라)
            if isEditing {
                TextEditor(text: $descriptionText)
                    .frame(height: 120)
                    .padding()
                    .background(Color.gray.opacity(0.1))
                    .clipShape(RoundedRectangle(cornerRadius: 8))
                    .focused($isFocused)
                    .padding(.horizontal)
            } else {
                ScrollView {
                    Text(descriptionText.isEmpty ? "설명 없음" : descriptionText)
                        .frame(maxWidth: .infinity, alignment: .leading)
                        .padding()
                        .background(Color.gray.opacity(0.1))
                        .clipShape(RoundedRectangle(cornerRadius: 8))
                        .padding(.horizontal)
                }
            }
            
            Spacer()
            
            // 버튼
            if isEditing {
                Button("저장") {
                    if let img = image {
                        photoStore.savePhoto(img, for: date, with: descriptionText)
                        isEditing = false
                        isFocused = false
                    }
                }
                .padding()
            } else {
                HStack {
                    Button("수정") {
                        isEditing = true
                        if let photo = photoStore.getPhotoData(for: date) {
                            image = photoStore.loadImage(from: photo.filename)
                            descriptionText = photo.description
                        }
                        DispatchQueue.main.asyncAfter(deadline: .now() + 0.2) {
                            isFocused = true
                        }
                    }
                    .padding()
                    
                    Button("사진 변경") {
                        showImagePicker = true
                    }
                }
            }
        }
        .onAppear {
            if let photo = photoStore.getPhotoData(for: date) {
                image = photoStore.loadImage(from: photo.filename)
                descriptionText = photo.description
                isEditing = false
            } else {
                isEditing = true
            }
        }
        .sheet(isPresented: $showImagePicker) {
            ImgPicker(image: $image)
        }
    }
    
    func formattedDate(_ date: Date) -> String {
        let formatter = DateFormatter()
        formatter.dateStyle = .long
        return formatter.string(from: date)
    }
}
