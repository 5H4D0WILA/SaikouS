//
//  Reader.swift
//  Saikou Beta
//
//  Created by Inumaki on 02.03.23.
//

import SwiftUI
import Kingfisher
import SwiftUIFontIcon

struct mangaImages: Codable {
    let page: Int
    let img: String
}

struct Reader: View {
    let mangaData: MangaInfoData?
    let selectedChapterIndex: Int
    @State var images: [mangaImages]? = nil
    @Environment(\.presentationMode) var presentationMode: Binding<PresentationMode>
    
    func getImages(id: String) async {
        guard let url = URL(string: "https://api.consumet.org/meta/anilist-manga/read?chapterId=\(id)&provider=mangadex") else {
            //completion(.failure(error: AnilistFetchError.invalidUrlProvided))
            return
        }
        do {
            let (data, _) = try await URLSession.shared.data(from: url)
            do {
                let data = try JSONDecoder().decode([mangaImages].self, from: data)
                images = data
                print(images)
                //completion(.success(data: data))
            } catch let error {
                print(error)
                //completion(.failure(error: AnilistFetchError.dataParsingFailed(reason: error)))
            }
            
        } catch let error {
            print(error)
            //completion(.failure(error: AnilistFetchError.dataLoadFailed))
        }
    }
    
    @State var offset: CGFloat = 0
    @State var width: CGFloat = 0
    @State var currentPage: Int = 0
    @State var totalPages: Int = 0
    @State var movingOffset: CGFloat = 0
    
    var body: some View {
        GeometryReader { proxy in
            ZStack {
                ScrollView(.horizontal) {
                    if(images != nil) {
                        HStack(spacing: 0) {
                            ForEach(0..<images!.count, id: \.self) { index in
                                ZStack {
                                    Color(hex: "#91A6FF")
                                    
                                    KFImage(URL(string: images![index].img))
                                        .placeholder({ Progress in
                                            ZStack {
                                                Circle()
                                                    .stroke(Color.white.opacity(0.4),style: StrokeStyle(lineWidth: 4))
                                                    .rotationEffect(.init(degrees: -90))
                                                    .frame(maxWidth: 60)
                                                    .animation(.linear)
                                                Circle()
                                                    .trim(from: 0, to: Progress.fractionCompleted)
                                                    .stroke(Color.white,style: StrokeStyle(lineWidth: 4))
                                                    .rotationEffect(.init(degrees: -90))
                                                    .frame(maxWidth: 60)
                                                    .animation(.linear)
                                            }
                                        })
                                        .resizable()
                                        .aspectRatio(contentMode: .fit)
                                        .frame(minWidth: proxy.size.width, maxWidth: proxy.size.width)
                                        .rotation3DEffect(Angle(degrees: 180), axis: (x: CGFloat(0), y: CGFloat(10), z: CGFloat(0)))
                                }
                                .frame(minWidth: proxy.size.width, maxWidth: proxy.size.width)
                            }
                            NextChapterDisplay(currentChapter: "Volume 1 Chapter 1", nextChapter: "Volume 1 Chapter 2", status: "Ready")
                                .frame(minWidth: proxy.size.width, maxWidth: proxy.size.width)
                                .rotation3DEffect(Angle(degrees: 180), axis: (x: CGFloat(0), y: CGFloat(10), z: CGFloat(0)))
                        }
                        .offset(x: offset - movingOffset)
                        .animation(movingOffset != 0 ? .linear : .easeInOut)
                    }
                }
                .flipsForRightToLeftLayoutDirection(true)
                .environment(\.layoutDirection, .rightToLeft)
                .disabled(true)
                .onAppear {
                    width = proxy.size.width
                }
                .gesture(DragGesture(minimumDistance: 0, coordinateSpace: .local)
                    .onChanged({ value in
                        print(value.translation)
                        movingOffset = value.translation.width
                    })
                        .onEnded({ value in
                            
                            if value.translation.width < 0 {
                                // left
                                if(currentPage != 1) {
                                    currentPage -= 1
                                }
                                offset = CGFloat((currentPage - 1)) * -width
                                movingOffset = 0
                            }
                            
                            if value.translation.width > 0 {
                                // right
                                if(images != nil && currentPage != images!.count + 1) {
                                    currentPage += 1
                                }
                                offset = CGFloat((currentPage - 1)) * -width
                                movingOffset = 0
                            }
                        }))
                
                VStack {
                    ZStack(alignment: .topLeading) {
                        //Rectangle 216
                        Rectangle()
                            .fill(LinearGradient(
                                    gradient: Gradient(stops: [
                                        .init(color: Color(hex: "#ff000000"), location: 0),
                                        .init(color: Color(hex: "#00000000"), location: 1)]),
                                    startPoint: UnitPoint(x: 0, y: 0),
                                    endPoint: UnitPoint(x: 0, y: 1)))
                            .frame(width: proxy.size.width, height: 215)
                        
                        HStack {
                            Image(systemName: "chevron.left")
                                .font(.system(size: 24, weight: .bold))
                                .onTapGesture {
                                    self.presentationMode.wrappedValue.dismiss()
                                }
                            
                            VStack(alignment: .leading) {
                                Text("Volume 1 Chapter 1")
                                    .font(.system(size: 16))
                                    .bold()
                                Text("Classroom of the Elite")
                                    .foregroundColor(.white.opacity(0.7))
                                    .font(.system(size: 14))
                                    .bold()
                            }
                            
                            Spacer()
                            
                            FontIcon.button(.awesome5Solid(code: .cog), action: {
                                print("open settings")
                            }, fontsize: 28)
                            .foregroundColor(.white)
                        }
                        .padding(.top, 60)
                        .padding(.horizontal, 20)
                    }
                    
                    Spacer()
                    
                    ZStack {
                        //Rectangle 216
                        Rectangle()
                            .fill(LinearGradient(
                                gradient: Gradient(stops: [
                                    .init(color: Color(hex: "#00000000"), location: 0),
                                    .init(color: Color(hex: "#ff000000"), location: 1)]),
                                startPoint: UnitPoint(x: 0, y: 0),
                                endPoint: UnitPoint(x: 0, y: 1)))
                            .frame(width: proxy.size.width, height: 215)
                        VStack {
                            CustomReaderSlider(isDragging: .constant(false), currentPage: $currentPage, totalPages: $totalPages, offset: $offset, width: $width,total: 1.0)
                                .frame(maxHeight: 40)
                                .padding(.horizontal, 20)
                                .rotation3DEffect(Angle(degrees: 180), axis: (x: CGFloat(0), y: CGFloat(10), z: CGFloat(0)))
                            
                            HStack {
                                Image(systemName: "arrowtriangle.left.circle.fill")
                                    .font(.system(size: 32))
                                
                                Spacer()
                                
                                Image(systemName: "arrowtriangle.right.circle.fill")
                                    .font(.system(size: 32))
                            }
                            .padding(.horizontal, 20)
                            .foregroundColor(Color(hex: "#ff91A6FF"))
                        }
                        
                    }
                }
                .frame(maxWidth: proxy.size.width, maxHeight: .infinity, alignment: .bottom)
            }
        }
        .ignoresSafeArea()
        .onAppear {
            Task {
                if(mangaData != nil && mangaData!.chapters != nil) {
                    await getImages(id: mangaData!.chapters![selectedChapterIndex].id)
                }
                if(images != nil) {
                    totalPages = images!.count
                }
            }
        }
    }
}

