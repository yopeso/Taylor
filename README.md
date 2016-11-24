![](Assets/logo.png)

# Taylor

A tool aimed to increase Swift code quality, by checking for conformance to code metrics.

[![Build Status](https://travis-ci.org/yopeso/Taylor.svg?branch=master)](https://travis-ci.org/yopeso/Taylor)
[![codecov.io](https://codecov.io/github/yopeso/Taylor/coverage.svg?branch=master)](https://codecov.io/github/yopeso/Taylor?branch=master)
[![Release version](https://img.shields.io/badge/release-0.2.0-blue.svg)](https://github.com/yopeso/Taylor/releases/tag/0.2.0)
[![Swift Code](https://img.shields.io/badge/language-swift-orange.svg)](https://github.com/yopeso/Taylor)
[![Platform](https://img.shields.io/badge/platform-osx-yellow.svg)](https://github.com/yopeso/Taylor)
[![License](https://img.shields.io/badge/license-MIT-lightgrey.svg)](https://github.com/yopeso/Taylor/blob/master/LICENSE)

Taylor uses [SourceKitten](https://github.com/S2dentik/SourceKitten) to a more
accurate [AST](http://clang.llvm.org/docs/IntroductionToTheClangAST.html)
representation and generates the final report in either **Xcode, JSON, PMD** or **plain text** formats.

## Installation

### Homebrew (recommended)
You need to have [Homebrew](http://brew.sh) installed.
```shell
brew update
brew install taylor
```
### Source
Rebuild dependencies by running `carthage bootstrap --platform Mac` ([Carthage](https://github.com/Carthage/Carthage) required)  
Clone the project and run `make install` (**latest version of Xcode required**).

### Package
Download the latest [release](https://github.com/yopeso/Taylor/releases) and run:
```shell
Taylor.app/Contents/Resources/install
```

## Usage

### Xcode

To get warnings displayed in the IDE add a new **Run Script Phase** with:

```bash
if which taylor >/dev/null; then
  taylor -p ${PROJECT_DIR} -r xcode
else
  echo "Taylor not installed"
fi
```
![](Assets/runscriptphase.png)

### Command line 

To use Taylor from command line run it as follows:

`taylor [option1 [option1_argument]] [option2 option2_argument] […]`

##### Available options

|`taylor`           |Description|
|----------------|-------------------|
|`-h`/`--help`| Print **help**.|
|`-v`/`--version`| Print Taylor **version**.|
|`-p`/`--path` `path`| **Path** to the folder to be analysed (current folder by default).|
|`-e`/`--exclude` `file`| Path to either **directory or file to be excluded** from analysis.|
|`-ef`/`--excludeFile` `file`| Path to **exclude file** in `.yml` format.|
|`-f`/`--file` `file`| File to be **included** in analysis (may be from an external source).|
|`-t`/`--type` `type`| **Type of files** to be analysed.|
|`-vl`/`--verbosityLevel` `level`| **Verbosity level** for output messages (info, warning and error).|
|`-r`/`--reporter` `type:name`| Type of final report (**json, xcode, pmd** or **plain text**) and filename.|
|`-rc`/`--ruleCustomization` `rule=value`| **Customize rules** by giving custom values. See [help](/Resources/Help.txt) for more details.|

`taylor` alone with **no arguments** analyses `.swift` files inside current folder.


### Excludes

If you want to exclude some files or folders from checking create a new `.yml` file and call Taylor with
`-ef /path/to/file` argument.  
Default filename is `excludes.yml` and its default location is the folder
specified by `--path` flag.  
The following excluding name formats can be specified:

```yaml
- "/path/to/file"
- "file"
- "Folder"
- "Folder/*"
- ".*Tests.*"
```


### Rules

These are the code quality rules currently existing:

#### Excessive Class Length

[Number of lines in a class]("http://phpmd.org/rules/codesize.html#excessiveclasslength") must not exceed given limit. Default limit = `400 lines`.  
Example: `taylor -rc ExcessiveClassLength=100`.

#### Excessive Method Length

[Number of lines in a method]("http://phpmd.org/rules/codesize.html#excessivemethodlength") must not exceed given limit. Default limit = `20 lines`.  
Example: `taylor -rc ExcessiveMethodLength=10`.

#### Too Many Methods

[Number of methods in a class]("http://phpmd.org/rules/codesize.html#toomanymethods") must not exceed given limit. Default limit = `10 methods`.  
Example: `taylor -rc TooManyMethods=7`.

#### Cyclomatic Complexity

[Cyclomatic Complexity](http://phpmd.org/rules/codesize.html#cyclomaticcomplexity) number of a method must not exceed maximal admitted value. Default = `5`.  
Example: `taylor -rc CyclomaticComplexity=10`.

#### Nested Block Depth

[Block Depth](http://docs.oclint.org/en/dev/rules/size.html#nestedblockdepth) of a method must not exceed maximal admitted value. Default = `3`.  
Example: `taylor -rc NestedBlockDepth=7`.

#### N-Path Complexity

[N-Path Complexity](http://phpmd.org/rules/codesize.html#npathcomplexity) of a method must not exceed maximal admitted value. Default = `100`.  
Example: `taylor -rc NPathComplexity=50`.

#### Excessive Parameter List

[Number of parameters](http://phpmd.org/rules/codesize.html#excessiveparameterlist) given to a method must not exceed maximal admitted value. Default = `3`.  
Example: `taylor -rc ExcessiveParameterList=5`.

## Credits

Thanks to [JP Simard](https://github.com/jpsim) for developing [SourceKitten](https://github.com/jpsim/SourceKitten).

## License

MIT Licensed.
