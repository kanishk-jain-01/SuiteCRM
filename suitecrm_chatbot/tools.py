"""LangGraph tools for SuiteCRM account operations."""

import json
import logging
from typing import Dict, Any, List, Optional, Type
from langchain.tools import BaseTool
from pydantic import BaseModel, Field
from suitecrm_client import SuiteCRMClient

logger = logging.getLogger(__name__)

class CreateAccountInput(BaseModel):
    """Input schema for creating an account."""
    name: str = Field(..., description="The account name (required)")
    website: Optional[str] = Field(None, description="The account website URL")
    phone_office: Optional[str] = Field(None, description="Office phone number")
    phone_fax: Optional[str] = Field(None, description="Fax number")
    email1: Optional[str] = Field(None, description="Primary email address")
    billing_address_street: Optional[str] = Field(None, description="Billing street address")
    billing_address_city: Optional[str] = Field(None, description="Billing city")
    billing_address_state: Optional[str] = Field(None, description="Billing state")
    billing_address_postalcode: Optional[str] = Field(None, description="Billing postal code")
    billing_address_country: Optional[str] = Field(None, description="Billing country")
    shipping_address_street: Optional[str] = Field(None, description="Shipping street address")
    shipping_address_city: Optional[str] = Field(None, description="Shipping city")
    shipping_address_state: Optional[str] = Field(None, description="Shipping state")
    shipping_address_postalcode: Optional[str] = Field(None, description="Shipping postal code")
    shipping_address_country: Optional[str] = Field(None, description="Shipping country")
    industry: Optional[str] = Field(None, description="Industry type")
    account_type: Optional[str] = Field(None, description="Account type")
    annual_revenue: Optional[str] = Field(None, description="Annual revenue")
    employees: Optional[str] = Field(None, description="Number of employees")
    description: Optional[str] = Field(None, description="Account description")
    rating: Optional[str] = Field(None, description="Account rating")
    ownership: Optional[str] = Field(None, description="Ownership type")
    ticker_symbol: Optional[str] = Field(None, description="Stock ticker symbol")
    sic_code: Optional[str] = Field(None, description="SIC code")

class SearchAccountInput(BaseModel):
    """Input schema for searching accounts."""
    name: Optional[str] = Field(None, description="Filter by account name")
    website: Optional[str] = Field(None, description="Filter by website")
    industry: Optional[str] = Field(None, description="Filter by industry")
    account_type: Optional[str] = Field(None, description="Filter by account type")
    fields: Optional[List[str]] = Field(None, description="Specific fields to return")

class GetAccountInput(BaseModel):
    """Input schema for getting an account by ID."""
    account_id: str = Field(..., description="The account ID to retrieve")

class UpdateAccountInput(BaseModel):
    """Input schema for updating an account."""
    account_id: str = Field(..., description="The account ID to update")
    name: Optional[str] = Field(None, description="The account name")
    website: Optional[str] = Field(None, description="The account website URL")
    phone_office: Optional[str] = Field(None, description="Office phone number")
    email1: Optional[str] = Field(None, description="Primary email address")
    billing_address_street: Optional[str] = Field(None, description="Billing street address")
    billing_address_city: Optional[str] = Field(None, description="Billing city")
    billing_address_state: Optional[str] = Field(None, description="Billing state")
    billing_address_country: Optional[str] = Field(None, description="Billing country")
    industry: Optional[str] = Field(None, description="Industry type")
    description: Optional[str] = Field(None, description="Account description")

class DeleteAccountInput(BaseModel):
    """Input schema for deleting an account."""
    account_id: str = Field(..., description="The account ID to delete")

class CreateAccountTool(BaseTool):
    """Tool for creating a new account in SuiteCRM."""
    
    name: str = "create_account"
    description: str = """Create a new account in SuiteCRM. 
    Required: name
    Optional: website, phone_office, email1, billing/shipping address fields, industry, 
    account_type, annual_revenue, employees, description, rating, ownership, etc.
    Returns the created account data including the new account ID."""
    args_schema: Type[BaseModel] = CreateAccountInput
    
    def _run(self, **kwargs) -> str:
        """Create account synchronously."""
        import asyncio
        return asyncio.run(self._arun(**kwargs))
    
    async def _arun(self, **kwargs) -> str:
        """Create account asynchronously."""
        try:
            client = SuiteCRMClient()
            
            # Remove None values
            account_data = {k: v for k, v in kwargs.items() if v is not None}
            
            result = await client.create_account(account_data)
            
            account_info = result.get('data', {})
            account_id = account_info.get('id')
            attributes = account_info.get('attributes', {})
            
            return f"✅ Account created successfully!\n\n" \
                   f"**Account ID:** {account_id}\n" \
                   f"**Name:** {attributes.get('name', 'N/A')}\n" \
                   f"**Website:** {attributes.get('website', 'N/A')}\n" \
                   f"**Phone:** {attributes.get('phone_office', 'N/A')}\n" \
                   f"**Email:** {attributes.get('email1', 'N/A')}\n" \
                   f"**Industry:** {attributes.get('industry', 'N/A')}\n\n" \
                   f"You can now view this account in SuiteCRM or perform additional operations."
                   
        except Exception as e:
            logger.error(f"Error creating account: {str(e)}")
            return f"❌ Error creating account: {str(e)}"

