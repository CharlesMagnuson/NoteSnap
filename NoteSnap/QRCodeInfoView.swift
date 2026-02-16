import SwiftUI

struct QRCodeInfoView: View {
    @Environment(\.dismiss) private var dismiss

    var body: some View {
        NavigationView {
            ScrollView {
                VStack(alignment: .leading, spacing: 20) {
                    // Header
                    VStack(alignment: .leading, spacing: 8) {
                        Text("QR Code Feature")
                            .font(.title2)
                            .fontWeight(.bold)

                        Text("Embed OmniFocus task links in your printed notes")
                            .font(.body)
                            .foregroundColor(.secondary)
                    }

                    Divider()

                    // How it works
                    VStack(alignment: .leading, spacing: 12) {
                        Text("How It Works")
                            .font(.headline)

                        VStack(alignment: .leading, spacing: 8) {
                            FeatureStep(
                                number: "1",
                                title: "Copy OmniFocus Link",
                                description: "In OmniFocus, tap a task and select 'Copy Link' from the share menu"
                            )

                            FeatureStep(
                                number: "2",
                                title: "Enable QR Code",
                                description: "Turn on the QR code toggle when writing your note"
                            )

                            FeatureStep(
                                number: "3",
                                title: "Generate & Print",
                                description: "Create your note - a QR code will appear at the bottom"
                            )

                            FeatureStep(
                                number: "4",
                                title: "Scan to Return",
                                description: "Later, scan the QR code to jump back to the original task"
                            )
                        }
                    }

                    Divider()

                    // Link format example
                    VStack(alignment: .leading, spacing: 12) {
                        Text("Link Format")
                            .font(.headline)

                        Text("OmniFocus task links look like this:")
                            .font(.body)
                            .foregroundColor(.secondary)

                        Text("omnifocus:///task/ABC123-DEF456")
                            .font(.footnote)
                            .fontDesign(.monospaced)
                            .padding(12)
                            .background(Color(.systemGray6))
                            .cornerRadius(8)
                    }

                    Divider()

                    // Tips
                    VStack(alignment: .leading, spacing: 12) {
                        Text("Tips")
                            .font(.headline)

                        VStack(alignment: .leading, spacing: 8) {
                            TipView(
                                icon: "lightbulb",
                                tip: "The QR code toggle shows a status indicator when enabled"
                            )

                            TipView(
                                icon: "camera.viewfinder",
                                tip: "QR codes work with the built-in iPhone Camera app"
                            )

                            TipView(
                                icon: "printer",
                                tip: "QR codes are sized for optimal scanning on 2\"×3\" prints"
                            )
                        }
                    }

                    Spacer()
                }
                .padding(.horizontal, 20)
                .padding(.vertical, 16)
            }
            .navigationTitle("QR Code Help")
            .navigationBarTitleDisplayMode(.inline)
            .navigationBarBackButtonHidden(true)
            .toolbar {
                ToolbarItem(placement: .navigationBarTrailing) {
                    Button("Done") {
                        dismiss()
                    }
                    .fontWeight(.semibold)
                }
            }
        }
    }
}

struct FeatureStep: View {
    let number: String
    let title: String
    let description: String

    var body: some View {
        HStack(alignment: .top, spacing: 12) {
            Text(number)
                .font(.caption)
                .fontWeight(.bold)
                .foregroundColor(.white)
                .frame(width: 20, height: 20)
                .background(Circle().fill(Color.blue))
                .accessibilityLabel("Step \(number)")

            VStack(alignment: .leading, spacing: 2) {
                Text(title)
                    .font(.subheadline)
                    .fontWeight(.medium)

                Text(description)
                    .font(.caption)
                    .foregroundColor(.secondary)
            }

            Spacer()
        }
    }
}

struct TipView: View {
    let icon: String
    let tip: String

    var body: some View {
        HStack(alignment: .top, spacing: 10) {
            Image(systemName: icon)
                .font(.system(size: 14))
                .foregroundColor(.blue)
                .frame(width: 16, alignment: .center)

            Text(tip)
                .font(.caption)
                .foregroundColor(.secondary)

            Spacer()
        }
    }
}

struct QRCodeInfoView_Previews: PreviewProvider {
    static var previews: some View {
        QRCodeInfoView()
    }
}