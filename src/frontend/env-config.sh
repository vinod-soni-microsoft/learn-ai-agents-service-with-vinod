#!/bin/sh

# Environment configuration for React frontend
# This script creates a config.js file with environment variables at runtime

cat <<EOF > /usr/share/nginx/html/config.js
window.ENV = {
  API_BASE_URL: "${API_BASE_URL:-}",
  ENVIRONMENT: "${ENVIRONMENT:-production}"
};
EOF

echo "Environment configuration created:"
cat /usr/share/nginx/html/config.js
