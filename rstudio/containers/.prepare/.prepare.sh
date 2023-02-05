#!/bin/bash

ls -alh ./.run/.*/.*.sh && chmod +x ./.run/.*/.*.sh
ls -alh ./.prepare/.*/.*.sh && chmod +x ./.prepare/.*/.*.sh

./.prepare/.create.volumes.folders.sh
# ./.certbot/
./.prepare/.nginx/init-letsencrypt.sh
# ./.postgres.db/
# ./.rstudio/
