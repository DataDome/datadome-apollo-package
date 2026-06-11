//
//  ContentView.swift
//  Example
//
//  Created by Alexandre Brispot on 13/11/2024.
//

import SwiftUI

final class ContentViewModel: ObservableObject {
    var networkManager: NetworkManager = .shared
    
    // TODO: Replace the example URL by the protected endpoint you want to test
    var endpoint = URL(string: "https://example.com/")!
    var responsePageView: DataDomeResponsePageView? = nil
    @Published var presentingResponsePage: Bool = false
    
    init() {
        URLSession.shared.configuration.requestCachePolicy = .reloadIgnoringLocalAndRemoteCacheData
    }
    
    func clearDDCookie() {
        let cookies = HTTPCookieStorage.shared.cookies ?? []
        for cookie in cookies {
            HTTPCookieStorage.shared.deleteCookie(cookie)
        }
    }
    
    func makeSingleCall(_ id: Int = 0) async {
        _ = try? await networkManager.protectedData(from: endpoint, withId: id)
    }
    
    func makeMuiltipleCalls(number: Int) async {
        for i in 1...number {
            await makeSingleCall(i)
        }
    }
}

struct ContentView: View {
    @StateObject var vm = ContentViewModel()
    
    var body: some View {
        NavigationView {
            VStack(spacing: 0) {
//                List(vm.logger.logs) { log in
//                    Text(log.message.joined(separator: " "))
//                }
                Spacer()
                HStack(alignment: .center) {
                    Button {
                        Task(priority: .userInitiated) {
                            await vm.makeSingleCall()
                        }
                    } label: {
                        Image(systemName: "1.circle.fill")
                        Text("Make request")
                            .fontWeight(.semibold)
                    }
                    .accessibilityIdentifier("singleRequestButton")
                    Spacer()
                    Button {
                        Task(priority: .userInitiated) {
                            await vm.makeMuiltipleCalls(number: 5)
                        }
                    } label: {
                        Image(systemName: "repeat.circle.fill")
                        Text("Multiple requests")
                            .fontWeight(.semibold)
                    }
                }
                .padding([.top, .leading, .trailing])
            }
            .navigationTitle("DD Requests Tester")
            .toolbar {
                ToolbarItem(placement: .topBarTrailing) {
                    Menu {
                        Button(action: vm.clearDDCookie, label: {
                            Image(systemName: "xmark.bin")
                            Text("Clear cookies")
                        })
                        .accessibilityIdentifier("clearCookieBtn")
                    } label: {
                        Image(systemName: "line.3.horizontal")
                    }
                    .accessibilityIdentifier("menuBtn")
                    
                }
            }
            .sheet(isPresented: $vm.presentingResponsePage) {
                vm.responsePageView = nil
            } content: {
                vm.responsePageView
            }
        }
    }
}

struct DataDomeResponsePageView: UIViewControllerRepresentable {
    typealias UIViewControllerType = UIViewController
    let vc: UIViewController

    func makeUIViewController(context: Context) -> UIViewController {
        return vc
    }
    
    func updateUIViewController(_ uiViewController: UIViewController, context: Context) {
        
    }
}

#Preview {
    ContentView()
}
