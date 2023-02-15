#!/bin/bash

USERNAME="${MLAPI_DB_USERNAME}"
PASSWORD="${MLAPI_DB_PASSWORD}"
python3 mlapi_dbuser.py -u $USERNAME -p $PASSWORD
python3 mlapi.py -c ./config/mlapiconfig.ini