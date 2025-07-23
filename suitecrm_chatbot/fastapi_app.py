"""FastAPI REST API interface for SuiteCRM chatbot."""

import logging
from typing import Dict, Any, List, Optional
from datetime import datetime
import uvicorn
from fastapi import FastAPI, HTTPException, BackgroundTasks
from fastapi.middleware.cors import CORSMiddleware
from pydantic import BaseModel, Field
from agent import create_suitecrm_agent, SuiteCRMAgent
from config import config

# Configure logging
logging.basicConfig(level=config.LOG_LEVEL)
logger = logging.getLogger(__name__)

# Create FastAPI app
app = FastAPI(
    title="SuiteCRM Account Assistant API",
    description="REST API for the SuiteCRM Account Management Chatbot",
    version="1.0.0",
    docs_url="/docs",
    redoc_url="/redoc"
)

# Add CORS middleware
app.add_middleware(
    CORSMiddleware,
    allow_origins=["*"],  # In production, specify actual origins
    allow_credentials=True,
    allow_methods=["*"],
    allow_headers=["*"],
)

# Global agent instance
_agent: Optional[SuiteCRMAgent] = None

# Request/Response models
class ChatRequest(BaseModel):
    """Request model for chat endpoint."""
    message: str = Field(..., description="User message", min_length=1, max_length=2000)
    session_id: Optional[str] = Field(None, description="Optional session ID for tracking")

class ChatResponse(BaseModel):
    """Response model for chat endpoint."""
    response: str = Field(..., description="Agent response")
    session_id: Optional[str] = Field(None, description="Session ID if provided")
    timestamp: datetime = Field(default_factory=datetime.now, description="Response timestamp")
    success: bool = Field(True, description="Whether the request was successful")

class HealthResponse(BaseModel):
    """Response model for health check."""
    status: str
    timestamp: datetime
    suitecrm_configured: bool
    openai_configured: bool
    agent_ready: bool

class AccountCreateRequest(BaseModel):
    """Direct account creation request."""
    name: str = Field(..., description="Account name (required)")
    website: Optional[str] = Field(None, description="Website URL")
    phone_office: Optional[str] = Field(None, description="Office phone")
    email1: Optional[str] = Field(None, description="Primary email")
    industry: Optional[str] = Field(None, description="Industry")
    account_type: Optional[str] = Field(None, description="Account type")
    billing_address_street: Optional[str] = Field(None, description="Billing street")
    billing_address_city: Optional[str] = Field(None, description="Billing city")
    billing_address_state: Optional[str] = Field(None, description="Billing state")
    billing_address_country: Optional[str] = Field(None, description="Billing country")
    description: Optional[str] = Field(None, description="Account description")

class AccountSearchRequest(BaseModel):
    """Account search request."""
    name: Optional[str] = Field(None, description="Filter by name")
    industry: Optional[str] = Field(None, description="Filter by industry")
    account_type: Optional[str] = Field(None, description="Filter by type")
    fields: Optional[List[str]] = Field(None, description="Fields to return")

def get_agent() -> SuiteCRMAgent:
    """Get or create the SuiteCRM agent."""
    global _agent
    if _agent is None:
        _agent = create_suitecrm_agent()
    return _agent

@app.on_event("startup")
async def startup_event():
    """Initialize the agent on startup."""
    try:
        logger.info("Initializing SuiteCRM agent...")
        get_agent()
        logger.info("SuiteCRM agent initialized successfully")
    except Exception as e:
        logger.error(f"Failed to initialize agent: {str(e)}")

@app.get("/health", response_model=HealthResponse)
async def health_check():
    """Health check endpoint."""
    try:
        agent = get_agent()
        agent_ready = agent is not None
    except Exception:
        agent_ready = False
    
    return HealthResponse(
        status="healthy" if agent_ready else "degraded",
        timestamp=datetime.now(),
        suitecrm_configured=bool(config.SUITECRM_CLIENT_ID and config.SUITECRM_CLIENT_SECRET),
        openai_configured=bool(config.OPENAI_API_KEY),
        agent_ready=agent_ready
    )

@app.post("/chat", response_model=ChatResponse)
async def chat(request: ChatRequest):
    """Chat with the SuiteCRM assistant."""
    try:
        agent = get_agent()
        
        # Get response from agent
        response = agent.chat_sync(request.message)
        
        return ChatResponse(
            response=response,
            session_id=request.session_id,
            timestamp=datetime.now(),
            success=True
        )
        
    except Exception as e:
        logger.error(f"Error in chat endpoint: {str(e)}")
        raise HTTPException(
            status_code=500,
            detail=f"Error processing chat request: {str(e)}"
        )

