#!/usr/bin/env python3

import sys
import os

def validate_yaml_syntax(file_path):
    """Simple YAML syntax validation by checking basic structure"""
    try:
        with open(file_path, 'r') as f:
            content = f.read()
            
        # Basic checks
        if 'openapi:' not in content:
            return False, "Missing openapi: field"
            
        if 'info:' not in content:
            return False, "Missing info: field"
            
        if 'paths:' not in content:
            return False, "Missing paths: field"
            
        # Check for basic YAML syntax issues
        lines = content.split('\n')
        indent_stack = []
        
        for i, line in enumerate(lines, 1):
            stripped = line.lstrip()
            if not stripped or stripped.startswith('#'):
                continue
                
            indent = len(line) - len(stripped)
            
            # Check if indentation is consistent (even number of spaces)
            if indent % 2 != 0:
                return False, f"Line {i}: Inconsistent indentation ({indent} spaces)"
                
            # Check if indentation decreases by more than 2 spaces at a time
            # (allow 4 spaces for YAML lists/blocks)
            if indent_stack and indent < indent_stack[-1]:
                if indent_stack[-1] - indent > 4:
                    return False, f"Line {i}: Indentation decreased by more than 4 spaces"
                while indent_stack and indent < indent_stack[-1]:
                    indent_stack.pop()
                    
            indent_stack.append(indent)
            
        return True, "Valid YAML structure"
        
    except Exception as e:
        return False, f"Error reading file: {e}"

def main():
    if len(sys.argv) < 2:
        print("Usage: python3 validate_yaml.py <file1> [<file2> ...]")
        sys.exit(1)
        
    for file_path in sys.argv[1:]:
        if not os.path.exists(file_path):
            print(f"❌ File not found: {file_path}")
            continue
            
        is_valid, message = validate_yaml_syntax(file_path)
        if is_valid:
            print(f"✅ {file_path}: {message}")
        else:
            print(f"❌ {file_path}: {message}")

if __name__ == "__main__":
    main()