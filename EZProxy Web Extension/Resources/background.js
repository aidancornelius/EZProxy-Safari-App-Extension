// Background script for EZProxy Web Extension
// Handles toolbar button clicks and proxy redirection

// Default settings
const defaultSettings = {
  proxyBase: 'proxy.slsa.sa.gov.au',
  useSSL: false,
  keepTab: true,
  useOpenAthens: false,
  useContentScript: false
};

// Load settings from storage
async function getSettings() {
  try {
    const result = await browser.storage.local.get('settings');
    return result.settings || defaultSettings;
  } catch (error) {
    console.error('Error loading settings:', error);
    return defaultSettings;
  }
}

// Save settings to storage
async function saveSettings(settings) {
  try {
    await browser.storage.local.set({ settings });
  } catch (error) {
    console.error('Error saving settings:', error);
  }
}

// Initialize settings on installation
browser.runtime.onInstalled.addListener(async () => {
  const existingSettings = await getSettings();
  if (!existingSettings || Object.keys(existingSettings).length === 0) {
    await saveSettings(defaultSettings);
  }
});

// Construct proxy URL based on settings
function constructProxyURL(originalURL, settings) {
  const url = new URL(originalURL);
  const host = url.hostname;
  const path = url.pathname;
  
  if (settings.useOpenAthens) {
    // OpenAthens URL format
    const encodedHost = encodeURIComponent(host);
    const encodedPath = encodeURIComponent(path);
    return `https://go.openathens.net/redirector/${settings.proxyBase}?url=http://${encodedHost}${encodedPath}`;
  } else {
    // EZProxy URL format
    const protocol = settings.useSSL ? 'https' : 'http';
    return `${protocol}://${settings.proxyBase}/login?url=http://${host}${path}`;
  }
}

// Handle toolbar button click
browser.action.onClicked.addListener(async (tab) => {
  try {
    const settings = await getSettings();
    
    if (!tab.url || tab.url.startsWith('about:') || tab.url.startsWith('chrome://')) {
      console.log('Cannot proxy special pages');
      return;
    }
    
    const proxyURL = constructProxyURL(tab.url, settings);
    
    if (settings.useContentScript) {
      // Use content script to navigate (preserves history)
      await browser.tabs.sendMessage(tab.id, {
        action: 'redirectToProxy',
        proxyURL: proxyURL
      });
    } else if (settings.keepTab) {
      // Open in new tab
      await browser.tabs.create({
        url: proxyURL,
        active: true,
        index: tab.index + 1
      });
    } else {
      // Replace current tab
      await browser.tabs.update(tab.id, {
        url: proxyURL
      });
    }
  } catch (error) {
    console.error('Error handling toolbar click:', error);
  }
});

// Handle messages from content script or native app
browser.runtime.onMessage.addListener((request, sender, sendResponse) => {
  if (request.action === 'getSettings') {
    getSettings().then(settings => {
      sendResponse(settings);
    });
    return true; // Will respond asynchronously
  } else if (request.action === 'saveSettings') {
    saveSettings(request.settings).then(() => {
      sendResponse({ success: true });
    });
    return true; // Will respond asynchronously
  }
});

// Handle native app connection for settings sync
let nativePort = null;

function connectToNativeApp() {
  try {
    nativePort = browser.runtime.connectNative('com.cornelius-bell.EZProxy');
    
    nativePort.onMessage.addListener(async (message) => {
      if (message.type === 'settingsUpdate') {
        await saveSettings(message.settings);
      }
    });
    
    nativePort.onDisconnect.addListener(() => {
      console.log('Native app disconnected');
      nativePort = null;
      // Try to reconnect after a delay
      setTimeout(connectToNativeApp, 5000);
    });
  } catch (error) {
    console.error('Error connecting to native app:', error);
  }
}

// Try to connect to native app on startup
connectToNativeApp();