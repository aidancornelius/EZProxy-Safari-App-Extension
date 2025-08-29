//
//  SettingsView.swift
//  EZProxy
//
//  Main settings interface
//

import SwiftUI

struct SettingsView: View {
    @StateObject private var viewModel = SettingsViewModel()
    @State private var testURL = "https://link.springer.com/article/10.1007/s10734-022-00972-z"
    
    var body: some View {
        VStack(alignment: .leading, spacing: 0) {
            // Header
            VStack(alignment: .leading, spacing: 8) {
                Text("Extension settings")
                    .font(.largeTitle)
                    .fontWeight(.bold)
                
                Text("Configure your proxy service and browsing preferences")
                    .font(.body)
                    .foregroundColor(.secondary)
            }
            .padding(.horizontal, 30)
            .padding(.top, 30)
            .padding(.bottom, 24)
            
            ScrollView {
                VStack(spacing: 24) {
                    // Service Configuration
                    VStack(alignment: .leading, spacing: 20) {
                        VStack(alignment: .leading, spacing: 6) {
                            Text("Service configuration")
                                .font(.headline)
                            Text("Choose your authentication service and enter the required details")
                                .font(.subheadline)
                                .foregroundColor(.secondary)
                        }
                        
                        VStack(alignment: .leading, spacing: 16) {
                            // Service Type
                            VStack(alignment: .leading, spacing: 8) {
                                Text("Service type")
                                    .font(.subheadline)
                                    .fontWeight(.medium)
                                
                                Picker("", selection: $viewModel.useOpenAthens) {
                                    Text("EZProxy").tag(false)
                                    Text("OpenAthens").tag(true)
                                }
                                .pickerStyle(MenuPickerStyle())
                                .frame(maxWidth: .infinity, alignment: .leading)
                                .onChange(of: viewModel.useOpenAthens) { _ in
                                    viewModel.saveSettings()
                                }
                            }
                            
                            // Service URL/Identifier
                            VStack(alignment: .leading, spacing: 8) {
                                Text(viewModel.useOpenAthens ? "OpenAthens identifier" : "Proxy URL")
                                    .font(.subheadline)
                                    .fontWeight(.medium)
                                Text(viewModel.useOpenAthens ? "Usually your institution's domain name. i.e., unisa.edu.au" : "Check with your library. i.e., proxy.library.sydney.edu.au")
                                    .font(.subheadline)
                                    .foregroundColor(.secondary)
                                
                                TextField(
                                    viewModel.useOpenAthens ? "Enter your OpenAthens identifier" : "Enter your proxy URL",
                                    text: $viewModel.proxyBase,
                                    onCommit: {
                                        viewModel.validateAndSaveProxy()
                                    }
                                )
                                .textFieldStyle(RoundedBorderTextFieldStyle())
                            }
                            
                            // HTTPS Toggle (only for EZProxy)
                            if !viewModel.useOpenAthens {
                                Toggle("Use HTTPS", isOn: $viewModel.useSSL)
                                    .onChange(of: viewModel.useSSL) { _ in
                                        viewModel.saveSettings()
                                    }
                            }
                            
                            // Action Buttons
                            HStack(spacing: 12) {
                                Button(action: {
                                    viewModel.validateAndSaveProxy()
                                }) {
                                    Label("Save", systemImage: "square.and.arrow.down")
                                        .frame(maxWidth: .infinity)
                                }
                                .buttonStyle(.borderedProminent)
                                .controlSize(.large)
                                
                                Button(action: {
                                    viewModel.testProxyConnection(with: testURL)
                                }) {
                                    Label("Test", systemImage: "network")
                                        .frame(maxWidth: .infinity)
                                }
                                .buttonStyle(.bordered)
                                .controlSize(.large)
                                .disabled(viewModel.proxyBase.isEmpty)
                            }
                        }
                    }
                    .padding(20)
                    .background(Color(NSColor.controlBackgroundColor))
                    .cornerRadius(10)
                    
                    // Tab Behavior - with fixed width
                    VStack(alignment: .leading, spacing: 20) {
                        VStack(alignment: .leading, spacing: 6) {
                            Text("Tab behavior")
                                .font(.headline)
                            Text("Choose how links should open when using the extension")
                                .font(.subheadline)
                                .foregroundColor(.secondary)
                        }
                        
                        VStack(alignment: .leading, spacing: 12) {
                            Picker("", selection: $viewModel.keepTab) {
                                Text("Open in new tab").tag(true)
                                Text("Replace current tab").tag(false)
                            }
                            .pickerStyle(RadioGroupPickerStyle())
                            .onChange(of: viewModel.keepTab) { _ in
                                viewModel.saveSettings()
                            }
                            
                            // Experimental option - only show when "Replace current tab" is selected
                            if !viewModel.keepTab {
                                VStack(alignment: .leading, spacing: 10) {
                                    Toggle("Preserve browsing history (experimental)", isOn: $viewModel.useContentScript)
                                        .onChange(of: viewModel.useContentScript) { _ in
                                            viewModel.saveSettings()
                                        }
                                        .padding(.leading, 20)
                                    
                                    if viewModel.useContentScript {
                                        Text("Navigates within the same tab to maintain back button functionality")
                                            .font(.caption)
                                            .foregroundColor(.secondary)
                                            .padding(.leading, 40)
                                            .fixedSize(horizontal: false, vertical: true)
                                    }
                                }
                                .padding(.top, 4)
                            }
                        }
                        .frame(maxWidth: .infinity, alignment: .leading)
                    }
                    .padding(20)
                    .background(Color(NSColor.controlBackgroundColor))
                    .cornerRadius(10)
                    
                    // Extension Management
                    VStack(alignment: .leading, spacing: 20) {
                        VStack(alignment: .leading, spacing: 6) {
                            Text("Extension management")
                                .font(.headline)
                            Text("Manage your Safari extension settings")
                                .font(.subheadline)
                                .foregroundColor(.secondary)
                        }
                        
                        Button(action: {
                            viewModel.openSafariExtensionPreferences()
                        }) {
                            HStack {
                                Label("Open Safari extension settings", systemImage: "gearshape")
                                Spacer()
                                Image(systemName: "arrow.up.forward.square")
                                    .foregroundColor(.secondary)
                            }
                            .padding(.vertical, 8)
                        }
                        .buttonStyle(.plain)
                    }
                    .padding(20)
                    .background(Color(NSColor.controlBackgroundColor))
                    .cornerRadius(10)
                }
                .padding(.horizontal, 30)
                .padding(.bottom, 30)
            }
            
            // Status Message
            if viewModel.showSettingsMessage {
                HStack {
                    Image(systemName: viewModel.settingsMessage.contains("success") ? "checkmark.circle.fill" : "exclamationmark.triangle.fill")
                        .foregroundColor(viewModel.settingsMessage.contains("success") ? .green : .orange)
                    Text(viewModel.settingsMessage)
                        .font(.caption)
                    Spacer()
                }
                .padding(12)
                .background(Color(NSColor.controlBackgroundColor))
                .cornerRadius(8)
                .padding(.horizontal, 30)
                .padding(.bottom, 20)
                .transition(.move(edge: .bottom).combined(with: .opacity))
                .animation(.easeOut(duration: 0.3), value: viewModel.showSettingsMessage)
            }
        }
        .frame(width: 600, height: 750)
        .fixedSize()
    }
}
