//
//  SpotifyAuth.swift
//  Previewtify
//
//  Created by Samuel Folledo on 9/18/20.
//  Copyright © 2020 SamuelFolledo. All rights reserved.
//

import Foundation

struct SpotifyAuth {
    public let tokenType: String //Bearer
    public let refreshToken: String
    public let accessToken: String
    public let expiresIn: Int
    public let scope: String
}

extension SpotifyAuth: Codable { }
