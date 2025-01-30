import pandas as pd
import numpy as np
from PIL import Image
import sys
import time

def print_progress(message, width=40):
    """Animated progress indicator"""
    sys.stdout.write("\r" + " " * 100 + "\r")  # Clear line
    sys.stdout.write(f"{message[:width]:<{width}}")
    sys.stdout.flush()

def hex_to_rgb(hex_color):
    """Convert hex color code to RGB tuple"""
    hex_color = str(hex_color).strip().lstrip('#')
    if len(hex_color) != 6:
        raise ValueError(f"Invalid color code: {hex_color}")
    return tuple(int(hex_color[i:i+2], 16) for i in (0, 2, 4))

def extract_png_colors(image_path):
    """Extract unique RGB colors from PNG file with progress"""
    print("\n[1/3] Analyzing PNG image...")
    try:
        img = Image.open(image_path).convert('RGBA')
        data = np.array(img)
        
        print_progress("Processing pixels...")
        pixels = data.reshape(-1, 4)[:, :3]
        
        print_progress("Finding unique colors...")
        unique_colors = np.unique(pixels, axis=0)
        
        print(f"\rPNG analysis complete: Found {len(unique_colors)} unique colors")
        return {tuple(color) for color in unique_colors}
    
    except Exception as e:
        print(f"\nError processing image: {str(e)}")
        raise

def load_csv_data(csv_path, color_column):
    """Load CSV data with progress indicators"""
    print("\n[2/3] Processing CSV file...")
    try:
        print_progress("Reading CSV...")
        df = pd.read_csv(csv_path)
        
        # Validate columns
        required_columns = ['REGION_NAME', color_column]
        missing = [col for col in required_columns if col not in df.columns]
        if missing:
            raise ValueError(f"Missing columns: {', '.join(missing)}")
            
        print_progress("Converting color codes...")
        df['rgb'] = df[color_column].apply(hex_to_rgb)
        
        print(f"\rCSV processing complete: {len(df)} regions loaded")
        return df
    
    except Exception as e:
        print(f"\nError processing CSV: {str(e)}")
        raise

def find_missing_regions(csv_path, image_path, color_column):
    """Main comparison function with progress tracking"""
    try:
        # Phase 1: Load data
        png_colors = extract_png_colors(image_path)
        df = load_csv_data(csv_path, color_column)
        
        # Phase 2: Comparison
        print("\n[3/3] Comparing regions...")
        print_progress("Matching colors...")
        
        total_regions = len(df)
        df['in_png'] = False
        match_count = 0
        
        for idx, row in df.iterrows():
            if row['rgb'] in png_colors:
                df.at[idx, 'in_png'] = True
                match_count += 1
            if idx % 10 == 0:
                progress = (idx + 1) / total_regions * 100
                print_progress(f"Checked {idx+1}/{total_regions} regions ({progress:.1f}%)")
        
        print(f"\rComparison complete: {match_count} matches found, {len(df)-match_count} missing")
        return df[~df['in_png']][['REGION_NAME', color_column]].drop_duplicates()
    
    except Exception as e:
        print(f"\nComparison failed: {str(e)}")
        return pd.DataFrame()

def main():
    # Configuration
    csv_path = 'DataRegions.csv'
    image_path = 'Data_Regions.png'
    color_column = 'REGION_ID'
    
    print("=== Region Validation Tool ===")
    print(f"CSV: {csv_path}")
    print(f"PNG: {image_path}")
    print(f"Color Column: {color_column}\n")
    
    start_time = time.time()
    
    try:
        missing_df = find_missing_regions(csv_path, image_path, color_column)
        
        if not missing_df.empty:
            print("\nMissing regions detected:")
            print(missing_df.to_string(index=False, max_rows=10))
            
            if len(missing_df) > 10:
                print(f"\n(...showing first 10 of {len(missing_df)} missing regions)")
            
            # Save results
            print_progress("\nSaving results to file...")
            missing_df.to_csv('missing_regions.csv', index=False)
            print(f"\rResults saved to missing_regions.csv")
        else:
            print("\nAll regions match! No missing colors found.")
            
        print(f"\nTotal processing time: {time.time()-start_time:.2f} seconds")
        
    except Exception as e:
        print(f"\nOperation failed: {str(e)}")
        print("Please check:")
        print("- File paths and permissions")
        print("- CSV format and column names")
        print("- Image file integrity")

if __name__ == '__main__':
    main()