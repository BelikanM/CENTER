"""
Script de compression video avec OpenCV (plus simple)
Compresse les videos > 10 MB a 720p
"""

import os
import sys
from pathlib import Path

try:
    import cv2
except ImportError:
    print("\n[ERREUR] OpenCV n'est pas installe")
    print("\nInstallation:")
    print("  pip install opencv-python")
    print("\nOu avec conda:")
    print("  conda install -c conda-forge opencv")
    sys.exit(1)

# Configuration
DEST_FOLDER = "assets/videos"
MAX_SIZE_MB = 10
TARGET_HEIGHT = 720
FPS = 30

def get_video_info(video_path):
    """Obtenir les infos d'une video"""
    try:
        cap = cv2.VideoCapture(str(video_path))
        if not cap.isOpened():
            return None, None, None, None
        
        width = int(cap.get(cv2.CAP_PROP_FRAME_WIDTH))
        height = int(cap.get(cv2.CAP_PROP_FRAME_HEIGHT))
        fps = int(cap.get(cv2.CAP_PROP_FPS))
        frame_count = int(cap.get(cv2.CAP_PROP_FRAME_COUNT))
        duration = frame_count / fps if fps > 0 else 0
        
        cap.release()
        
        size_mb = video_path.stat().st_size / (1024 * 1024)
        
        return duration, size_mb, (width, height), fps
    except Exception as e:
        print(f"   [ERREUR] Impossible de lire: {e}")
        return None, None, None, None

def compress_video(input_path, output_path, target_height=720, target_fps=30):
    """Compresser une video avec OpenCV"""
    try:
        # Ouvrir la video source
        cap = cv2.VideoCapture(str(input_path))
        if not cap.isOpened():
            print("   [ERREUR] Impossible d'ouvrir la video")
            return False
        
        # Obtenir les proprietes
        width = int(cap.get(cv2.CAP_PROP_FRAME_WIDTH))
        height = int(cap.get(cv2.CAP_PROP_FRAME_HEIGHT))
        fps_original = int(cap.get(cv2.CAP_PROP_FPS))
        
        # Calculer les nouvelles dimensions
        if height > target_height:
            new_height = target_height
            new_width = int(width * (target_height / height))
            # Assurer que la largeur est paire
            new_width = new_width if new_width % 2 == 0 else new_width - 1
        else:
            new_height = height
            new_width = width
        
        print(f"   Redimensionnement: {width}x{height} -> {new_width}x{new_height}")
        print(f"   FPS: {fps_original} -> {target_fps}")
        print(f"   Compression en cours...", end="", flush=True)
        
        # Codec H.264
        fourcc = cv2.VideoWriter_fourcc(*'mp4v')
        
        # Creer le writer
        out = cv2.VideoWriter(
            str(output_path),
            fourcc,
            target_fps,
            (new_width, new_height)
        )
        
        if not out.isOpened():
            print(" [ERREUR] Impossible de creer le writer")
            cap.release()
            return False
        
        # Traiter les frames
        frame_count = 0
        skip_frames = max(1, fps_original // target_fps)
        
        while True:
            ret, frame = cap.read()
            if not ret:
                break
            
            # Sauter des frames pour reduire le FPS
            if frame_count % skip_frames == 0:
                # Redimensionner
                if height > target_height:
                    frame = cv2.resize(frame, (new_width, new_height))
                
                # Ecrire
                out.write(frame)
            
            frame_count += 1
        
        # Liberer les ressources
        cap.release()
        out.release()
        
        print(" [OK]")
        return True
        
    except Exception as e:
        print(f" [ERREUR]")
        print(f"   Details: {e}")
        return False

def main():
    print("=" * 60)
    print("   COMPRESSION DES VIDEOS AQUATIQUES (OpenCV)")
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
        duration, size_mb, resolution, fps = get_video_info(video)
        
        if duration is None:
            failed += 1
            print()
            continue
        
        print(f"   Taille actuelle: {size_mb:.2f} MB")
        print(f"   Resolution: {resolution[0]}x{resolution[1]}")
        print(f"   Duree: {duration:.1f}s")
        
        # Fichier temporaire
        temp_path = video.parent / f"{video.stem}_temp{video.suffix}"
        
        # Compresser
        success = compress_video(video, temp_path, TARGET_HEIGHT, FPS)
        
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
            print(f"  [!]  {vid.name} - {size_mb:.2f} MB (a recompresser)")
    
    print()
    print(f"Videos OK (< {MAX_SIZE_MB} MB): {ok_count} / {len(all_videos)}")
    print(f"Taille totale: {total_size:.2f} MB")
    print()
    
    if ok_count < len(all_videos):
        print("NOTE: Certaines videos sont encore > 10 MB")
        print("      Vous pouvez les supprimer ou les compresser manuellement")
        print("      avec: https://www.freeconvert.com/video-compressor")
    
    print()
    print("Termine!")

if __name__ == "__main__":
    main()
