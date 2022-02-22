//
//  ErrorMessage.swift
//  GithubSearchClone
//
//  Created by 박승태 on 2022/02/21.
//

import Foundation

struct ErrorMessage {
    
    static let login: String                 = "로그인이 필요합니다."
    static let requireLogin: String          = "로그인 후 이용해주세요."
    static let resultEmpty: String           = "검색 결과가 없습니다."
    static let registerInterestRepo: String  = "관심 있는 저장소를 등록해주세요."
    static let failedRemoveStar              = "스타 해제에 실패했습니다. \n다시 시도해주세요."
    
    static let notAllowedPage: String        = "해당 페이지에 접근이 허용되지 않았습니다."
    static let defaultAPIFailed: String      = "예기치 못한 오류가 발생했습니다. \n잠시 후 다시 시도해주세요."
    static let defaultAPIServer: String      = "일시적으로 이용이 불가능합니다. \n잠시 후 다시 시도해주세요."
}
