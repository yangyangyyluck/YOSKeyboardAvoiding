# YOSKeyboardAvoiding
A solution for UITextField/UITextView's keyboard cover view.

# How to use
`
- (void)viewWillAppear:(BOOL)animated {
    [super viewWillAppear:animated];
    
    [YOSKeyboardAvoiding setAvoidingView:self.view];
}
`
`
- (void)viewWillDisappear:(BOOL)animated {
    [super viewWillDisappear:animated];
    
    [YOSKeyboardAvoiding resume];
}
`

# Warn
must set scrollView's delegate = nil in the dealloc, otherwirse YOSKeyboardAvoiding will crash.

- (void)dealloc {
  _scrollView.delegate = nil;
}
