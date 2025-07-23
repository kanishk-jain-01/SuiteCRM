# SuiteCRM API Routing Structure

## Overview

SuiteCRM provides a RESTful API built on the Slim Framework that follows JSON API specification standards. The API supports OAuth2 authentication and provides comprehensive CRUD operations for CRM modules, relationships, and metadata.

## Architecture

### Entry Point
- **Main Entry**: `Api/index.php`
- **Core Application**: `Api/Core/app.php`
- **Framework**: Slim Framework v3 with custom configuration

### Directory Structure
```
Api/
├── Core/                    # Core API infrastructure
│   ├── Config/             # Configuration files
│   ├── Loader/             # Bootstrap loaders
│   └── Resolver/           # Configuration resolvers
├── V8/                     # API Version 8 implementation
│   ├── Controller/         # Request controllers
│   ├── Service/            # Business logic services
│   ├── Param/              # Parameter validation
│   ├── Middleware/         # Request middleware
│   ├── OAuth2/             # Authentication system
│   ├── JsonApi/            # JSON API response formatting
│   ├── Config/             # V8-specific configuration
│   └── Factory/            # Dependency injection factories
├── docs/                   # API documentation
│   └── swagger/            # OpenAPI specification
└── index.php              # API entry point
```

## Route Loading System

### 1. Bootstrap Process
```php
// Api/index.php
chdir('../');
require_once __DIR__ . '/Core/app.php';
$app->run();
```

### 2. Application Configuration
```php
// Api/Core/app.php
$app = new \Slim\App(\Api\Core\Loader\ContainerLoader::configure());
$routeLoader = new \Api\Core\Loader\RouteLoader();
$routeLoader->configureRoutes($app);
```

### 3. Route Registration
Routes are loaded from configuration files defined in `Api\Core\Config\ApiConfig`:
- `Api/V8/Config/routes.php` - Main route definitions

## Authentication & Security

### OAuth2 Implementation
- **Grant Types**: Password and Client Credentials
- **Token Endpoint**: `/access_token`
- **Token Storage**: Database-backed with `OAuth2Tokens` and `OAuth2Clients` modules
- **Security**: All API endpoints require valid OAuth2 bearer tokens

### Token Management
- **Access Tokens**: Time-limited with automatic expiration
- **Refresh Tokens**: Support for token renewal
- **Revocation**: Tokens can be revoked via logout endpoint

## Available API Endpoints

### Authentication
| Method | Endpoint | Description |
|--------|----------|-------------|
| POST | `/access_token` | Obtain OAuth2 access token |
| POST | `/V8/logout` | Revoke access token and logout |

### Module Operations
| Method | Endpoint | Description |
|--------|----------|-------------|
| GET | `/V8/module/{moduleName}` | Get module records collection |
| GET | `/V8/module/{moduleName}/{id}` | Get specific module record |
| POST | `/V8/module` | Create new module record |
| PATCH | `/V8/module` | Update existing module record |
| DELETE | `/V8/module/{moduleName}/{id}` | Delete module record |

### Relationship Operations
| Method | Endpoint | Description |
|--------|----------|-------------|
| GET | `/V8/module/{moduleName}/{id}/relationships/{linkFieldName}` | Get relationships |
| POST | `/V8/module/{moduleName}/{id}/relationships` | Create relationship |
| POST | `/V8/module/{moduleName}/{id}/relationships/{linkFieldName}` | Create relationship by link |
| DELETE | `/V8/module/{moduleName}/{id}/relationships/{linkFieldName}/{relatedBeanId}` | Delete relationship |

### Metadata & Utilities
| Method | Endpoint | Description |
|--------|----------|-------------|
| GET | `/V8/current-user` | Get current authenticated user |
| GET | `/V8/meta/modules` | Get available modules list |
| GET | `/V8/meta/fields/{moduleName}` | Get module field definitions |
| GET | `/V8/user-preferences/{id}` | Get user preferences |
| GET | `/V8/search-defs/module/{moduleName}` | Get module search definitions |
| GET | `/V8/listview/columns/{moduleName}` | Get listview column definitions |

## Controllers & Services

### Controller Architecture
All controllers extend `BaseController` which provides:
- JSON API response formatting
- Error handling with proper HTTP status codes
- Content-Type management (`application/vnd.api+json`)

### Available Controllers
- **ModuleController**: CRUD operations for CRM modules
- **RelationshipController**: Module relationship management
- **UserController**: User-related operations
- **MetaController**: Metadata and schema information
- **ListViewController**: List view configurations
- **ListViewSearchController**: Search form definitions
- **UserPreferencesController**: User preference management
- **LogoutController**: Authentication termination

## Request Processing Pipeline

### 1. URL Rewriting
```apache
# Api/.htaccess
RewriteEngine On
RewriteCond %{REQUEST_FILENAME} !-f
RewriteCond %{REQUEST_FILENAME} !-d
RewriteRule ^(.*)$ index.php [QSA,L]
```

### 2. Middleware Stack
1. **OAuth2 Resource Server Middleware**: Token validation
2. **Authorization Server Middleware**: Token generation (for `/access_token`)
3. **Parameters Middleware**: Request parameter validation and injection
4. **CORS Headers**: Cross-origin request support

