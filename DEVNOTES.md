## BETA 0.3.0

The next phase in the library's development is to incorporate [API NOTES](https://clang.llvm.org/docs/APINotes.html).

## TO-DOs

 - [x] Move **macOS** build to use `CSDL3` (aka, system module)
 - [x] Add initial `.apinotes`; fix any build errors; successfully compile & run existing test executables
 - [ ] Rewrite `Game` protocol to be `GameLoop` (remove `App` enum, etc.; use more `SDL_PropertiesID`)
 - [ ]

## Known Issues

### `xcframework` & `.apinotes`
Using `.apinotes` with a modulemap is straightforward with system modules; less so when compiling a `xcframework`. 

 - The [reference documentation](https://clang.llvm.org/docs/APINotes.html) notes how it's supposed to work;
 - LLVM/Clang shows a [small example](https://github.com/llvm/llvm-project/blob/main/clang/test/APINotes/Inputs/Frameworks/SomeKit.framework/Headers/SomeKit.apinotes).
 
SwiftSDL's library API design changes significantly (for the better)) when using `.apinotes`. 
Ignoring **iOS** & **tvOS** builds temporarily, and moving **macOS** to _CSDL3_ allows development to continue.
