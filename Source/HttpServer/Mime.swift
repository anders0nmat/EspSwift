
public enum MimeTypeText: String {
    case plain
    case html
    case css
    case csv
}

public enum MimeTypeApplication: String {
    case json
    case javascript
    case xml
}

public enum MimeTypeImage: String {
    case gif
    case jpeg
    case png
    case svg = "svg+xml"
}

public enum MimeType {
    case text(MimeTypeText)
    case application(MimeTypeApplication)
    case image(MimeTypeImage)

    case custom(type: String, subtype: String)

    var description: String {
        switch self {
            case .text(let subtype): "text/" + subtype.rawValue
            case .application(let subtype): "application/" + subtype.rawValue
            case .image(let subtype): "image/" + subtype.rawValue
            case .custom(let type, let subtype): type + "/" + subtype
        }
    }
}

func stringEquals(_ lhs: String.UTF8View, _ rhs: Substring.UTF8View) -> Bool {
    guard lhs.count == rhs.count else { return false }
    
    let uppercase_letters = ("A".utf8.first!..."Z".utf8.first!)

    for (lc, var rc) in zip(lhs, rhs) {
        if uppercase_letters.contains(rc) {
            rc += "a".utf8.first! - "A".utf8.first!
        }
        if lc != rc {
            return false
        }
    }
    return true
}

func mimeType(of file: String) -> MimeType {
    // Do all of this without using string utilities
    let mimeExt: [(String, MimeType)] = [
        ("html", .text(.html)),
        ("css", .text(.css)),
        ("txt", .text(.plain)),
        ("csv", .text(.csv)),
        ("json", .application(.json)),
        ("js", .application(.javascript)),
        ("xml", .application(.xml)),
        ("gif", .image(.gif)),
        ("jpg", .image(.jpeg)),
        ("jpeg", .image(.jpeg)),
        ("png", .image(.png)),
        ("svg", .image(.svg)),
    ]

    let utf8_dot = ".".utf8.first!
    let utf8_slash = "/".utf8.first!
    
    if let lastDot = file.utf8.lastIndex(where: { $0 == utf8_dot || $0 == utf8_slash }), file.utf8[lastDot] == utf8_dot {
        let ext = file.utf8.suffix(from: file.utf8.index(after: lastDot))
        if let (_, mimeMatch) = mimeExt.first(where: { stringEquals($0.0.utf8, ext) }) {
            return mimeMatch
        }
    }
    return .text(.plain)
}
