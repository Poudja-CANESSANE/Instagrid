//
//  ViewController.swift
//  Instagrid
//
//  Created by Canessane Poudja on 02/03/2020.
//  Copyright © 2020 Canessane Poudja. All rights reserved.
//

import UIKit
import Photos

class PhotoGridViewController: UIViewController {
    
    // MARK: - INTERNAL
    
    // MARK: Properties
    
    @IBOutlet weak var photoGridView: UIView!
    @IBOutlet weak var topStackView: UIStackView!
    @IBOutlet weak var bottomStackView: UIStackView!
    @IBOutlet weak var swipeToShareLabel: UILabel!
    @IBOutlet weak var arrowImageView: UIImageView!
    
    @IBOutlet var layoutButtons: [UIButton]!
    
    // MARK: Methods
    
    ///It builds the chosen photoLayout in the photoGridView when the user tap on one of the layout button (those at the bottom of the screen) and updates the 4 layout buttons background image
    @IBAction func didTapOnLayoutButton(sender: UIButton) {
        let photoLayout = sender.tag == 3 ?
            photoLayoutProvider.getRandomPhotoLayout() :
            photoLayoutProvider.photoLayouts[sender.tag]
        
        setupLayout(from: photoLayout)
        setupLayoutButtonsBackgroundImage(sender)
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        setupSwipeToShare()
    }
    
    override func viewWillTransition(to size: CGSize, with coordinator: UIViewControllerTransitionCoordinator) {
        super.viewWillTransition(to: size, with: coordinator)
        
        coordinator.animate(alongsideTransition: { (_) in
            self.setupSwipeToShareViewsAccordingToInterfaceOrientation()
        })
    }
    
    // MARK: - PRIVATE
    
    // MARK: Properties
    
    private let photoLayoutProvider = PhotoLayoutProvider()
    private var swipeGestureRecognizer: UISwipeGestureRecognizer?
    
    ///This is the photo button tapped by the user
    private var currentPhotoButton: UIButton?
    
