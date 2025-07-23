"""Configuration file for SuiteCRM LangGraph Chatbot."""

import os
from typing import Optional
from dotenv import load_dotenv

# Load environment variables
load_dotenv()

class Config:
    """Configuration class for the SuiteCRM chatbot."""
    
    # OpenAI Configuration
    OPENAI_API_KEY: Optional[str] = os.getenv("OPENAI_API_KEY")
    
    # SuiteCRM API Configuration
    SUITECRM_BASE_URL: str = os.getenv("SUITECRM_BASE_URL", "http://localhost/Api/V8")
    SUITECRM_CLIENT_ID: Optional[str] = os.getenv("SUITECRM_CLIENT_ID")
    SUITECRM_CLIENT_SECRET: Optional[str] = os.getenv("SUITECRM_CLIENT_SECRET")
    SUITECRM_USERNAME: Optional[str] = os.getenv("SUITECRM_USERNAME")
    SUITECRM_PASSWORD: Optional[str] = os.getenv("SUITECRM_PASSWORD")
    
    # Chatbot Configuration
    CHATBOT_PORT: int = int(os.getenv("CHATBOT_PORT", "8000"))
    DEBUG: bool = os.getenv("DEBUG", "True").lower() == "true"
    LOG_LEVEL: str = os.getenv("LOG_LEVEL", "INFO")
    
    # Model Configuration
    DEFAULT_MODEL: str = "gpt-4-turbo-preview"
    MAX_TOKENS: int = 4000
    TEMPERATURE: float = 0.1
    
    @classmethod
    def validate(cls) -> None:
        """Validate required configuration values."""
        if not cls.OPENAI_API_KEY:
            raise ValueError("OPENAI_API_KEY is required")
        if not cls.SUITECRM_CLIENT_ID:
            raise ValueError("SUITECRM_CLIENT_ID is required")
        if not cls.SUITECRM_CLIENT_SECRET:
            raise ValueError("SUITECRM_CLIENT_SECRET is required")

config = Config() 