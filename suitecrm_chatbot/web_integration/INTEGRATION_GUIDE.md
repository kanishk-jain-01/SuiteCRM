# 🌐 SuiteCRM Chatbot Website Integration Guide

This guide shows you multiple ways to integrate the SuiteCRM LangGraph chatbot directly into your SuiteCRM website, making it available to users as they navigate your CRM.

## 🚀 Integration Options

### 1. 📱 Floating Chat Widget (Recommended)

The easiest way to add the chatbot to any SuiteCRM page.

**Features:**
- Floating action button in corner of screen
- Popup chat interface
- Remembers state across pages
- Mobile responsive
- Minimal setup required

**Implementation:**

```html
<!-- Add this to your SuiteCRM layout files -->
<script src="/suitecrm_chatbot/web_integration/embed_snippet.js"></script>
```

**Customization:**
```javascript
// Edit embed_snippet.js to customize:
const CHAT_CONFIG = {
    apiUrl: 'https://your-domain.com:8000', // Your chatbot API URL
    position: 'bottom-right', // bottom-left, top-right, top-left
    autoOpen: false, // Set to true to auto-open on page load
    welcomeMessage: true, // Show welcome message
    persistent: true // Remember chat state across pages
};
```

### 2. 🖼️ Iframe Embed

Embed the Streamlit interface directly in your pages.

```html
<!-- Add to any SuiteCRM page -->
<iframe 
    src="http://localhost:8501" 
    width="100%" 
    height="600px" 
    style="border: none; border-radius: 8px;"
    title="SuiteCRM Assistant">
</iframe>
```

### 3. 🔗 Dashboard Integration

Add as a dashlet in SuiteCRM dashboard.

**Create a custom dashlet file:**

```php
<?php
// custom/modules/Home/Dashlets/SuiteCRMChatDashlet/SuiteCRMChatDashlet.php

require_once('include/Dashlets/DashletGeneric.php');

class SuiteCRMChatDashlet extends DashletGeneric {
    public function __construct($id, $def = null) {
        parent::__construct($id, $def);
        
        if(empty($def['title'])) {
            $this->title = 'SuiteCRM Assistant';
        }
        
        $this->searchFields = array();
        $this->columns = array();
    }
    
    public function displayOptions() {
        // Options for the dashlet
        return '<table width="100%"></table>';
    }
    
    public function process($lvsParams = array()) {
        // Main dashlet content
        $chatbot_url = 'http://localhost:8501';
        
        $html = '<div style="height: 400px;">
            <iframe src="' . $chatbot_url . '" 
                    width="100%" 
                    height="100%" 
                    style="border: none; border-radius: 4px;"
                    title="SuiteCRM Assistant">
            </iframe>
        </div>';
        
        $this->contents = $html;
    }
}
?>
```

### 4. 📄 Custom SuiteCRM Module

Create a dedicated module for the chatbot.

**Step 1: Create Module Structure**
```
custom/modules/SuiteCRMChat/
├── SuiteCRMChat.php
├── vardefs.php
├── metadata/
│   ├── detailviewdefs.php
│   └── listviewdefs.php
└── views/
    └── view.detail.php
```

**Step 2: Module Definition**
```php
<?php
// custom/modules/SuiteCRMChat/SuiteCRMChat.php

class SuiteCRMChat extends SugarBean {
    public $module_dir = 'SuiteCRMChat';
    public $object_name = 'SuiteCRMChat';
    public $table_name = 'suitecrm_chat';
    public $new_schema = true;
    
    public function __construct() {
        parent::__construct();
    }
}
?>
```

**Step 3: Detail View**
```php
<?php
// custom/modules/SuiteCRMChat/views/view.detail.php

class SuiteCRMChatViewDetail extends ViewDetail {
    public function display() {
        echo '<div style="padding: 20px;">
            <h2>SuiteCRM Assistant</h2>
            <div id="chat-container" style="height: 600px; border: 1px solid #ddd; border-radius: 8px;">
                <iframe src="http://localhost:8501" 
                        width="100%" 
                        height="100%" 
                        style="border: none;"
                        title="SuiteCRM Assistant">
                </iframe>
            </div>
        </div>';
    }
}
?>
```

### 5. 🎨 Custom Theme Integration

Add chatbot to your SuiteCRM theme.

**Edit Theme Template:**
```php
// themes/YourTheme/tpls/_headerModuleList.tpl (or similar)

<!-- Add before closing body tag -->
<script>
// Configuration
window.SUITECRM_CHAT_CONFIG = {
    apiUrl: '{$CHAT_API_URL}',
    position: 'bottom-right',
    autoOpen: false
};
</script>
<script src="{$SITE_URL}/suitecrm_chatbot/web_integration/embed_snippet.js"></script>
```

### 6. 🔌 REST API Integration

Build custom frontend using the REST API.