### 3. Parameter Binding
Each endpoint uses parameter classes for validation:
- `GetModuleParams`, `CreateModuleParams`, `UpdateModuleParams`, `DeleteModuleParams`
- `GetRelationshipParams`, `CreateRelationshipParams`, etc.
- Parameters are automatically validated and injected into controller methods

## Request/Response Format

### JSON API Specification
The API follows [JSON API specification](https://jsonapi.org/) standards:

**Request Example**:
```json
{
  "data": {
    "type": "Accounts",
    "id": "86ee02b3-96d2-47b3-bd6d-9e1035daff3a",
    "attributes": {
      "name": "Account name",
      "phone_office": "+1234567890"
    }
  }
}
```

**Response Example**:
```json
{
  "data": {
    "type": "Accounts",
    "id": "86ee02b3-96d2-47b3-bd6d-9e1035daff3a",
    "attributes": {
      "name": "Account name",
      "phone_office": "+1234567890",
      "date_entered": "2023-01-15 10:30:00"
    },
    "relationships": {
      "contacts": {
        "links": {
          "related": "/V8/module/Accounts/86ee02b3-96d2-47b3-bd6d-9e1035daff3a/relationships/contacts"
        }
      }
    }
  }
}
```

### Query Parameters
- **Filtering**: `filter[field][operator]=value` (EQ, NEQ, GT, GTE, LT, LTE)
- **Sorting**: `sort=field` (ascending) or `sort=-field` (descending)
- **Pagination**: `page[number]=1&page[size]=20`
- **Field Selection**: `fields[ModuleName]=field1,field2`
- **Logical Operators**: `filter[operator]=AND|OR`

## Custom Route Extensions

### Extension System
Custom routes can be added via the extension system:
- **Location**: `custom/application/Ext/Api/V8/Config/routes.php`
- **Loading**: Automatically loaded via `CustomLoader::loadCustomRoutes()`

### Example Custom Route
```php
<?php
// custom/application/Ext/Api/V8/Config/routes.php

$app->get('/custom/my-endpoint', function ($request, $response, $args) {
    // Custom endpoint logic
    return $response->withJson(['message' => 'Custom endpoint response']);
});
```

### Custom Route Group
Custom routes are loaded within the `/V8/custom` group:
```php
$app->group('/custom', function () use ($app) {
    $app = CustomLoader::loadCustomRoutes($app);
});
```

## Error Handling

### HTTP Status Codes
- **200**: Success (GET, PATCH, DELETE)
- **201**: Created (POST)
- **400**: Bad Request (validation errors, invalid parameters)
- **401**: Unauthorized (invalid/missing token)
- **404**: Not Found (resource doesn't exist)
- **500**: Internal Server Error

### Error Response Format
```json
{
  "errors": [{
    "status": "400",
    "title": "Bad Request",
    "detail": "Validation error message"
  }]
}
```

## Configuration Files

### Core Configuration
- `Api/Core/Config/ApiConfig.php` - Main API configuration
- `Api/Core/Config/slim.php` - Slim framework settings

### Service Configuration
- `Api/V8/Config/services.php` - Dependency injection container
- `Api/V8/Config/services/` - Service-specific configurations
  - `controllers.php` - Controller bindings
  - `middlewares.php` - Middleware configurations
  - `params.php` - Parameter validation classes

## Security Features

### Built-in Security
- OAuth2 token-based authentication
- CORS support with configurable headers
- Input validation and sanitization
- SQL injection prevention via ORM
- XSS protection headers

### Headers
```
Access-Control-Allow-Origin: *
Access-Control-Allow-Methods: POST, PATCH, GET, OPTIONS, PUT, DELETE
Access-Control-Allow-Headers: Content-Type, Authorization, X-Requested-With
X-Content-Type-Options: nosniff
X-Frame-Options: DENY
X-XSS-Protection: 1; mode=block
```

## Extensibility

### Adding New Endpoints
1. Create controller in `Api/V8/Controller/`
2. Create service in `Api/V8/Service/`
3. Create parameter classes in `Api/V8/Param/`
4. Register in `Api/V8/Config/services/controllers.php`
5. Add routes in `Api/V8/Config/routes.php` or custom extension

### Bean Integration
The API integrates with SuiteCRM's bean system via `BeanManager`:
- Automatic module detection
- Field validation
- Relationship handling
- ACL integration
- Hook system integration

## Performance Considerations

### Caching
- Route caching via Slim framework
- Service container caching
- Bean metadata caching

### Optimization
- Lazy loading of services
- Efficient parameter binding
- Minimal memory footprint for large datasets
- Pagination support for collections

## Development & Testing

### API Documentation
- OpenAPI/Swagger specification available at `Api/docs/swagger/swagger.json`
- Interactive documentation via Swagger UI
- Comprehensive endpoint examples

### Testing
- Unit tests for controllers and services
- Integration tests for API endpoints
- OAuth2 flow testing
- Parameter validation testing

This routing structure provides a robust, secure, and extensible API framework that follows modern REST API best practices while integrating seamlessly with SuiteCRM's existing architecture. 