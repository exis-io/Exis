// Copyright 2015 iAchieved.it LLC
//
// Licensed under the Apache License, Version 2.0 (the "License");
// you may not use this file except in compliance with the License.
// You may obtain a copy of the License at
//
//   http://www.apache.org/licenses/LICENSE-2.0
//
// Unless required by applicable law or agreed to in writing, software
// distributed under the License is distributed on an "AS IS" BASIS,
// WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
// See the License for the specific language governing permissions and
// limitations under the License.

import translator

// import Foundation
// import Glibc

// guard Process.arguments.count == 6 && 
//       Process.arguments[2]    == "from" &&
//       Process.arguments[4]    == "to" else {
//   print("Usage:  translate STRING from LANG to LANG")
//   exit(-1)
// }

// let string     = Process.arguments[1]
// let fromLang   = Process.arguments[3]
// let toLang     = Process.arguments[5]
// let translator = Translator()

// translator.translate(string, from:fromLang, to:toLang) {
//   (translation:String?, error:NSError?) -> Void in
//   guard error == nil && translation != nil else {
//     print("Error:  No translation available")
//     exit(-1)
//   }

//   if let translatedText = translation {
//     print("Translation:  " + translatedText)
//     exit(0)
//   }
// }

// import riff

print("Hello, Swift!")

let t = translator.biddle()