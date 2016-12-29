## 0.2.2: Don't get stuck

* Fixed the bug when Taylor got stuck [#51](https://github.com/yopeso/Taylor/pull/51)  
  [Alex Culeva](https://github.com/S2dentik)

* Fixed the bug when report files haven't been generated [#49](https://github.com/yopeso/Taylor/pull/49)  
  [Mihai Seremet](https://github.com/mihai8804858)

## 0.2.1: Make the wish again

* Fixed dependency issue  
  [Andrei Raifura](https://github.com/thelvis4)
  
* Added a sanity check after Travis build  
  [Andrei Raifura](https://github.com/thelvis4)

## 0.2.0: Newer and faster

* Migrated to Swift 3.0.1  
  [Andrei Vacaruc](https://github.com/sunnypro)

## 0.1.3: No Troubles At All

* Updated the codebase to Xcode 7.3 [#26](https://github.com/yopeso/Taylor/pull/26)  
  [Alex Culeva](https://github.com/S2dentik)

* Slightly improved the performance (it was very fast, now it's lightning fast)  
  [Alex Culeva](https://github.com/S2dentik)

* When running make install, now it uses xcpretty if available  
  [Alex Culeva](https://github.com/S2dentik)

* Made Easter egg great again  
  [Alex Culeva](https://github.com/S2dentik)

* Now it prints running time with two decimal places  
  [Andrei Raifura](https://github.com/thelvis4)

* Slightly changed rules warning messages  
  [Alex Culeva](https://github.com/S2dentik)

## 0.1.2: Taylor gets smarter

* Fixed the bug when closure parameters were recognized as simple parameters
  leading to `tooManyArguments` violation trigger  
  [Alex Culeva](https://github.com/S2dentik)

* Fixed the crash when empty string was passed as report filename  
  [Alex Culeva](https://github.com/S2dentik)

* Guard statement is now recognized  
  [Alex Culeva](https://github.com/S2dentik)

* Extracted the logic of excluded files in a framework  
  [Simion Schiopu](https://github.com/simionschiopu)

* Edited Makefile. Homebrew will use `make install` to deploy the binaries  
  [Andrei Raifura](https://github.com/thelvis4)

* Taylor now uses Carthage as dependency manager  
  [Andrei Raifura](https://github.com/thelvis4)

* Improved compile time  
  [Andrei Raifura](https://github.com/thelvis4)

## 0.1.1: Before New Year's Eve Party

* Prepared Makefile for Homebrew integration  
  [Andrei Raifura](https://github.com/thelvis4)

## 0.1.0: Brand New First Version

* Implemented `Finder` module  
  [Simion Schiopu](https://github.com/simionschiopu)

* Implemented `Temper` module reponsible for rule conformance checking
  and report generation  
  [Mihai Seremet](https://github.com/mihai8804858)

* Implemented `Caprices` module responsible for parsing command-line
  arguments and storing into a dictionary  
  [Dmitrii Celpan](https://github.com/CelpanDmitrii)

* Implemented `Scissors` module responsible for parsing 
  [SourceKitten](https://github.com/jpsim/SourceKitten) AST dictionary into
  a more convenient to work with form  
  [Alex Culeva](https://github.com/S2dentik)

* Implemented `Taylor` application and set the logic flow throughout the
  modules  
  [Andrei Raifura](https://github.com/thelvis4)
