//
//  Version.swift
//  Taylor
//
//  Created by Andrei Raifura on 10/2/15.
//  Copyright © 2015 YOPESO. All rights reserved.
//

let version = "0.2.0"


// Changes
/*

Version 0.1.1

* Improved the searching algorithm. Now it can find computed properties, closures and other goodies.
* ExcessiveParameterList rule has been added. The rule can be customized by adding -rc <rule>=<threshold> as well.
* Now, the tool runs asynchronously. It takes advanted of all the processor cores.
* Now there are 3 verbosity levels: info, warning, error(default). The verbosity level can be set using -v parameter. (example taylor -v info)


Version 0.1.2

* Easted egg included.
* Taylor can be installer by running `path/to/taylor/Contents/Resources/install`


Version 0.2.0

* Now excludes file may contain wildcard excludes. Ex: .*NameToBeExcluded.*
* Performance improve for big files.

*/