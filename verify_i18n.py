import os
import re

def scan_files(root_dir):
    patterns = [
        (r'>\s*([A-Z][a-zA-Z0-9\s\.\!\?]+)\s*<', "Text Content"),
        (r'placeholder="([A-Za-z0-9\s\.\!\?]+)"', "Placeholder"),
        (r'title="([A-Za-z0-9\s\.\!\?]+)"', "Title"),
        (r'aria-label="([A-Za-z0-9\s\.\!\?]+)"', "Aria Label"),
        (r'alt="([A-Za-z0-9\s\.\!\?]+)"', "Alt Text"),
    ]
    
    ignore_files = ['verify_i18n.py', 'vite.config.ts', 'vite-env.d.ts', 'setupTests.ts']
    ignore_dirs = ['node_modules', 'dist', 'build', 'coverage', '.git']
    
    # Common technical terms to ignore in matches
    ignore_terms = ['App', 'React', 'AI Studio', 'HTML', 'CSS', 'SQL', 'JSON', 'ID', 'No', 'Yes', 'OK', 'Loading...', 'Error', 'Success', 'Save', 'Cancel', 'Delete', 'Edit', 'Create', 'Close', 'MySQL', 'PostgreSQL', 'SQLite', 'OpenAI', 'Anthropic', 'Gemini', 'DeepSeek', 'Qwen', 'Moonshot', 'Ollama']
    
    # Files that are allowed to have English (e.g. config, tests)
    allowed_files = ['reportWebVitals.ts', 'main.tsx', 'router.tsx']

    print(f"Scanning {root_dir} for potential hardcoded English text...")
    
    found_issues = False
    
    for root, dirs, files in os.walk(root_dir):
        # Filter directories
        dirs[:] = [d for d in dirs if d not in ignore_dirs]
        
        for file in files:
            if not file.endswith('.tsx') and not file.endswith('.ts'):
                continue
                
            if file in ignore_files or file in allowed_files:
                continue
                
            path = os.path.join(root, file)
            try:
                with open(path, 'r', encoding='utf-8') as f:
                    content = f.read()
                    
                lines = content.split('\n')
                
                for i, line in enumerate(lines):
                    # Skip lines with t('...') call as they are likely translated
                    if "t('" in line or 't("' in line:
                        continue
                        
                    # Skip comments
                    if line.strip().startswith('//') or line.strip().startswith('/*'):
                        continue
                        
                    for pattern, type_name in patterns:
                        matches = re.finditer(pattern, line)
                        for match in matches:
                            text = match.group(1).strip()
                            if len(text) < 2: continue
                            if text in ignore_terms: continue
                            
                            # Simple heuristic: if it contains no spaces and is PascalCase, it might be a component name
                            if ' ' not in text and text[0].isupper() and text != text.upper():
                                # Likely component name e.g. <Sidebar /> matches >Sidebar< ? No, regex expects >Text<
                                # But <Component>Text</Component> -> Text
                                pass
                                
                            print(f"[POTENTIAL] {file}:{i+1} [{type_name}]: '{text}'")
                            found_issues = True
            except Exception as e:
                print(f"Error reading {path}: {e}")

    if not found_issues:
        print("No obvious hardcoded English text found.")
    else:
        print("Scan complete. Please review potential issues.")

if __name__ == "__main__":
    scan_files(r"d:\Code\KY\frontend\src")
