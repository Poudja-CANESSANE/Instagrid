//
//  ViewController.swift
//  Instagrid
//
//  Created by Canessane Poudja on 02/03/2020.
//  Copyright © 2020 Canessane Poudja. All rights reserved.
//

import UIKit

class PhotoGridViewController: UIViewController {
    
// MARK: - INTERNAL
    
// MARK: Properties
    
    @IBOutlet weak var photoGridView: UIView!
    @IBOutlet weak var topStackView: UIStackView!
    @IBOutlet weak var bottomStackView: UIStackView!
    @IBOutlet weak var swipeToShareLabel: UILabel!
    @IBOutlet weak var arrowImageView: UIImageView!
    
// MARK: Methods
    
    ///It builds the chosen photoLayout in the photoGridView when the user tap on one of the layout button (those at the bottom of the screen)
    @IBAction func didTapOnLayoutButton(sender: UIButton) {
        let photoLayout = sender.tag == 3 ?
            photoLayoutProvider.getRandomPhotoLayout() :
            photoLayoutProvider.photoLayouts[sender.tag]
        
        setupLayout(from: photoLayout)
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        setupSwipeToShare()
        
    }
    
    override func traitCollectionDidChange(_ previousTraitCollection: UITraitCollection?) {
        super.traitCollectionDidChange(previousTraitCollection)
        guard let windowInterfaceOrientation = windowInterfaceOrientation else { return }
        swipeGestureRecognizer.direction = windowInterfaceOrientation.isLandscape ? .left : .up
        swipeToShareLabel.text = windowInterfaceOrientation.isLandscape ? "Swipe left to share" : "Swipe up to share"
        arrowImageView.image = windowInterfaceOrientation.isLandscape ? UIImage(named: "Arrow Left") : UIImage(named: "Arrow Up")
        
    }
    
// MARK: - PRIVATE
    
// MARK: Properties
    
    private let photoLayoutProvider = PhotoLayoutProvider()
    private var currentPhotoButton: UIButton?
    private var swipeGestureRecognizer: UISwipeGestureRecognizer!
    
    ///Interface orientation
    private var windowInterfaceOrientation: UIInterfaceOrientation? {
        return UIApplication.shared.windows.first?.windowScene?.interfaceOrientation
    }
    
// MARK: Methods
    
// MARK: Handle photoGridView Layout
    
    ///It clears the photoGridView and adds the correct quantity of UIButton in the topStackView and the bottomStackView
    private func setupLayout(from photoLayout: PhotoLayout) {
        resetLayout()
        
        addPhotoButtons(stackView: topStackView, quantity: photoLayout.topPhotoCount)
        addPhotoButtons(stackView: bottomStackView, quantity: photoLayout.bottomPhotoCount)
    }
    
    ///It clears the topStackView and the bottomStackView
    private func resetLayout() {
        reset(stackView: topStackView)
        reset(stackView: bottomStackView)
    }
    
    ///It clears a UIStackView
    private func reset(stackView: UIStackView) {
        for subview in stackView.arrangedSubviews {
            stackView.removeArrangedSubview(subview)
        }
    }
    
