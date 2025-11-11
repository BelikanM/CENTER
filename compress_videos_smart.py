"""
Script intelligent de compression video
Compresse progressivement jusqu'a atteindre la taille cible
Avec barre de progression et preview
"""

import os
import sys
from pathlib import Path
import time

try:
    import cv2
    import numpy as np
except ImportError:
    print("\n[ERREUR] OpenCV n'est pas installe")
    print("Installation en cours avec conda...")
    os.system("conda install -c conda-forge opencv -y")
    sys.exit(1)

# Configuration
DEST_FOLDER = "assets/videos"
TARGET_SIZE_MB = 9  # Cible 9 MB
MAX_SIZE_MB = 10
TARGET_HEIGHT = 720
MIN_HEIGHT = 480
TARGET_FPS = 24  # 24 FPS pour equilibre taille/fluidite
TARGET_QUALITY = 23  # CRF pour H.264 (18-28, plus bas = meilleure qualite)

def print_progress_bar(iteration, total, prefix='', suffix='', length=50, fill='█'):
    """Affiche une barre de progression"""
    percent = f"{100 * (iteration / float(total)):.1f}"
    filled_length = int(length * iteration // total)
    bar = fill * filled_length + '-' * (length - filled_length)
    print(f'\r{prefix} |{bar}| {percent}% {suffix}', end='', flush=True)
    if iteration == total: 
        print()

def get_video_info(video_path):
    """Obtenir les infos detaillees d'une video"""
    try:
        cap = cv2.VideoCapture(str(video_path))
        if not cap.isOpened():
            return None
        
        width = int(cap.get(cv2.CAP_PROP_FRAME_WIDTH))
        height = int(cap.get(cv2.CAP_PROP_FRAME_HEIGHT))
        fps = cap.get(cv2.CAP_PROP_FPS)
        frame_count = int(cap.get(cv2.CAP_PROP_FRAME_COUNT))
        duration = frame_count / fps if fps > 0 else 0
        
        cap.release()
        
        size_mb = video_path.stat().st_size / (1024 * 1024)
        
        return {
            'width': width,
            'height': height,
            'fps': fps,
            'frame_count': frame_count,
            'duration': duration,
            'size_mb': size_mb,
            'bitrate': (size_mb * 8192) / duration if duration > 0 else 0
        }
    except Exception as e:
        print(f"   [ERREUR] Impossible de lire: {e}")
        return None

def calculate_optimal_settings(info, target_size_mb):
    """Calcule les parametres optimaux de compression"""
    # Calculer le bitrate cible
    target_bitrate_kbps = int((target_size_mb * 8192) / info['duration']) - 128  # -128 pour audio
    target_bitrate_kbps = max(500, target_bitrate_kbps)  # Minimum 500 kbps
    
    # Determiner la hauteur cible
    if info['height'] > TARGET_HEIGHT:
        new_height = TARGET_HEIGHT
    elif info['size_mb'] > target_size_mb * 1.5:  # Si trop gros, reduire plus
        new_height = MIN_HEIGHT
    else:
        new_height = info['height']
    
    # Calculer la largeur proportionnelle
    aspect_ratio = info['width'] / info['height']
    new_width = int(new_height * aspect_ratio)
    new_width = new_width if new_width % 2 == 0 else new_width - 1  # Pair pour H.264
    
    # FPS adaptatif
    if info['fps'] > TARGET_FPS:
        new_fps = TARGET_FPS
    else:
        new_fps = info['fps']
    
    return {
        'width': new_width,
        'height': new_height,
        'fps': new_fps,
        'bitrate': target_bitrate_kbps,
        'skip_frames': max(1, int(info['fps'] / new_fps))
    }

def compress_video_smart(input_path, output_path, info, settings):
    """Compresse une video avec parametres optimises"""
    try:
        cap = cv2.VideoCapture(str(input_path))
        if not cap.isOpened():
            return False, "Impossible d'ouvrir la video"
        
        # Creer le writer avec H.264
        fourcc = cv2.VideoWriter_fourcc(*'mp4v')
        
        out = cv2.VideoWriter(
            str(output_path),
            fourcc,
            settings['fps'],
            (settings['width'], settings['height']),
        )
        
        if not out.isOpened():
            cap.release()
            return False, "Impossible de creer le writer"
        
        # Traiter les frames avec progression
        frame_idx = 0
        written_frames = 0
        total_frames = info['frame_count']
        
        print(f"   Traitement: 0/{total_frames} frames", end='', flush=True)
        
        while True:
            ret, frame = cap.read()
            if not ret:
                break
            
            # Sauter des frames pour reduire FPS
            if frame_idx % settings['skip_frames'] == 0:
                # Redimensionner
                if info['height'] != settings['height'] or info['width'] != settings['width']:
                    frame = cv2.resize(frame, (settings['width'], settings['height']), 
                                     interpolation=cv2.INTER_AREA)
                
                # Appliquer un leger lissage pour reduire le bruit
                frame = cv2.GaussianBlur(frame, (3, 3), 0)
                
                # Ecrire
                out.write(frame)
                written_frames += 1
                
                # Mise a jour progression toutes les 30 frames
                if written_frames % 30 == 0:
                    print(f"\r   Traitement: {frame_idx}/{total_frames} frames", end='', flush=True)
            
            frame_idx += 1
        
        print(f"\r   Traitement: {total_frames}/{total_frames} frames [OK]")
        
        cap.release()
        out.release()
        
        return True, f"{written_frames} frames ecrits"
        
    except Exception as e:
        return False, str(e)

def compress_video_aggressive(input_path, output_path, target_size_mb):
    """Compression aggressive pour les tres gros fichiers"""
    try:
        info = get_video_info(input_path)
        if not info:
            return False
        
        # Parametres tres agressifs
        new_height = MIN_HEIGHT
        new_width = int((info['width'] / info['height']) * new_height)
        new_width = new_width if new_width % 2 == 0 else new_width - 1
        new_fps = 20  # Encore plus bas
        
        cap = cv2.VideoCapture(str(input_path))
        fourcc = cv2.VideoWriter_fourcc(*'mp4v')
        
        out = cv2.VideoWriter(
            str(output_path),
            fourcc,
            new_fps,
            (new_width, new_height),
        )
        
        if not out.isOpened():
            cap.release()
            return False
        
        frame_idx = 0
        skip = max(1, int(info['fps'] / new_fps))
        
        while True:
            ret, frame = cap.read()
            if not ret:
                break
            
            if frame_idx % skip == 0:
                frame = cv2.resize(frame, (new_width, new_height), interpolation=cv2.INTER_AREA)
                frame = cv2.GaussianBlur(frame, (5, 5), 0)  # Plus de lissage
                out.write(frame)
            
            frame_idx += 1
        
        cap.release()
        out.release()
        return True
        
    except Exception as e:
        print(f"   [ERREUR] {e}")
        return False

def main():
    print("=" * 70)
    print("   COMPRESSION INTELLIGENTE DES VIDEOS AQUATIQUES")
    print("=" * 70)
    print()
    
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
        
        # Afficher les videos existantes
        all_videos = sorted(dest_path.glob("aquarium_*.mp4"), key=lambda x: x.name)
        if all_videos:
            print("Videos disponibles:")
            for vid in all_videos:
                size_mb = vid.stat().st_size / (1024 * 1024)
                print(f"  [OK] {vid.name} - {size_mb:.2f} MB")
        return
    
    print(f"Videos a compresser: {len(videos)}")
    print()
    
    compressed = 0
    failed = 0
    total_saved = 0
    
    for idx, video in enumerate(videos, 1):
        print(f"\n{'='*70}")
        print(f"[{idx}/{len(videos)}] {video.name}")
        print(f"{'='*70}")
        
        # Analyser la video
        print("   Analyse de la video...", end='', flush=True)
        info = get_video_info(video)
        
        if not info:
            print(" [ERREUR]")
            failed += 1
            continue
        
        print(" [OK]")
        
        # Afficher les infos
        print(f"   Taille actuelle: {info['size_mb']:.2f} MB")
        print(f"   Resolution: {info['width']}x{info['height']}")
        print(f"   FPS: {info['fps']:.1f}")
        print(f"   Duree: {info['duration']:.1f}s")
        print(f"   Bitrate: {info['bitrate']:.0f} kbps")
        
        # Calculer les parametres optimaux
        settings = calculate_optimal_settings(info, TARGET_SIZE_MB)
        
        print(f"\n   Parametres de compression:")
        print(f"   - Resolution: {info['width']}x{info['height']} -> {settings['width']}x{settings['height']}")
        print(f"   - FPS: {info['fps']:.1f} -> {settings['fps']}")
        print(f"   - Bitrate cible: {settings['bitrate']} kbps")
        print()
        
        # Fichier temporaire
        temp_path = video.parent / f"{video.stem}_temp{video.suffix}"
        
        # Compression intelligente
        success, message = compress_video_smart(video, temp_path, info, settings)
        
        if success and temp_path.exists():
            new_size_mb = temp_path.stat().st_size / (1024 * 1024)
            
            # Si encore trop gros, compression aggressive
            if new_size_mb > TARGET_SIZE_MB * 1.2:
                print(f"\n   Taille intermediaire: {new_size_mb:.2f} MB (encore trop)")
                print(f"   Application compression aggressive...")
                
                temp_path2 = video.parent / f"{video.stem}_temp2{video.suffix}"
                if compress_video_aggressive(temp_path, temp_path2, TARGET_SIZE_MB):
                    temp_path.unlink()
                    temp_path = temp_path2
                    new_size_mb = temp_path.stat().st_size / (1024 * 1024)
            
            # Remplacer l'original
            video.unlink()
            temp_path.rename(video)
            
            reduction = ((info['size_mb'] - new_size_mb) / info['size_mb']) * 100
            saved = info['size_mb'] - new_size_mb
            total_saved += saved
            
            print(f"\n   [SUCCES] {info['size_mb']:.2f} MB -> {new_size_mb:.2f} MB")
            print(f"   Reduction: -{reduction:.1f}% (economie: {saved:.2f} MB)")
            
            if new_size_mb <= MAX_SIZE_MB:
                print(f"   Statut: OK pour Flutter")
            else:
                print(f"   Statut: Encore un peu volumineuse")
            
            compressed += 1
        else:
            if temp_path.exists():
                temp_path.unlink()
            print(f"\n   [ECHEC] {message}")
            failed += 1
    
    # Resume final
    print(f"\n{'='*70}")
    print("RESUME FINAL")
    print(f"{'='*70}")
    print(f"Videos compressees: {compressed}/{len(videos)}")
    if failed > 0:
        print(f"Echecs: {failed}")
    print(f"Espace economise: {total_saved:.2f} MB")
    print()
    
    # Liste finale complete
    all_videos = sorted(dest_path.glob("aquarium_*.mp4"), key=lambda x: x.name)
    total_size = 0
    ok_count = 0
    
    print("TOUTES LES VIDEOS:")
    print()
    
    for vid in all_videos:
        size_mb = vid.stat().st_size / (1024 * 1024)
        total_size += size_mb
        
        # Obtenir la duree
        info = get_video_info(vid)
        duration_str = f"{info['duration']:.1f}s" if info else "?"
        
        if size_mb <= MAX_SIZE_MB:
            print(f"  [OK] {vid.name:<20} {size_mb:>6.2f} MB  {duration_str:>6}")
            ok_count += 1
        else:
            print(f"  [!]  {vid.name:<20} {size_mb:>6.2f} MB  {duration_str:>6}")
    
    print()
    print(f"Videos OK (< {MAX_SIZE_MB} MB): {ok_count}/{len(all_videos)}")
    print(f"Taille totale: {total_size:.2f} MB")
    print()
    
    if ok_count == len(all_videos):
        print("PARFAIT! Toutes les videos sont optimisees!")
        print("Vous pouvez maintenant les utiliser dans Flutter.")
    else:
        print(f"NOTE: {len(all_videos) - ok_count} video(s) encore > {MAX_SIZE_MB} MB")
        print("Vous pouvez les recompresser avec un service en ligne:")
        print("  https://www.freeconvert.com/video-compressor")
    
    print()
    print("Termine!")
    print()

if __name__ == "__main__":
    try:
        main()
    except KeyboardInterrupt:
        print("\n\nInterrompu par l'utilisateur.")
        sys.exit(1)
    except Exception as e:
        print(f"\n[ERREUR CRITIQUE] {e}")
        import traceback
        traceback.print_exc()
        sys.exit(1)