```javascript
// Example: Custom chat implementation
class CustomSuiteCRMChat {
    constructor(apiUrl) {
        this.apiUrl = apiUrl;
    }
    
    async sendMessage(message) {
        const response = await fetch(`${this.apiUrl}/chat`, {
            method: 'POST',
            headers: { 'Content-Type': 'application/json' },
            body: JSON.stringify({ message })
        });
        
        return await response.json();
    }
    
    async createAccount(accountData) {
        const response = await fetch(`${this.apiUrl}/accounts/create`, {
            method: 'POST',
            headers: { 'Content-Type': 'application/json' },
            body: JSON.stringify(accountData)
        });
        
        return await response.json();
    }
}
```

## 🔧 Setup Instructions

### Prerequisites

1. **Chatbot Server Running:**
   ```bash
   cd suitecrm_chatbot
   python fastapi_app.py
   ```

2. **Configure CORS** (if needed):
   ```python
   # In fastapi_app.py, update CORS settings:
   app.add_middleware(
       CORSMiddleware,
       allow_origins=["https://your-suitecrm-domain.com"],
       allow_credentials=True,
       allow_methods=["*"],
       allow_headers=["*"],
   )
   ```

### Option 1: Quick Setup (Floating Widget)

1. **Copy the embed script:**
   ```bash
   cp suitecrm_chatbot/web_integration/embed_snippet.js /path/to/your/suitecrm/public/
   ```

2. **Add to your main layout:**
   ```html
   <!-- In your main SuiteCRM template file -->
   <script src="/embed_snippet.js"></script>
   ```

3. **Update API URL in the script:**
   ```javascript
   // Edit embed_snippet.js
   const CHAT_CONFIG = {
       apiUrl: 'https://your-domain.com:8000', // Your actual API URL
       // ... other options
   };
   ```

### Option 2: Full HTML Page

1. **Create a dedicated chat page:**
   ```bash
   cp suitecrm_chatbot/web_integration/chat_widget.html /path/to/your/suitecrm/chat.html
   ```

2. **Update the API URL in chat_widget.html:**
   ```javascript
   // At the bottom of chat_widget.html
   const chatWidget = new SuiteCRMChatWidget('https://your-domain.com:8000');
   ```

3. **Link to the chat page:**
   ```html
   <a href="/chat.html" target="_blank">Open SuiteCRM Assistant</a>
   ```

### Option 3: SuiteCRM Module Integration

1. **Create the module files** (see Custom Module section above)

2. **Register the module:**
   ```php
   // Add to custom/Extension/application/Ext/Include/modules.ext.php
   $moduleList[] = 'SuiteCRMChat';
   $beanList['SuiteCRMChat'] = 'SuiteCRMChat';
   $beanFiles['SuiteCRMChat'] = 'custom/modules/SuiteCRMChat/SuiteCRMChat.php';
   ```

3. **Run Quick Repair and Rebuild** from SuiteCRM Admin

## 🎯 Recommended Deployment

For production websites, we recommend:

### 1. **Use the Floating Widget** for best user experience
### 2. **Deploy FastAPI with proper hosting:**

```dockerfile
# Dockerfile for production
FROM python:3.9-slim

WORKDIR /app
COPY requirements.txt .
RUN pip install -r requirements.txt

COPY . .

# Use Gunicorn for production
CMD ["gunicorn", "fastapi_app:app", "-w", "4", "-k", "uvicorn.workers.UvicornWorker", "--bind", "0.0.0.0:8000"]
```

### 3. **Use a reverse proxy (Nginx):**

```nginx
# nginx configuration
location /chatbot/ {
    proxy_pass http://localhost:8000/;
    proxy_set_header Host $host;
    proxy_set_header X-Real-IP $remote_addr;
    proxy_set_header X-Forwarded-For $proxy_add_x_forwarded_for;
}
```

### 4. **Configure HTTPS and proper CORS**

## 🔍 Troubleshooting

### Common Issues:

**1. CORS Errors:**
- Update `fastapi_app.py` CORS settings
- Ensure API URL matches your domain

**2. Chat Widget Not Appearing:**
- Check browser console for errors
- Verify script is loading correctly
- Confirm API server is running

**3. API Connection Failed:**
- Check network connectivity
- Verify API URL configuration
- Check firewall settings

**4. Authentication Issues:**
- Verify SuiteCRM OAuth2 credentials
- Check user permissions
- Confirm API access is enabled

## 📱 Mobile Considerations

The chat widget is responsive and works well on mobile devices. For optimal mobile experience:

1. **Test on various screen sizes**
2. **Consider bottom-left position for mobile**
3. **Adjust chat popup size for small screens**

## 🎨 Customization

### Styling
- Edit CSS in `embed_snippet.js` or `chat_widget.html`
- Match your SuiteCRM theme colors
- Customize positioning and animations

### Functionality
- Add custom welcome messages
- Integrate with SuiteCRM user sessions
- Add typing indicators and read receipts

---

## 🎉 You're All Set!

Your SuiteCRM chatbot is now ready to be integrated into your website! Choose the integration method that best fits your needs and technical requirements.

For support or questions, refer to the main README.md or create an issue in the repository. 