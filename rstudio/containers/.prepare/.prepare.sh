#!/bin/bash

ls -alh ./.run/.*/.*.sh && chmod +x ./.run/.*/.*.sh
ls -alh ./.prepare/.*/.*.sh && chmod +x ./.prepare/.*/.*.sh
chmod +x ./.prepare/.create.volumes.folders.sh
./.prepare/.create.volumes.folders.sh
# ./.certbot/
chmod +x ./.prepare/.nginx/init-letsencrypt.sh
./.prepare/.nginx/init-letsencrypt.sh
# ./.postgres.db/
# ./.rstudio/