class SearchAccountsTool(BaseTool):
    """Tool for searching accounts in SuiteCRM."""
    
    name: str = "search_accounts"
    description: str = """Search for accounts in SuiteCRM with optional filters.
    You can filter by name, website, industry, account_type.
    You can also specify which fields to return.
    Returns a list of matching accounts."""
    args_schema: Type[BaseModel] = SearchAccountInput
    
    def _run(self, **kwargs) -> str:
        """Search accounts synchronously."""
        import asyncio
        return asyncio.run(self._arun(**kwargs))
    
    async def _arun(self, **kwargs) -> str:
        """Search accounts asynchronously."""
        try:
            client = SuiteCRMClient()
            
            # Prepare filters
            filters = {k: v for k, v in kwargs.items() 
                      if v is not None and k != 'fields'}
            
            fields = kwargs.get('fields')
            
            result = await client.search_accounts(filters=filters, fields=fields)
            
            accounts = result.get('data', [])
            
            if not accounts:
                return "🔍 No accounts found matching the search criteria."
            
            response = f"🔍 Found {len(accounts)} account(s):\n\n"
            
            for account in accounts[:10]:  # Limit to first 10 results
                attributes = account.get('attributes', {})
                response += f"**{attributes.get('name', 'N/A')}** (ID: {account.get('id')})\n"
                response += f"  • Website: {attributes.get('website', 'N/A')}\n"
                response += f"  • Phone: {attributes.get('phone_office', 'N/A')}\n"
                response += f"  • Industry: {attributes.get('industry', 'N/A')}\n\n"
            
            if len(accounts) > 10:
                response += f"... and {len(accounts) - 10} more accounts"
                
            return response
            
        except Exception as e:
            logger.error(f"Error searching accounts: {str(e)}")
            return f"❌ Error searching accounts: {str(e)}"

class GetAccountTool(BaseTool):
    """Tool for retrieving a specific account by ID."""
    
    name: str = "get_account"
    description: str = """Get detailed information about a specific account by its ID.
    Requires the account ID.
    Returns complete account information."""
    args_schema: Type[BaseModel] = GetAccountInput
    
    def _run(self, account_id: str) -> str:
        """Get account synchronously."""
        import asyncio
        return asyncio.run(self._arun(account_id=account_id))
    
    async def _arun(self, account_id: str) -> str:
        """Get account asynchronously."""
        try:
            client = SuiteCRMClient()
            result = await client.get_account(account_id)
            
            account_info = result.get('data', {})
            attributes = account_info.get('attributes', {})
            
            response = f"📄 **Account Details**\n\n"
            response += f"**ID:** {account_info.get('id')}\n"
            response += f"**Name:** {attributes.get('name', 'N/A')}\n"
            response += f"**Website:** {attributes.get('website', 'N/A')}\n"
            response += f"**Phone:** {attributes.get('phone_office', 'N/A')}\n"
            response += f"**Email:** {attributes.get('email1', 'N/A')}\n"
            response += f"**Industry:** {attributes.get('industry', 'N/A')}\n"
            response += f"**Type:** {attributes.get('account_type', 'N/A')}\n"
            response += f"**Employees:** {attributes.get('employees', 'N/A')}\n"
            response += f"**Revenue:** {attributes.get('annual_revenue', 'N/A')}\n"
            response += f"**Description:** {attributes.get('description', 'N/A')}\n\n"
            
            # Billing Address
            billing_parts = [
                attributes.get('billing_address_street'),
                attributes.get('billing_address_city'),
                attributes.get('billing_address_state'),
                attributes.get('billing_address_postalcode'),
                attributes.get('billing_address_country')
            ]
            billing_address = ', '.join([part for part in billing_parts if part])
            response += f"**Billing Address:** {billing_address or 'N/A'}\n"
            
            # Shipping Address
            shipping_parts = [
                attributes.get('shipping_address_street'),
                attributes.get('shipping_address_city'),
                attributes.get('shipping_address_state'),
                attributes.get('shipping_address_postalcode'),
                attributes.get('shipping_address_country')
            ]
            shipping_address = ', '.join([part for part in shipping_parts if part])
            response += f"**Shipping Address:** {shipping_address or 'N/A'}\n"
            
            return response
            
        except Exception as e:
            logger.error(f"Error getting account: {str(e)}")
            return f"❌ Error retrieving account: {str(e)}"

