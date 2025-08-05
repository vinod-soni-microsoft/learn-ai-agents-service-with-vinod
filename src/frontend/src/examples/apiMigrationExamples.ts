// Example: How to update frontend components to use APIM-aware API calls
// This file demonstrates the changes needed to support both direct and APIM routing

import { apiFetch, getApiUrl, getApiConfig } from '../utils/apiConfig';

// Example 1: Simple API call update
// BEFORE:
/*
const response = await fetch("/agent", {
  method: "GET",
  headers: {
    "Content-Type": "application/json",
  },
});
*/

// AFTER:
async function fetchAgentDetails() {
  const response = await apiFetch("/agent", {
    method: "GET",
  });
  
  if (!response.ok) {
    throw new Error(`Failed to fetch agent details: ${response.status}`);
  }
  
  return response.json();
}

// Example 2: Chat API call update
// BEFORE:
/*
const response = await fetch("/chat", {
  method: "POST",
  headers: {
    "Content-Type": "application/json",
  },
  body: JSON.stringify(postData),
  credentials: "include",
});
*/

// AFTER:
async function sendChatMessage(message: string) {
  const postData = { message };
  
  const response = await apiFetch("/chat", {
    method: "POST",
    body: JSON.stringify(postData),
    credentials: "include",
  });
  
  if (!response.ok) {
    throw new Error(`Chat request failed: ${response.status}`);
  }
  
  return response;
}

// Example 3: Chat history API call update
// BEFORE:
/*
const response = await fetch("/chat/history", {
  method: "GET",
  headers: {
    "Content-Type": "application/json",
  },
  credentials: "include",
});
*/

// AFTER:
async function loadChatHistory() {
  const response = await apiFetch("/chat/history", {
    method: "GET",
    credentials: "include",
  });
  
  if (!response.ok) {
    throw new Error(`Failed to load chat history: ${response.status}`);
  }
  
  return response.json();
}

// Example 4: Azure config API call update
// BEFORE:
/*
const response = await fetch("/config/azure");
*/

// AFTER:
async function fetchAzureConfig() {
  const response = await apiFetch("/config/azure");
  
  if (!response.ok) {
    throw new Error(`Failed to fetch Azure config: ${response.status}`);
  }
  
  return response.json();
}

// Example 5: Using getApiUrl directly if you need the URL
function getDownloadUrl(fileId: string) {
  return getApiUrl(`/download/${fileId}`);
}

// Example 6: Debug configuration (useful for troubleshooting)
function debugApiConfiguration() {
  const config = getApiConfig();
  console.log('API Configuration:', config);
  
  // Example output:
  // {
  //   useApim: true,
  //   apimBaseUrl: "https://apim-abc123.azure-api.net",
  //   baseUrl: "https://apim-abc123.azure-api.net",
  //   environment: "production"
  // }
}

// Migration steps for existing components:
// 
// 1. Import the API utilities:
//    import { apiFetch, getApiUrl, getApiConfig } from '../utils/apiConfig';
//
// 2. Replace direct fetch calls:
//    - fetch("/endpoint", options) → apiFetch("/endpoint", options)
//    - fetch(`/api/${endpoint}`, options) → apiFetch(`/${endpoint}`, options)
//
// 3. Remove manual Content-Type headers (handled automatically):
//    - Remove: headers: { "Content-Type": "application/json" }
//
// 4. Test both modes:
//    - VITE_USE_APIM=false (direct mode) 
//    - VITE_USE_APIM=true (APIM mode)

export {
  fetchAgentDetails,
  sendChatMessage,
  loadChatHistory,
  fetchAzureConfig,
  getDownloadUrl,
  debugApiConfiguration,
};
