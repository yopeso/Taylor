## Components

To add a new component to be seen as a `Component` node, add a new case to `ComponentType` enum, find its `sourcekit` equivalent in 
`strings /Applications/Xcode.app/Contents/Developer/Toolchains/XcodeDefault.xctoolchain/usr/lib/sourcekitd.framework/Versions/A/XPCServices/SourceKitService.xpc/Contents/MacOS/SourceKitService | grep source.lang.swift.`, and add the string as a new value to
the case key inside `types` dictionary in `ScissorsExtensions.swift` file. 

Sometimes the tree obtained isn't same as the source code tree, so checking the AST dictionary is recommended first.

## Command-line arguments

To add a new flag like `-h` or `-v` add a new class or struct and conform it to `Flag` protocol.

There are two types of options, `InformationalOption` and `ExecutableOption`. Informational option is used to 
send information to `Caprice` public interface, while executable performs some changes on the resultant dictionary. 

After adding the `Option`, add it as a case to `optionObjectFromOption(_:_:)` function inside `OptionsProcessor` class.

## Rules

Add a new class that implements `Rule` protocol and add it as an element of the return array inside `RulesFactory` class.

Violation checking is performed by `checkComponent(_:)` function implemented by the protocol.