struct Reader_Previews: PreviewProvider {
    static var previews: some View {
        Reader(mangaData: nil, selectedChapterIndex: 0)
    }
}

struct CustomReaderSlider: View {
    
    @State private var percentage: Double = 0.0 // or some value binded
    @Binding var isDragging: Bool
    @Binding var currentPage: Int
    @Binding var totalPages: Int
    @Binding var offset: CGFloat
    @Binding var width: CGFloat
    @State var barHeight: CGFloat = 6
    
    var total: Double
    
    var body: some View {
        GeometryReader { geometry in
            // TODO: - there might be a need for horizontal and vertical alignments
            ZStack(alignment: .bottomLeading) {
                
                Rectangle()
                    .foregroundColor(.white.opacity(0.5)).frame(height: barHeight, alignment: .bottom).cornerRadius(12)
                    .gesture(DragGesture(minimumDistance: 0)
                        .onEnded({ value in
                            self.percentage = min(max(0, Double(value.location.x / geometry.size.width * total)), total)
                            
                            self.currentPage = min(max(1, Int(Double(totalPages) * self.percentage)), totalPages)
                            offset = CGFloat((currentPage - 1)) * -width
                            self.isDragging = false
                            self.barHeight = 6
                        })
                            .onChanged({ value in
                                self.isDragging = true
                                self.barHeight = 10
                                print(value)
                                // TODO: - maybe use other logic here
                                self.percentage = min(max(0, Double(value.location.x / geometry.size.width * total)), total)
                                
                                self.currentPage = min(max(1, Int(Double(totalPages) * self.percentage)), totalPages)
                                offset = CGFloat((currentPage - 1)) * -width
                            })).animation(.spring(response: 0.3), value: self.isDragging)
                Rectangle()
                    .foregroundColor(Color(hex: "#ff91A6FF"))
                    .frame(width: geometry.size.width * CGFloat(self.percentage / total)).frame(height: barHeight, alignment: .bottom).cornerRadius(12)
                
                
            }.frame(maxHeight: .infinity, alignment: .center)
                .cornerRadius(12)
                .gesture(DragGesture(minimumDistance: 0)
                    .onEnded({ value in
                        self.percentage = min(max(0, Double(value.location.x / geometry.size.width * total)), total)
                        
                        self.currentPage = min(max(1, Int(Double(totalPages) * self.percentage)), totalPages)
                        offset = CGFloat((currentPage - 1)) * -width
                        self.isDragging = false
                        self.barHeight = 6
                    })
                        .onChanged({ value in
                            self.isDragging = true
                            self.barHeight = 10
                            print(value)
                            // TODO: - maybe use other logic here
                            self.percentage = min(max(0, Double(value.location.x / geometry.size.width * total)), total)
                            self.currentPage = min(max(1, Int(Double(totalPages) * self.percentage)), totalPages)
                            offset = CGFloat((currentPage - 1)) * -width
                        })).animation(.spring(response: 0.3), value: self.isDragging)
            
        }
        .onChange(of: currentPage) { newValue in
            self.percentage = Double(newValue) / Double(totalPages)
        }
    }
}