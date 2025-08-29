//
//  SettingsView.swift
//  EZProxy Universal
//
//  Cross-platform settings interface
//

import SwiftUI
import SafariServices

struct SettingsView: View {
    @EnvironmentObject var viewModel: SettingsViewModel
    @State private var testURL = "https://www.nature.com"
    
    var body: some View {
        #if os(macOS)
        macOSLayout
        #else
        iOSLayout
        #endif
    }
    
    var mainContent: some View {
        VStack(spacing: 20) {
            // Header
            VStack(spacing: 10) {
                Image(systemName: "lock.shield")
                    .font(.system(size: 60))
                    .foregroundColor(.accentColor)
                
                Text("EZProxy")
                    .font(.largeTitle)
                    .fontWeight(.bold)
                
                Text("Access academic resources off-campus")
                    .font(.subheadline)
                    .foregroundColor(.secondary)
            }
            .padding(.top)
            
            // Settings Section
            VStack(alignment: .leading, spacing: 15) {
                GroupBox("Proxy configuration") {
                    VStack(alignment: .leading, spacing: 12) {
                        HStack {
                            Text("Proxy domain:")
                            TextField("e.g., ezproxy.university.edu", text: $viewModel.proxyBase)
                                .textFieldStyle(.roundedBorder)
                                #if os(iOS)
                                .autocapitalization(.none)
                                .keyboardType(.URL)
                                #endif
                        }
                        
                        Toggle("Use HTTPS", isOn: $viewModel.useSSL)
                        
                        Toggle("Use OpenAthens", isOn: $viewModel.useOpenAthens)
                            .help("Enable if your institution uses OpenAthens instead of EZProxy")
                    }
                    .padding(.vertical, 5)
                }
                
                GroupBox("Behaviour") {
                    VStack(alignment: .leading, spacing: 12) {
                        Toggle("Open in new tab", isOn: $viewModel.keepTab)
                            .help("Open proxied pages in a new tab instead of replacing the current one")
                        
                        Toggle("Preserve browser history", isOn: $viewModel.useContentScript)
                            .help("Use JavaScript navigation to maintain back button functionality")
                    }
                    .padding(.vertical, 5)
                }
            }
            .padding(.horizontal)
            
            // Test Section
            GroupBox("Test connection") {
                VStack(spacing: 10) {
                    HStack {
                        Text("Test URL:")
                        TextField("Enter a URL to test", text: $testURL)
                            .textFieldStyle(.roundedBorder)
                            #if os(iOS)
                            .autocapitalization(.none)
                            .keyboardType(.URL)
                            #endif
                    }
                    
                    Button(action: {
                        viewModel.testProxyConnection(with: testURL)
                    }) {
                        Label("Test proxy", systemImage: "safari")
                    }
                    .buttonStyle(.borderedProminent)
                    .disabled(viewModel.proxyBase.isEmpty)
                }
                .padding(.vertical, 5)
            }
            .padding(.horizontal)
            
            // Action Buttons
            HStack(spacing: 15) {
                Button(action: {
                    viewModel.openSafariExtensionPreferences()
                }) {
                    Label("Open Safari settings", systemImage: "gearshape")
                }
                .buttonStyle(.bordered)
                
                Button(action: {
                    viewModel.validateAndSaveProxy()
                }) {
                    Label("Save settings", systemImage: "checkmark.circle")
                }
                .buttonStyle(.borderedProminent)
            }
            .padding()
            
            Spacer()
        }
    }
    
    #if os(macOS)
    var macOSLayout: some View {
        mainContent
            .frame(maxWidth: .infinity, maxHeight: .infinity)
            .background(Color(NSColor.controlBackgroundColor))
            .alert("Settings", isPresented: $viewModel.showSettingsMessage) {
                Button("OK") { }
            } message: {
                Text(viewModel.settingsMessage)
            }
    }
    #else
    var iOSLayout: some View {
        NavigationView {
            ScrollView {
                mainContent
                    .padding()
            }
            .navigationTitle("EZProxy")
            .navigationBarTitleDisplayMode(.inline)
            .background(Color(UIColor.systemGroupedBackground))
            .alert("Settings", isPresented: $viewModel.showSettingsMessage) {
                Button("OK") { }
            } message: {
                Text(viewModel.settingsMessage)
            }
        }
        .navigationViewStyle(StackNavigationViewStyle())
    }
    #endif
}