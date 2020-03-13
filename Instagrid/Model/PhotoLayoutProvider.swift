//
//  PhotoLayoutProvider.swift
//  Instagrid
//
//  Created by Canessane Poudja on 07/03/2020.
//  Copyright © 2020 Canessane Poudja. All rights reserved.
//

import Foundation

struct PhotoLayoutProvider {
    
    let photoLayouts: [PhotoLayout] = [
        PhotoLayout(topPhotoCount: 1, bottomPhotoCount: 2),
        PhotoLayout(topPhotoCount: 2, bottomPhotoCount: 1),
        PhotoLayout(topPhotoCount: 2, bottomPhotoCount: 2)
    ]
    
    func getRandomPhotoLayout() -> PhotoLayout {
        PhotoLayout(topPhotoCount: Int.random(in: 1...3), bottomPhotoCount: Int.random(in: 1...3))
    }
}
