//
//  SizeSettingsView.swift
//  NoteSnap
//
//  Created by Charles Magnuson on 2/11/26.
//

import SwiftUI

struct SizeSettingsView: View {
    @Binding var widthInches: Double
    @Binding var heightInches: Double
    @State private var tempWidth: Double
    @State private var tempHeight: Double
    let onSave: () -> Void
    let onCancel: () -> Void

    init(widthInches: Binding<Double>, heightInches: Binding<Double>, onSave: @escaping () -> Void, onCancel: @escaping () -> Void) {
        self._widthInches = widthInches
        self._heightInches = heightInches
        self._tempWidth = State(initialValue: widthInches.wrappedValue)
        self._tempHeight = State(initialValue: heightInches.wrappedValue)
        self.onSave = onSave
        self.onCancel = onCancel
    }

    var body: some View {
        NavigationView {
            VStack(spacing: 24) {
                Text("Image Size Settings")
                    .font(.title2)
                    .fontWeight(.bold)
                    .padding(.top)

                Text("Customize the dimensions of your printed notes")
                    .font(.subheadline)
                    .foregroundColor(.secondary)
                    .multilineTextAlignment(.center)

                VStack(spacing: 20) {
                    // Width Setting
                    VStack(alignment: .leading, spacing: 8) {
                        Text("Width (inches)")
                            .font(.headline)

                        HStack {
                            TextField("Width", value: $tempWidth, format: .number.precision(.fractionLength(1)))
                                .textFieldStyle(.roundedBorder)
                                .keyboardType(.decimalPad)

                            Text("inches")
                                .foregroundColor(.secondary)
                        }

                        Text("Range: 1.0 - 6.0 inches")
                            .font(.caption)
                            .foregroundColor(.secondary)
                    }

                    // Height Setting
                    VStack(alignment: .leading, spacing: 8) {
                        Text("Height (inches)")
                            .font(.headline)

                        HStack {
                            TextField("Height", value: $tempHeight, format: .number.precision(.fractionLength(1)))
                                .textFieldStyle(.roundedBorder)
                                .keyboardType(.decimalPad)

                            Text("inches")
                                .foregroundColor(.secondary)
                        }

                        Text("Range: 1.0 - 6.0 inches")
                            .font(.caption)
                            .foregroundColor(.secondary)
                    }
                }
                .padding()
                .background(Color(.systemGray6))
                .cornerRadius(12)

                // Preview Info
                VStack(spacing: 8) {
                    Text("Preview:")
                        .font(.headline)

                    Text("Image size will be \(Int(tempWidth * 300))×\(Int(tempHeight * 300)) pixels")
                        .font(.subheadline)
                        .foregroundColor(.secondary)

                    Text("(\(String(format: "%.1f", tempWidth))\" × \(String(format: "%.1f", tempHeight))\" at 300 DPI)")
                        .font(.caption)
                        .foregroundColor(.secondary)
                }
                .padding()
                .background(Color(.systemGray5))
                .cornerRadius(8)

                Spacer()

                // Action Buttons
                HStack(spacing: 16) {
                    Button("Cancel") {
                        onCancel()
                    }
                    .font(.headline)
                    .foregroundColor(.primary)
                    .frame(maxWidth: .infinity)
                    .frame(height: 50)
                    .background(Color(.systemGray5))
                    .cornerRadius(12)

                    Button("Save") {
                        // Validate ranges
                        let clampedWidth = max(1.0, min(6.0, tempWidth))
                        let clampedHeight = max(1.0, min(6.0, tempHeight))

                        widthInches = clampedWidth
                        heightInches = clampedHeight
                        onSave()
                    }
                    .font(.headline)
                    .fontWeight(.semibold)
                    .foregroundColor(.black)
                    .frame(maxWidth: .infinity)
                    .frame(height: 50)
                    .background(Color(red: 1.0, green: 0.988, blue: 0.0)) // Snapchat yellow
                    .cornerRadius(12)
                }
                .padding(.bottom)
            }
            .padding()
            .navigationBarHidden(true)
        }
        .onChange(of: tempWidth) { _, newValue in
            tempWidth = max(1.0, min(6.0, newValue))
        }
        .onChange(of: tempHeight) { _, newValue in
            tempHeight = max(1.0, min(6.0, newValue))
        }
    }
}

#Preview {
    SizeSettingsView(
        widthInches: .constant(2.0),
        heightInches: .constant(3.0),
        onSave: {},
        onCancel: {}
    )
}