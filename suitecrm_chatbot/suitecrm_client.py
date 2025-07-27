"""SuiteCRM API Client for account operations."""

import asyncio
import logging
from typing import Dict, Any, Optional, List
import httpx
from datetime import datetime, timedelta
from config import config

logger = logging.getLogger(__name__)

class SuiteCRMClient:
    """Client for interacting with SuiteCRM API."""
    
    def __init__(self):
        self.base_url = config.SUITECRM_BASE_URL
        self.client_id = config.SUITECRM_CLIENT_ID
        self.client_secret = config.SUITECRM_CLIENT_SECRET
        self.username = config.SUITECRM_USERNAME
        self.password = config.SUITECRM_PASSWORD
        self.access_token: Optional[str] = None
        self.token_expires_at: Optional[datetime] = None
        
    async def _get_access_token(self) -> str:
        """Get OAuth2 access token from SuiteCRM."""
        if (self.access_token and self.token_expires_at and 
            datetime.now() < self.token_expires_at - timedelta(minutes=5)):
            return self.access_token
            
        async with httpx.AsyncClient() as client:
            token_url = f"{self.base_url.rstrip('/').replace('/V8', '')}/access_token"
            
            data = {
                "grant_type": "password",
                "client_id": self.client_id,
                "client_secret": self.client_secret,
                "username": self.username,
                "password": self.password,
            }
            
            try:
                response = await client.post(token_url, data=data)
                response.raise_for_status()
                
                token_data = response.json()
                self.access_token = token_data["access_token"]
                expires_in = token_data.get("expires_in", 3600)
                self.token_expires_at = datetime.now() + timedelta(seconds=expires_in)
                
                logger.info("Successfully obtained access token")
                return self.access_token
                
            except httpx.HTTPStatusError as e:
                logger.error(f"Failed to get access token: HTTP {e.response.status_code} - {e.response.text}")
                raise Exception(f"Authentication failed: {e.response.text}")
            except Exception as e:
                logger.error(f"Error getting access token: {str(e)}")
                raise
    
    async def _make_request(self, method: str, endpoint: str, **kwargs) -> Dict[str, Any]:
        """Make authenticated request to SuiteCRM API."""
        
        token = await self._get_access_token()
        
        headers = {
            "Authorization": f"Bearer {token}",
            "Content-Type": "application/json",
            "Accept": "application/json"
        }
        
        if "headers" in kwargs:
            headers.update(kwargs["headers"])
            
        kwargs["headers"] = headers
        
        # Fix double slash issue
        full_url = f"{self.base_url.rstrip('/')}/{endpoint.lstrip('/')}"
        
        async with httpx.AsyncClient() as client:
            try:
                response = await client.request(method, full_url, **kwargs)
                response.raise_for_status()
                return response.json()
                
            except httpx.HTTPStatusError as e:
                logger.error(f"API request failed: {method} {e.request.url} - HTTP {e.response.status_code}: {e.response.text}")
                raise Exception(f"API request failed: {e.response.text}")
            except Exception as e:
                logger.error(f"Error making {method} request to {full_url}: {str(e)}")
                raise
    
    async def create_account(self, account_data: Dict[str, Any]) -> Dict[str, Any]:
        """Create a new account in SuiteCRM.
        
        Args:
            account_data: Dictionary containing account information
            
        Returns:
            Dictionary containing the created account data
        """
        payload = {
            "data": {
                "type": "Accounts",
                "attributes": account_data
            }
        }
        
        logger.info(f"Creating account with data: {account_data}")
        result = await self._make_request("POST", "/module", json=payload)
        account_id = result.get('data', {}).get('id')
        logger.info(f"Account '{account_data.get('name')}' created successfully with ID: {account_id}")
        return result
    
    async def get_account(self, account_id: str) -> Dict[str, Any]:
        """Get account by ID.
        
        Args:
            account_id: The account ID to retrieve
            
        Returns:
            Dictionary containing account data
        """
        result = await self._make_request("GET", f"/module/Accounts/{account_id}")
        return result
    
    async def update_account(self, account_id: str, account_data: Dict[str, Any]) -> Dict[str, Any]:
        """Update an existing account.
        
        Args:
            account_id: The account ID to update
            account_data: Dictionary containing updated account information
            
        Returns:
            Dictionary containing the updated account data
        """
        payload = {
            "data": {
                "type": "Accounts",
                "id": account_id,
                "attributes": account_data
            }
        }
        
        result = await self._make_request("PATCH", "/module", json=payload)
        return result
    
    async def search_accounts(self, filters: Optional[Dict[str, Any]] = None, 
                            fields: Optional[List[str]] = None) -> Dict[str, Any]:
        """Search for accounts with optional filters.
        
        Args:
            filters: Dictionary of filter conditions
            fields: List of fields to include in response
            
        Returns:
            Dictionary containing search results
        """
        params = {}
        
        if filters:
            for field, value in filters.items():
                params[f"filter[{field}][eq]"] = value
                
        if fields:
            params["fields[Accounts]"] = ",".join(fields)
        
        result = await self._make_request("GET", "/module/Accounts", params=params)
        return result
    
    async def delete_account(self, account_id: str) -> Dict[str, Any]:
        """Delete an account by ID.
        
        Args:
            account_id: The account ID to delete
            
        Returns:
            Dictionary containing deletion confirmation
        """
        result = await self._make_request("DELETE", f"/module/Accounts/{account_id}")
        return result
    
    async def get_account_fields_metadata(self) -> Dict[str, Any]:
        """Get metadata about account fields.
        
        Returns:
            Dictionary containing field metadata
        """
        result = await self._make_request("GET", "/meta/fields/Accounts")
        return result 