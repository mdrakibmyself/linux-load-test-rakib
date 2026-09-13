#!/bin/bash

# 1. Set your service account name here
SVC_NAME="bgdsvc_rakib"

# 2. Check if the user already exists
if id "$SVC_NAME" >/dev/null 2>&1; then
    echo "User $SVC_NAME already exists! Doing nothing."
else
    echo "Creating user $SVC_NAME..."
    sudo useradd -r -m -s /usr/sbin/nologin "$SVC_NAME"
    echo "User $SVC_NAME created successfully."
fi

# 3. Show user info to confirm
id "$SVC_NAME"
getent passwd "$SVC_NAME"