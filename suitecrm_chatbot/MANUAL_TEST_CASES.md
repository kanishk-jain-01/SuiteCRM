# 🧪 Manual Test Cases for SuiteCRM Chatbot

This document provides step-by-step test cases to manually verify all chatbot functionalities.

## 🚀 Pre-Test Setup

1. **Start the FastAPI backend:**
   ```bash
   cd suitecrm_chatbot
   python fastapi_app.py
   ```

2. **Verify health check:**
   - Open: http://localhost:8000/health
   - Ensure all components show as configured

3. **Access chat interface:**
   - Option A: Use the floating widget on your SuiteCRM instance
   - Option B: Direct API testing at http://localhost:8000/docs
   - Option C: Use curl commands (provided below)

---

## 📋 Test Case 1: Get Account Fields Metadata

**Purpose:** Understand available fields before creating accounts

### Test 1A: Basic Field Information
**Input:**
```
"What fields are available for accounts?"
```

**Expected Output:**
- List of common account fields (name, website, phone_office, email1, etc.)
- Field types and requirements
- Total count of available fields

### Test 1B: Alternative Phrasing
**Input:**
```
"Show me account field metadata"
```

**Expected Output:**
- Same metadata information
- Demonstrates natural language flexibility

---

## 🆕 Test Case 2: Account Creation

**Purpose:** Test creating accounts with various field combinations

### Test 2A: Minimal Account (Name Only)
**Input:**
```
"Create an account for TestCorp Basic"
```

**Expected Output:**
- ✅ Success message
- Account ID generated
- Name field populated
- Other fields showing N/A

### Test 2B: Complete Account Information
**Input:**
```
"Create an account for TechInnovations Inc with website www.techinnovations.com, phone 555-0123, email contact@techinnovations.com, industry Technology, and billing address 123 Innovation Drive, San Francisco, CA 94105, USA"
```

**Expected Output:**
- ✅ Success message with new account ID
- All provided fields populated correctly
- Formatted display of created account

### Test 2C: Account with Multiple Address Fields
**Input:**
```
"I need to create an account for Global Manufacturing Corp. Set the website to globalmanuf.com, industry to Manufacturing, billing address as 456 Factory Lane, Detroit, MI 48201, and shipping address as 789 Warehouse St, Chicago, IL 60601"
```

**Expected Output:**
- Account created with both billing and shipping addresses
- All address components properly separated

### Test 2D: Business Information Focus
**Input:**
```
"Create an account called StartupXYZ with industry Software, 50 employees, annual revenue 2000000, account type Customer, and description 'Innovative software startup focused on AI solutions'"
```

**Expected Output:**
- Account with business-specific fields populated
- Description and financial information captured

---

## 🔍 Test Case 3: Account Search

**Purpose:** Test various search and filtering capabilities

### Test 3A: Search by Industry
**Input:**
```
"Find all accounts in the Technology industry"
```

**Expected Output:**
- List of accounts filtered by Technology industry
- Account names, IDs, and key details
- Count of results found

### Test 3B: Search by Name Pattern
**Input:**
```
"Search for accounts with 'Tech' in their name"
```

**Expected Output:**
- Accounts containing "Tech" in the name field
- Formatted list with details

### Test 3C: Multiple Filter Search
**Input:**
```
"Show me Technology industry accounts that are Customer type"
```

**Expected Output:**
- Accounts matching both industry and account type filters
- Demonstrates complex filtering

### Test 3D: No Results Search
**Input:**
```
"Find accounts in the Unicorn industry"
```

**Expected Output:**
- "No accounts found" message
- Graceful handling of empty results

---

## 📄 Test Case 4: Account Retrieval

**Purpose:** Test getting detailed account information

### Test 4A: Get Account by ID
**Prerequisite:** Use an account ID from previous create/search tests

**Input:**
```
"Show me details for account ID [ACCOUNT_ID_FROM_PREVIOUS_TEST]"
```

**Expected Output:**
- Complete account profile
- All fields with proper formatting
- Billing and shipping addresses formatted
- Contact information displayed

### Test 4B: Alternative Phrasing
**Input:**
```
"Get me the full information for account [ACCOUNT_ID]"
```

**Expected Output:**
- Same detailed account information
- Natural language understanding demonstrated

### Test 4C: Invalid Account ID
**Input:**
```
"Show me account ID invalid-12345"
```

**Expected Output:**
- Error message about account not found
- Graceful error handling

---

## ✏️ Test Case 5: Account Updates

**Purpose:** Test modifying existing account information

### Test 5A: Single Field Update
**Prerequisite:** Use an existing account ID

**Input:**
```
"Update account [ACCOUNT_ID] with new phone number 555-9999"
```

**Expected Output:**
- ✅ Update confirmation
- Account ID and updated field listed
- Confirmation of which fields were changed

### Test 5B: Multiple Field Update
**Input:**
```
"Update account [ACCOUNT_ID] with website newsite.com and email newemail@company.com"
```

**Expected Output:**
- Multiple fields updated simultaneously
- List of all changed fields

