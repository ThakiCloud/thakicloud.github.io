// Language dropdown toggle functionality
document.addEventListener('DOMContentLoaded', function() {
  const dropdownToggles = document.querySelectorAll('.dropdown-toggle');
  
  dropdownToggles.forEach(function(toggle) {
    toggle.addEventListener('click', function(e) {
      e.preventDefault();
      e.stopPropagation();
      
      const dropdown = this.nextElementSibling;
      const isVisible = dropdown.classList.contains('show');
      
      // Close all other dropdowns
      document.querySelectorAll('.dropdown-menu').forEach(function(menu) {
        menu.style.display = 'none';
        menu.classList.remove('show');
      });
      
      // Toggle current dropdown with animation
      if (!isVisible) {
        dropdown.style.display = 'block';
        // Force reflow for animation
        dropdown.offsetHeight;
        dropdown.classList.add('show');
      }
    });
  });
  
  // Close dropdown when clicking outside
  document.addEventListener('click', function() {
    document.querySelectorAll('.dropdown-menu').forEach(function(menu) {
      menu.classList.remove('show');
      // Hide after animation completes
      setTimeout(function() {
        if (!menu.classList.contains('show')) {
          menu.style.display = 'none';
        }
      }, 200);
    });
  });
  
  // Prevent dropdown from closing when clicking inside
  document.querySelectorAll('.dropdown-menu').forEach(function(menu) {
    menu.addEventListener('click', function(e) {
      e.stopPropagation();
    });
  });
});
