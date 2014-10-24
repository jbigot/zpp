################################################################################
# Copyright (c) 2013-2014, CEA
# All rights reserved.
#
# Redistribution and use in source and binary forms, with or without
# modification, are permitted provided that the following conditions are met:
#  1. Redistributions of source code must retain the above copyright notice,
# this list of conditions and the following disclaimer.
#  2. Redistributions in binary form must reproduce the above copyright notice,
# this list of conditions and the following disclaimer in the documentation
# and/or other materials provided with the distribution.
#
# THIS SOFTWARE IS PROVIDED BY THE COPYRIGHT HOLDERS AND CONTRIBUTORS "AS IS"
# AND ANY EXPRESS OR IMPLIED WARRANTIES, INCLUDING, BUT NOT LIMITED TO, THE
# IMPLIED WARRANTIES OF MERCHANTABILITY AND FITNESS FOR A PARTICULAR PURPOSE ARE
# DISCLAIMED. IN NO EVENT SHALL THE COPYRIGHT HOLDER OR CONTRIBUTORS BE LIABLE
# FOR ANY DIRECT, INDIRECT, INCIDENTAL, SPECIAL, EXEMPLARY, OR CONSEQUENTIAL
# DAMAGES (INCLUDING, BUT NOT LIMITED TO, PROCUREMENT OF SUBSTITUTE GOODS OR
# SERVICES; LOSS OF USE, DATA, OR PROFITS; OR BUSINESS INTERRUPTION) HOWEVER
# CAUSED AND ON ANY THEORY OF LIABILITY, WHETHER IN CONTRACT, STRICT LIABILITY,
# OR TORT (INCLUDING NEGLIGENCE OR OTHERWISE) ARISING IN ANY WAY OUT OF THE USE
# OF THIS SOFTWARE, EVEN IF ADVISED OF THE POSSIBILITY OF SUCH DAMAGE.
################################################################################

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
