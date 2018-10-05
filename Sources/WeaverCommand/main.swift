//
//  main.swift
//  WeaverCommand
//
//  Created by Théophane Rupin on 2/20/18.
//

import Foundation
import Commander
import WeaverCodeGen
import SourceKittenFramework
import Darwin
import PathKit

private extension Linker {

    convenience init(_ inputPaths: [String], shouldLog: Bool = true) throws {

        // ---- Parse ----

        if shouldLog { Logger.log(.info, "Parsing...") }
        
        let asts: [Expr] = try inputPaths.compactMap { filePath in
            guard let file = File(path: filePath) else {
                return nil
            }
            
            if shouldLog { Logger.log(.info, "<- '\(filePath)'") }
            let tokens = try Lexer(file, fileName: filePath).tokenize()
            return try Parser(tokens, fileName: filePath).parse()
        }
        
        // ---- Link ----
        
        try self.init(syntaxTrees: asts)
    }
}

let main = Group {
    $0.command("generate",
        Option<String>("output_path", default: ".", description: "Where the swift files will be generated."),
        Option<TemplatePathArgument>("template_path", default: TemplatePathArgument(), description: "Custom template path."),
        Flag("unsafe", default: false),
        Argument<InputPathsArgument>("input_paths", description: "Swift files to parse.")
    ) { outputPath, templatePath, unsafeFlag, inputPaths in

        do {
            
            // ---- Link ----

            let linker = try Linker(inputPaths.values.map { $0.string })
            let dependencyGraph = linker.dependencyGraph
            
            // ---- Generate ----

            let generator = try Generator(dependencyGraph: dependencyGraph, template: templatePath.value)
            let generatedData = try generator.generate()
            
            // ---- Collect ----
            
            let dataToWrite: [(path: Path, data: String?)] = generatedData.compactMap { (file, data) in

                let filePath = Path(file)

                guard let fileName = filePath.components.last else {
                    Logger.log(.error, "Could not retrieve file name from path '\(filePath)'")
                    return nil
                }
                let generatedFilePath = Path(outputPath) + "Weaver.\(fileName)"
                
                guard let data = data else {
                    Logger.log(.info, "-- No Weaver annotation found in file '\(filePath)'.")
                    return (path: generatedFilePath, data: nil)
                }

                return (path: generatedFilePath, data: data)
            }
            
            // ---- Inspect ----

            if !unsafeFlag {
                Logger.log(.info, "")
                Logger.log(.info, "Checking dependency graph...")
                
                let inspector = Inspector(dependencyGraph: dependencyGraph)
                try inspector.validate()
            }
            
            // ---- Write ----
            
            Logger.log(.info, "")
            Logger.log(.info, "Writing...")
            
            for (path, data) in dataToWrite {
                if let data = data {
                    try path.write(data)
                    Logger.log(.info, "-> '\(path)'")
                } else if path.isFile && path.isDeletable {
                    try path.delete()
                    Logger.log(.info, " X '\(path)'")
                }
            }

            Logger.log(.info, "")
            Logger.log(.info, "Done.")
        } catch {
            Logger.log(.error, "\(error)")
            exit(1)
        }
    }
    
    $0.command(
        "export",
        Flag("pretty", default: false),
        Argument<InputPathsArgument>("input_paths", description: "Swift files to parse.")
    ) { pretty, inputPaths in
        do {
            // ---- Link ----
            
            let linker = try Linker(inputPaths.values.map { $0.string }, shouldLog: false)
            let dependencyGraph = linker.dependencyGraph

            // ---- Export ----
            
            let encoder = JSONEncoder()
            if pretty {
                encoder.outputFormatting = .prettyPrinted
            }
            let jsonData = try encoder.encode(dependencyGraph)
            guard let jsonString = String(data: jsonData, encoding: .utf8) else {
                Logger.log(.error, "Could not generate json from data.")
                exit(1)
            }
            Logger.log(.info, jsonString)
        } catch {
            Logger.log(.error, "\(error)")
            exit(1)
        }
    }
}

main.run("0.10.3")
