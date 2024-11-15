class HangulHelper {
  static const List<String> _cho = [
    'ㄱ', 'ㄲ', 'ㄴ', 'ㄷ', 'ㄸ', 'ㄹ', 'ㅁ', 'ㅂ', 'ㅃ', 
    'ㅅ', 'ㅆ', 'ㅇ', 'ㅈ', 'ㅉ', 'ㅊ', 'ㅋ', 'ㅌ', 'ㅍ', 'ㅎ'
  ];

  static String getChoseong(String text) {
    StringBuffer result = StringBuffer();
    
    for (int i = 0; i < text.length; i++) {
      int code = text.codeUnitAt(i);
      if (code >= 0xAC00 && code <= 0xD7A3) {
        int cho = ((code - 0xAC00) / 28 / 21).floor();
        result.write(_cho[cho]);
      }
    }
    
    return result.toString();
  }

  static bool matchesSearch(String text, String query) {
    if (query.isEmpty) return true;
    
    // 검색어와 대상 텍스트를 소문자로 변환
    text = text.toLowerCase();
    query = query.toLowerCase();
    
    // 일반 검색 (영문, 한글 모두)
    if (text.contains(query)) return true;
    
    // 한글 초성 검색 (query가 한글 자음으로만 이루어진 경우)
    if (RegExp(r'^[ㄱ-ㅎ]+$').hasMatch(query)) {
      String textChoseong = getChoseong(text);
      return textChoseong.contains(query);
    }
    
    return false;
  }
} 