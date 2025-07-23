/**
 * SuiteCRM Chat Assistant - Embedded Widget
 * 
 * Integrated chat assistant for SuiteCRM using the SuiteP theme styling.
 */

(function() {
    'use strict';
    
    // Configuration - Customize these settings
    const CHAT_CONFIG = {
        apiUrl: 'http://localhost:8001', // Your FastAPI server URL
        position: 'bottom-right', // Options: bottom-right, bottom-left, top-right, top-left
        theme: 'suitep', // Theme: suitep (matches SuiteCRM theme)
        autoOpen: false, // Auto-open chat on page load
        welcomeMessage: true, // Show welcome message
        persistent: true // Remember chat state across pages
    };
    
    // Don't load if already loaded
    if (window.SuiteCRMChatLoaded) return;
    window.SuiteCRMChatLoaded = true;
    
    // CSS Styles - Updated to match SuiteP theme
    const styles = `
        .suitecrm-chat-container {
            position: fixed;
            z-index: 999999;
            font-family: -apple-system, BlinkMacSystemFont, 'Segoe UI', Roboto, "Helvetica Neue", sans-serif;
        }
        
        .suitecrm-chat-container.bottom-right {
            bottom: 20px;
            right: 20px;
        }
        
        .suitecrm-chat-container.bottom-left {
            bottom: 20px;
            left: 20px;
        }
        
        .suitecrm-chat-container.top-right {
            top: 80px;
            right: 20px;
        }
        
        .suitecrm-chat-container.top-left {
            top: 80px;
            left: 20px;
        }
        
        .chat-fab {
            width: 56px;
            height: 56px;
            border-radius: 50%;
            background: linear-gradient(135deg, #3371A3 0%, #5FAFF7 100%);
            border: none;
            color: white;
            cursor: pointer;
            display: flex;
            align-items: center;
            justify-content: center;
            font-size: 20px;
            box-shadow: 0 4px 12px rgba(51, 113, 163, 0.4);
            transition: all 0.3s cubic-bezier(0.4, 0, 0.2, 1);
            position: relative;
            overflow: hidden;
        }
        
        .chat-fab:hover {
            transform: scale(1.1);
            box-shadow: 0 6px 20px rgba(51, 113, 163, 0.6);
            background: linear-gradient(135deg, #5FAFF7 0%, #3371A3 100%);
        }
        
        .chat-fab:active {
            transform: scale(0.95);
        }
        
        .chat-fab .icon {
            transition: transform 0.3s ease;
        }
        
        .chat-fab.open .icon {
            transform: rotate(180deg);
        }
        
        .chat-popup {
            position: absolute;
            bottom: 70px;
            right: 0;
            width: 350px;
            height: 500px;
            background: white;
            border-radius: 12px;
            box-shadow: 0 8px 32px rgba(0, 0, 0, 0.24);
            display: none;
            flex-direction: column;
            overflow: hidden;
            transform: scale(0.8) translateY(20px);
            opacity: 0;
            transition: all 0.3s cubic-bezier(0.4, 0, 0.2, 1);
        }
        
        .chat-popup.open {
            display: flex;
            transform: scale(1) translateY(0);
            opacity: 1;
        }
        
        .chat-popup.bottom-left,
        .chat-popup.top-left {
            right: auto;
            left: 0;
        }
        
        .chat-popup.top-right,
        .chat-popup.top-left {
            bottom: auto;
            top: 70px;
        }
        
        .chat-header {
            background: linear-gradient(135deg, #1f4e79 0%, #2c5f8c 100%);
            color: white;
            padding: 16px;
            display: flex;
            align-items: center;
            justify-content: space-between;
        }
        
        .chat-title {
            font-size: 16px;
            font-weight: 600;
            margin: 0;
        }
        
        .close-chat {
            background: none;
            border: none;
            color: white;
            font-size: 18px;
            cursor: pointer;
            padding: 4px;
            border-radius: 4px;
            transition: background 0.2s;
        }
        
        .close-chat:hover {
            background: rgba(255, 255, 255, 0.1);
        }
        
        .chat-messages {
            flex: 1;
            padding: 16px;
            overflow-y: auto;
            background: #f8f9fa;
        }
        
        .message {
            margin-bottom: 12px;
            max-width: 85%;
        }
        
        .message.user {
            margin-left: auto;
        }
        
        .message-bubble {
            padding: 8px 12px;
            border-radius: 16px;
            font-size: 14px;
            line-height: 1.4;
        }
        
        .message.user .message-bubble {
            background: #1f4e79;
            color: white;
        }
        
        .message.assistant .message-bubble {
            background: white;
            color: #333;
            border: 1px solid #e1e5e9;
        }
        
        .chat-input-area {
            padding: 12px;
            background: white;
            border-top: 1px solid #e1e5e9;
            display: flex;
            gap: 8px;
        }
        
        .chat-input {
            flex: 1;
            padding: 8px 12px;
            border: 1px solid #ddd;
            border-radius: 20px;
            outline: none;
            font-size: 14px;
        }
        
        .chat-input:focus {
            border-color: #1f4e79;
        }
        
        .send-button {
            background: #1f4e79;
            border: none;
            color: white;
            width: 36px;
            height: 36px;
            border-radius: 50%;
            cursor: pointer;
            display: flex;
            align-items: center;
            justify-content: center;
            transition: background 0.2s;
        }
        
        .send-button:hover:not(:disabled) {
            background: #2c5f8c;
        }
        
        .send-button:disabled {
            opacity: 0.6;
            cursor: not-allowed;
        }
        
        .typing-indicator {
            padding: 8px 16px;
            color: #666;
            font-size: 12px;
            font-style: italic;
            display: none;
        }
        
        /* Mobile responsive */
        @media (max-width: 768px) {
            .suitecrm-chat-container {
                bottom: 10px !important;
                right: 10px !important;
            }
            
            .chat-popup {
                width: calc(100vw - 20px);
                height: calc(100vh - 100px);
                bottom: 70px;
                right: -10px;
            }
        }
    `;
    
    // HTML Template
    const chatHTML = `
        <div class="suitecrm-chat-container ${CHAT_CONFIG.position}">
            <button class="chat-fab" id="chatFab">
                <span class="icon">💬</span>
            </button>
            <div class="chat-popup ${CHAT_CONFIG.position}" id="chatPopup">
                <div class="chat-header">
                    <h3 class="chat-title">🏢 SuiteCRM Assistant</h3>
                    <button class="close-chat" id="closeChat">×</button>
                </div>
                <div class="chat-messages" id="chatMessages"></div>
                <div class="typing-indicator" id="typingIndicator">Assistant is typing...</div>
                <div class="chat-input-area">
                    <input type="text" class="chat-input" id="chatInput" placeholder="Ask me about accounts..." maxlength="1000">
                    <button class="send-button" id="sendButton">
                        <svg width="16" height="16" viewBox="0 0 24 24" fill="currentColor">
                            <path d="M2.01 21L23 12 2.01 3 2 10l15 2-15 2z"/>
                        </svg>
                    </button>
                </div>
            </div>
        </div>
    `;
    
    // Chat functionality
    class SuiteCRMChatWidget {
        constructor() {
            this.isOpen = false;
            this.isLoading = false;
            this.sessionId = this.getSessionId();
            this.init();
        }
        
        init() {
            this.injectStyles();
            this.injectHTML();
            this.bindEvents();
            
            if (CHAT_CONFIG.welcomeMessage) {
                this.addWelcomeMessage();
            }
            
            if (CHAT_CONFIG.autoOpen) {
                setTimeout(() => this.openChat(), 1000);
            }
        }
        
        injectStyles() {
            const styleSheet = document.createElement('style');
            styleSheet.textContent = styles;
            document.head.appendChild(styleSheet);
        }
        
        injectHTML() {
            const container = document.createElement('div');
            container.innerHTML = chatHTML;
            document.body.appendChild(container.firstElementChild);
            
            this.elements = {
                fab: document.getElementById('chatFab'),
                popup: document.getElementById('chatPopup'),
                close: document.getElementById('closeChat'),
                messages: document.getElementById('chatMessages'),
                input: document.getElementById('chatInput'),
                send: document.getElementById('sendButton'),
                typing: document.getElementById('typingIndicator')
            };
        }
        
        bindEvents() {
            this.elements.fab.addEventListener('click', () => this.toggleChat());
            this.elements.close.addEventListener('click', () => this.closeChat());
            this.elements.send.addEventListener('click', () => this.sendMessage());
            this.elements.input.addEventListener('keypress', (e) => {
                if (e.key === 'Enter' && !e.shiftKey) {
                    e.preventDefault();
                    this.sendMessage();
                }
            });
        }
        
        toggleChat() {
            this.isOpen ? this.closeChat() : this.openChat();
        }
        
        openChat() {
            this.isOpen = true;
            this.elements.fab.classList.add('open');
            this.elements.popup.classList.add('open');
            setTimeout(() => this.elements.input.focus(), 300);
            
            if (CHAT_CONFIG.persistent) {
                localStorage.setItem('suitecrm_chat_open', 'true');
            }
        }
        
        closeChat() {
            this.isOpen = false;
            this.elements.fab.classList.remove('open');
            this.elements.popup.classList.remove('open');
            
            if (CHAT_CONFIG.persistent) {
                localStorage.setItem('suitecrm_chat_open', 'false');
            }
        }
        
        async sendMessage() {
            const message = this.elements.input.value.trim();
            if (!message || this.isLoading) return;
            
            this.addMessage(message, 'user');
            this.elements.input.value = '';
            this.setLoading(true);
            
            try {
                const response = await fetch(`${CHAT_CONFIG.apiUrl}/chat`, {
                    method: 'POST',
                    headers: { 'Content-Type': 'application/json' },
                    body: JSON.stringify({
                        message: message,
                        session_id: this.sessionId
                    })
                });
                
                const data = await response.json();
                this.setLoading(false);
                
                if (response.ok) {
                    this.addMessage(data.response, 'assistant');
                } else {
                    this.addMessage(`❌ Error: ${data.detail || 'Something went wrong'}`, 'assistant');
                }
            } catch (error) {
                this.setLoading(false);
                this.addMessage(`❌ Connection error. Please check if the chatbot service is running.`, 'assistant');
            }
        }
        
        addMessage(content, sender) {
            const messageDiv = document.createElement('div');
            messageDiv.className = `message ${sender}`;
            
            const bubbleDiv = document.createElement('div');
            bubbleDiv.className = 'message-bubble';
            
            // Simple markdown-like formatting
            content = content
                .replace(/\*\*(.*?)\*\*/g, '<strong>$1</strong>')
                .replace(/\*(.*?)\*/g, '<em>$1</em>')
                .replace(/\n/g, '<br>');
            
            bubbleDiv.innerHTML = content;
            messageDiv.appendChild(bubbleDiv);
            this.elements.messages.appendChild(messageDiv);
            
            this.scrollToBottom();
        }
        
        addWelcomeMessage() {
            this.addMessage(`👋 Hi! I'm your SuiteCRM Assistant. I can help you:

• Create new accounts
• Search existing accounts
• Update account information
• Get account details

Try asking: "Create an account for ABC Corp" or "Search for tech companies"`, 'assistant');
        }
        
        setLoading(loading) {
            this.isLoading = loading;
            this.elements.send.disabled = loading;
            this.elements.typing.style.display = loading ? 'block' : 'none';
            if (loading) this.scrollToBottom();
        }
        
        scrollToBottom() {
            this.elements.messages.scrollTop = this.elements.messages.scrollHeight;
        }
        
        getSessionId() {
            let sessionId = localStorage.getItem('suitecrm_chat_session');
            if (!sessionId) {
                sessionId = 'web_' + Date.now() + '_' + Math.random().toString(36).substr(2, 9);
                localStorage.setItem('suitecrm_chat_session', sessionId);
            }
            return sessionId;
        }
    }
    
    // Initialize when DOM is ready
    function initializeChat() {
        // Check if we should restore chat state
        if (CHAT_CONFIG.persistent && localStorage.getItem('suitecrm_chat_open') === 'true') {
            CHAT_CONFIG.autoOpen = true;
        }
        
        new SuiteCRMChatWidget();
    }
    
    if (document.readyState === 'loading') {
        document.addEventListener('DOMContentLoaded', initializeChat);
    } else {
        initializeChat();
    }
    
})(); 