"""
Script de compression video avec MoviePy
Compresse les videos > 10 MB a 720p avec bitrate optimise
"""

import os
import sys
from pathlib import Path

try:
    from moviepy.editor import VideoFileClip
except ImportError:
    print("\n[ERREUR] MoviePy n'est pas installe")
    print("\nInstallation:")
    print("  pip install moviepy")
    print("\nOu avec conda:")
    print("  conda install -c conda-forge moviepy")
    sys.exit(1)

# Configuration
DEST_FOLDER = "assets/videos"
TARGET_SIZE_MB = 9  # Cible 9 MB pour avoir de la marge
MAX_SIZE_MB = 10

def get_video_info(video_path):
    """Obtenir les infos d'une video"""
    try:
        clip = VideoFileClip(str(video_path))
        duration = clip.duration
        size = video_path.stat().st_size / (1024 * 1024)  # MB
        clip.close()
        return duration, size
    except Exception as e:
        print(f"   [ERREUR] Impossible de lire: {e}")
        return None, None

def compress_video(input_path, output_path, target_size_mb, duration):
    """Compresser une video avec moviepy"""
    try:
        # Calculer le bitrate cible (en kbps)
        # Formule: (taille_MB * 8192) / duree_s - 128 (audio)
        target_bitrate = int((target_size_mb * 8192) / duration) - 128
        
        # Bitrate minimum
        if target_bitrate < 500:
            target_bitrate = 500
        
        print(f"   Bitrate cible: {target_bitrate} kbps")
        print(f"   Compression en cours...", end="", flush=True)
        
        # Charger la video
        clip = VideoFileClip(str(input_path))
        
        # Redimensionner a 720p si necessaire
        if clip.h > 720:
            clip = clip.resize(height=720)
        
        # Ecrire la video compresse
        clip.write_videofile(
            str(output_path),
            codec='libx264',
            bitrate=f"{target_bitrate}k",
            audio_codec='aac',
            audio_bitrate='96k',
            fps=30,
            preset='medium',
            threads=4,
            logger=None  # Desactiver les logs verbeux
        )
        
        clip.close()
        print(" [OK]")
        return True
        
    except Exception as e:
        print(f" [ERREUR]")
        print(f"   Details: {e}")
        return False

def main():
    print("=" * 60)
    print("   COMPRESSION DES VIDEOS AQUATIQUES")
    print("=" * 60)
    print()
    
    # Verifier le dossier
    dest_path = Path(DEST_FOLDER)
    if not dest_path.exists():
        print(f"[ERREUR] Dossier introuvable: {DEST_FOLDER}")
        sys.exit(1)
    
    # Lister les videos > 10 MB
    videos = [
        f for f in dest_path.glob("aquarium_*.mp4")
        if f.stat().st_size > (MAX_SIZE_MB * 1024 * 1024)
    ]
    
    videos.sort(key=lambda x: x.stat().st_size)
    
    if not videos:
        print("[OK] Aucune video a compresser!")
        print()
        return
    
    print(f"Videos a compresser: {len(videos)}")
    print()
    
    compressed = 0
    failed = 0
    
    for idx, video in enumerate(videos, 1):
        print(f"[{idx}/{len(videos)}] {video.name}")
        
        # Info video
        duration, size_mb = get_video_info(video)
        
        if duration is None:
            failed += 1
            print()
            continue
        
        print(f"   Taille actuelle: {size_mb:.2f} MB")
        print(f"   Duree: {duration:.1f}s")
        
        # Fichier temporaire
        temp_path = video.parent / f"{video.stem}_temp{video.suffix}"
        
        # Compresser
        success = compress_video(video, temp_path, TARGET_SIZE_MB, duration)
        
        if success and temp_path.exists():
            new_size_mb = temp_path.stat().st_size / (1024 * 1024)
            
            # Remplacer l'original
            video.unlink()
            temp_path.rename(video)
            
            reduction = ((size_mb - new_size_mb) / size_mb) * 100
            print(f"   [OK] {size_mb:.2f} MB -> {new_size_mb:.2f} MB (-{reduction:.1f}%)")
            compressed += 1
        else:
            if temp_path.exists():
                temp_path.unlink()
            print(f"   [ECHEC]")
            failed += 1
        
        print()
    
    # Resume
    print("=" * 60)
    print("RESUME")
    print("=" * 60)
    print(f"Compressees avec succes: {compressed}")
    if failed > 0:
        print(f"Echecs: {failed}")
    print()
    
    # Liste finale
    all_videos = sorted(dest_path.glob("aquarium_*.mp4"), key=lambda x: x.name)
    total_size = 0
    ok_count = 0
    
    print("TOUTES LES VIDEOS:")
    print()
    
    for vid in all_videos:
        size_mb = vid.stat().st_size / (1024 * 1024)
        total_size += size_mb
        
        if size_mb <= MAX_SIZE_MB:
            print(f"  [OK] {vid.name} - {size_mb:.2f} MB")
            ok_count += 1
        else:
            print(f"  [!]  {vid.name} - {size_mb:.2f} MB")
    
    print()
    print(f"Videos OK (< {MAX_SIZE_MB} MB): {ok_count} / {len(all_videos)}")
    print(f"Taille totale: {total_size:.2f} MB")
    print()
    print("Termine!")

if __name__ == "__main__":
    main()
