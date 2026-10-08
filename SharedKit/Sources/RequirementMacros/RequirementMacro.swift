import SwiftCompilerPlugin
import SwiftSyntax
import SwiftSyntaxMacros

public struct RequirementMacro: PeerMacro {
    public static func expansion(
        of node: AttributeSyntax,
        providingPeersOf declaration: some DeclSyntaxProtocol,
        in context: some MacroExpansionContext
    ) throws -> [DeclSyntax] {
        []
    }
}

@main
struct RequirementMacrosPlugin: CompilerPlugin {
    let providingMacros: [Macro.Type] = [RequirementMacro.self]
}
