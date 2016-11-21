# AutoCompleteTextField

[![CI Status](https://img.shields.io/badge/build-passed-brightgreen.svg)](https://img.shields.io/badge/build-passed-brightgreen.svg)
[![Version](https://img.shields.io/badge/pod-v0.1.5-blue.svg)](https://img.shields.io/badge/pod-v0.1.5-blue.svg)
[![License](https://img.shields.io/badge/License-MIT-yellow.svg)](https://img.shields.io/badge/Lisence-MIT-yellow.svg)
[![Carthage compatible](https://img.shields.io/badge/Carthage-compatible-4BC51D.svg?style=flat)](https://github.com/Carthage/Carthage)
[![Platform](https://img.shields.io/badge/platform-ios-lightgrey.svg)](https://img.shields.io/badge/platform-ios-lightgrey.svg)

![ezgif com-resize 1](https://cloud.githubusercontent.com/assets/6511079/16903266/0f2c58e2-4c50-11e6-827c-57b47992c9b2.gif)

## Features
- [x] Provides a subclass of UITextField that has suggestion from input
- [x] Data suggestion are provided by users
- [x] Has autocomplete input feature
- [x] Optimized and light weight


## Requirements

- iOS 8.0+ / Mac OS X 10.9+
- Xcode 7.2+


## Installation

#### CocoaPods
You can use [CocoaPods](http://cocoapods.org/) to install `AutoCompleteTextField` by adding it to your `Podfile`:

```ruby
pod "AutoCompleteTextField"
```

#### Carthage
Create a `Cartfile` that lists the framework and run `carthage bootstrap`. Follow the [instructions](https://github.com/Carthage/Carthage#if-youre-building-for-ios) to add `$(SRCROOT)/Carthage/Build/iOS/AutoCompleteTextField.framework` to an iOS project.

```
github "nferocious76/AutoCompleteTextField"
```

#### Manually
1. Download and drop ```/Pod/Classes```folder in your project.  
2. Congratulations!  

## Usage

```Swift

// Subclass a TextField with 'AutoCompleteTextField'
let myTextField = AutoCompleteTextField(frame: CGRectMake(0, 0, 100, 30))

// Set dataSource, it can be setted from the XCode IB like TextFieldDelegate
myTextField.autoCompleteTextFieldDataSource = self

// Setting delimiter is optional. If setted, it will only look for suggestion if delimiter is found
myTextField.setDelimiter("@")

// 'autoCompleteTextFieldDelegate' acts like the default 'delegate' which 'delegate' is also accessible to the IB.
myTextField.autoCompleteTextFieldDelegate = YourDelegate

// Setting an autocompletion button with text field events
myTextField.showAutoCompleteButton(autoCompleteButtonViewMode: .WhileEditing)

// Then provide your data source to get the suggestion from inputs
func autoCompleteTextFieldDataSource(autoCompleteTextField: AutoCompleteTextField) -> [String] {
        
    return AutoCompleteTextField.domainNames // ["gmail.com", "hotmail.com", "domain.net"]
}

// Initializing with datasource
let textFieldWithDelegateAndDataSource = AutoCompleteTextField(frame: CGRect(x: 20, y: 64, width: view.frame.width - 40, height: 40), autoCompleteTextFieldDataSource: self)

```

## Contribute
We would love for you to contribute to `AutoCompleteTextField`. See the [LICENSE](https://github.com/nferocious76/AutoCompleteTextField/blob/master/LICENSE) file for more info.

## Author

Neil Francis Ramirez Hipona, nferocious76@gmail.com

### About

This project was inpired by 'HTAutocompleteTextField' an Objc-C framework of the same feature.

## License

AutoCompleteTextField is available under the MIT license. See the [LICENSE](https://github.com/nferocious76/AutoCompleteTextField/blob/master/LICENSE) file for more info.
