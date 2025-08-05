/// <reference types="vite/client" />

interface ImportMetaEnv {
  readonly VITE_USE_APIM: string
  readonly VITE_API_BASE_URL: string
  readonly VITE_FASTAPI_URL: string
  readonly MODE: string
  readonly BASE_URL: string
  readonly PROD: boolean
  readonly DEV: boolean
  readonly SSR: boolean
}

interface ImportMeta {
  readonly env: ImportMetaEnv
}