    ///It adds the given quantity of UIButton in a UIStackView
    private func addPhotoButtons(stackView: UIStackView, quantity: Int) {
        for _ in 1...quantity {
            let photoButton = UIButton()
            photoButton.backgroundColor = UIColor.white
            photoButton.setImage(UIImage(named: "Plus"), for: .normal)
            photoButton.addTarget(self, action: #selector(onPhotoButtonTapped), for: .touchUpInside)
            stackView.addArrangedSubview(photoButton)
        }
    }
    
    ///The user can choose a photo from his photo library when he has tapped on a photo button (those in the photoGridView)
    @objc private func onPhotoButtonTapped(from button: UIButton) {
        currentPhotoButton = button
        
        let imagePickerController = UIImagePickerController()
        imagePickerController.delegate = self
        imagePickerController.sourceType = .photoLibrary
        self.present(imagePickerController, animated: true)
    }
    
// MARK: Handle Swipe
    
    ///It adds to the view a UISwipeGestureRecognizer
    private func setupSwipeToShare() {
        swipeGestureRecognizer = UISwipeGestureRecognizer(target: self, action: #selector(didSwipeToShare))
        swipeGestureRecognizer.numberOfTouchesRequired = 1
        view.addGestureRecognizer(swipeGestureRecognizer)
        
    }
    
    ///It presents a UIActivityViewController when the user has swipped. An animation occurs before and after this.
    @objc private func didSwipeToShare() {
        UIView.animate(withDuration: 0.3, delay: 0, options: .curveEaseOut, animations: {
            self.setupViewsToAnimateOnSwipe()
        }) { (_) in
            
            let activityController = UIActivityViewController(activityItems: [self.convertPhotoGridViewAsImage()], applicationActivities: nil)
            
            self.present(activityController, animated: true)
            activityController.completionWithItemsHandler = {
                (activityType: UIActivity.ActivityType?, completed: Bool, returnedItems: [Any]?, error: Error?) in
                
                UIView.animate(withDuration: 0.3, delay: 0, options: .curveEaseOut, animations: {
                    self.setupViewsToAnimateOnCompletionOfActivityViewController()
                })
            }
        }
    }
    
    ///It converts the photoGridView into an image
    private func convertPhotoGridViewAsImage() -> UIImage {
        let renderer = UIGraphicsImageRenderer(bounds: photoGridView.bounds)
        return renderer.image { photoGridView.layer.render(in: $0.cgContext) }
    }
    
// MARK: Handle Animations
    
    ///The photoGridView, swipeToShareLabel and arrowImageView will transform according to the interface orientation and their alpha will be set to 0
    private func setupViewsToAnimateOnSwipe() {
        setupViewToAnimateOnSwipeAccordingToInterfaceOrientation(photoGridView)
        setupViewToAnimateOnSwipeAccordingToInterfaceOrientation(swipeToShareLabel)
        setupViewToAnimateOnSwipeAccordingToInterfaceOrientation(arrowImageView)
    }
    
    ///It transforms a UIView and sets its alpha to 0 according to the interface orientation
    private func setupViewToAnimateOnSwipeAccordingToInterfaceOrientation(_ view: UIView) {
        guard let windowInterfaceOrientation = windowInterfaceOrientation else { return }
        view.transform = windowInterfaceOrientation.isPortrait ?
        CGAffineTransform(translationX: 0, y: -30) :
        CGAffineTransform(translationX: -30, y: 0)
        view.alpha = 0
    }
    
    ///The photoGridView, swipeToShareLabel and arrowImageView will transform to .identity and their alpha will be set to 1
    private func setupViewsToAnimateOnCompletionOfActivityViewController() {
        setupViewToAnimateOnCompletionOfActivityViewController(photoGridView)
        setupViewToAnimateOnCompletionOfActivityViewController(swipeToShareLabel)
        setupViewToAnimateOnCompletionOfActivityViewController(arrowImageView)
    }
    
    ///It transforms a UIView to .identity and sets its alpha to 1
    private func setupViewToAnimateOnCompletionOfActivityViewController(_ view: UIView) {
        view.transform = .identity
        view.alpha = 1
    }
}

// MARK: - EXTENSIONS

extension PhotoGridViewController: UIImagePickerControllerDelegate {
    
    ///It sets the currentPhotoButton's image with the chosen image by the user
    func imagePickerController(_ picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [UIImagePickerController.InfoKey : Any]) {
        
        guard
            let image = info[UIImagePickerController.InfoKey.originalImage] as? UIImage,
            let currentPhotoButton = currentPhotoButton
            else { return }
        
        currentPhotoButton.setImage(image, for: .normal)
        currentPhotoButton.imageView?.contentMode = .scaleAspectFill
        
        picker.dismiss(animated: true, completion: nil)
    }
    
    
    func imagePickerControllerDidCancel(_ picker: UIImagePickerController) {
        picker.dismiss(animated: true, completion: nil)
    }
}

extension PhotoGridViewController: UINavigationControllerDelegate { }
