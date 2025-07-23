# 🏢 SuiteCRM LangGraph Chatbot Assistant

A powerful AI-powered chatbot built with LangGraph that integrates directly into your SuiteCRM interface. This assistant provides an intuitive floating chat widget for managing SuiteCRM accounts through natural language commands.

## ✨ Features

- 🤖 **Natural Language Interface**: Chat with the assistant using everyday language
- 🏢 **Complete Account Management**: Create, read, update, delete, and search accounts
- 🔗 **Direct SuiteCRM Integration**: Real-time operations via SuiteCRM REST API V8
- 🌐 **Integrated UI**: Floating chat widget directly in SuiteCRM interface
- 🛠️ **LangGraph Architecture**: Robust workflow management with tool calling
- 📊 **Rich Information Display**: Formatted responses with comprehensive account details
- 🔍 **Advanced Search**: Filter accounts by multiple criteria
- 📋 **Field Metadata**: Get information about available account fields
- 🎨 **SuiteP Theme Integration**: Matches your SuiteCRM theme perfectly

## 🛠️ Architecture

```
┌─────────────────┐    ┌─────────────────┐    ┌─────────────────┐
│   SuiteCRM UI   │───▶│  Chat Widget    │───▶│   FastAPI       │
│   (Floating     │    │  (JavaScript)   │    │   Backend       │
│   Chat Widget)  │    │                 │    │                 │
└─────────────────┘    └─────────────────┘    └─────────────────┘
                              │                         │
                              ▼                         ▼
                    ┌─────────────────┐    ┌─────────────────┐
                    │  LangGraph      │───▶│   SuiteCRM      │
                    │  Agent          │    │   REST API      │
                    └─────────────────┘    └─────────────────┘
                              │
                              ▼
                    ┌─────────────────┐
                    │   Tool Layer    │
                    │ - Create Account│
                    │ - Search Accounts│
                    │ - Update Account│
                    │ - Delete Account│
                    │ - Get Metadata  │
                    └─────────────────┘
```

## 📋 Prerequisites

- Python 3.8+
- SuiteCRM instance with REST API V8 enabled
- OpenAI API key
- SuiteCRM OAuth2 credentials

## 🚀 Quick Start

### 1. Clone and Setup

```bash
# Navigate to your SuiteCRM directory
cd /path/to/your/SuiteCRM

# The chatbot should be in: suitecrm_chatbot/
cd suitecrm_chatbot

# Install dependencies
pip install -r requirements.txt
```

### 2. Configuration

Create a `.env` file with your credentials:

```env
# OpenAI Configuration
OPENAI_API_KEY=your_openai_api_key_here

# SuiteCRM API Configuration
SUITECRM_BASE_URL=http://your-suitecrm-instance.com/Api/V8
SUITECRM_CLIENT_ID=your_oauth_client_id
SUITECRM_CLIENT_SECRET=your_oauth_client_secret
SUITECRM_USERNAME=your_username
SUITECRM_PASSWORD=your_password

# Optional Configuration
CHATBOT_PORT=8000
DEBUG=True
LOG_LEVEL=INFO
```

### 3. SuiteCRM OAuth2 Setup

1. **Create OAuth2 Client in SuiteCRM:**
   - Go to Administration → OAuth2 Clients and Tokens
   - Click "Create OAuth2 Client"
   - Set the client name and save
   - Note the Client ID and Client Secret

2. **Enable API Access:**
   - Ensure your user has API access permissions
   - Check that REST API V8 is enabled in your SuiteCRM instance

### 4. Run the Application

**Start the FastAPI Backend:**
```bash
python3 fastapi_app.py
```
Access at: http://localhost:8000
API Docs: http://localhost:8000/docs

**The chat widget is automatically integrated into your SuiteCRM interface!**

## 💬 Usage Examples

### Natural Language Commands

**Account Creation:**
```
User: "Create an account for ABC Corporation"
User: "Add a new company called TechStart with website techstart.com and phone 555-0123"
User: "I need to create an account for Global Industries with billing address in New York"
```

**Search and Retrieval:**
```
User: "Find all accounts in the technology industry"
User: "Search for companies with 'software' in their name"
User: "Show me the details for account ID xyz-123-456"
User: "List accounts in California"
```

**Updates and Management:**
```
User: "Update account xyz-123 with new phone number 555-9999"
User: "Change the website for account abc-456 to newsite.com"
User: "What fields can I use when creating accounts?"
```

### REST API Examples

**Chat Endpoint:**
```bash
curl -X POST "http://localhost:8000/chat" \
  -H "Content-Type: application/json" \
  -d '{"message": "Create an account for ABC Corp"}'
```

**Direct Account Creation:**
```bash
curl -X POST "http://localhost:8000/accounts/create" \
  -H "Content-Type: application/json" \
  -d '{
    "name": "ABC Corporation",
    "website": "https://abc-corp.com",
    "phone_office": "555-0123",
    "industry": "Technology"
  }'
```

