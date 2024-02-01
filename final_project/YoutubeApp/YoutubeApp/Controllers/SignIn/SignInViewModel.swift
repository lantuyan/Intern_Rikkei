//
//  SignInViewModel.swift
//  YoutubeApp
//
//  Created by Admin on 24/01/2024.
//

import Foundation
import UIKit
class SignInViewModel {
    func loadMyChannel(completion: @escaping Completion) {
        APIManager.Channel.getMyChannelInfo() { result in
            switch result {
            case .failure(let error):
                completion(false, error.localizedDescription)
            case .success(let channelResult):
                let channel = channelResult.channel
                DataManager.shared().saveChannelToUserDefaults(channel: channel)
                completion(true,"")
            }
        }
    }
}
