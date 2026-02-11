//
//  PhotosManager.swift
//  NoteSnap
//
//  Created by Charles Magnuson on 2/11/26.
//

import Photos
import UIKit

class PhotosManager {

    enum PhotosError: Error, LocalizedError {
        case accessDenied
        case saveFailed(Error)
        case unknown

        var errorDescription: String? {
            switch self {
            case .accessDenied:
                return "Photos access is required to save images. Please enable it in Settings."
            case .saveFailed(let error):
                return "Save failed: \(error.localizedDescription)"
            case .unknown:
                return "An unknown error occurred while saving."
            }
        }
    }

    func saveToPhotos(image: UIImage, completion: @escaping (Result<Void, PhotosError>) -> Void) {
        // First, check and request permission
        checkPhotoLibraryPermission { [weak self] authorized in
            guard authorized else {
                completion(.failure(.accessDenied))
                return
            }

            // Save the image
            self?.performSave(image: image, completion: completion)
        }
    }

    private func checkPhotoLibraryPermission(completion: @escaping (Bool) -> Void) {
        let status = PHPhotoLibrary.authorizationStatus(for: .addOnly)

        switch status {
        case .authorized, .limited:
            completion(true)

        case .denied, .restricted:
            completion(false)

        case .notDetermined:
            // Request permission
            PHPhotoLibrary.requestAuthorization(for: .addOnly) { newStatus in
                DispatchQueue.main.async {
                    completion(newStatus == .authorized || newStatus == .limited)
                }
            }

        @unknown default:
            completion(false)
        }
    }

    private func performSave(image: UIImage, completion: @escaping (Result<Void, PhotosError>) -> Void) {
        PHPhotoLibrary.shared().performChanges({
            // Create the image creation request
            let creationRequest = PHAssetCreationRequest.forAsset()
            creationRequest.addResource(with: .photo, data: image.pngData()!, options: nil)

            // Optional: Create a custom album for Note Snap images
            // This can be added in a future version if desired

        }) { success, error in
            DispatchQueue.main.async {
                if success {
                    completion(.success(()))
                } else if let error = error {
                    completion(.failure(.saveFailed(error)))
                } else {
                    completion(.failure(.unknown))
                }
            }
        }
    }

    // MARK: - Helper Methods

    /// Creates a custom album for Note Snap images (optional feature for future)
    private func createNoteSnapAlbum(completion: @escaping (PHAssetCollection?) -> Void) {
        let albumName = "Note Snap"

        // Check if album already exists
        let fetchOptions = PHFetchOptions()
        fetchOptions.predicate = NSPredicate(format: "title = %@", albumName)
        let collections = PHAssetCollection.fetchAssetCollections(with: .album, subtype: .any, options: fetchOptions)

        if let existingAlbum = collections.firstObject {
            completion(existingAlbum)
            return
        }

        // Create new album
        PHPhotoLibrary.shared().performChanges({
            PHAssetCollectionChangeRequest.creationRequestForAssetCollection(withTitle: albumName)
        }) { success, _ in
            if success {
                let newCollections = PHAssetCollection.fetchAssetCollections(with: .album, subtype: .any, options: fetchOptions)
                completion(newCollections.firstObject)
            } else {
                completion(nil)
            }
        }
    }
}