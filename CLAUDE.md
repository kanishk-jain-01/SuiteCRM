# CLAUDE.md

This file provides guidance to Claude Code (claude.ai/code) when working with code in this repository.

## About SuiteCRM

SuiteCRM 7.14.6 is an open-source Customer Relationship Management (CRM) application built on PHP. It's based on SugarCRM Community Edition with additional features and improvements by SalesAgility Ltd. The codebase follows a modular architecture with a custom MVC framework.

## Development Commands

### Testing
- **Run all tests**: `vendor/bin/codecept run` (using Codeception framework)
- **Unit tests**: `vendor/bin/codecept run unit`
- **API tests**: `vendor/bin/codecept run api`
- **Acceptance tests**: `vendor/bin/codecept run acceptance`
- **Install tests**: `vendor/bin/codecept run install`
- **PHPUnit tests**: `vendor/bin/phpunit -c tests/phpunit.xml.dist`

### Code Quality
- **PHP CodeSniffer**: `vendor/bin/phpcs` (PSR2 standard with exclusions)
- **PHP Stan**: `vendor/bin/phpstan analyse` (static analysis)
- **PHP CS Fixer**: `vendor/bin/php-cs-fixer fix` (code formatting)

### Dependency Management
- **Install dependencies**: `composer install`
- **Update dependencies**: `composer update`

### Build and Deployment
- **Robo tasks**: `vendor/bin/robo` (task runner)
- **Quick Repair & Rebuild**: Access via Admin > Repair > Quick Repair and Rebuild (web interface)
- **Clear cache**: Delete contents of `cache/` directory

## Architecture Overview

### Core Structure
- **Entry Point**: `index.php` → `include/MVC/preDispatch.php` → `include/MVC/SugarApplication.php`
- **MVC Framework**: Custom implementation in `include/MVC/`
  - Controllers: `include/MVC/Controller/SugarController.php`
  - Views: `include/MVC/View/SugarView.php`
  - Models: Module-specific beans extending `data/SugarBean.php`

### Module Architecture
- **Location**: `modules/[ModuleName]/`
- **Core Components**:
  - `[ModuleName].php` - Main bean class
  - `vardefs.php` - Database field definitions
  - `metadata/` - View definitions (listviewdefs.php, detailviewdefs.php, editviewdefs.php)
  - `Menu.php` - Module navigation
  - `controller.php` - Custom controller logic
  - `views/` - Custom view implementations

### Database Layer
- **Manager**: `include/database/DBManager.php` and subclasses
- **Factory**: `include/database/DBManagerFactory.php`
- **Supported DBs**: MySQL/MariaDB (primary), MSSQL, PostgreSQL via specific managers

### Template System
- **Smarty Templates**: Located in `include/Smarty/` (version 4.x)
- **Theme System**: `include/SugarTheme/` with themes in `themes/`
- **View Templates**: `.tpl` files in module directories and `include/`

### Key Libraries and Integrations
- **Email**: PHPMailer 6.x in `include/SugarPHPMailer.php`
- **PDF**: TCPDF in `include/Sugarpdf/`
- **Search**: ElasticSearch integration in `lib/Search/`
- **Charts**: Multiple chart libraries (JIT, C3, RGraph) in `include/SugarCharts/`
- **OAuth**: OAuth2 server/client support in `modules/OAuth2*/`
- **WYSIWYG**: TinyMCE and Mozaik editors

### API Structure
- **V8 API**: RESTful API in `Api/V8/` using Slim Framework 3.x
- **Legacy SOAP**: In `soap/` directory
- **Authentication**: OAuth2, SAML2, and traditional login

### Custom Development Patterns
- **Logic Hooks**: Event system in `include/utils/LogicHook.php`
- **SugarFields**: Custom field types in `include/SugarFields/`
- **Dashlets**: Dashboard widgets in `modules/*/Dashlets/`
- **Workflows**: Advanced workflow in `modules/AOW_WorkFlow/`
- **Reports**: Advanced reporting in `modules/AOR_Reports/`

### Extension Framework
- **Custom Directory**: `custom/` - Override core functionality without modifying core files
- **Extension Manager**: `ModuleInstall/ExtensionManager.php`
- **Module Builder**: Dynamic module creation via web interface

### Security Features
- **CSRF Protection**: Built into forms and AJAX requests
- **XSS Protection**: HTML sanitization in `include/HtmlSanitizer.php`
- **SQL Injection**: Prepared statements in DBManager classes
- **Access Control**: ACL system in `modules/ACL*/`
- **Security Groups**: Role-based access in `modules/SecurityGroups/`

### Configuration
- **Main Config**: `config.php` and `config_override.php`
- **Installation**: `install/` directory with setup wizard
- **Caching**: Multiple cache backends in `include/SugarCache/`

### File Upload System
- **Core**: `include/UploadFile.php`
- **Security**: File type validation and scanning hooks
- **Storage**: `upload/` directory with access controls

## Important Development Notes

- The system uses a mix of legacy and modern PHP patterns
- Many classes use `#[\AllowDynamicProperties]` for PHP 8+ compatibility
- Database queries should use DBManager methods for cross-DB compatibility
- Always use the module's bean class for data operations
- UI customizations go in `custom/` directory to preserve during upgrades
- The system has extensive logging via `SugarLogger` classes
- Time/date handling uses `TimeDate` and `SugarDateTime` classes for timezone support

## Common File Locations
- **Language files**: `modules/[Module]/language/` and `include/language/`
- **JavaScript**: `modules/[Module]/` and `include/javascript/`
- **CSS**: `themes/[Theme]/css/` and module-specific directories
- **Images**: `themes/[Theme]/images/` and `include/images/`
- **Logs**: `suitecrm.log` (configurable location)