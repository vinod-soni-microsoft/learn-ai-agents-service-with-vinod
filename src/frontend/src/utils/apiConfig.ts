// API configuration utility for frontend
// Handles both direct FastAPI access and APIM gateway routing

/**
 * Get the base URL for API calls
 * When APIM is enabled, use the APIM gateway URL
 * Otherwise, use relative URLs (current behavior)
 */
export function getApiBaseUrl(): string {
  // Check if APIM is enabled via environment variable
  const useApim = import.meta.env.VITE_USE_APIM === 'true';
  const apimBaseUrl = import.meta.env.VITE_API_BASE_URL;
  
  if (useApim && apimBaseUrl) {
    // Use APIM gateway URL
    return apimBaseUrl;
  }
  
  // Default to relative URLs (works for both direct access and when served through APIM)
  return '';
}

/**
 * Construct full API URL for a given endpoint
 * @param endpoint - API endpoint path (e.g., '/chat', '/agent')
 * @returns Full URL for the API call
 */
export function getApiUrl(endpoint: string): string {
  const baseUrl = getApiBaseUrl();
  
  // Ensure endpoint starts with /
  const normalizedEndpoint = endpoint.startsWith('/') ? endpoint : `/${endpoint}`;
  
  if (baseUrl) {
    // Remove trailing slash from base URL if present
    const normalizedBaseUrl = baseUrl.endsWith('/') ? baseUrl.slice(0, -1) : baseUrl;
    return `${normalizedBaseUrl}/api${normalizedEndpoint}`;
  }
  
  // Relative URL - works when frontend is served from the same origin as API
  return `/api${normalizedEndpoint}`;
}

/**
 * Enhanced fetch wrapper that uses the configured API base URL
 * @param endpoint - API endpoint path
 * @param options - Fetch options
 * @returns Promise with fetch response
 */
export async function apiFetch(endpoint: string, options: RequestInit = {}): Promise<Response> {
  const url = getApiUrl(endpoint);
  
  // Default headers
  const defaultHeaders: HeadersInit = {
    'Content-Type': 'application/json',
  };
  
  // Merge with provided headers
  const headers = {
    ...defaultHeaders,
    ...(options.headers || {}),
  };
  
  return fetch(url, {
    ...options,
    headers,
  });
}

/**
 * Configuration info for debugging
 */
export function getApiConfig() {
  return {
    useApim: import.meta.env.VITE_USE_APIM === 'true',
    apimBaseUrl: import.meta.env.VITE_API_BASE_URL,
    baseUrl: getApiBaseUrl(),
    environment: import.meta.env.MODE,
  };
}
