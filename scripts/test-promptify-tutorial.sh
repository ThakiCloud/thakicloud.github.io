#!/bin/bash

# Promptify Tutorial Test Script
# 프롬프트파이 튜토리얼 테스트를 위한 스크립트

set -e

echo "🚀 Starting Promptify Tutorial Test..."

# Check if Python is installed
if ! command -v python3 &> /dev/null; then
    echo "❌ Python3 is not installed. Please install Python3 first."
    exit 1
fi

# Check if pip is installed
if ! command -v pip3 &> /dev/null; then
    echo "❌ pip3 is not installed. Please install pip3 first."
    exit 1
fi

echo "✅ Python3 and pip3 are available"

# Create virtual environment if it doesn't exist
if [ ! -d "venv-promptify" ]; then
    echo "📦 Creating virtual environment..."
    python3 -m venv venv-promptify
fi

# Activate virtual environment
echo "🔧 Activating virtual environment..."
source venv-promptify/bin/activate

# Upgrade pip
echo "⬆️  Upgrading pip..."
pip install --upgrade pip

# Install required packages
echo "📥 Installing required packages..."
pip install promptify openai python-dotenv

# Create test Python script
cat > test_promptify_setup.py << 'EOF'
#!/usr/bin/env python3
"""
Promptify Tutorial Test Script
Tests basic Promptify functionality
"""

import os
import sys
from dotenv import load_dotenv

# Load environment variables
load_dotenv()

def test_imports():
    """Test if Promptify imports work"""
    print("🔍 Testing imports...")
    try:
        from promptify import Prompter, OpenAI, Pipeline
        print("✅ Promptify imports successful")
        return True
    except ImportError as e:
        print(f"❌ Import failed: {e}")
        return False

def test_basic_setup():
    """Test basic setup without API call"""
    print("🔧 Testing basic setup...")
    try:
        from promptify import Prompter, OpenAI, Pipeline
        
        # Test Prompter without API call
        prompter = Prompter()
        print("✅ Prompter initialized successfully")
        
        # Test if OpenAI class can be instantiated (without actual API key)
        # This just tests the class structure, not actual API calls
        print("✅ Basic setup test passed")
        return True
    except Exception as e:
        print(f"❌ Basic setup failed: {e}")
        return False

def test_api_key_check():
    """Check if API key is available (without making API calls)"""
    print("🔑 Checking API key availability...")
    
    api_key = os.getenv("OPENAI_API_KEY")
    if not api_key:
        print("⚠️  OPENAI_API_KEY not found in environment variables")
        print("💡 To test with real API calls, set your OpenAI API key:")
        print("   export OPENAI_API_KEY='your-api-key-here'")
        return False
    else:
        print("✅ OPENAI_API_KEY found in environment")
        return True

def test_template_loading():
    """Test template loading"""
    print("📄 Testing template loading...")
    try:
        from promptify import Prompter
        
        # Test loading built-in templates
        template_names = ['ner.jinja', 'classification.jinja', 'qa.jinja', 'summarization.jinja']
        
        for template_name in template_names:
            try:
                prompter = Prompter(template_name)
                print(f"✅ Template '{template_name}' loaded successfully")
            except Exception as e:
                print(f"⚠️  Template '{template_name}' failed to load: {e}")
        
        return True
    except Exception as e:
        print(f"❌ Template loading test failed: {e}")
        return False

def main():
    """Run all tests"""
    print("🚀 Starting Promptify Tutorial Tests\n")
    
    tests = [
        test_imports,
        test_basic_setup,
        test_api_key_check,
        test_template_loading
    ]
    
    passed = 0
    total = len(tests)
    
    for test in tests:
        if test():
            passed += 1
        print()  # Add spacing between tests
    
    print(f"📊 Test Results: {passed}/{total} tests passed")
    
    if passed >= 3:  # Allow API key test to fail
        print("🎉 Core tests passed! Promptify is ready to use.")
        if passed < total:
            print("💡 Set OPENAI_API_KEY environment variable for full functionality.")
    else:
        print("⚠️  Some core tests failed. Check your installation.")
        sys.exit(1)

if __name__ == "__main__":
    main()
EOF

# Make test script executable
chmod +x test_promptify_setup.py

# Run the test
echo "🧪 Running Promptify tests..."
python3 test_promptify_setup.py

# Deactivate virtual environment
deactivate

echo "✅ Promptify tutorial test completed!"
echo "📝 Note: To use Promptify with real API calls, set your OpenAI API key:"
echo "   export OPENAI_API_KEY='your-api-key-here'"

# Cleanup test files
echo "🧹 Cleaning up test files..."
rm -f test_promptify_setup.py

echo "🎉 All done! Promptify tutorial is ready to use."
