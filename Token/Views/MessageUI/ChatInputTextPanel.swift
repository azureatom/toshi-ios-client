import NoChat
import HPGrowingTextView

protocol ChatInputTextPanelDelegate: NOCChatInputPanelDelegate {
    func inputTextPanel(_ inputTextPanel: ChatInputTextPanel, requestSendText text: String)
}

private let TGRetinaPixel = CGFloat(0.5)
private let TG_EPSILON = CGFloat(0.0001)

class ChatInputTextPanel: NOCChatInputPanel, HPGrowingTextViewDelegate {

    public var text: String? {
        get {
            return self.inputField.internalTextView.text
        }
        set {
            self.inputField.internalTextView.text = nil
            self.inputField.internalTextView.insertText(newValue ?? "")
        }
    }

    var stripeLayer: CALayer
    var backgroundView: UIView

    var inputField: HPGrowingTextView
    var inputFieldClippingContainer: UIView
    var fieldBackground: UIImageView

    var sendButton: UIButton
    var attachButton: UIButton

    private var sendButtonWidth = CGFloat(0)

    var currentSendButtonWidth: CGFloat {
        return (self.sendButton.isHidden ? 8 : self.sendButtonWidth)
    }

    private let inputFiledInsets = UIEdgeInsets(top: 9, left: 41, bottom: 8, right: 0)
    private let inputFiledInternalEdgeInsets = UIEdgeInsets(top: -2 - TGRetinaPixel, left: 6, bottom: 0, right: 6)
    private let baseHeight = CGFloat(48)

    private var parentSize = CGSize.zero

    private var messageAreaSize = CGSize.zero
    private var keyboardHeight = CGFloat(0)

