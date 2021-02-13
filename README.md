Permet de créer des hardlink d'un répertoire vers un autre, en gardant l'arborescence.

## USAGE 

Remplacer les paramètres dans le script
```bash
export SOURCE_DIR=/home/steph/dir1
export DEST_DIR=/home/steph/dir2
export DATABASE_FILE=/home/steph/symlink.db # ne doit pas être dans source ou dest dir
export DEBUG=0                              # 0 = pas de debug, 1= debug
export KEEP_DAYS=15                         # nombre de jours à garder dans la db
```
Puis laner le script à intervalles réguliers