@app.post("/accounts/create")
async def create_account_direct(request: AccountCreateRequest):
    """Create an account directly via API."""
    try:
        from suitecrm_client import SuiteCRMClient
        
        client = SuiteCRMClient()
        
        # Convert request to dict and remove None values
        account_data = {k: v for k, v in request.dict().items() if v is not None}
        
        # Create the account
        result = await client.create_account(account_data)
        
        return {
            "success": True,
            "message": "Account created successfully",
            "account_id": result.get('data', {}).get('id'),
            "account_data": result.get('data', {}).get('attributes', {}),
            "timestamp": datetime.now()
        }
        
    except Exception as e:
        logger.error(f"Error creating account: {str(e)}")
        raise HTTPException(
            status_code=500,
            detail=f"Error creating account: {str(e)}"
        )

@app.post("/accounts/search")
async def search_accounts_direct(request: AccountSearchRequest):
    """Search accounts directly via API."""
    try:
        from suitecrm_client import SuiteCRMClient
        
        client = SuiteCRMClient()
        
        # Prepare filters
        filters = {k: v for k, v in request.dict().items() if v is not None and k != 'fields'}
        
        # Search accounts
        result = await client.search_accounts(filters=filters, fields=request.fields)
        
        return {
            "success": True,
            "message": f"Found {len(result.get('data', []))} accounts",
            "accounts": result.get('data', []),
            "total_count": len(result.get('data', [])),
            "timestamp": datetime.now()
        }
        
    except Exception as e:
        logger.error(f"Error searching accounts: {str(e)}")
        raise HTTPException(
            status_code=500,
            detail=f"Error searching accounts: {str(e)}"
        )

@app.get("/accounts/{account_id}")
async def get_account_direct(account_id: str):
    """Get account by ID directly via API."""
    try:
        from suitecrm_client import SuiteCRMClient
        
        client = SuiteCRMClient()
        result = await client.get_account(account_id)
        
        return {
            "success": True,
            "message": "Account retrieved successfully",
            "account": result.get('data', {}),
            "timestamp": datetime.now()
        }
        
    except Exception as e:
        logger.error(f"Error getting account: {str(e)}")
        raise HTTPException(
            status_code=500,
            detail=f"Error retrieving account: {str(e)}"
        )

@app.delete("/accounts/{account_id}")
async def delete_account_direct(account_id: str):
    """Delete account by ID directly via API."""
    try:
        from suitecrm_client import SuiteCRMClient
        
        client = SuiteCRMClient()
        result = await client.delete_account(account_id)
        
        return {
            "success": True,
            "message": f"Account {account_id} deleted successfully",
            "timestamp": datetime.now()
        }
        
    except Exception as e:
        logger.error(f"Error deleting account: {str(e)}")
        raise HTTPException(
            status_code=500,
            detail=f"Error deleting account: {str(e)}"
        )

@app.get("/accounts/fields/metadata")
async def get_account_fields():
    """Get account field metadata."""
    try:
        from suitecrm_client import SuiteCRMClient
        
        client = SuiteCRMClient()
        result = await client.get_account_fields_metadata()
        
        return {
            "success": True,
            "message": "Field metadata retrieved successfully",
            "fields": result.get('data', {}).get('attributes', {}),
            "timestamp": datetime.now()
        }
        
    except Exception as e:
        logger.error(f"Error getting field metadata: {str(e)}")
        raise HTTPException(
            status_code=500,
            detail=f"Error retrieving field metadata: {str(e)}"
        )

@app.get("/")
async def root():
    """Root endpoint with API information."""
    return {
        "message": "SuiteCRM Account Assistant API",
        "version": "1.0.0",
        "documentation": "/docs",
        "health": "/health",
        "endpoints": {
            "chat": "POST /chat - Chat with the assistant",
            "create_account": "POST /accounts/create - Create account directly",
            "search_accounts": "POST /accounts/search - Search accounts",
            "get_account": "GET /accounts/{id} - Get account by ID",
            "delete_account": "DELETE /accounts/{id} - Delete account",
            "field_metadata": "GET /accounts/fields/metadata - Get field metadata"
        }
    }

# Error handlers
@app.exception_handler(404)
async def not_found_handler(request, exc):
    return {"error": "Endpoint not found", "status_code": 404}

@app.exception_handler(500)
async def internal_error_handler(request, exc):
    return {"error": "Internal server error", "status_code": 500}

if __name__ == "__main__":
    uvicorn.run(
        "fastapi_app:app",
        host="0.0.0.0",
        port=config.CHATBOT_PORT,
        reload=config.DEBUG,
        log_level=config.LOG_LEVEL.lower()
    ) 