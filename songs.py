import os
from mutagen.mp3 import MP3
import math

def insert_mp3_data(directory):
    for filename in os.listdir(directory):
        if filename.endswith('.mp3'):
            file_path = os.path.join(directory, filename)
            
            audio = MP3(file_path)
            length = math.floor(audio.info.length)
            
            print(f"INSERT INTO songs (name, filename, seconds) VALUES (\"{filename.replace(' - Beabadoobee.mp3', '')}\", \"{filename}\", {length})")
    

if __name__ == '__main__':
    insert_mp3_data('priv/audio')
