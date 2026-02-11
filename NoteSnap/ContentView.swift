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
    @FocusState private var isTextFieldFocused: Bool

    private let imageGenerator = ImageGenerator()
    private let photosManager = PhotosManager()

    var body: some View {
        NavigationView {
            VStack(spacing: 30) {
                Spacer()

                // App Title
                Text("Note Snap")
                    .font(.largeTitle)
                    .fontWeight(.bold)
                    .foregroundColor(.primary)

                Text("Create printable notes for your 2\"×3\" printer")
                    .font(.subheadline)
                    .foregroundColor(.secondary)
                    .multilineTextAlignment(.center)
                    .padding(.horizontal)

                Spacer()

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

                // Generate Button
                Button(action: generateAndSaveImage) {
                    HStack {
                        if isGenerating {
                            ProgressView()
                                .progressViewStyle(CircularProgressViewStyle(tint: .white))
                                .scaleEffect(0.9)
                        } else {
                            Image(systemName: "photo.badge.plus")
                                .font(.system(size: 18, weight: .medium))
                        }

                        Text(isGenerating ? "Creating..." : "Create & Save")
                            .font(.headline)
                            .fontWeight(.semibold)
                    }
                    .foregroundColor(.white)
                    .frame(maxWidth: .infinity)
                    .frame(height: 56)
                    .background(
                        LinearGradient(
                            gradient: Gradient(colors: [Color.blue, Color.purple]),
                            startPoint: .leading,
                            endPoint: .trailing
                        )
                    )
                    .cornerRadius(16)
                    .shadow(color: Color.blue.opacity(0.3), radius: 8, x: 0, y: 4)
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
            // Auto-focus the text field when app opens
            DispatchQueue.main.asyncAfter(deadline: .now() + 0.5) {
                isTextFieldFocused = true
            }
        }
        .onTapGesture {
            // Dismiss keyboard when tapping outside
            isTextFieldFocused = false
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

        // Generate the image
        let image = imageGenerator.generateImage(from: noteText)

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
}

#Preview {
    ContentView()
}
