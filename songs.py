import os
from mutagen.mp3 import MP3
import math

# Function to create or connect to a SQLite database and create a table

# Function to get MP3 files' details and insert into the database
def insert_mp3_data(directory):
    for filename in os.listdir(directory):
        if filename.endswith('.mp3'):
            # Full path of the mp3 file
            file_path = os.path.join(directory, filename)
            
            # Get MP3 file details
            audio = MP3(file_path)
            length = math.floor(audio.info.length)  # Duration in seconds
            
            # Insert the data into the database
            print(f"INSERT INTO songs (name, filename, seconds) VALUES (\"{filename.replace(' - Beabadoobee.mp3', '')}\", \"{filename}\", {length})")
    

if __name__ == '__main__':
    # Directory containing MP3 files
    directory = 'priv/audio'  # Change this to your directory
    
    # Insert MP3 files data into the database
    insert_mp3_data(directory)
