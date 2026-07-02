import json
import os
import re

def parse_law_content(input_text):
    # Split the content by your horizontal lines
    sections = re.split(r'_{10,}', input_text)
    
    unit_data = {
        "id": "unit1",
        "number": 1,
        "title": "Historical Background of the Constitution",
        "description": "The evolution of the Indian Constitution through British rule and legislative reforms.",
        "color": "#1E3A5F",
        "topics": []
    }
    
    topic_id_counter = 1
    
    for section in sections:
        lines = section.strip().split('\n')
        if not lines or len(lines) < 2:
            continue
            
        # The first non-empty line is usually the Title
        title = ""
        for line in lines:
            if line.strip():
                title = line.strip()
                break
        
        # Everything else is the content
        content = section.strip()
        
        # Simple Logic to create a topic
        if title and len(content) > 50:
            # Clean up the title (remove "Part X" or "Unit X" prefixes if they exist)
            clean_title = re.sub(r'^(Part \d+|Unit \d+)\s*–\s*', '', title, flags=re.IGNORECASE)
            
            # Simple keyword extraction for key points
            key_points = []
            if "Act" in clean_title:
                key_points.append("Legislative Reform")
            if "1773" in clean_title or "1784" in clean_title:
                key_points.append("Company Rule Era")
            
            topic = {
                "id": f"1.{topic_id_counter}",
                "title": clean_title,
                "content": content,
                "key_points": key_points,
                "video_url": None # You can add these manually later if needed
            }
            unit_data["topics"].append(topic)
            topic_id_counter += 1
            
    return [unit_data]

def main():
    # 1. Look for a file named 'input.txt' in the same folder
    input_file = 'input.txt'
    
    if not os.path.exists(input_file):
        print(f"Error: Please create a file named '{input_file}' and paste your text there.")
        return

    with open(input_file, 'r', encoding='utf-8') as f:
        text = f.read()

    print("Parsing content...")
    final_json = parse_law_content(text)

    # 2. Save as content.json
    output_file = 'content.json'
    with open(output_file, 'w', encoding='utf-8') as f:
        json.dump(final_json, f, indent=2)

    print(f"Success! '{output_file}' has been created with {len(final_json[0]['topics'])} topics.")
    print("Now upload this content.json to your GitHub repo root.")

if __name__ == "__main__":
    main()
