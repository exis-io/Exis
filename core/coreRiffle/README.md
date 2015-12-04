# Riffle Core

Makes up all the juicy bits of all the other libraries, because lets face it-- go is pretty awsome. 

Unfortunatly it also has to deal with the vagaries of each individual platform, so this library can be all over the map at times. Each language and platform is built a little differently and has different qualities.

1. **OSX**: built as a static library. Can't handle collections. Really doesn't like callbacks from Go -> Swift. 
2. **iOS**: built using **gomobile**, a tool that creates ready-to-consume frameworks for arm and x86. Doesn't do well inside a cocoapod. In contrast to OSX, deals fantastically well with type conversion, but also doesn't like calling into swift.
3. **Python**: built as a shared library. Can also be built with **gopy**, but then has to deal with typing issues the shared library doesn't. Doesn't always play well with the GIL and GC.
4. **JS**: seamless connections between the languages using **gopherjs**, but Javascript is the only language that can't use the same websocket implementation as the rest of the lot. 


