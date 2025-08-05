# Azure API Management (APIM) Integration

This document explains how to integrate Azure API Management with the AI agent solution to route frontend API calls through a managed gateway.

## Overview

Azure API Management provides:
- Centralized API gateway with routing and load balancing
- Security features like authentication, authorization, and rate limiting
- CORS policy management for frontend applications
- API analytics and monitoring
- Developer portal for API documentation

## Deployment

### Enable APIM in Deployment

To deploy with APIM enabled, set the following environment variables:

```bash
# Enable APIM
azd env set ENABLE_APIM true

# Optional: Configure APIM settings (defaults provided)
azd env set APIM_PUBLISHER_NAME "Your Organization"
azd env set APIM_PUBLISHER_EMAIL "admin@yourorg.com"
azd env set APIM_SKU "Consumption"
```

Then deploy:

```bash
azd up
```

### APIM SKU Options

- **Consumption**: Pay-per-use, serverless, suitable for development and light workloads
- **Developer**: Full-featured, for development and testing (not for production)
- **Basic**: Production-ready with basic features
- **Standard**: Production-ready with advanced features
- **Premium**: Enterprise-grade with multi-region support

## API Endpoints

When APIM is enabled, the following APIs are exposed through the gateway:

### Chat API
- **POST** `/api/chat` - Send chat messages to the AI agent
- **GET** `/api/chat/history` - Retrieve chat history

### Agent Information API
- **GET** `/api/agent` - Get agent details and configuration

### Health Check API
- **GET** `/api/config/azure` - Azure configuration and health status

### Static Frontend
- **GET** `/` - React frontend application served through APIM

## CORS Configuration

APIM is configured with a permissive CORS policy to allow frontend access:

- **Allowed Origins**: `*` (all origins)
- **Allowed Methods**: GET, POST, PUT, DELETE, OPTIONS
- **Allowed Headers**: `*` (all headers)
- **Allow Credentials**: `true`

For production, consider restricting origins to your specific domains.

## Frontend Configuration

When APIM is enabled, the frontend should route API calls through the APIM gateway URL instead of directly to the FastAPI backend.

### Environment Variables

After deployment with APIM enabled, you can get the APIM gateway URL:

```bash
# Get APIM gateway URL from deployment outputs
azd env get-values | grep APIM_GATEWAY_URL
```

### Automatic Configuration

A configuration script is provided to automatically update the frontend to use APIM URLs:

```bash
# Run the configuration script
./scripts/configure_apim_frontend.sh
```

This script will:
1. Read the APIM gateway URL from deployment outputs
2. Update the frontend environment configuration
3. Rebuild the React application if needed

## Security Considerations

### Production Recommendations

1. **CORS Policy**: Restrict origins to your actual frontend domains
2. **Authentication**: Add API key or OAuth authentication
3. **Rate Limiting**: Configure rate limits to prevent abuse
4. **IP Filtering**: Restrict access to known client IPs if applicable
5. **SSL/TLS**: Ensure all communication uses HTTPS

### Configuration Examples

Update the APIM Bicep template (`infra/core/gateway/apim.bicep`) for production:

```bicep
// Restrict CORS origins for production
corsAllowedOrigins: [
  'https://yourdomain.com'
  'https://www.yourdomain.com'
]

// Add API key authentication
policies: {
  inbound: [
    {
      name: 'validate-jwt'
      // JWT validation configuration
    }
  ]
}
```

## Monitoring and Analytics

APIM provides built-in analytics and monitoring:

1. **Azure Portal**: View API metrics, errors, and performance
2. **Application Insights**: Detailed telemetry and logging (when enabled)
3. **Developer Portal**: API documentation and testing interface

### Accessing Analytics

1. Navigate to Azure Portal
2. Find your APIM instance (named `apim-{resourceToken}`)
3. View Analytics section for API usage metrics

## Troubleshooting

### Common Issues

1. **CORS Errors**: Ensure CORS policy is properly configured for your frontend domain
2. **404 Errors**: Verify API operations are correctly defined in APIM
3. **Authentication Errors**: Check API key or authentication configuration
4. **Performance Issues**: Monitor APIM metrics and consider upgrading SKU

### Debug Steps

1. Check APIM gateway logs in Azure Portal
2. Test APIs directly through APIM developer portal
3. Verify backend service health through Container Apps
4. Review APIM policies for any blocking rules

## Cost Considerations

### APIM Pricing

- **Consumption**: ~$0.035 per 10,000 calls + $0.0035 per GB outbound data
- **Developer**: ~$49/month (non-production only)
- **Basic**: ~$140/month
- **Standard**: ~$560/month  
- **Premium**: ~$2,800/month

### Cost Optimization

1. Use Consumption tier for development and testing
2. Monitor API call volume to choose appropriate tier
3. Enable caching to reduce backend calls
4. Consider regional deployment for multi-region scenarios

## Next Steps

1. Deploy with APIM enabled using the environment variables above
2. Configure frontend to use APIM gateway URLs
3. Test all API endpoints through APIM
4. Set up monitoring and alerting
5. Plan production security configuration
