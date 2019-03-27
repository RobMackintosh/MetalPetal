#!/usr/bin/env xcrun --sdk macosx swift

import Foundation

struct MetalPetalUmbrellaHeaderGenerator {
    static func headerFileNames(in directory: URL) -> [String] {
        var fileNames: [String] = []
        if let contents = try? FileManager.default.contentsOfDirectory(at: directory, includingPropertiesForKeys: nil, options: []) {
            for url in contents {
                if url.pathExtension == "h" {
                    fileNames.append(url.lastPathComponent)
                } else {
                    let isDirectory = try? url.resourceValues(forKeys: Set([URLResourceKey.isDirectoryKey])).isDirectory
                    if isDirectory ?? false {
                        fileNames.append(contentsOf: headerFileNames(in: url))
                    }
                }
            }
        }
        return fileNames
    }

    static func run() {
        let currentDirectoryURL = URL(fileURLWithPath: FileManager.default.currentDirectoryPath)
        let scriptURL: URL
        if CommandLine.arguments[0].hasPrefix("/") {
            scriptURL = URL(fileURLWithPath: CommandLine.arguments[0])
        } else {
            scriptURL = currentDirectoryURL.appendingPathComponent(CommandLine.arguments[0])
        }
        let directoryURL = scriptURL.deletingLastPathComponent()
        let privateHeaderFiles = ["MetalPetal.h","MTIPrint.h","MTIDefer.h","MTIContext+Internal.h","MTIImage+Promise.h","MTIHasher.h"]
        let headerFileNames = self.headerFileNames(in: directoryURL).filter({ !privateHeaderFiles.contains($0) })
        let content = """
        // MetalPetal Umbrella Header
        // Auto Generated by umbrella-header-update.sh

        \(headerFileNames.reduce("", { result, value in return result + "#import <MetalPetal/\(value)>\n"}))
        FOUNDATION_EXPORT double MetalPetalVersionNumber;
        FOUNDATION_EXPORT const unsigned char MetalPetalVersionString[];
        
        """
        try! content.write(to: directoryURL.appendingPathComponent("MetalPetal.h"), atomically: true, encoding: .utf8)
    }
}

MetalPetalUmbrellaHeaderGenerator.run()
