//
//  AuthManager.swift
//  Spotify
//
//  Created by Anthony Kim on 3/15/21.
//

import Foundation
// responsible for user is signed in, sign in

final class AuthManager {
    // Spotify uses OAuth2 Standard
    // getting access token on behalf of user and the token expires after certain number of times
    // so you also need to get a refresh token,
    // tokens also have scope. (permission to do xyz)
    
    static let shared = AuthManager()
    
    private var refreshingToken = false
    
    struct Constants {
        static let clientID = "a64e5ce183cb40aaacd59824b2da3e86"
        static let clientSecret = "4a79a7fd2e4e48419e116af058568930" // normally want to keep it on backend server for security
        static let tokenAPIURL = "https://accounts.spotify.com/api/token"
        static let redirectURI = "https://www.iosacademy.io"
        static let scopes = "user-read-private%20playlist-modify-public%20playlist-read-private%20playlist-modify-private%20user-library-modify%20user-library-read%20user-read-email"
    }
    
    private init() {}
    
    public var signInURL: URL? {
        let base = "https://accounts.spotify.com/authorize"
        let string = "\(base)?response_type=code&client_id=\(Constants.clientID)&scope=\(Constants.scopes)&redirect_uri=\(Constants.redirectURI)&show_dialog=TRUE"
        return URL(string: string)
    }
    
    var isSignedIn: Bool {
        return accessToken != nil // if its not equal to nil we know that the user is signed in
    }
    
    private var accessToken: String? {
        return UserDefaults.standard.string(forKey: "access_token")
    }
    
    private var refreshToken: String? {
        return UserDefaults.standard.string(forKey: "refresh_token")
    }
    
    private var tokenExpirationDate: Date? {
        return UserDefaults.standard.object(forKey: "expirationDate") as? Date
    }
    
    private var shouldRefreshToken: Bool {
        // want to refresh when we have couple minute left for that token to be valid
        guard let expirationDate = tokenExpirationDate else {
            return false
        }
        let currentDate = Date()
        let fiveMinutes: TimeInterval = 300
        return currentDate.addingTimeInterval(fiveMinutes) >= expirationDate
    }
    
    public func exchangeCodeForToken(code: String, completion: @escaping ((Bool) -> Void))
    {
        // completion handler to let caller know that it succeeded
        // Get Token
        guard let url = URL(string: Constants.tokenAPIURL) else {
            return
        }
        
        var components = URLComponents()
        components.queryItems = [
            URLQueryItem(name: "grant_type", value: "authorization_code"),
            URLQueryItem(name: "code", value: code),
            URLQueryItem(name: "redirect_uri", value: Constants.redirectURI),
            
        ]
        
        var request = URLRequest(url: url)
        request.httpMethod = "POST"
        request.setValue("application/x-www-form-urlencoded", forHTTPHeaderField: "Content-Type")
        request.httpBody = components.query?.data(using: .utf8)
        
        let basicToken = Constants.clientID+":"+Constants.clientSecret
        let data = basicToken.data(using: .utf8)
        guard let base64String = data?.base64EncodedString() else {
            completion(false)
            print("Failure to get base64")
            return
            
        }
        request.setValue("Basic \(base64String)", forHTTPHeaderField: "Authorization")
        
        let task = URLSession.shared.dataTask(with: request) { [weak self] data, _, error in
            guard let data = data, error == nil else {
                completion(false)
                return
            }
            // convert data into json
            do {
//                let json = try JSONSerialization.jsonObject(with: data,
//                                                            options: .allowFragments)
                let result = try JSONDecoder().decode(AuthReponse.self, from: data)
                // now cache
                self?.cacheToken(result: result)
//                print("SUCCESS: \(json)")
                completion(true)
            } catch {
                print(error.localizedDescription)
                completion(false)
            }
        }
        task.resume()
        
        
    }
    
    private var onRefreshBlocks = [((String) -> Void)]() //array of escaping closures
    
    /// Supplies valid token to be used with API calls
    public func withValidToken(completion: @escaping (String) -> Void) {
        guard !refreshingToken else {
            // Append the completion
            onRefreshBlocks.append(completion)
            return
        }
        
        if shouldRefreshToken {
            // Refresh
            refreshIfNeeded { [weak self] success in
                    if let token = self?.accessToken, success {
                        completion(token)
                    }
                }
            }
            else if let token = accessToken{
            completion(token)
        }
    }
    
    public func refreshIfNeeded(completion: ((Bool) -> Void)?) {
        // whenever we make an API call, we are going to stay with the latest token and
        // we are going to check right before making any API call, make sure the token is in fact
        // the latest one.
        // dont want token to expire like 2 second after we make an API call.
        
        guard !refreshingToken else {
            return
        }
        
        guard shouldRefreshToken else {
            completion?(true)
            return
        }
        
        guard let refreshToken = self.refreshToken else {
            return
        }
        
        // Refresh the token
        guard let url = URL(string: Constants.tokenAPIURL) else {
            return
        }
        
        refreshingToken = true
        
        var components = URLComponents()
        components.queryItems = [
            URLQueryItem(name: "grant_type", value: "refresh_token"),
           
            URLQueryItem(name: "refresh_token", value: refreshToken),
            
        ]
        
        var request = URLRequest(url: url)
        request.httpMethod = "POST"
        request.setValue("application/x-www-form-urlencoded", forHTTPHeaderField: "Content-Type")
        request.httpBody = components.query?.data(using: .utf8)
        
        let basicToken = Constants.clientID+":"+Constants.clientSecret
        let data = basicToken.data(using: .utf8)
        guard let base64String = data?.base64EncodedString() else {
            completion?(false)
            print("Failure to get base64")
            return
            
        }
        request.setValue("Basic \(base64String)", forHTTPHeaderField: "Authorization")
        
        let task = URLSession.shared.dataTask(with: request) { [weak self] data, _, error in
            self?.refreshingToken = false
            guard let data = data, error == nil else {
                completion?(false)
                return
            }
            
            do {
//                let json = try JSONSerialization.jsonObject(with: data,
//                                                            options: .allowFragments)
                let result = try JSONDecoder().decode(AuthReponse.self, from: data)
                self?.onRefreshBlocks.forEach({ $0(result.access_token) })
                self?.onRefreshBlocks.removeAll() // we dont want to redundantly call blocks we saved
//                print("Successfully refreshed")
                // now cache
                self?.cacheToken(result: result)
//                print("SUCCESS: \(json)")
                completion?(true)
            } catch {
                print(error.localizedDescription)
                completion?(false)
            }
        }
        task.resume()
    }
    
    private func cacheToken(result: AuthReponse) {
        UserDefaults.standard.setValue(result.access_token, forKey: "access_token")
        if let refresh_token = result.refresh_token {
            UserDefaults.standard.setValue(refresh_token, forKey: "refresh_token")
        }
        
        UserDefaults.standard.setValue(Date().addingTimeInterval(TimeInterval(result.expires_in)), forKey: "expirationDate")
    }
    
    public func signOut(completion: (Bool) -> Void) {
        // nil out all the cached value we have
        UserDefaults.standard.setValue(nil, forKey: "access_token")
        UserDefaults.standard.setValue(nil, forKey: "refresh_token")
        UserDefaults.standard.setValue(nil, forKey: "expirationDate")
        completion(true)
    }
}

