import os
import re
import shutil
import logging

# Configure logging
logging.basicConfig(level=logging.INFO, format='%(asctime)s - %(levelname)s: %(message)s')

# Paths (using raw strings to handle Windows backslashes correctly)
posts_dir = r"D:\Dev\Second-Brain\content\posts"
attachments_dir = r"D:\Obsidian\Vault\Attachments"
static_media_dir = r"D:\Dev\Second-Brain\static\media"

# Comprehensive list of supported file types
SUPPORTED_FILE_TYPES = [
    # Images
    '.png', '.jpg', '.jpeg', '.gif', '.webp', '.bmp', '.tiff', '.svg', 
    
    # Video files
    '.mp4', '.avi', '.mov', '.mkv', '.wmv', '.flv', '.webm', '.hevc', '.m4v', 
    
    # Audio files
    '.mp3', '.wav', '.ogg', '.flac', '.aac', '.wma', '.m4a', 
    
    # Document files (if needed)
    '.pdf', '.docx', '.xlsx', '.pptx', 
    
    # Other multimedia
    '.gif', '.webm'
]

def process_markdown_files():
    # Ensure static media directory exists
    os.makedirs(static_media_dir, exist_ok=True)

    # Track processed files to avoid redundant copies
    processed_files = set()

    for filename in os.listdir(posts_dir):
        if filename.endswith(".md"):
            filepath = os.path.join(posts_dir, filename)
            
            try:
                with open(filepath, "r", encoding="utf-8") as file:
                    content = file.read()
                
                # Dynamically create regex pattern for all supported file types
                file_types_pattern = '|'.join(map(re.escape, SUPPORTED_FILE_TYPES))
                images = re.findall(rf'\[\[([^]]*\.(?:{file_types_pattern[1:]}))\]\]', content)
                
                modified = False
                for file_item in images:
                    # Determine file type and create appropriate markdown/link
                    file_ext = os.path.splitext(file_item)[1].lower()
                    
                    # Different handling based on file type
                    if file_ext in ['.png', '.jpg', '.jpeg', '.gif', '.webp', '.bmp', '.tiff', '.svg']:
                        # Image handling
                        markdown_item = f"![Media Description](/media/{file_item.replace(' ', '%20')})"
                    elif file_ext in ['.mp4', '.avi', '.mov', '.mkv', '.wmv', '.flv', '.webm', '.hevc', '.m4v']:
                        # Video handling
                        markdown_item = f"[Video: {file_item}](/media/{file_item.replace(' ', '%20')})"
                    elif file_ext in ['.mp3', '.wav', '.ogg', '.flac', '.aac', '.wma', '.m4a']:
                        # Audio handling
                        markdown_item = f"[Audio: {file_item}](/media/{file_item.replace(' ', '%20')})"
                    else:
                        # Generic file handling
                        markdown_item = f"[File: {file_item}](/media/{file_item.replace(' ', '%20')})"
                    
                    # Replace Obsidian link with new markdown/link
                    content = content.replace(f"[[{file_item}]]", markdown_item)
                    
                    # Copy file only if not already processed
                    file_source = os.path.join(attachments_dir, file_item)
                    if os.path.exists(file_source) and file_item not in processed_files:
                        try:
                            shutil.copy(file_source, static_media_dir)
                            processed_files.add(file_item)
                            logging.info(f"Copied media: {file_item}")
                            modified = True
                        except Exception as copy_error:
                            logging.error(f"Failed to copy {file_item}: {copy_error}")
                
                # Write back only if content was modified
                if modified:
                    with open(filepath, "w", encoding="utf-8") as file:
                        file.write(content)
                    logging.info(f"Processed file: {filename}")
            
            except Exception as e:
                logging.error(f"Error processing {filename}: {e}")

def main():
    try:
        process_markdown_files()
        logging.info("Markdown files processed and media copied successfully.")
    except Exception as e:
        logging.error(f"An error occurred: {e}")

if __name__ == "__main__":
    main()