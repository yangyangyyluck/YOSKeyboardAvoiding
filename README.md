# YOSKeyboardAvoiding
A solution for UITextField/UITextView's keyboard cover view.

# How to use
```objective-c
- (void)viewWillAppear:(BOOL)animated {
    [super viewWillAppear:animated];
    
    [YOSKeyboardAvoiding setAvoidingView:self.view];
}

- (void)viewWillDisappear:(BOOL)animated {
    [super viewWillDisappear:animated];
    
    [YOSKeyboardAvoiding resume];
}
```

# Warn
must set scrollView's delegate = nil in the dealloc, otherwirse YOSKeyboardAvoiding will crash.
```objective-c
- (void)dealloc {
  _scrollView.delegate = nil;
}
```
welcome pr :)
