//
//  AuthenticationManager.swift
//  XCE-FACTOR
//
//  Created by Антон Шуплецов on 22.11.2020.
//  Copyright © 2020 Владислав. All rights reserved.
//

protocol AuthenticationManagerProtocol {

    typealias Complition = (AuthenticationManager.ResultDefault) -> Void
    
    /// Отправить код подтверждения на email
    /// - Parameter email: Почта пользователя
    func sendEmail(email: String)

    /// Начать процесс авторизации
    /// - Parameters:
    ///   - email: Почта пользователя
    ///   - password: Пароль пользователя
    ///   - completion: Комплишн завершения операции
    func startAuthentication(with email: String,
                             _ password: String,
                             completion: @escaping Complition)

    /// Зарегистрировать пользователя
    /// - Parameters:
    ///   - userAuthModel: Модель данных пользователя
    ///   - completion: Комплишн завершения операции
    func registerUser(with userAuthModel: UserAuthModel, completion: @escaping Complition)
    
    /// Восстановить пароль
    /// - Parameters:
    ///   - email: Почту, на которую нужно отправить забытый пароль
    ///   - completion: Комплишн завершения операции
    func resetPassword(email: String, completion: @escaping (Result<Bool, NetworkErrors>) -> Void)
}

/// Менеджер отвечает за логику авторизации/регистрации/подтверждения клиента
final class AuthenticationManager {

    // MARK: - Private Properties

    private let authenticationService: AuthenticationServiceProtocol
    private let registrationService: RegistrationServiceProtocol
    private let sendEmailService: SendEmailServiceProtocol
    private let resetPasswordService: ResetPasswordServiceProtocol

    private struct Path {
        static let basePath = "/api/auth"
    }

    enum ResultDefault {
        case success
        case failure(_ error: NetworkErrors)
    }

    // MARK: - Init

    init(networkClient: NetworkClientProtocol) {
        authenticationService = AuthenticationService(networkClient: networkClient, basePath: Path.basePath)
        registrationService = RegistrationService(networkClient: networkClient, basePath: Path.basePath)
        sendEmailService = SendEmailService(networkClient: networkClient, basePath: Path.basePath)
        resetPasswordService = ResetPasswordService(networkClient: networkClient, basePath: Path.basePath)
    }
}

// MARK: - Authentication Manager Protocol

extension AuthenticationManager: AuthenticationManagerProtocol {

    func startAuthentication(with email: String, _ password: String, completion: @escaping Complition) {
        let credentials = Credentials(email: email, password: password)
        authenticationService.startAuthorization(requestModel: credentials) { result in
            switch result {
            case .success(let tokenModel):
                guard !tokenModel.confirmationRequired else {
                    print("Error: User email is not confirmed")
                    completion(.failure(NetworkErrors.unconfirmed))
                    return
                }
                
                guard let token = tokenModel.token else {
                    print("Wrong email or password")
                    completion(.failure(NetworkErrors.wrondCredentials))
                    return
                }

                /// Saving to Globals and Defaults
                Globals.user.token = "Bearer \(token)"
                Globals.user.email = email
                Defaults.save(token: Globals.user.token, email: Globals.user.email)
                print("   success with token \(token)")

                completion(.success)
            case .failure(let error):
                completion(.failure(error))
            }
        }
    }

    func registerUser(with userAuthModel: UserAuthModel, completion: @escaping Complition) {
        registrationService.registerNewUser(requestModel: userAuthModel) { [weak self] result in
            guard let self = self else { return }
        
            switch result {
            case .failure:
                completion(.failure(NetworkErrors.default))
            case .success(let isAccountExist):
                guard isAccountExist else {
                    completion(.failure(NetworkErrors.userExists))
                    return
                }

                Globals.user.email = userAuthModel.email
                self.startAuthentication(with: userAuthModel.email, userAuthModel.password, completion: completion)
            }
        }
    }

    func sendEmail(email: String = Globals.user.email) {
        sendEmailService.send(email: email) { result in
            print("sent with result: \(result)")
        }
    }

    func resetPassword(email: String, completion: @escaping (Result<Bool, NetworkErrors>) -> Void) {
        resetPasswordService.resetPassword(email: email) { result in
            switch result {
            case .failure:
                completion(.failure(NetworkErrors.default))
            case .success(let isResetSuccess):
                completion(.success(isResetSuccess))
            }
        }
    }
}
