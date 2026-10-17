#!/usr/bin/env bash

if [ "$#" -lt 1 ]; then
  zenity --error --text="No files provided."
  exit 1
fi

# Liste des fichiers en entrée
files=("$@")
total=${#files[@]}

# Fonction pour convertir un fichier et envoyer la progression globale
convert_file() {
  local file_idx="$1"
  local input="$2"

  # Durée du fichier en secondes (float)
  local duration
  duration=$(ffprobe -v error -show_entries format=duration -of default=nk=1:nw=1 "$input")
  if [ -z "$duration" ]; then
    echo "# Could not read duration for: $(basename "$input")"
    return
  fi

  local output
  output="${input%.*}_dnxhr_hqx.mov"

  # Afficher le message initial
  echo "# Converting: $(basename "$input")"
  
  # Envoyer la progression initiale
  printf "%d\n" "$((file_idx * 100 / total))"
  
  # Variables pour tracker le timing (mise à jour tous les 0.5s)
  local last_update=0
  local current_time
  
  # Lancer FFmpeg avec grep pour extraire les lignes "time=" en temps réel
  ffmpeg -hide_banner -y -i "$input" \
    -c:v dnxhd -profile:v dnxhr_hqx -vf "format=yuv422p10le" \
    -c:a pcm_s24le \
    "$output" 2>&1 | grep --line-buffered "time=" | while IFS= read -r line; do
    
    # Extraire la valeur de time= avec sed
    local time_str
    time_str=$(echo "$line" | sed -n 's/.*time=\([0-9:]*\.[0-9]*\).*/\1/p')
    
    if [ -n "$time_str" ]; then
      # Convertir HH:MM:SS.ms en secondes
      local secs=0
      IFS=':' read -r h m s <<<"$time_str"
      
      # Gérer le cas où h ou m manquent
      if [ -z "$m" ]; then
        secs=$(awk "BEGIN {printf \"%.2f\", $h}")
      elif [ -z "$h" ]; then
        secs=$(awk "BEGIN {printf \"%.2f\", $m * 60 + $s}")
      else
        secs=$(awk "BEGIN {printf \"%.2f\", $h * 3600 + $m * 60 + $s}")
      fi
      
      # Calculer le pourcentage du fichier actuel
      local percent_file=$(awk "BEGIN {printf \"%.1f\", $secs * 100 / $duration}")
      if (( $(awk "BEGIN {print ($percent_file > 100)}") )); then
        percent_file=100
      fi
      
      # Calculer la progression globale
      local global=$(awk "BEGIN {printf \"%.1f\", ($file_idx + $percent_file / 100) * 100 / $total}")
      if (( $(awk "BEGIN {print ($global > 100)}") )); then
        global=100
      fi
      
      # Vérifier si 0.5 seconde s'est écoulée depuis la dernière mise à jour
      current_time=$(date +%s%3N)
      if (( current_time - last_update >= 500 )); then
        printf "%d\n" "${global%.*}"
        last_update=$current_time
      fi
    fi
  done
  
  # Envoyer la progression finale (100% pour ce fichier)
  printf "%d\n" "$(( (file_idx + 1) * 100 / total ))"
}

# On envoie tout vers zenity --progress
(
  i=0
  for f in "${files[@]}"; do
    convert_file "$i" "$f"
    i=$((i+1))
  done
) | zenity --progress \
      --title="Conversion for Resolve" \
      --text="  Conversion in progress...  " \
      --percentage=0 \
      --auto-close \
      --auto-kill
