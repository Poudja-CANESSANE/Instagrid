//
//  ViewController.swift
//  Instagrid
//
//  Created by Canessane Poudja on 02/03/2020.
//  Copyright © 2020 Canessane Poudja. All rights reserved.
//

import UIKit

class PhotoGridViewController: UIViewController {
    
    
    
    @IBOutlet weak var gridView: UIView!
    @IBOutlet weak var topStackView: UIStackView!
    @IBOutlet weak var bottomStackView: UIStackView!
    @IBOutlet weak var swipeToShareLabel: UILabel!
    @IBOutlet weak var arrowImageView: UIImageView!
    
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
    /// Interface orientation
    private var windowInterfaceOrientation: UIInterfaceOrientation? {
        return UIApplication.shared.windows.first?.windowScene?.interfaceOrientation
    }
    
    
    override func traitCollectionDidChange(_ previousTraitCollection: UITraitCollection?) {
        super.traitCollectionDidChange(previousTraitCollection)
        swipeGestureRecognizer.direction = interfaceOrientation.isLandscape ? .left : .up
        swipeToShareLabel.text = interfaceOrientation.isLandscape ? "Swipe left to share" : "Swipe up to share"
        arrowImageView.image = interfaceOrientation.isLandscape ? UIImage(named: "Arrow Left") : UIImage(named: "Arrow Up")
        
    }
    
    
    private let photoLayoutProvider = PhotoLayoutProvider()
    private var currentPhotoButton: UIButton?
    private var swipeGestureRecognizer: UISwipeGestureRecognizer!
    
    private func setupLayout(from photoLayout: PhotoLayout) {
        resetLayout()
        
        addPhotoButtons(stackView: topStackView, quantity: photoLayout.topPhotoCount)
        addPhotoButtons(stackView: bottomStackView, quantity: photoLayout.bottomPhotoCount)
    }
    
    private func resetLayout() {
        reset(stackView: topStackView)
        reset(stackView: bottomStackView)
    }
    
    private func reset(stackView: UIStackView) {
        for subview in stackView.arrangedSubviews {
            stackView.removeArrangedSubview(subview)
        }
    }
    
    private func addPhotoButtons(stackView: UIStackView, quantity: Int) {
        for _ in 1...quantity {
            let photoButton = UIButton()
            photoButton.backgroundColor = UIColor.white
            photoButton.setImage(UIImage(named: "Plus"), for: .normal)
            photoButton.addTarget(self, action: #selector(onPhotoButtonTapped), for: .touchUpInside)
            stackView.addArrangedSubview(photoButton)
        }
    }
    
    @objc private func onPhotoButtonTapped(from button: UIButton) {
        currentPhotoButton = button
        
        let imagePickerController = UIImagePickerController()
        imagePickerController.delegate = self
        imagePickerController.sourceType = .photoLibrary
        self.present(imagePickerController, animated: true, completion: nil)
    }
    
    
    private func setupSwipeToShare() {
        swipeGestureRecognizer = UISwipeGestureRecognizer(target: self, action: #selector(didSwipeToShare))
        swipeGestureRecognizer.numberOfTouchesRequired = 1
        view.addGestureRecognizer(swipeGestureRecognizer)
        
    }
    
    
    @objc private func didSwipeToShare() {
        UIView.animate(withDuration: 0.3, delay: 0, options: .curveEaseOut, animations: {
            self.setupViewsToAnimateOnSwipe()
        }) { (_) in
            
            let activityController = UIActivityViewController(activityItems: [self.convertGridViewAsImage()], applicationActivities: nil)
            
            self.present(activityController, animated: true)
            activityController.completionWithItemsHandler = {
                (activityType: UIActivity.ActivityType?, completed: Bool, returnedItems: [Any]?, error: Error?) in
                
                UIView.animate(withDuration: 0.3, delay: 0, options: .curveEaseOut, animations: {
                    self.setupViewsToAnimateOnCompletionOfActivityViewController()
                })
            }
        }
    }
    
    
    private func setupViewsToAnimateOnSwipe() {
        setupViewToAnimateOnSwipe(gridView)
        setupViewToAnimateOnSwipe(swipeToShareLabel)
        setupViewToAnimateOnSwipe(arrowImageView)
    }
    
    
    private func setupViewToAnimateOnSwipe(_ view: UIView) {
        view.transform = interfaceOrientation.isPortrait ?
        CGAffineTransform(translationX: 0, y: -30) :
        CGAffineTransform(translationX: -30, y: 0)
        view.alpha = 0
    }
    
    
    private func setupViewsToAnimateOnCompletionOfActivityViewController() {
        setupViewToAnimateOnCompletionOfActivityViewController(gridView)
        setupViewToAnimateOnCompletionOfActivityViewController(swipeToShareLabel)
        setupViewToAnimateOnCompletionOfActivityViewController(arrowImageView)
    }
    
    
    private func setupViewToAnimateOnCompletionOfActivityViewController(_ view: UIView) {
        view.transform = .identity
        view.alpha = 1
    }
    
    
    private func convertGridViewAsImage() -> UIImage {
        let renderer = UIGraphicsImageRenderer(bounds: gridView.bounds)
        return renderer.image { gridView.layer.render(in: $0.cgContext) }
    }
    
}


extension PhotoGridViewController: UIImagePickerControllerDelegate {
    
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
