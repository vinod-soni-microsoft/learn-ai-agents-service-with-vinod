// API configuration utility
declare global {
  interface Window {
    ENV?: {
      API_BASE_URL?: string;
      ENVIRONMENT?: string;
    };
  }
}

export const getApiBaseUrl = (): string => {
  // Check if running in development
  if (import.meta.env.DEV) {
    return import.meta.env.VITE_API_BASE_URL || 'http://localhost:50505';
  }
  
  // Production: use environment config injected at runtime
  return window.ENV?.API_BASE_URL || '';
};

export const apiConfig = {
  baseUrl: getApiBaseUrl(),
  headers: {
    'Content-Type': 'application/json',
  },
  credentials: 'include' as RequestCredentials,
};

// API utility function
export const apiCall = async (endpoint: string, options: RequestInit = {}) => {
  const url = `${apiConfig.baseUrl}${endpoint}`;
  
  const response = await fetch(url, {
    ...options,
    headers: {
      ...apiConfig.headers,
      ...options.headers,
    },
    credentials: apiConfig.credentials,
  });

  if (!response.ok) {
    throw new Error(`API call failed: ${response.status} ${response.statusText}`);
  }

  return response;
};