### Test 5C: Address Update
**Input:**
```
"Change the billing address for account [ACCOUNT_ID] to 999 New Street, Boston, MA 02101"
```

**Expected Output:**
- Address fields properly updated
- Billing address components separated correctly

### Test 5D: Business Information Update
**Input:**
```
"Update account [ACCOUNT_ID] with industry Healthcare and 75 employees"
```

**Expected Output:**
- Business fields updated
- Confirmation of changes

### Test 5E: Invalid Field Update
**Input:**
```
"Update account [ACCOUNT_ID] with invalid_field_name test123"
```

**Expected Output:**
- Graceful handling of invalid fields
- Either ignore invalid fields or provide helpful error message

---

## 🗑️ Test Case 6: Account Deletion

**Purpose:** Test account removal (USE WITH CAUTION)

### Test 6A: Standard Deletion
**Prerequisite:** Create a test account specifically for deletion

**Input:**
```
"Delete account [TEST_ACCOUNT_ID]"
```

**Expected Output:**
- ⚠️ Warning about permanent deletion
- Confirmation message
- Account successfully removed

### Test 6B: Delete Non-existent Account
**Input:**
```
"Delete account fake-account-id-12345"
```

**Expected Output:**
- Error message about account not found
- No system errors or crashes

---

## 🤖 Test Case 7: Natural Language Understanding

**Purpose:** Test the AI's ability to understand various phrasings

### Test 7A: Conversational Style
**Input:**
```
"Hi! I need help creating a new company record for ABC Industries"
```

**Expected Output:**
- Understands "company record" means account
- Prompts for additional information or creates basic account

### Test 7B: Informal Language
**Input:**
```
"Can you make an account for some company called QuickStart? They're in tech and their website is quickstart.io"
```

**Expected Output:**
- Parses informal language correctly
- Creates account with provided information

### Test 7C: Step-by-step Guidance
**Input:**
```
"I want to create an account but I'm not sure what information I need"
```

**Expected Output:**
- Helpful guidance about required and optional fields
- Suggestions for account creation process

---

## 🔄 Test Case 8: Complex Workflows

**Purpose:** Test realistic business scenarios

### Test 8A: Complete Account Management Workflow
**Steps:**
1. `"What fields can I use for accounts?"`
2. `"Create an account for WorkflowTest Corp with website workflow.com"`
3. `"Find the account I just created"`
4. `"Update that account with phone 555-WORKFLOW"`
5. `"Show me the updated account details"`
6. `"Search for accounts with 'Workflow' in the name"`

**Expected:** Each step works seamlessly, data persists correctly

### Test 8B: Bulk Operations Simulation
**Steps:**
1. Create 3 different accounts in Technology industry
2. Search for Technology accounts
3. Update one account's information
4. Verify changes with detailed view

---

## 📊 Test Case 9: Edge Cases and Error Handling

### Test 9A: Empty/Malformed Requests
**Input:**
```
""
"asdf"
"Create account"
```

**Expected Output:**
- Helpful error messages or requests for clarification
- No system crashes

### Test 9B: Very Long Input
**Input:**
```
"Create an account with a very very very long description that goes on and on and includes lots of details about the company including their history, mission, vision, and future plans that span multiple paragraphs and should test how well the system handles lengthy inputs and whether it can extract the relevant information properly..."
```

**Expected Output:**
- Handles long input gracefully
- Extracts relevant information

---

## ✅ Success Criteria Checklist

For each test case, verify:

- [ ] **Functionality Works**: Core operation completes successfully
- [ ] **Data Accuracy**: Information stored/retrieved correctly
- [ ] **Error Handling**: Graceful failure for invalid inputs
- [ ] **Natural Language**: Understands various phrasings
- [ ] **Response Format**: Clear, helpful, properly formatted responses
- [ ] **Performance**: Reasonable response times
- [ ] **SuiteCRM Integration**: Data appears correctly in SuiteCRM interface

---

## 🐛 Troubleshooting Common Issues

**If tests fail:**

1. **Check API Connection:**
   ```bash
   curl http://localhost:8000/health
   ```

2. **Verify SuiteCRM Credentials:**
   - Check `.env` file configuration
   - Test OAuth2 authentication manually

3. **Review Logs:**
   - Check FastAPI application logs
   - Look for authentication or API errors

4. **Test Direct API Endpoints:**
   ```bash
   # Test chat endpoint
   curl -X POST "http://localhost:8000/chat" \
     -H "Content-Type: application/json" \
     -d '{"message": "What fields are available for accounts?"}'
   ```

---

## 📝 Testing Notes Template

Use this template to record your test results:

```
Test Case: [X.X]
Date: [DATE]
Tester: [NAME]
Input: "[TEST_INPUT]"
Expected: [EXPECTED_RESULT]
Actual: [ACTUAL_RESULT]
Status: ✅ PASS / ❌ FAIL
Notes: [ANY_OBSERVATIONS]
```

---

Happy Testing! 🎉

Remember to test in a safe environment and avoid deleting important production data. 