class UpdateAccountTool(BaseTool):
    """Tool for updating an existing account."""
    
    name: str = "update_account"
    description: str = """Update an existing account in SuiteCRM.
    Requires the account ID and at least one field to update.
    Returns the updated account information."""
    args_schema: Type[BaseModel] = UpdateAccountInput
    
    def _run(self, **kwargs) -> str:
        """Update account synchronously."""
        import asyncio
        return asyncio.run(self._arun(**kwargs))
    
    async def _arun(self, **kwargs) -> str:
        """Update account asynchronously."""
        try:
            client = SuiteCRMClient()
            
            account_id = kwargs.pop('account_id')
            # Remove None values
            account_data = {k: v for k, v in kwargs.items() if v is not None}
            
            if not account_data:
                return "❌ No data provided to update. Please specify at least one field to update."
            
            result = await client.update_account(account_id, account_data)
            
            account_info = result.get('data', {})
            attributes = account_info.get('attributes', {})
            
            return f"✅ Account updated successfully!\n\n" \
                   f"**Account ID:** {account_id}\n" \
                   f"**Name:** {attributes.get('name', 'N/A')}\n" \
                   f"**Updated fields:** {', '.join(account_data.keys())}"
                   
        except Exception as e:
            logger.error(f"Error updating account: {str(e)}")
            return f"❌ Error updating account: {str(e)}"

class DeleteAccountTool(BaseTool):
    """Tool for deleting an account."""
    
    name: str = "delete_account"
    description: str = """Delete an account from SuiteCRM by ID.
    Warning: This action cannot be undone!
    Requires the account ID.
    Returns confirmation of deletion."""
    args_schema: Type[BaseModel] = DeleteAccountInput
    
    def _run(self, account_id: str) -> str:
        """Delete account synchronously."""
        import asyncio
        return asyncio.run(self._arun(account_id=account_id))
    
    async def _arun(self, account_id: str) -> str:
        """Delete account asynchronously."""
        try:
            client = SuiteCRMClient()
            result = await client.delete_account(account_id)
            
            return f"✅ Account {account_id} has been deleted successfully."
            
        except Exception as e:
            logger.error(f"Error deleting account: {str(e)}")
            return f"❌ Error deleting account: {str(e)}"

class GetAccountFieldsTool(BaseTool):
    """Tool for getting account field metadata."""
    
    name: str = "get_account_fields"
    description: str = """Get metadata about available account fields in SuiteCRM.
    This helps understand what fields are available for creating or updating accounts.
    Returns field information including types, descriptions, and requirements."""
    
    def _run(self) -> str:
        """Get account fields synchronously."""
        import asyncio
        return asyncio.run(self._arun())
    
    async def _arun(self) -> str:
        """Get account fields asynchronously."""
        try:
            client = SuiteCRMClient()
            result = await client.get_account_fields_metadata()
            
            fields_data = result.get('data', {}).get('attributes', {})
            
            response = "📋 **Available Account Fields:**\n\n"
            
            # Common fields to highlight
            common_fields = [
                'name', 'website', 'phone_office', 'email1', 'industry', 
                'account_type', 'billing_address_street', 'billing_address_city',
                'shipping_address_street', 'shipping_address_city', 'description'
            ]
            
            response += "**Common Fields:**\n"
            for field in common_fields:
                if field in fields_data:
                    field_info = fields_data[field]
                    field_type = field_info.get('type', 'unknown')
                    required = field_info.get('required', False)
                    req_indicator = ' (Required)' if required else ''
                    response += f"• **{field}** ({field_type}){req_indicator}\n"
            
            response += f"\n**Total available fields:** {len(fields_data)}\n"
            response += "\nUse the create_account tool with any of these fields to create a new account."
            
            return response
            
        except Exception as e:
            logger.error(f"Error getting account fields: {str(e)}")
            return f"❌ Error getting account fields: {str(e)}"

# List of all available tools
SUITECRM_TOOLS = [
    CreateAccountTool(),
    SearchAccountsTool(),
    GetAccountTool(),
    UpdateAccountTool(),
    DeleteAccountTool(),
    GetAccountFieldsTool(),
] 