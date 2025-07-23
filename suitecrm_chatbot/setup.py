"""Setup script for SuiteCRM LangGraph Chatbot."""

from setuptools import setup, find_packages

# Read README for long description
with open("README.md", "r", encoding="utf-8") as fh:
    long_description = fh.read()

# Read requirements
with open("requirements.txt", "r", encoding="utf-8") as fh:
    requirements = [line.strip() for line in fh if line.strip() and not line.startswith("#")]

setup(
    name="suitecrm-langgraph-chatbot",
    version="1.0.0",
    author="SuiteCRM Community",
    author_email="community@suitecrm.com",
    description="AI-powered chatbot for SuiteCRM account management using LangGraph",
    long_description=long_description,
    long_description_content_type="text/markdown",
    url="https://github.com/salesagility/SuiteCRM",
    packages=find_packages(),
    classifiers=[
        "Development Status :: 4 - Beta",
        "Intended Audience :: Developers",
        "Intended Audience :: End Users/Desktop",
        "License :: OSI Approved :: GNU Affero General Public License v3",
        "Operating System :: OS Independent",
        "Programming Language :: Python :: 3",
        "Programming Language :: Python :: 3.8",
        "Programming Language :: Python :: 3.9",
        "Programming Language :: Python :: 3.10",
        "Programming Language :: Python :: 3.11",
        "Topic :: Office/Business",
        "Topic :: Office/Business :: CRM",
        "Topic :: Scientific/Engineering :: Artificial Intelligence",
        "Topic :: Communications :: Chat",
    ],
    python_requires=">=3.8",
    install_requires=requirements,
    extras_require={
        "dev": [
            "pytest",
            "pytest-asyncio",
            "black",
            "isort",
            "flake8",
            "mypy",
        ],
        "test": [
            "pytest",
            "pytest-asyncio",
            "pytest-mock",
            "responses",
        ],
    },
    entry_points={
        "console_scripts": [
            "suitecrm-chatbot=agent:main",
            "suitecrm-chatbot-api=fastapi_app:main",
            "suitecrm-chatbot-web=streamlit_app:main",
        ],
    },
    include_package_data=True,
    package_data={
        "": ["*.md", "*.txt", "*.yml", "*.yaml"],
    },
    keywords=[
        "suitecrm",
        "crm",
        "chatbot",
        "langgraph",
        "ai",
        "assistant",
        "automation",
        "account-management",
        "openai",
    ],
    project_urls={
        "Bug Reports": "https://github.com/salesagility/SuiteCRM/issues",
        "Source": "https://github.com/salesagility/SuiteCRM",
        "Documentation": "https://docs.suitecrm.com/",
        "SuiteCRM Community": "https://suitecrm.com/",
    },
) 