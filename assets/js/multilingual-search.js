// Multilingual Search Enhancement
(function() {
  'use strict';

  // Detect current language from URL
  function getCurrentLanguage() {
    const path = window.location.pathname;
    if (path.startsWith('/ko/')) return 'ko';
    if (path.startsWith('/en/')) return 'en';
    if (path.startsWith('/ar/')) return 'ar';
    return 'ko'; // default
  }

  // Get search data URL based on language
  function getSearchDataUrl(lang) {
    const baseUrl = window.location.origin;
    switch(lang) {
      case 'ko': return `${baseUrl}/search-ko.json`;
      case 'en': return `${baseUrl}/search-en.json`;
      case 'ar': return `${baseUrl}/search-ar.json`;
      default: return `${baseUrl}/search.json`;
    }
  }

  // Language-specific search configuration
  const searchConfig = {
    ko: {
      placeholder: '검색어를 입력하세요...',
      noResults: '검색 결과가 없습니다.',
      searching: '검색 중...',
      resultsFound: '개 결과 발견'
    },
    en: {
      placeholder: 'Enter search terms...',
      noResults: 'No results found.',
      searching: 'Searching...',
      resultsFound: 'results found'
    },
    ar: {
      placeholder: 'أدخل مصطلحات البحث...',
      noResults: 'لم يتم العثور على نتائج.',
      searching: 'جاري البحث...',
      resultsFound: 'نتيجة موجودة'
    }
  };

  // Initialize multilingual search
  function initMultilingualSearch() {
    const currentLang = getCurrentLanguage();
    const config = searchConfig[currentLang];
    
    // Update search placeholder
    const searchInput = document.querySelector('#search-input, .search-input, input[type="search"]');
    if (searchInput && config) {
      searchInput.placeholder = config.placeholder;
    }

    // Override default search data URL if lunr search is used
    if (window.searchData) {
      window.searchData = getSearchDataUrl(currentLang);
    }

    // Add language-specific search enhancements
    enhanceSearchResults(currentLang, config);
  }

  // Enhance search results display
  function enhanceSearchResults(lang, config) {
    // Add language indicator to search results
    const observer = new MutationObserver(function(mutations) {
      mutations.forEach(function(mutation) {
        mutation.addedNodes.forEach(function(node) {
          if (node.nodeType === Node.ELEMENT_NODE) {
            const searchResults = node.querySelectorAll('.search-result, .list__item');
            searchResults.forEach(function(result) {
              if (!result.querySelector('.language-indicator')) {
                const langIndicator = document.createElement('span');
                langIndicator.className = 'language-indicator';
                langIndicator.textContent = lang.toUpperCase();
                langIndicator.style.cssText = `
                  display: inline-block;
                  background: #007bff;
                  color: white;
                  padding: 2px 6px;
                  border-radius: 3px;
                  font-size: 0.75em;
                  margin-left: 8px;
                  font-weight: bold;
                `;
                
                const title = result.querySelector('h2, h3, .archive__item-title');
                if (title) {
                  title.appendChild(langIndicator);
                }
              }
            });
          }
        });
      });
    });

    observer.observe(document.body, {
      childList: true,
      subtree: true
    });
  }

  // Language switcher enhancement
  function enhanceLanguageSwitcher() {
    const langSwitchers = document.querySelectorAll('a[href*="/ko/"], a[href*="/en/"], a[href*="/ar/"]');
    langSwitchers.forEach(function(link) {
      link.addEventListener('click', function(e) {
        // Store current search query if exists
        const searchInput = document.querySelector('#search-input, .search-input, input[type="search"]');
        if (searchInput && searchInput.value) {
          const query = searchInput.value;
          const targetUrl = new URL(link.href);
          targetUrl.searchParams.set('q', query);
          link.href = targetUrl.toString();
        }
      });
    });
  }

  // Auto-restore search query from URL parameter
  function restoreSearchQuery() {
    const urlParams = new URLSearchParams(window.location.search);
    const query = urlParams.get('q');
    if (query) {
      const searchInput = document.querySelector('#search-input, .search-input, input[type="search"]');
      if (searchInput) {
        searchInput.value = query;
        // Trigger search if search function exists
        if (typeof window.executeSearch === 'function') {
          window.executeSearch(query);
        }
      }
    }
  }

  // Initialize when DOM is ready
  if (document.readyState === 'loading') {
    document.addEventListener('DOMContentLoaded', function() {
      initMultilingualSearch();
      enhanceLanguageSwitcher();
      restoreSearchQuery();
    });
  } else {
    initMultilingualSearch();
    enhanceLanguageSwitcher();
    restoreSearchQuery();
  }

})();
