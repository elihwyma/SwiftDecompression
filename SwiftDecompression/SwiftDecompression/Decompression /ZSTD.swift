//
//  ZSTD.swift
//  Sileo
//
//  Created by Amy on 31/05/2021.
//  Copyright © 2021 Sileo Team. All rights reserved.
//
#if !targetEnvironment(simulator) && !TARGET_SANDBOX
import Foundation

final class ZSTD {

    class func decompress(path: String) -> (String?, Data?) {
        guard let fin = fopen(path, "rb") else { return (ZSTDError.fileLoad.rawValue, nil) }
        defer {
            fclose(fin)
        }
        let buffInSize = ZSTD_DStreamInSize()
        let buffOutSize = ZSTD_DStreamOutSize()
        let inBuf = UnsafeMutablePointer<UInt8>.allocate(capacity: Int(buffInSize))
        let outBuf = UnsafeMutablePointer<UInt8>.allocate(capacity: Int(buffOutSize))
        defer {
            inBuf.deallocate()
            outBuf.deallocate()
        }
        guard let dctx = ZSTD_createDCtx() else { return (ZSTDError.context.rawValue, nil) }
        defer {
            ZSTD_freeDCtx(dctx)
        }
        var read: size_t = 0
        var lastRet: size_t = 0
        var isEmpty = true
        let data = NSMutableData()
        while true {
            read = fread(inBuf, 1, buffInSize, fin)
            if read == 0 { break }
            isEmpty = false
            var input = ZSTD_inBuffer(src: inBuf, size: read, pos: 0)
            while input.pos < input.size {
                var output = ZSTD_outBuffer(dst: outBuf, size: buffOutSize, pos: 0)
                let ret = ZSTD_decompressStream(dctx, &output, &input)
                if ZSTD_isError(ret) != 0 {
                    if let error = ZSTD_getErrorName(ret) {
                        let string = String(cString: error)
                        return (string, nil)
                    } else {
                        return (ZSTDError.unknown.rawValue, nil)
                    }
                }
                data.append(Data(bytes: outBuf, count: output.pos))
                lastRet = ret
            }
        }
        if isEmpty {
            return (ZSTDError.empty.rawValue, nil)
        }
        if lastRet != 0 {
            return (ZSTDError.midFrame.rawValue, nil)
        }
        
        return (nil, data as Data)
    }
}

enum ZSTDError: String {
    case fileLoad = "Failed to load file"
    case buffIn = "Failed to load buffin in memory"
    case buffOut = "Failed to load buffout in memory"
    case context = "Failed to create decompression context"
    case unknown = "Unknown Error"
    case empty = "Input File was Empty"
    case midFrame = "Data finished mid-frame"
}
#endif
