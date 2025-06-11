module Jekyll
  module AdvancedSearchFilter
    def prepare_search_content(input)
      return '' if input.nil? || input.empty?
      
      # HTML 태그 제거
      content = input.gsub(/<[^>]*>/, '')
      
      # 특수 문자 정규화
      content = normalize_text(content)
      
      # 연속 공백을 단일 공백으로
      content = content.gsub(/\s+/, ' ')
      
      # 앞뒤 공백 제거
      content.strip
    end
    
    def normalize_text(input)
      return '' if input.nil?
      
      # 백슬래시 처리
      text = input.gsub('\\', '&#92;')
      
      # 탭을 공백으로 변환
      text = text.gsub(/\t/, ' ')
      
      # 제어 문자 제거 (유니코드 지원)
      text = text.gsub(/[\u0000-\u001F\u007F-\u009F]/, '')
      
      # 불필요한 특수문자 정리 (한글, 영문, 숫자, 기본 문장부호 유지)
      text = text.gsub(/[^\p{L}\p{N}\p{P}\p{Z}\p{S}&&[^\u0000-\u001F]]/, ' ')
      
      text
    end
    
    def create_search_index(content)
      return [] if content.nil? || content.empty?
      
      # 검색 가능한 토큰 생성
      tokens = []
      
      # 단어 단위 분할 (한글, 영문 지원)
      words = content.scan(/\p{L}+/)
      tokens.concat(words.map(&:downcase))
      
      # 한글의 경우 음절 단위 인덱싱도 추가
      korean_chars = content.scan(/[\p{Hangul}]/)
      tokens.concat(korean_chars.map(&:downcase))
      
      # 2-gram, 3-gram 생성 (부분 매칭 지원)
      if content.length >= 2
        (0..content.length-2).each do |i|
          gram2 = content[i, 2].downcase.strip
          tokens << gram2 if gram2.match(/\p{L}/)
        end
      end
      
      if content.length >= 3
        (0..content.length-3).each do |i|
          gram3 = content[i, 3].downcase.strip
          tokens << gram3 if gram3.match(/\p{L}/)
        end
      end
      
      tokens.uniq.compact.reject(&:empty?)
    end
    
    def search_score(content, query)
      return 0 if content.nil? || query.nil? || content.empty? || query.empty?
      
      normalized_content = normalize_text(content).downcase
      normalized_query = normalize_text(query).downcase
      
      score = 0
      
      # 완전 일치 (가장 높은 점수)
      if normalized_content.include?(normalized_query)
        score += 100
      end
      
      # 단어 단위 매칭
      query_words = normalized_query.scan(/\p{L}+/)
      content_words = normalized_content.scan(/\p{L}+/)
      
      query_words.each do |word|
        content_words.each do |content_word|
          if content_word == word
            score += 50
          elsif content_word.include?(word)
            score += 25
          elsif word.length >= 2 && content_word.include?(word[0, 2])
            score += 10
          end
        end
      end
      
      # 문자 단위 매칭 (한글 지원)
      query.each_char do |char|
        next unless char.match(/\p{L}/)
        score += 5 if normalized_content.include?(char.downcase)
      end
      
      score
    end
    
    def highlight_matches(content, query)
      return content if query.nil? || query.empty?
      
      highlighted = content.dup
      normalized_query = normalize_text(query)
      
      # 완전 매칭 하이라이트
      highlighted = highlighted.gsub(
        /(#{Regexp.escape(normalized_query)})/i,
        '<mark>\1</mark>'
      )
      
      # 단어 단위 하이라이트
      query_words = normalized_query.scan(/\p{L}+/)
      query_words.each do |word|
        next if word.length < 2
        highlighted = highlighted.gsub(
          /(#{Regexp.escape(word)})/i,
          '<mark>\1</mark>'
        )
      end
      
      highlighted
    end
    
    def extract_snippet(content, query, length = 200)
      return content[0, length] if query.nil? || query.empty?
      
      normalized_content = normalize_text(content)
      normalized_query = normalize_text(query)
      
      # 쿼리가 포함된 위치 찾기
      match_pos = normalized_content.downcase.index(normalized_query.downcase)
      
      if match_pos
        # 매칭 위치 주변으로 스니펫 생성
        start_pos = [match_pos - length/4, 0].max
        snippet = content[start_pos, length]
        
        # 단어 경계에서 자르기
        if start_pos > 0 && snippet.match(/^\S/)
          snippet = snippet.sub(/^\S*\s/, '...')
        end
        
        if snippet.length >= length && !snippet.match(/\s$/)
          snippet = snippet.sub(/\s\S*$/, '...')
        end
        
        snippet
      else
        content[0, length]
      end
    end
    
    # 검색 결과 필터링
    def filter_search_results(posts, query, limit = 20)
      return [] if query.nil? || query.strip.empty?
      
      results = []
      
      posts.each do |post|
        # 제목, 내용, 태그, 카테고리에서 검색
        title_score = search_score(post['title'], query)
        content_score = search_score(post['content'], query)
        tags_score = post['tags'] ? search_score(post['tags'].join(' '), query) : 0
        categories_score = post['categories'] ? search_score(post['categories'].join(' '), query) : 0
        
        total_score = title_score * 3 + content_score + tags_score * 2 + categories_score * 2
        
        if total_score > 0
          results << {
            'post' => post,
            'score' => total_score,
            'title_highlighted' => highlight_matches(post['title'] || '', query),
            'snippet' => extract_snippet(post['content'] || '', query),
            'snippet_highlighted' => highlight_matches(extract_snippet(post['content'] || '', query), query)
          }
        end
      end
      
      # 점수순으로 정렬하고 제한
      results.sort_by { |result| -result['score'] }.first(limit)
    end
    
    # 구버전 호환성 유지
    def remove_chars(input)
      prepare_search_content(input)
    end
  end
end

Liquid::Template.register_filter(Jekyll::AdvancedSearchFilter)

# String 클래스 확장 (구버전 호환성)
class String
  def strip_control_and_extended_characters
    # 유니코드 지원 버전으로 개선
    chars.each_with_object("") do |char, str|
      # 제어 문자가 아닌 모든 유니코드 문자 허용
      str << char unless char.ord.between?(0, 31) || char.ord.between?(127, 159)
    end
  end
end