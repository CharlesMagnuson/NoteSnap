//
//  ContentView.swift
//  NoteSnap
//
//  Created by Charles Magnuson on 2/11/26.
//

import SwiftUI
import Photos

struct ContentView: View {
    @State private var noteText: String = ""
    @State private var isGenerating: Bool = false
    @State private var showSuccessMessage: Bool = false
    @State private var errorMessage: String? = nil
    @State private var showSizeSettings: Bool = false
    @State private var widthInches: Double = 2.0
    @State private var heightInches: Double = 3.0
    @FocusState private var isTextFieldFocused: Bool

    private let imageGenerator = ImageGenerator()
    private let photosManager = PhotosManager()

    var body: some View {
        NavigationView {
            VStack(spacing: 15) {
                Spacer()

                // App Title - Tappable for settings
                Button(action: {
                    showSizeSettings = true
                }) {
                    Text("NoteSnap")
                        .font(.largeTitle)
                        .fontWeight(.bold)
                        .foregroundColor(.primary)
                }
                .buttonStyle(PlainButtonStyle())

                Spacer()
                    .frame(height: 10)

                // Text Input Area
                VStack(alignment: .leading, spacing: 8) {
                    Text("Enter your note:")
                        .font(.headline)
                        .foregroundColor(.primary)

                    TextEditor(text: $noteText)
                        .focused($isTextFieldFocused)
                        .font(.body)
                        .padding(12)
                        .background(Color(.systemGray6))
                        .cornerRadius(12)
                        .frame(minHeight: 120)
                        .overlay(
                            RoundedRectangle(cornerRadius: 12)
                                .stroke(Color(.systemGray4), lineWidth: 1)
                        )
                        .overlay(
                            Group {
                                if noteText.isEmpty {
                                    Text("Enter your note...")
                                        .foregroundColor(.secondary)
                                        .padding(.horizontal, 16)
                                        .padding(.vertical, 20)
                                        .allowsHitTesting(false)
                                }
                            },
                            alignment: .topLeading
                        )
                }
                .padding(.horizontal, 20)

                Spacer()
                    .frame(height: 10)

                // Generate Button - Snapchat Yellow
                Button(action: generateAndSaveImage) {
                    HStack {
                        if isGenerating {
                            ProgressView()
                                .progressViewStyle(CircularProgressViewStyle(tint: .black))
                                .scaleEffect(0.9)
                        } else {
                            Image(systemName: "photo.badge.plus")
                                .font(.system(size: 18, weight: .medium))
                        }

                        Text(isGenerating ? "Creating..." : "Create & Save")
                            .font(.headline)
                            .fontWeight(.semibold)
                    }
                    .foregroundColor(.black)
                    .frame(maxWidth: .infinity)
                    .frame(height: 56)
                    .background(Color(red: 1.0, green: 0.988, blue: 0.0)) // Snapchat yellow
                    .cornerRadius(16)
                    .shadow(color: Color(red: 1.0, green: 0.988, blue: 0.0).opacity(0.3), radius: 8, x: 0, y: 4)
                }
                .disabled(noteText.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty || isGenerating)
                .padding(.horizontal, 20)

                // Success/Error Messages
                Group {
                    if showSuccessMessage {
                        HStack {
                            Image(systemName: "checkmark.circle.fill")
                                .foregroundColor(.green)
                            Text("Saved to Photos!")
                                .font(.subheadline)
                                .fontWeight(.medium)
                        }
                        .padding(.horizontal, 16)
                        .padding(.vertical, 8)
                        .background(Color.green.opacity(0.1))
                        .cornerRadius(8)
                    }

                    if let errorMessage = errorMessage {
                        HStack {
                            Image(systemName: "exclamationmark.circle.fill")
                                .foregroundColor(.red)
                            Text(errorMessage)
                                .font(.subheadline)
                        }
                        .padding(.horizontal, 16)
                        .padding(.vertical, 8)
                        .background(Color.red.opacity(0.1))
                        .cornerRadius(8)
                    }
                }
                .animation(.easeInOut(duration: 0.3), value: showSuccessMessage)
                .animation(.easeInOut(duration: 0.3), value: errorMessage)

                Spacer()
            }
            .navigationBarHidden(true)
        }
        .onAppear {
            loadSizeSettings()
            // Auto-focus the text field when app opens
            DispatchQueue.main.asyncAfter(deadline: .now() + 0.5) {
                isTextFieldFocused = true
            }
        }
        .onTapGesture {
            // Dismiss keyboard when tapping outside
            isTextFieldFocused = false
        }
        .sheet(isPresented: $showSizeSettings) {
            SizeSettingsView(
                widthInches: $widthInches,
                heightInches: $heightInches,
                onSave: {
                    saveSizeSettings()
                    showSizeSettings = false
                },
                onCancel: {
                    loadSizeSettings() // Restore previous values
                    showSizeSettings = false
                }
            )
        }
    }

    private func generateAndSaveImage() {
        guard !noteText.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty else {
            return
        }

        // Clear previous messages
        showSuccessMessage = false
        errorMessage = nil
        isGenerating = true

        // Generate the image with custom dimensions
        let image = imageGenerator.generateImage(from: noteText, widthInches: widthInches, heightInches: heightInches)

        // Save to Photos
        photosManager.saveToPhotos(image: image) { result in
            DispatchQueue.main.async {
                isGenerating = false

                switch result {
                case .success:
                    showSuccessMessage = true
                    // Clear the text after successful save
                    noteText = ""
                    // Hide success message after 3 seconds
                    DispatchQueue.main.asyncAfter(deadline: .now() + 3) {
                        showSuccessMessage = false
                    }

                case .failure(let error):
                    errorMessage = "Failed to save: \(error.localizedDescription)"
                    // Hide error message after 5 seconds
                    DispatchQueue.main.asyncAfter(deadline: .now() + 5) {
                        errorMessage = nil
                    }
                }
            }
        }
    }

    private func saveSizeSettings() {
        UserDefaults.standard.set(widthInches, forKey: "noteSnapWidthInches")
        UserDefaults.standard.set(heightInches, forKey: "noteSnapHeightInches")
    }

    private func loadSizeSettings() {
        if UserDefaults.standard.object(forKey: "noteSnapWidthInches") != nil {
            widthInches = UserDefaults.standard.double(forKey: "noteSnapWidthInches")
            heightInches = UserDefaults.standard.double(forKey: "noteSnapHeightInches")
        } else {
            // Default values
            widthInches = 2.0
            heightInches = 3.0
        }
    }
}

#Preview {
    ContentView()
}
