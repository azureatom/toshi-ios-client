import Foundation
import Files
import PathKit
import ShellOut
import Stencil

// MARK: - Possible local errors

enum StencilScriptError: Error {
    case
    couldNotLoadDictionary,
    couldNotAccessPluralValues
}

// MARK: - Git Helpers

/// - Returns: An array of Strings representing files that have changed since the last commit. Each string is the path relative to the source root.
/// - Throws: Any error attempting to run the git command.
func changedFiles() throws -> [String] {
    let diff = try shellOut(to: ShellOutCommand(string: "git diff --name-only"))

    // Split the file names into an array
    return diff.components(separatedBy: "\n")
}

/// Determines if a particular file has changed given its file name only.
/// NOTE: Only useful for files with a unique name across the codebase.
///
/// - Parameter fileName: The name of the file, including any extensions
/// - Returns: true if the file has changed, false if not.
/// - Throws: Any error attempting to run the git command.
func hasFileChanged(named fileName: String) throws -> Bool {
    // Take the last path component of each file name
    let fileNamesInDiff = try changedFiles().flatMap { $0.components(separatedBy: "/").last }
    return fileNamesInDiff.contains(fileName)
}

// MARK: - Filesystem Helpers

/// Loads a dictionary with string keys and string values.
///
/// - Parameter file: The file to load from the filesystem.
/// - Returns: The loaded dictionary
/// - Throws: An error if the dictionary could not be loaded or is of incorrect type.
func loadStringDictionary(from file: File) throws -> [String: String] {
    guard let dictionary = NSDictionary(contentsOfFile: file.path) as? [String: String] else {
        throw StencilScriptError.couldNotLoadDictionary
    }

    return dictionary
}

/// Loads a dictionary with `String` keys and `Any` values.
///
/// - Parameter file: The file to load from the filesystem.
/// - Returns: The loaded dictionary.
/// - Throws: An error if the dictionary could not be loaded or is of incorrect type.
func loadDictionary(from file: File) throws -> [String: Any] {
    guard let dictionary = NSDictionary(contentsOfFile: file.path) as? [String: Any] else {
        throw StencilScriptError.couldNotLoadDictionary
    }

    return dictionary
}

// MARK: - Helper classes for Stencil

struct LocalizedString {
    let key: String
    let value: String
}

struct LocalizedPlural {
    let key: String
    let values: [ String ]
}

// MARK: - Functions taking existing information and preparing it to write

func localizableStrings(from baseLanguageFolder: Folder, fileName: String) throws -> [LocalizedString] {
    let localizableFile = try baseLanguageFolder.file(named: fileName)
    let localizableContents = try loadStringDictionary(from: localizableFile)
    let sortedKeys = localizableContents.keys.sorted()
    let localizedStrings: [LocalizedString] = sortedKeys.map { key in
        let value = localizableContents[key]!
        let valueWithoutNewlineCharacters = value.replacingOccurrences(of: "\n", with: "\\n")
        return LocalizedString(key: key, value: valueWithoutNewlineCharacters)
    }

    return localizedStrings
}

func localizablePlurals(from baseLanguageFolder: Folder, fileName: String) throws -> [LocalizedPlural] {
    let localizablePluralFile = try baseLanguageFolder.file(named: fileName)
    let pluralContents = try loadDictionary(from: localizablePluralFile)
    let sortedKeys = pluralContents.keys.sorted()
    let localizedPlurals: [LocalizedPlural] = try sortedKeys.map { key in
        guard
            let dictForCurrent = pluralContents[key] as? [String: Any],
            var valuesDict = dictForCurrent["value"] as? [String: String] else {
                throw StencilScriptError.couldNotAccessPluralValues
        }
        valuesDict.removeValue(forKey: "NSStringFormatSpecTypeKey")
        valuesDict.removeValue(forKey: "NSStringFormatValueTypeKey")
        let values = valuesDict.map { "\($0): \"\($1)\"" }
        return LocalizedPlural(key: key, values: values)
    }

    return localizedPlurals
}

// MARK: - Functions to generate the code

func writeLocalizableFile(withLocalized localizedStrings: [LocalizedString],
                          localizedPlurals: [LocalizedPlural],
                          inFolder codeFolder: Folder,
                          environment: Environment) throws {
    let context: [String: Any] = [
        "developer_language": "en",
        "localized_strings": localizedStrings,
        "localized_plurals": localizedPlurals
    ]

    let fileContents = try environment.renderTemplate(name: "LocalizedStrings.swift.stencil", context: context)

    let file = try codeFolder.createFileIfNeeded(withName: "LocalizedStrings.swift")
    try file.write(string: fileContents)
    print("Rendered \(file.name)")
}

// MARK: - Actual Script

guard let sourceRootPath = ProcessInfo.processInfo.environment["SRCROOT"] else {
    fatalError("Could not access source root!")
}

let rootFolder = try Folder(path: sourceRootPath)
let toshiFolder = try rootFolder.subfolder(named: "Toshi")
let resourcesFolder = try toshiFolder.subfolder(named: "Resources")
let baseLanguageFolder = try resourcesFolder.subfolder(named: "Base.lproj")
let generatedFolder = try toshiFolder.subfolder(named: "Generated")
let templatesFolder = try generatedFolder.subfolder(named: "Templates")
let codeFolder = try generatedFolder.subfolder(named: "Code")

let localizableFileName = "Localizable.strings"
let localizablePluralsFileName = "Localizable.stringsdict"

let fileSystemLoader = FileSystemLoader(paths: [ Path(templatesFolder.path) ])
let environment = Environment(loader: fileSystemLoader)

let localizableStringsChanged = try hasFileChanged(named: localizableFileName)
let localizablePluralsChanged = try hasFileChanged(named: localizablePluralsFileName)

if localizableStringsChanged || localizablePluralsChanged {
    try writeLocalizableFile(withLocalized: try localizableStrings(from: baseLanguageFolder, fileName: localizableFileName),
                             localizedPlurals: try localizablePlurals(from: baseLanguageFolder, fileName: localizablePluralsFileName),
                             inFolder: codeFolder,
                             environment: environment)
} else {
    print("Neither \(localizableFileName) nor \(localizablePluralsFileName) have changed, not regenerating")
}
