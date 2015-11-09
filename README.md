# Taylor

A tool aimed to increase Swift code quality, based on many rules from
[OCLint](https://github.com/oclint/oclint).

Taylor uses [SourceKitten](https://github.com/S2dentik/SourceKitten) to a more
accurate [AST](http://clang.llvm.org/docs/IntroductionToTheClangAST.html)
representation and produces the final report based on it.

## Installation

You can install Taylor by running ....

## Usage

### Xcode

Integrate Taylor into an Xcode scheme to get warnings displayed in the IDE. Just
add a new "Run Script Phase" with:

```bash
if which taylor >/dev/null; then
  taylor -p ${PROJECT_DIR} -r xcode -ef ${PROJECT_DIR}/exclude.yml
else
  echo "Taylor not installed"
fi
```