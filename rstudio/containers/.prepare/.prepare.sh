#!/bin/bash

ls -alh ./.run/.*/.*.sh && chmod +x ./.run/.*/.*.sh
ls -alh ./.prepare/.*/.*.sh && chmod +x ./.prepare/.*/.*.sh
chmod +x ./.prepare/.create.volumes.folders.sh
./.prepare/.create.volumes.folders.sh

echo
echo "# --- # --- # --- "
echo "# --- Volumes Folders are now created."
echo "# --- # --- # --- "
echo


echo
echo "# --- # --- # --- "
echo "# --- Now initializing nginx/letsencrypt."
echo "# --- # --- # --- "
echo
# ./.certbot/
chmod +x ./.prepare/.nginx/init-letsencrypt.sh
sudo ./.prepare/.nginx/init-letsencrypt.sh
# ./.postgres.db/
# ./.rstudio/
