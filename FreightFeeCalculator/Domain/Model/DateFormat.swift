//
//  DateFormat.swift
//  FreightFeeCalculator
//
//  Created by Swain Yun on 7/19/25.
//

import Foundation

/// 날짜, 시간 표현 방식
enum DateFormat: String {
    /// 년.월.일
    case yyyyMMdd = "yyyy.MM.dd"
    
    /// 년-월-일
    case yyyyMMddHyphen = "yyyy-MM-dd"
    
    /// 년월일 (구분자 없음)
    case yyyyMMddRaw
    
    /// 한국어 년월일 (yyyy년 MM월 dd일)
    case yyyyMMddKorean = "yyyy년 MM월 dd일"
    
    /// 한국어 년월일 (yyyy년 M월 d일)
    case yyyyMdKorean = "yyyy년 M월 d일"
    
    /// 한국어 월일 (MM월 dd일)
    case MMddKorean = "MM월 dd일"
    
    /// 한국어 월일 (M월 d일)
    case MdKorean = "M월 d일"
    
    /// 년.월
    case yyyyMM = "yyyy.MM"
    
    /// 한국어 년월 (yyyy년 MM월)
    case yyyyMMKorean = "yyyy년 MM월"
    
    /// 월.일
    case MMdd = "MM.dd"
    
    /// 한국어 월일 요일 (MM월 dd일(EE))
    case MMddEEKorean = "MM월 dd일(EE)"
    
    /// 일
    case d = "d"
    
    /// 년.월.일 시:분:초
    case dateTime = "yyyy.MM.dd HH:mm:ss"
    
    /// 년.월.일 시:분
    case yyyyMMddHHmm = "yyyy.MM.dd HH:mm"
    
    /// 년.월.일 오전/오후 시(12)
    case yyyyMMddah = "yyyy.MM.dd a h시"
    
    /// 년.월.일 오전/오후 시:분
    case yyyyMMddahhmm = "yyyy.MM.dd a hh:mm"
    
    /// 년.월.일 오전/오후 시(24):분
    case yyyyMMddaHHmm = "yyyy.MM.dd a HH:mm"
    
    /// 시:분:초
    case HHmmss = "HH:mm:ss"
    
    /// 시:분
    case HHmm = "HH:mm"
    
    /// 오전/오후 시:분
    case ahhmm = "a hh:mm"
    
    /// 오전/오후 시
    /// - Note: 시 단위가 0으로 시작하지 않음
    case ah = "a h"
    
    /// 오전/오후 시:분
    /// - Note: 시 단위가 0으로 시작하지 않음
    case ahmm = "a h:mm"
    
    /// 축약 요일 (월, 화)
    case ee = "EE"
    
    /// 서버 날짜, 시간 (년-월-일'시각구분'시:분:초)
    case serverDateTime1 = "yyyy-MM-dd'T'HH:mm:ss"
    
    /// 서버 날짜, 시간 (년-월-일 시:분:초)
    case serverDateTime2 = "yyyy-MM-dd HH:mm:ss"
    
    /// 서버 날짜, 시간 밀리초 (년-월-일 시:분:초.밀리초)
    case serverDateTimeWithMS = "yyyy-MM-dd HH:mm:ss.SSSSS"
}
