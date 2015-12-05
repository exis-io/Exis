![alt icon](https://github.com/IdleHandsApps/IHKeyboardAvoiding/blob/gh-pages/Icon-40.png) IHKeyboardAvoiding [![Carthage compatible](https://img.shields.io/badge/Carthage-compatible-4BC51D.svg?style=flat)](https://github.com/Carthage/Carthage)
------------------------------

An elegant solution for keeping any UIView visible when the keyboard is being shown

![alt demo](https://github.com/IdleHandsApps/IHKeyboardAvoiding/blob/gh-pages/IHKeyboardAvoidingDemo.gif)

## Description

IHKeyboardAvoiding will translate any UIView up when the keyboard is being shown, then return it when the keyboard is hidden.  

Register an ```avoidingView```(UIView) with IHKeyboardAvoiding; when the keyboard is shown, if  the ```avoidingView's``` frame will be intersected by the keyboard, then it will move up just above the keyboard. When the keyboard is dismissed, the ```avoidingView``` is returned to its original position.

What sets IHKeyboardAvoiding apart from other keyboard avoiding solutions is that it doesn't require placing your content in a UIScrollView.  No scroll view is used. And it isn't restricted to keeping UITextFields visible, with IHKeyboardAvoiding any UIView can avoid the keyboard

If Autolayout is used then the constraints are animated, otherwise a CGAffine translation is done.

## Supported Features

* iPhone keyboard
* iPad docked keyboard
* iPad undocked keyboard
* iPad split keyboard
* landscape & protrait
* 3rd party keyboards
* Auto Layout
* AutoResizingMask (Springs & Struts)

## How to install

Add this to your CocoaPods Podfile.
```
pod 'IHKeyboardAvoiding'
```

## How to use

To set the avoiding view
```objective-c
[IHKeyboardAvoiding setAvoidingView:(UIView *)avoidingView];
```

Put it in ```(void)viewDidLoad``` or ```(void)viewDidAppear:(BOOL)animated``` depending on your usage

If you're unsure put it in ```(void)viewDidAppear:(BOOL)animated```

If you need to set the avoidingView, or its properites, dynamically consider putting it in ```(BOOL)textViewShouldBeginEditing:(UITextView *)textView```

Optional methods    
```(void)setAvoidingView:(UIView *)avoidingView withTriggerView:(UIView *)triggerView``` Use this to set an avoidingView but have a different view that triggers the avoiding. If a triggerView's frame will be intersected by the keyboard, then the avoidingView will be moved so that the triggerView is above the keyboard
```(void)setBuffer:(int)buffer``` The avoidingView will move if the keyboard is within [buffer] points of the triggerView's frame.  Default buffer is 0  
```(void)setPaddingForCurrentAvoidingView:(int)padding``` The padding to put between the keyboard and triggerView.  Default padding is 0

## Buy now and get these free gifts :)

Tap to dismiss the keyboard with IHKeyboardDismissing https://github.com/IdleHandsApps/IHKeyboardDismissing

A drop in nav controller with cool parallax transitions https://github.com/IdleHandsApps/IHParallaxNavigationController

## IHKeyboardAvoiding vs UIScrollView solutions - Fight, fight!
UIScrollView pros:
* They're quick n easy

IHKeyboardAvoiding pros:
* You dont have scrollviews littered throughout your app
* Having multiple scrollviews in your view heirarchy can cause problems
* When the keyboard hides, scrollviews dont always scroll back to their original position
* Scrollviews only scroll enough to keep the focused textfield visible
* IHKeyboardAvoiding provides control over which UIViews are visible when the keyboard appears

## Similar keyboard avoiding solutions

https://github.com/michaeltyson/TPKeyboardAvoiding (UIScrollView based)  
https://github.com/kirpichenko/EKKeyboardAvoiding (UIScrollView based)  
https://github.com/robbdimitrov/RDVKeyboardAvoiding (UIScrollView based) 
https://github.com/hackiftekhar/IQKeyboardManager (looks interesting) 
https://github.com/danielamitay/DAKeyboardControl (looks interesting)

## Author

* Fraser Scott-Morrison (fraserscottmorrison@me.com)

It'd be great to hear about any cool apps that are using IHKeyboardAvoiding

## License 

Distributed under the MIT License

## Do To

* Improve demo project

## Known Issue

In iOS8 for iPad, when splitting/undocking the keyboard the notifications arent reliably sent by the OS meaning IHKeyboardAvoiding can be left in the wrong state
A radar has been filed http://openradar.appspot.com/18010127