    ///Interface orientation
    private var windowInterfaceOrientation: UIInterfaceOrientation? {
        if #available(iOS 13, *) {
            return UIApplication.shared.windows.first?.windowScene?.interfaceOrientation
        } else {
            return UIApplication.shared.statusBarOrientation
        }
    }
    
    ///To know if there is at least 1 photo source available either photo library or camera
    private var isOnePhotoSourceAvailable: Bool {
        UIImagePickerController.isSourceTypeAvailable(.photoLibrary) ||
            UIImagePickerController.isSourceTypeAvailable(.camera)
    }
    
    ///This array contains the views to animate on swipe and on the completion of UIActivityViewController
    private var viewsToAnimate: [UIView] {
        [photoGridView, swipeToShareLabel, arrowImageView]
    }
    
    // MARK: Methods
    
    // MARK: Handle Interface Orientation
    
    ///It sets the swipeGestureRecognizer's direction, swipeToShareLabel's text and arrowImageView's image according to the interface orientation
    private func setupSwipeToShareViewsAccordingToInterfaceOrientation() {
        guard
            let windowInterfaceOrientation = windowInterfaceOrientation,
            let swipeGestureRecognizer = swipeGestureRecognizer else { return }
        
        swipeGestureRecognizer.direction = windowInterfaceOrientation.isLandscape ?
            .left :
            .up
        
        swipeToShareLabel.text = windowInterfaceOrientation.isLandscape ?
            "Swipe left to share" : "Swipe up to share"
        
        arrowImageView.image = windowInterfaceOrientation.isLandscape ?
            UIImage(named: "Arrow Left") :
            UIImage(named: "Arrow Up")
    }
    
    // MARK: Handle Layout Buttons
    
    ///It sets the tapped layout button background image to selected and the other layout buttons to .none
    private func setupLayoutButtonsBackgroundImage(_ sender: UIButton) {
        layoutButtons.forEach { $0.setBackgroundImage(.none, for: .normal) }
        
        let layoutButtonToSelect = layoutButtons[sender.tag]
        layoutButtonToSelect.setBackgroundImage(UIImage(named: "Selected"), for: .normal)
    }
    
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
        stackView.arrangedSubviews.forEach { $0.removeFromSuperview() }
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
    
    ///The user can choose a photo from his photo library or take a photo with his camera when he has tapped on a photo button (those in the photoGridView)
    @objc private func onPhotoButtonTapped(from button: UIButton) {
        guard isOnePhotoSourceAvailable else {
            presentSourcesNotAvailableAlert()
            return
        }
        
        currentPhotoButton = button
        presentSourcesChoiceAlert()
    }
    
    //MARK: Handle Alerts and ImagePickerController
    
    ///It presents an alert telling that any photo sources are available
    private func presentSourcesNotAvailableAlert() {
        let alertController = UIAlertController(
            title: "Photo Sources Unavailable",
            message: "Your device doesn't support any photo sources",
            preferredStyle: .alert)
        
        let confirmAlertAction = UIAlertAction(
            title: "Okay",
            style: .default)
        
        alertController.addAction(confirmAlertAction)
        
        present(alertController, animated: true)
    }
    
    ///It presents an alert asking the user to choose a photo source: photo library or camera
    private func presentSourcesChoiceAlert() {
        
        let alertController = UIAlertController(
            title: "Choose a source",
            message: nil,
            preferredStyle: .actionSheet)
        
        if UIImagePickerController.isSourceTypeAvailable(.photoLibrary) {
            let photoAlertAction = UIAlertAction(
                title: "Photo Library",
                style: .default,
                handler: photoAlertHandler(alertAction:))
            
            alertController.addAction(photoAlertAction)
        }
        
        if UIImagePickerController.isSourceTypeAvailable(.camera) {
            let cameraAlertAction = UIAlertAction(
                title: "Camera",
                style: .default,
                handler: cameraAlertHandler(alertAction:))
            
            alertController.addAction(cameraAlertAction)
        }
        
        present(alertController, animated: true)
    }
    
    ///It presents a UIImagePickerController with .photoLibrary as source type
    private func photoAlertHandler(alertAction: UIAlertAction) {
        presentImagePickerController(from: .photoLibrary)
    }
    
    ///It presents a UIImagePickerController with .camera as source type
    private func cameraAlertHandler(alertAction: UIAlertAction) {
        presentImagePickerController(from: .camera)
    }
    
    ///It presents a UIImagePickerController with the correct source type
    private func presentImagePickerController(from source: UIImagePickerController.SourceType) {
        let imagePickerController = UIImagePickerController()
        imagePickerController.delegate = self
        imagePickerController.sourceType = source
        present(imagePickerController, animated: true)
    }
    
    // MARK: Handle Swipe
    
    ///It adds to the view a UISwipeGestureRecognizer
    private func setupSwipeToShare() {
        swipeGestureRecognizer = UISwipeGestureRecognizer(
            target: self,
            action: #selector(didSwipeToShare))
        
        setupSwipeToShareViewsAccordingToInterfaceOrientation()
        
        guard let swipeGestureRecognizer = swipeGestureRecognizer else { return }
        
        view.addGestureRecognizer(swipeGestureRecognizer)
    }
    
    ///It presents a UIActivityViewController when the user has swipped. An animation occurs before and after this.
    @objc private func didSwipeToShare() {
        let activityController = UIActivityViewController(
            activityItems: [convertPhotoGridViewAsImage()],
            applicationActivities: nil)
        
        UIView.animate(
            withDuration: 0.3,
            delay: 0,
            options: .curveEaseOut,
            animations: setupViewsToAnimateOnSwipe,
            completion: { (_) in
                self.present(activityController, animated: true)
        })
        
        activityController.completionWithItemsHandler = { (_, _, _, _) in
            UIView.animate(
                withDuration: 0.3,
                delay: 0,
                options: .curveEaseOut,
                animations: {
                    self.setupViewsToAnimateOnCompletionOfActivityViewController()
            })
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
        viewsToAnimate.forEach { setupViewToAnimateOnSwipeAccordingToInterfaceOrientation($0) }
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
        viewsToAnimate.forEach { setupViewToAnimateOnCompletionOfActivityViewController($0) }
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
        
        picker.dismiss(animated: true)
    }
}

extension PhotoGridViewController: UINavigationControllerDelegate { }
