//
//  ZIP.swift
//  SwiftDecompression
//
//  Created by Andromeda on 23/09/2021.
//

import Foundation

final class ZIP {
    
    class func safePathCreate(_ path: URL) -> String? {
        do {
            try FileManager.default.createDirectory(at: path, withIntermediateDirectories: true, attributes: nil)
            return nil
        } catch {
            return error.localizedDescription
        }
    }
    
    class func decompress(path: String, destinationFolder: URL) -> String? {
        var error: Int32 = 0
        guard let zip = zip_open(path, 0, &error) else {
            return "Error Opening Archive"
        }
        defer {
            zip_close(zip)
        }
        if let error = safePathCreate(destinationFolder) {
            return "Error: \(error)"
        }
        let buf = UnsafeMutablePointer<UInt8>.allocate(capacity: 100)
        defer {
            buf.deallocate()
        }
        var zip_stat = zip_stat()
        for length in 0..<zip_get_num_entries(zip, 0) {
            guard zip_stat_index(zip, zip_uint64_t(length), 0, &zip_stat) == 0 else { return "Error Stating File" }
            let name = String(cString: zip_stat.name)
            let fileURL = destinationFolder.appendingPathComponent(name)
            if name.last == "/" {
                if let error = safePathCreate(fileURL) {
                    return "Error: \(error)"
                }
            } else {
                guard let zip_file = zip_fopen_index(zip, zip_uint64_t(length), 0) else { return "Error Opening File" }
                let fileDescriptor = open(fileURL.path, O_RDWR | O_TRUNC | O_CREAT)
                defer {
                    close(fileDescriptor)
                    zip_fclose(zip_file)
                }
                guard fileDescriptor >= 0 else {
                    continue
                }
                
                var sum: zip_uint64_t = 0
                while sum != zip_stat.size {
                    let len = zip_fread(zip_file, buf, 100)
                    guard len >= 0 else { continue }
                    write(fileDescriptor, buf, Int(len))
                    sum += UInt64(len)
                }
            }
        }
        
        return nil
    }
    
}
