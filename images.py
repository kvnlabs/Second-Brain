import os
import re
import shutil

# Paths (using raw strings to handle Windows backslashes correctly)
posts_dir = r"D:\Dev\Second-Brain\content\posts"
attachments_dir = r"D:\Obsidian\Vault\Attachments"
static_media_dir = r"D:\Dev\Second-Brain\static\media"

# Expanded list of file extensions
SUPPORTED_EXTENSIONS = [
    # Images
    '.png', '.jpg', '.jpeg', '.gif', '.webp', '.bmp', '.heic', '.svg', 
    
    # Video files
    '.mp4', '.avi', '.mov', '.mkv', '.wmv', '.flv', '.webm', 
    
    # Audio files
    '.mp3', '.wav', '.ogg', '.flac', 
    
    # Document files
    '.pdf', '.docx', '.xlsx', '.pptx'
]

# Step 1: Process each markdown file in the posts directory
for filename in os.listdir(posts_dir):
    if filename.endswith(".md"):
        filepath = os.path.join(posts_dir, filename)
        
        with open(filepath, "r", encoding="utf-8") as file:
            content = file.read()
        
        # Step 2: Find all file links with supported extensions
        file_types_pattern = '|'.join(map(re.escape, SUPPORTED_EXTENSIONS))
        files = re.findall(rf'\[\[([^]]*\.(?:{file_types_pattern[1:]}))\]\]', content)
        
        # Step 3: Replace file links and copy files
        for file_item in files:
            # Determine file type
            file_ext = os.path.splitext(file_item)[1].lower()
            
            # Create appropriate markdown link based on file type
            if file_ext in ['.png', '.jpg', '.jpeg', '.gif', '.webp', '.bmp', '.heic', '.svg']:
                markdown_link = f"![{file_item}](/media/{file_item.replace(' ', '%20')})"
            elif file_ext in ['.mp4', '.avi', '.mov', '.mkv', '.wmv', '.flv', '.webm']:
                markdown_link = f"[Video: {file_item}](/media/{file_item.replace(' ', '%20')})"
            elif file_ext in ['.mp3', '.wav', '.ogg', '.flac']:
                markdown_link = f"[Audio: {file_item}](/media/{file_item.replace(' ', '%20')})"
            else:
                markdown_link = f"[File: {file_item}](/media/{file_item.replace(' ', '%20')})"
            
            # Replace Obsidian link with new markdown link
            content = content.replace(f"[[{file_item}]]", markdown_link)
            
            # Step 4: Copy the file to the static media directory if it exists
            file_source = os.path.join(attachments_dir, file_item)
            if os.path.exists(file_source):
                shutil.copy(file_source, static_media_dir)

        # Step 5: Write the updated content back to the markdown file
        with open(filepath, "w", encoding="utf-8") as file:
            file.write(content)

print("Markdown files processed and media copied successfully.")