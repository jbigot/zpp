# Repeats string $1 ($3-$2+1) times, separated by string $4 inside $5 $6
# if $1 contains the '@N' substring, it will be replaced by the iteration number (from $2 to $3)
function str_repeat() {
  STR="$1"
  FROM="$2"
  TO="$3"
  SEP="$4"
  START="$5"
  END="$6"
  if [ "${TO}" -lt "${FROM}" ]; then return; fi
  RES="${START}${STR//@N/${FROM}}"
  (( ++FROM ))
  for N in $(seq $FROM $TO); do
    RES="${RES}${SEP}${STR//@N/${N}}"
  done
  echo "${RES}${END}"
}

# Repeats string $1 ($3-$2+1) times, separated by string $4
# if $1 contains the '@N' substring, it will be replaced by the iteration number (from $3 to $2)
function str_repeat_reverse() {
  STR="$1"
  FROM="$2"
  TO="$3"
  SEP="$4"
  RES="${STR//@N/${TO}}"
  TO=$(($TO-1))
  for N in $(seq $TO -1 $FROM); do
    RES="${RES}${SEP}${STR//@N/${N}}"
  done
  echo "$RES"
}
