// Content script for EZProxy Web Extension
// Handles in-page navigation to preserve browser history

// Listen for messages from the background script
browser.runtime.onMessage.addListener((request, sender, sendResponse) => {
  if (request.action === 'redirectToProxy') {
    // Use location.assign() to preserve browser history
    // This allows users to use the back button
    window.location.assign(request.proxyURL);
    sendResponse({ success: true });
  }
});

// Optional: Add visual indicator when on a proxied page
// This helps users know when they're accessing resources through the proxy
const currentURL = window.location.href;
if (currentURL.includes('.ezproxy.') || currentURL.includes('go.openathens.net')) {
  // Add a subtle indicator that the page is proxied
  const indicator = document.createElement('div');
  indicator.id = 'ezproxy-indicator';
  indicator.textContent = '🔐 Proxied';
  indicator.style.cssText = `
    position: fixed;
    bottom: 10px;
    right: 10px;
    background: rgba(0, 128, 0, 0.9);
    color: white;
    padding: 5px 10px;
    border-radius: 5px;
    font-size: 12px;
    z-index: 10000;
    pointer-events: none;
    font-family: -apple-system, BlinkMacSystemFont, 'Segoe UI', Roboto, sans-serif;
  `;
  
  // Add to page after DOM is ready
  if (document.readyState === 'loading') {
    document.addEventListener('DOMContentLoaded', () => {
      document.body.appendChild(indicator);
    });
  } else {
    document.body.appendChild(indicator);
  }
  
  // Auto-hide after 3 seconds
  setTimeout(() => {
    if (indicator && indicator.parentNode) {
      indicator.style.opacity = '0';
      indicator.style.transition = 'opacity 0.5s';
      setTimeout(() => {
        if (indicator.parentNode) {
          indicator.parentNode.removeChild(indicator);
        }
      }, 500);
    }
  }, 3000);
}