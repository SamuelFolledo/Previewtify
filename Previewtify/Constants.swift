//
//  Constants.swift
//  Previewtify
//
//  Created by Samuel Folledo on 9/14/20.
//  Copyright © 2020 SamuelFolledo. All rights reserved.
//

import Foundation

let accessTokenKey = "access-token-key"
let redirectUri = URL(string:"previewtify://")!
let spotifyClientId = "e9d953c9eff4433cb30acf3e4866a68d"
let spotifyClientSecretKey = "e891fd17090d4841afaf88c5730419a9"

/*
Scopes let you specify exactly what types of data your application wants to
access, and the set of scopes you pass in your call determines what access
permissions the user is asked to grant.
For more information, see https://developer.spotify.com/web-api/using-scopes/.
*/
let scope: SPTScope = [.appRemoteControl, .playlistReadPrivate]

let scopes: SPTScope = [.appRemoteControl, .playlistReadPrivate, .streaming, .userReadPlaybackState, .userModifyPlaybackState, .userReadCurrentlyPlaying, .userReadRecentlyPlayed, .userReadPrivate, .userTopRead, .userReadPrivate, .userReadEmail, .userLibraryRead]