**Search Accounts:**
```bash
curl -X POST "http://localhost:8000/accounts/search" \
  -H "Content-Type: application/json" \
  -d '{"industry": "Technology"}'
```

## 🔧 Available Tools

The chatbot includes these LangGraph tools:

1. **create_account** - Create new accounts with comprehensive field support
2. **search_accounts** - Search accounts with multiple filter options
3. **get_account** - Retrieve detailed account information by ID
4. **update_account** - Update existing account information
5. **delete_account** - Delete accounts (with confirmation prompts)
6. **get_account_fields** - Get metadata about available account fields

## 📊 Supported Account Fields

### Required Fields
- `name` - Account name (required)

### Optional Fields
- **Contact Information:**
  - `website`, `phone_office`, `phone_fax`, `email1`
- **Address Information:**
  - `billing_address_street`, `billing_address_city`, `billing_address_state`, `billing_address_postalcode`, `billing_address_country`
  - `shipping_address_street`, `shipping_address_city`, `shipping_address_state`, `shipping_address_postalcode`, `shipping_address_country`
- **Business Information:**
  - `industry`, `account_type`, `annual_revenue`, `employees`, `ownership`
- **Additional Information:**
  - `description`, `rating`, `ticker_symbol`, `sic_code`

## 🔄 SuiteCRM Integration

The chatbot integrates with SuiteCRM using:

- **REST API V8**: Modern RESTful interface
- **OAuth2 Authentication**: Secure token-based authentication
- **Real-time Operations**: Direct database operations
- **Full CRUD Support**: Create, Read, Update, Delete operations
- **Advanced Filtering**: Complex search capabilities
- **Field Metadata**: Dynamic field discovery
- **Floating Chat Widget**: Integrated directly into SuiteCRM UI
- **SuiteP Theme Matching**: Styled to match your SuiteCRM theme

## 🧠 LangGraph Architecture

The agent is built using LangGraph with:

- **State Management**: Maintains conversation context
- **Tool Calling**: Structured interaction with SuiteCRM
- **Error Handling**: Robust error management and user feedback
- **Workflow Control**: Conditional logic for tool execution
- **Response Formatting**: Rich, formatted responses

## 🔍 Troubleshooting

### Common Issues

**Authentication Errors:**
- Verify OAuth2 credentials are correct
- Check that the user has API access permissions
- Ensure SuiteCRM instance is accessible

**Connection Issues:**
- Verify SuiteCRM base URL is correct
- Check network connectivity
- Confirm REST API V8 is enabled

**Chat Widget Not Appearing:**
- Check browser console for JavaScript errors
- Verify FastAPI backend is running on port 8000
- Ensure the embed script is loading correctly

**Tool Execution Errors:**
- Check OpenAI API key is valid
- Verify account field names match SuiteCRM schema
- Review logs for detailed error information

### Debug Mode

Enable debug mode for detailed logging:
```env
DEBUG=True
LOG_LEVEL=DEBUG
```

### Health Check

Check system status:
```bash
curl http://localhost:8000/health
```

## 🚀 Deployment

### Production Configuration

1. **Security:**
   - Use environment variables for secrets
   - Configure CORS properly for web deployment
   - Use HTTPS in production

2. **Performance:**
   - Configure appropriate timeout values
   - Implement connection pooling
   - Monitor API rate limits

3. **Monitoring:**
   - Set up logging and monitoring
   - Implement health checks
   - Configure error alerting

### Docker Deployment

```dockerfile
FROM python:3.9-slim

WORKDIR /app
COPY requirements.txt .
RUN pip install -r requirements.txt

COPY . .

CMD ["python3", "fastapi_app.py"]
```

## 🤝 Contributing

1. Fork the repository
2. Create a feature branch
3. Make your changes
4. Add tests if applicable
5. Submit a pull request

## 📄 License

This project is licensed under the same license as SuiteCRM.

## 🔗 Related Links

- [SuiteCRM Documentation](https://docs.suitecrm.com/)
- [SuiteCRM REST API V8](https://docs.suitecrm.com/developer/api/developer-setup-guide/json-api/)
- [LangGraph Documentation](https://python.langchain.com/docs/langgraph)
- [OpenAI API Documentation](https://platform.openai.com/docs)

## 💡 Tips for Best Results

1. **Be Specific**: Provide clear account names and details
2. **Use Natural Language**: The AI understands conversational commands
3. **Check Field Names**: Use `get_account_fields` to see available fields
4. **Provide Context**: Include relevant details for better assistance
5. **Review Before Deletion**: Always confirm before deleting accounts

---

**Built with ❤️ using LangGraph, OpenAI, and SuiteCRM** 

## 🎯 Integration Complete!

Your SuiteCRM now has an integrated AI chatbot! The floating chat widget will appear on all SuiteCRM pages. Simply click the blue chat button in the bottom-right corner to start interacting with your AI assistant.

### Next Steps:
1. Start the FastAPI backend (`python3 fastapi_app.py`)
2. Navigate to your SuiteCRM instance
3. Look for the floating chat widget
4. Start chatting with your AI assistant! 