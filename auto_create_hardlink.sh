#!/bin/bash

######################################
# Parametres
export SOURCE_DIR=/home/steph/dir1
export DEST_DIR=/home/steph/dir2
export DATABASE_FILE=/home/steph/symlink.db # ne doit pas être dans source ou dest dir
export DEBUG=0                              # 0 = pas de debug, 1= debug
export KEEP_DAYS=15                         # nombre de jours à garder dans la db
######################################
# Functions

# Création de la db si besoin
function initdb() {
  if [ ! -f "${DATABASE_FILE}" ]; then
    sqlite3 "${DATABASE_FILE}" <<EOF
      create table files( path varchar(255) PRIMARY KEY,
                          link integer,
                          date_check datetime DEFAULT (datetime('now','localtime')) );
EOF
  fi
}

# check si un fichier existe dans la db
function check_exists() {
  relative_path=$(realpath --relative-to "${SOURCE_DIR}" "${1}")
  escape_string=$(echo "${relative_path}" | sed "s/'/\\\'/g")

  request="select count(*) from files where path ='"${escape_string}"'"
  RETURN=$(sqlite3 ${DATABASE_FILE} "${request}")
  if [ "${RETURN}" == 0 ]; then
    if [ "${DEBUG}" == 1 ]; then
      echo "Fichier $1 non trouvé"
    fi
    # Création de l'enregistrement
    request="insert into files (path,link) values ('"${escape_string}"',1)"
    if [ "${DEBUG}" == 1 ]; then
      echo "Requete = ${request}"
    fi
    sqlite3 ${DATABASE_FILE} "${request}"
    # On prend le répertoire du fichier
    directory_path=$(dirname "${relative_path}")
    mkdir -p "${DEST_DIR}/${directory_path}"
    # Création du hardlink
    ln "${SOURCE_DIR}/${relative_path}" "${DEST_DIR}/${relative_path}"
  else
    if [ ${DEBUG} == 1 ]; then
      echo "Fichier $1 trouvé, acune action"
    fi
  fi
}

# Suppression des vieux enregistrements
function delete_old_record() {
  request="DELETE FROM files WHERE date_check <= date('now','-${KEEP_DAYS} day')"
  sqlite3 ${DATABASE_FILE} "${request}"
}

##########################################
# Lancement principal
initdb
OLDIFS=${IFS}
IFS=$'\n'
for fichier in $(find ${SOURCE_DIR} -type f); do
  check_exists "${fichier}"

done
delete_old_record
IFS=${OLDIFS}
