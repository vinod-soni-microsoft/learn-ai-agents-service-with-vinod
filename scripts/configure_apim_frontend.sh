#!/bin/bash

# Script to configure frontend to use APIM gateway URLs when APIM is enabled
# This script reads APIM configuration from azd environment and updates frontend accordingly

set -e

echo "🔧 Configuring frontend for APIM integration..."

# Check if azd is available
if ! command -v azd &> /dev/null; then
    echo "❌ Azure Developer CLI (azd) is not installed or not in PATH"
    exit 1
fi

# Get current directory
SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
PROJECT_ROOT="$(dirname "$SCRIPT_DIR")"

# Read environment variables from azd
echo "📖 Reading APIM configuration from azd environment..."

# Check if APIM is enabled
ENABLE_APIM=$(azd env get-values | grep "ENABLE_APIM" | cut -d'=' -f2 | tr -d '"' || echo "false")

if [ "$ENABLE_APIM" != "true" ]; then
    echo "ℹ️  APIM is not enabled. Frontend will use direct FastAPI URLs."
    echo "   To enable APIM, run: azd env set ENABLE_APIM true"
    exit 0
fi

echo "✅ APIM is enabled. Configuring frontend to use APIM gateway..."

# Try to get APIM gateway URL from deployment outputs
echo "🔍 Looking for APIM gateway URL..."

# Check if there's a deployment to get outputs from
if ! azd env get-values | grep -q "SERVICE_API_URI"; then
    echo "⚠️  No deployment found. Please run 'azd up' first to deploy the infrastructure."
    exit 1
fi

# Get APIM gateway URL (this would be available after deployment)
# For now, we'll construct it based on the expected pattern
RESOURCE_GROUP=$(azd env get-values | grep "AZURE_RESOURCE_GROUP" | cut -d'=' -f2 | tr -d '"')
SUBSCRIPTION_ID=$(azd env get-values | grep "AZURE_SUBSCRIPTION_ID" | cut -d'=' -f2 | tr -d '"')
ENV_NAME=$(azd env get-values | grep "AZURE_ENV_NAME" | cut -d'=' -f2 | tr -d '"')
LOCATION=$(azd env get-values | grep "AZURE_LOCATION" | cut -d'=' -f2 | tr -d '"')

if [ -z "$RESOURCE_GROUP" ] || [ -z "$ENV_NAME" ] || [ -z "$LOCATION" ]; then
    echo "❌ Required environment variables not found. Please ensure azd is properly configured."
    exit 1
fi

# Generate the expected APIM service name (matches the pattern in main.bicep)
# In production, you would get this from deployment outputs:
# APIM_GATEWAY_URL=$(azd env get-values | grep "APIM_GATEWAY_URL" | cut -d'=' -f2 | tr -d '"')

# For now, construct based on the expected naming pattern
RESOURCE_TOKEN=$(echo "$SUBSCRIPTION_ID$ENV_NAME$LOCATION" | sha256sum | cut -c1-13)
APIM_NAME="apim-$RESOURCE_TOKEN"
APIM_GATEWAY_URL="https://$APIM_NAME.azure-api.net"

echo "📍 Expected APIM Gateway URL: $APIM_GATEWAY_URL"
echo "ℹ️  Note: After deployment, verify the actual URL with: azd env get-values | grep APIM"

# Frontend configuration file
FRONTEND_DIR="$PROJECT_ROOT/src/frontend"
ENV_FILE="$FRONTEND_DIR/.env.local"

# Create or update frontend environment file
echo "📝 Creating frontend environment configuration..."

cat > "$ENV_FILE" << EOF
# Frontend configuration for APIM integration
# Generated automatically by configure_apim_frontend.sh

# APIM Gateway URL
VITE_API_BASE_URL=$APIM_GATEWAY_URL

# Enable APIM mode
VITE_USE_APIM=true

# Original FastAPI URL (for fallback)
VITE_FASTAPI_URL=\${SERVICE_API_URI:-}
EOF

echo "✅ Created $ENV_FILE"

# Check if we need to update any hardcoded API URLs in the frontend code
echo "🔍 Checking frontend code for hardcoded API URLs..."

# Look for common API call patterns in frontend code
if find "$FRONTEND_DIR" -name "*.ts" -o -name "*.tsx" -o -name "*.js" -o -name "*.jsx" | xargs grep -l "fetch.*api\|axios.*api" > /dev/null 2>&1; then
    echo "⚠️  Found potential hardcoded API URLs in frontend code."
    echo "   Please ensure your frontend code uses the VITE_API_BASE_URL environment variable."
    echo "   Example:"
    echo "   const API_BASE_URL = import.meta.env.VITE_API_BASE_URL || window.location.origin;"
    echo "   fetch(\`\${API_BASE_URL}/api/chat\`, ...)"
fi

# Check if frontend build is needed
if [ -d "$FRONTEND_DIR/dist" ]; then
    echo "🔄 Frontend dist directory exists. Consider rebuilding for updated configuration."
    echo "   Run: cd $FRONTEND_DIR && npm run build"
fi

echo ""
echo "🎉 Frontend APIM configuration completed!"
echo ""
echo "Next steps:"
echo "1. Deploy the infrastructure with APIM enabled:"
echo "   azd up"
echo ""
echo "2. Verify the APIM gateway URL after deployment:"
echo "   azd env get-values | grep APIM"
echo ""
echo "3. Test the frontend through APIM:"
echo "   Open the application and verify API calls go through APIM"
echo ""
echo "📚 For more information, see: docs/apim_integration.md"
