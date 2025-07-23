"""Main LangGraph agent for SuiteCRM account management."""

import logging
from typing import Dict, Any, List, Optional, Annotated
from langchain_openai import ChatOpenAI
from langchain.schema import SystemMessage, HumanMessage, AIMessage
from langgraph.graph import StateGraph, MessagesState, START, END
from langgraph.prebuilt import ToolNode
from langgraph.graph.message import add_messages
from tools import SUITECRM_TOOLS
from config import config

logging.basicConfig(level=config.LOG_LEVEL)
logger = logging.getLogger(__name__)

class SuiteCRMAgentState(MessagesState):
    """State for the SuiteCRM agent."""
    pass

class SuiteCRMAgent:
    """LangGraph agent for SuiteCRM account management."""
    
    def __init__(self):
        """Initialize the SuiteCRM agent."""
        self.llm = ChatOpenAI(
            model=config.DEFAULT_MODEL,
            temperature=config.TEMPERATURE,
            max_tokens=config.MAX_TOKENS,
            openai_api_key=config.OPENAI_API_KEY
        )
        
        # Bind tools to the LLM
        self.llm_with_tools = self.llm.bind_tools(SUITECRM_TOOLS)
        
        # Create the graph
        self.graph = self._create_graph()
        
    def _create_graph(self) -> StateGraph:
        """Create the LangGraph workflow."""
        workflow = StateGraph(SuiteCRMAgentState)
        
        # Add nodes
        workflow.add_node("agent", self._agent_node)
        workflow.add_node("tools", ToolNode(SUITECRM_TOOLS))
        
        # Add edges
        workflow.add_edge(START, "agent")
        workflow.add_conditional_edges(
            "agent",
            self._should_continue,
            {
                "continue": "tools",
                "end": END,
            }
        )
        workflow.add_edge("tools", "agent")
        
        return workflow.compile()
    
    def _agent_node(self, state: SuiteCRMAgentState) -> Dict[str, Any]:
        """Main agent node that processes user input and decides on actions."""
        
        # Create system message
        system_prompt = """You are a helpful assistant for SuiteCRM account management. You can help users with:

🏢 **Account Operations:**
- Create new accounts with all relevant details
- Search for existing accounts with various filters
- View detailed account information
- Update account information
- Delete accounts (with warnings)
- Get information about available account fields

📋 **Available Tools:**
1. **create_account** - Create a new account (requires name, optional: website, phone, email, addresses, industry, etc.)
2. **search_accounts** - Search for accounts by name, website, industry, or account type
3. **get_account** - Get detailed information about a specific account by ID
4. **update_account** - Update an existing account's information
5. **delete_account** - Delete an account (use with caution!)
6. **get_account_fields** - Get information about available account fields

💡 **Guidelines:**
- Always ask for required information (like account name) when creating accounts
- Provide helpful suggestions for optional fields when creating accounts
- Confirm before deleting accounts
- Format responses clearly with appropriate emojis and markdown
- If users ask about account creation, guide them through the process step by step
- When searching, suggest useful filters to narrow down results

🎯 **SuiteCRM Integration:**
You're directly connected to a SuiteCRM instance via its REST API. All operations are performed in real-time on the actual CRM system.

Be helpful, professional, and make sure to explain what you're doing when performing operations."""

        messages = [SystemMessage(content=system_prompt)] + state["messages"]
        
        # Get response from LLM
        response = self.llm_with_tools.invoke(messages)
        
        return {"messages": [response]}
    
    def _should_continue(self, state: SuiteCRMAgentState) -> str:
        """Determine if we should continue to tools or end."""
        last_message = state["messages"][-1]
        
        # If the LLM makes a tool call, continue to tools
        if hasattr(last_message, 'tool_calls') and last_message.tool_calls:
            return "continue"
        
        # Otherwise, end the conversation
        return "end"
    
    async def chat(self, message: str) -> str:
        """Chat with the agent.
        
        Args:
            message: User message
            
        Returns:
            Agent response
        """
        try:
            # Create initial state
            initial_state = {
                "messages": [HumanMessage(content=message)]
            }
            
            # Run the graph
            result = await self.graph.ainvoke(initial_state)
            
            # Get the last message from the agent
            last_message = result["messages"][-1]
            
            if hasattr(last_message, 'content'):
                return last_message.content
            else:
                return str(last_message)
                
        except Exception as e:
            logger.error(f"Error in chat: {str(e)}")
            return f"❌ I encountered an error: {str(e)}. Please try again or check your configuration."
    
    def chat_sync(self, message: str) -> str:
        """Synchronous chat with the agent.
        
        Args:
            message: User message
            
        Returns:
            Agent response
        """
        try:
            # Create initial state
            initial_state = {
                "messages": [HumanMessage(content=message)]
            }
            
            # Run the graph
            result = self.graph.invoke(initial_state)
            
            # Get the last message from the agent
            last_message = result["messages"][-1]
            
            if hasattr(last_message, 'content'):
                return last_message.content
            else:
                return str(last_message)
                
        except Exception as e:
            logger.error(f"Error in chat: {str(e)}")
            return f"❌ I encountered an error: {str(e)}. Please try again or check your configuration."

def create_suitecrm_agent() -> SuiteCRMAgent:
    """Factory function to create a SuiteCRM agent."""
    try:
        config.validate()
        return SuiteCRMAgent()
    except Exception as e:
        logger.error(f"Failed to create SuiteCRM agent: {str(e)}")
        raise

# Example usage and testing
if __name__ == "__main__":
    import asyncio
    
    async def test_agent():
        """Test the agent with some example interactions."""
        agent = create_suitecrm_agent()
        
        test_messages = [
            "Hello! Can you help me understand what you can do?",
            "I want to create a new account for a company called 'Tech Solutions Inc'",
            "What fields are available when creating an account?",
            "Search for accounts in the technology industry",
        ]
        
        for message in test_messages:
            print(f"\n👤 User: {message}")
            response = await agent.chat(message)
            print(f"🤖 Agent: {response}")
            print("-" * 80)
    
    # Run the test if this script is executed directly
    if config.OPENAI_API_KEY:
        asyncio.run(test_agent())
    else:
        print("Please set OPENAI_API_KEY in your environment to test the agent.") 