    override init(frame: CGRect) {
        self.sendButtonWidth = min(150, "Send".size(attributes: [NSFontAttributeName: Theme.semibold(size: 16)]).width + 12)

        self.backgroundView = UIView()
        self.backgroundView.backgroundColor = Theme.inputFieldBackgroundColor

        self.stripeLayer = CALayer()
        self.stripeLayer.backgroundColor = Theme.borderColor.cgColor

        let filedBackgroundImage = #imageLiteral(resourceName: "TGInputFieldBackground")
        self.fieldBackground = UIImageView(image: filedBackgroundImage)
        self.fieldBackground.frame = CGRect(x: 41, y: 9, width: frame.width - 41 - 1, height: 31)

        let inputFiledClippingFrame = self.fieldBackground.frame
        self.inputFieldClippingContainer = UIView(frame: inputFiledClippingFrame)
        self.inputFieldClippingContainer.clipsToBounds = true

        self.inputField = HPGrowingTextView(frame: CGRect(x: self.inputFiledInternalEdgeInsets.left, y: self.inputFiledInternalEdgeInsets.top, width: inputFiledClippingFrame.width - self.inputFiledInternalEdgeInsets.left, height: inputFiledClippingFrame.height))
        self.inputField.placeholder = "Message"
        self.inputField.animateHeightChange = false
        self.inputField.animationDuration = 0
        self.inputField.font = .systemFont(ofSize: 16)
        self.inputField.backgroundColor = .clear
        self.inputField.isOpaque = false
        self.inputField.clipsToBounds = true
        self.inputField.internalTextView.backgroundColor = UIColor.clear
        self.inputField.internalTextView.isOpaque = false
        self.inputField.internalTextView.contentMode = .left
        self.inputField.internalTextView.scrollIndicatorInsets = UIEdgeInsets(top: -self.inputFiledInternalEdgeInsets.top, left: 0, bottom: 5 - TGRetinaPixel, right: 0)

        self.sendButton = UIButton(type: .system)
        self.sendButton.isExclusiveTouch = true
        self.sendButton.setAttributedTitle(NSAttributedString(string: "Send", attributes: [NSForegroundColorAttributeName: Theme.tintColor, NSFontAttributeName: Theme.semibold(size: 16)]), for: .normal)
        self.sendButton.setAttributedTitle(NSAttributedString(string: "Send", attributes: [NSForegroundColorAttributeName: Theme.greyTextColor, NSFontAttributeName: Theme.semibold(size: 16)]), for: .disabled)
        self.sendButton.titleLabel?.font = UIFont.systemFont(ofSize: 17)
        self.sendButton.isEnabled = false
        self.sendButton.isHidden = true

        self.attachButton = UIButton(type: .system)
        self.attachButton.isExclusiveTouch = true
        self.attachButton.setImage(#imageLiteral(resourceName: "TGAttachButton"), for: .normal)

        super.init(frame: frame)

        self.addSubview(self.backgroundView)
        self.layer.addSublayer(self.stripeLayer)
        self.addSubview(self.fieldBackground)
        self.addSubview(self.inputFieldClippingContainer)

        self.inputField.maxNumberOfLines = self.maxNumberOfLines(forSize: self.parentSize)
        self.inputField.delegate = self
        self.inputFieldClippingContainer.addSubview(self.inputField)

        self.sendButton.addTarget(self, action: #selector(didTapSendButton(_:)), for: .touchUpInside)

        self.addSubview(self.sendButton)
        self.addSubview(self.attachButton)
    }

    required init?(coder _: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    override func becomeFirstResponder() -> Bool {
        return self.inputField.internalTextView.becomeFirstResponder()
    }

    override func resignFirstResponder() -> Bool {
        return self.inputField.internalTextView.resignFirstResponder()
    }

    override var canBecomeFirstResponder: Bool {
        return true
    }

    override func layoutSubviews() {
        super.layoutSubviews()

        self.backgroundView.frame = self.bounds

        self.stripeLayer.frame = CGRect(x: 0, y: -TGRetinaPixel, width: self.bounds.width, height: TGRetinaPixel)

        self.fieldBackground.frame = CGRect(x: self.inputFiledInsets.left, y: self.inputFiledInsets.top, width: self.bounds.width - self.inputFiledInsets.left - self.inputFiledInsets.right - self.currentSendButtonWidth - 1, height: self.bounds.height - self.inputFiledInsets.top - self.inputFiledInsets.bottom)

        self.inputFieldClippingContainer.frame = fieldBackground.frame

        self.sendButton.frame = CGRect(x: self.bounds.width - self.sendButtonWidth, y: self.bounds.height - self.baseHeight, width: self.sendButtonWidth, height: self.baseHeight)

        self.attachButton.frame = CGRect(x: 0, y: self.bounds.height - self.baseHeight, width: 40, height: self.baseHeight)
    }

    override func endInputting(_: Bool) {
        if self.inputField.internalTextView.isFirstResponder {
            self.inputField.internalTextView.resignFirstResponder()
        }
    }

    override func adjust(for size: CGSize, keyboardHeight: CGFloat, duration: TimeInterval, animationCurve: Int32) {
        let previousSize = self.parentSize
        self.parentSize = size

        if abs(size.width - previousSize.width) > TG_EPSILON {
            change(to: size, keyboardHeight: keyboardHeight, duration: 0)
        }

        adjust(for: size, keyboardHeight: keyboardHeight, inputFiledHeight: self.inputField.frame.height, duration: duration, animationCurve: animationCurve)
    }

    override func change(to size: CGSize, keyboardHeight: CGFloat, duration: TimeInterval) {
        self.parentSize = size

        let messageAreaSize = size

        self.messageAreaSize = messageAreaSize
        self.keyboardHeight = keyboardHeight

        var inputFieldSnapshotView: UIView?
        if duration > DBL_EPSILON {
            inputFieldSnapshotView = self.inputField.internalTextView.snapshotView(afterScreenUpdates: false)
            if let v = inputFieldSnapshotView {
                v.frame = self.inputField.frame.offsetBy(dx: self.inputFieldClippingContainer.frame.origin.x, dy: self.inputFieldClippingContainer.frame.origin.y)

                self.addSubview(v)
            }
        }

        UIView.performWithoutAnimation {
            self.updateInputFiledLayout()
        }

        let inputContainerHeight = self.heightForInputFieldHeight(self.inputField.frame.size.height)
        let newInputContainerFrame = CGRect(x: 0, y: messageAreaSize.height - keyboardHeight - inputContainerHeight, width: messageAreaSize.width, height: inputContainerHeight)

        if duration > DBL_EPSILON {
            if inputFieldSnapshotView != nil {
                self.inputField.alpha = 0
            }

            UIView.animate(withDuration: duration, animations: {
                self.frame = newInputContainerFrame
                self.layoutSubviews()

                if let v = inputFieldSnapshotView {
                    self.inputField.alpha = 1
                    v.frame = self.inputField.frame.offsetBy(dx: self.inputFieldClippingContainer.frame.origin.x, dy: self.inputFieldClippingContainer.frame.origin.y)
                    v.alpha = 0
                }
            }, completion: { _ in
                inputFieldSnapshotView?.removeFromSuperview()
            })
        } else {
            self.frame = newInputContainerFrame
        }
    }

    func toggleSendButtonEnabled() {
        let hasText = self.inputField.internalTextView.hasText
        let wasHidden = self.sendButton.isHidden

        // We check if button state changed as well as if we have text to
        // set the new alpha. This makes it so that it only hides if it will re-appear
        self.sendButton.alpha = (hasText == wasHidden && hasText) ? 0 : 1
        self.sendButton.isHidden = !hasText
        self.sendButton.isEnabled = hasText

        if hasText == wasHidden {
            UIView.animate(withDuration: 0.15, animations: {
                self.layoutSubviews()
            }, completion: { _ in
                UIView.animate(withDuration: 0.15) {
                    self.sendButton.alpha = hasText ? 1 : 0
                }
            })
        }
    }

    func clearInputField() {
        self.inputField.internalTextView.text = nil
        self.inputField.refreshHeight()

        self.toggleSendButtonEnabled()
    }

    func growingTextView(_: HPGrowingTextView!, willChangeHeight height: Float) {
        let inputContainerHeight = self.heightForInputFieldHeight(CGFloat(height))

        let y = self.messageAreaSize == .zero ? self.frame.origin.y - (inputContainerHeight - self.frame.height) : self.messageAreaSize.height - self.keyboardHeight - inputContainerHeight
        let width = self.messageAreaSize == .zero ? self.frame.width : self.messageAreaSize.width

        let newInputContainerFrame = CGRect(x: 0, y: y, width: width, height: inputContainerHeight)

        UIView.animate(withDuration: 0.3) {
            self.frame = newInputContainerFrame
            self.layoutSubviews()
        }

        self.delegate?.inputPanel(self, willChangeHeight: inputContainerHeight, duration: 0.3, animationCurve: 0)
    }

    func growingTextViewDidChange(_: HPGrowingTextView!) {
        self.toggleSendButtonEnabled()
    }

    func didTapSendButton(_: UIButton) {
        // Resign and become first responder to accept auto-correct suggestions
        self.inputField.internalTextView.resignFirstResponder()
        self.inputField.internalTextView.becomeFirstResponder()

        guard let text = self.inputField.internalTextView.text else {
            return
        }

        let str = text.trimmingCharacters(in: CharacterSet.whitespacesAndNewlines)
        if str.characters.count > 0 {
            if let d = self.delegate as? ChatInputTextPanelDelegate {
                d.inputTextPanel(self, requestSendText: str)
            }

            self.clearInputField()
        }
    }

    private func adjust(for size: CGSize, keyboardHeight: CGFloat, inputFiledHeight: CGFloat, duration: TimeInterval, animationCurve: Int32) {
        let block = {
            let messageAreaSize = size

            self.messageAreaSize = messageAreaSize
            self.keyboardHeight = keyboardHeight

            let inputContainerHeight = self.heightForInputFieldHeight(inputFiledHeight)
            self.frame = CGRect(x: 0, y: messageAreaSize.height - keyboardHeight - inputContainerHeight, width: self.messageAreaSize.width, height: inputContainerHeight)
            self.layoutSubviews()
        }

        if duration > DBL_EPSILON {
            UIView.animate(withDuration: duration, delay: 0, options: UIViewAnimationOptions(rawValue: UInt(animationCurve << 16)), animations: block, completion: nil)
        } else {
            block()
        }
    }

    private func heightForInputFieldHeight(_ inputFiledHeight: CGFloat) -> CGFloat {
        return max(self.baseHeight, inputFiledHeight - 10 + self.inputFiledInsets.top + self.inputFiledInsets.bottom)
    }

    private func updateInputFiledLayout() {
        let range = self.inputField.internalTextView.selectedRange

        self.inputField.delegate = nil

        let inputFiledInsets = self.inputFiledInsets
        let inputFiledInternalEdgeInsets = self.inputFiledInternalEdgeInsets

        let inputFiledClippingFrame = CGRect(x: inputFiledInsets.left, y: inputFiledInsets.top, width: self.parentSize.width - inputFiledInsets.left - inputFiledInsets.right - self.currentSendButtonWidth - 1, height: 0)

        let inputFieldFrame = CGRect(x: inputFiledInternalEdgeInsets.left, y: inputFiledInternalEdgeInsets.top, width: inputFiledClippingFrame.width - inputFiledInternalEdgeInsets.left, height: 0)

        self.inputField.frame = inputFieldFrame
        self.inputField.internalTextView.frame = CGRect(x: 0, y: 0, width: inputFieldFrame.width, height: inputFieldFrame.height)
        self.fieldBackground.frame = CGRect(x: 41, y: 9, width: self.frame.width - 41 - self.currentSendButtonWidth - 1, height: 31)

        self.inputField.maxNumberOfLines = self.maxNumberOfLines(forSize: parentSize)
        self.inputField.refreshHeight()

        self.inputField.internalTextView.selectedRange = range

        self.inputField.delegate = self
    }

    private func maxNumberOfLines(forSize size: CGSize) -> Int32 {
        if size.height <= 320 {
            return 3
        } else if size.height <= 480 {
            return 5
        } else {
            return 7
        }
    }
}
