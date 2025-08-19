import React, { useState, useRef, useEffect } from 'react'

const App: React.FC = () => {
  const [selectedFile, setSelectedFile] = useState<File | null>(null)
  const [isLoading, setIsLoading] = useState(false)
  const [error, setError] = useState<string | null>(null)
  const [searchTerm, setSearchTerm] = useState('')
  const [currentPage, setCurrentPage] = useState(1)
  const [totalPages, setTotalPages] = useState(0)
  const [zoomLevel, setZoomLevel] = useState(100)
  
  const fileInputRef = useRef<HTMLInputElement>(null)
  const viewerRef = useRef<HTMLDivElement>(null)

  // 파일 선택 핸들러
  const handleFileChange = (event: React.ChangeEvent<HTMLInputElement>) => {
    const file = event.target.files?.[0]
    if (file && file.type === 'application/pdf') {
      setSelectedFile(file)
      setError(null)
      loadPDF(file)
    } else {
      setError('PDF 파일만 업로드 가능합니다.')
    }
  }

  // PDF 로드 함수 (실제 구현에서는 EmbedPDF API 사용)
  const loadPDF = async (file: File) => {
    setIsLoading(true)
    try {
      // 실제 EmbedPDF 로드 로직이 들어갈 부분
      // const viewer = new EmbedPDF(viewerRef.current, {
      //   file: file,
      //   plugins: ['annotations', 'search', 'zoom']
      // })
      
      // 데모용 시뮬레이션
      await new Promise(resolve => setTimeout(resolve, 1500))
      setTotalPages(10) // 데모용 페이지 수
      setCurrentPage(1)
      setIsLoading(false)
    } catch (err) {
      setError('PDF 로드 중 오류가 발생했습니다.')
      setIsLoading(false)
    }
  }

  // 페이지 네비게이션
  const goToPage = (page: number) => {
    if (page >= 1 && page <= totalPages) {
      setCurrentPage(page)
    }
  }

  // 줌 기능
  const handleZoom = (delta: number) => {
    const newZoom = Math.max(50, Math.min(200, zoomLevel + delta))
    setZoomLevel(newZoom)
  }

  // 검색 기능
  const handleSearch = () => {
    if (searchTerm.trim()) {
      console.log('검색어:', searchTerm)
      // 실제 구현에서는 EmbedPDF search API 사용
    }
  }

  return (
    <div className="app">
      <header className="header">
        <h1>🔗 EmbedPDF Tutorial</h1>
        <p>현대적이고 강력한 JavaScript PDF 뷰어</p>
      </header>

      <div className="demo-section">
        <h2>📄 PDF 파일 업로드</h2>
        <div className="file-input">
          <input
            ref={fileInputRef}
            type="file"
            accept=".pdf"
            onChange={handleFileChange}
          />
        </div>
        
        {error && (
          <div className="error">
            <strong>오류:</strong> {error}
          </div>
        )}

        {selectedFile && (
          <div className="info-box">
            <h3>선택된 파일</h3>
            <p><strong>파일명:</strong> {selectedFile.name}</p>
            <p><strong>크기:</strong> {(selectedFile.size / 1024 / 1024).toFixed(2)} MB</p>
          </div>
        )}
      </div>

      {selectedFile && (
        <div className="demo-section">
          <h2>🎮 PDF 뷰어 컨트롤</h2>
          
          {/* 검색 기능 */}
          <div className="search-container">
            <input
              type="text"
              placeholder="PDF 내용 검색..."
              value={searchTerm}
              onChange={(e) => setSearchTerm(e.target.value)}
              onKeyPress={(e) => e.key === 'Enter' && handleSearch()}
            />
            <button onClick={handleSearch}>검색</button>
          </div>

          {/* 컨트롤 버튼들 */}
          <div className="controls">
            <button 
              onClick={() => goToPage(currentPage - 1)}
              disabled={currentPage <= 1}
            >
              이전 페이지
            </button>
            <span>페이지 {currentPage} / {totalPages}</span>
            <button 
              onClick={() => goToPage(currentPage + 1)}
              disabled={currentPage >= totalPages}
            >
              다음 페이지
            </button>
            <button onClick={() => handleZoom(-25)}>축소</button>
            <span>{zoomLevel}%</span>
            <button onClick={() => handleZoom(25)}>확대</button>
            <button onClick={() => setZoomLevel(100)}>원본 크기</button>
          </div>

          {/* PDF 뷰어 영역 */}
          <div 
            ref={viewerRef} 
            className="pdf-viewer"
            style={isLoading ? undefined : {display: 'flex', alignItems: 'center', justifyContent: 'center', fontSize: '18px', color: '#666'}}
          >
            {isLoading ? (
              <div className="loading">
                <p>PDF 로딩 중...</p>
              </div>
            ) : (
              <div>
                <p>📋 실제 환경에서는 여기에 PDF가 렌더링됩니다</p>
                <p>현재 페이지: {currentPage}</p>
                <p>줌 레벨: {zoomLevel}%</p>
                {searchTerm && <p>검색어: "{searchTerm}"</p>}
              </div>
            )}
          </div>
        </div>
      )}

      <div className="demo-section">
        <h2>✨ EmbedPDF 주요 기능</h2>
        <div className="feature-grid">
          <div className="feature-card">
            <h3>🎯 프레임워크 무관</h3>
            <p>React, Vue, Svelte, Angular 또는 순수 JavaScript 어디서든 사용 가능</p>
          </div>
          <div className="feature-card">
            <h3>📝 풍부한 주석 기능</h3>
            <p>하이라이트, 스티키 노트, 자유 텍스트, 잉크 주석 지원</p>
          </div>
          <div className="feature-card">
            <h3>🔍 고급 검색</h3>
            <p>텍스트 선택, 검색, 줌, 회전 등 완전한 뷰어 기능</p>
          </div>
          <div className="feature-card">
            <h3>⚡ 고성능</h3>
            <p>가상화된 스크롤링으로 대용량 PDF도 부드럽게 처리</p>
          </div>
          <div className="feature-card">
            <h3>🔌 플러그인 아키텍처</h3>
            <p>필요한 기능만 로드하는 모듈형 구조</p>
          </div>
          <div className="feature-card">
            <h3>🛡️ 진정한 검열</h3>
            <p>내용을 실제로 제거하는 완전한 문서 보안</p>
          </div>
        </div>
      </div>
    </div>
  )
}

export default App
