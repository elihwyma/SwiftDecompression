//
//  ViewController.swift
//  SwiftDecompression
//
//  Created by Andromeda on 24/09/2021.
//

import UIKit

class ViewController: UIViewController {
    
    func getDocumentsDirectory() -> URL {
        let paths = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask)
        let documentsDirectory = paths[0]
        return documentsDirectory
    }

    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view.
        
        NSLog("[SwiftDecompression] Starting zst")
        guard let zstTest = Bundle.main.url(forResource: "Packages", withExtension: "zst") else { return }
        let (zstError, zstData) = ZSTD.decompress(path: zstTest.path)
        if let zstError = zstError {
            NSLog("[SwiftDecompression] Failed ZST with error \(zstError)")
        } else if let zstData = zstData {
            NSLog("[SwiftDecompression] ZST data is \(zstData)")
        } else {
            NSLog("[SwiftDecompression] Unknown Error with ZST")
        }
        
        NSLog("[SwiftDecompression] Starting XZ")
        guard let xzTest = Bundle.main.url(forResource: "Packages", withExtension: "xz") else { return }
        let (xzError, xzData) = XZ.decompress(path: xzTest.path, type: .xz)
        if let xzError = xzError {
            NSLog("[SwiftDecompression] Failed XZ with error \(xzError)")
        } else if let xzData = xzData {
            NSLog("[SwiftDecompression] XZ data is \(xzData)")
        } else {
            NSLog("[SwiftDecompression] Unknown Error with XZ")
        }
        
        NSLog("[SwiftDecompression] Starting BZ2")
        guard let bzTest = Bundle.main.url(forResource: "Packages", withExtension: "bz2") else { return }
        let (bzError, bzData) = BZIP.decompress(path: bzTest.path)
        if let bzError = bzError {
            NSLog("[SwiftDecompression] Failed BZ2 with error \(bzError)")
        } else if let bzData = bzData {
            NSLog("[SwiftDecompression] BZ2 data is \(bzData)")
        } else {
            NSLog("[SwiftDecompression] Unknown Error with BZ2")
        }
        
        let documentsFolder = getDocumentsDirectory()
        let destinationFolder = documentsFolder.appendingPathComponent("PackagesZipTest")
        try? FileManager.default.removeItem(at: destinationFolder)
        guard let zipTest = Bundle.main.url(forResource: "Packages", withExtension: "zip") else { return }
        NSLog("[SwiftDecompression] Extracting ZIP to \(destinationFolder.path)")
        if let error = ZIP.decompress(path: zipTest.path, destinationFolder: destinationFolder) {
            NSLog("[SwiftDecompression] Failed With Error \(error)")
        } else {
            NSLog("[SwiftDecompression] Un-zip worked!")
        }
    }


}
	
