#!/bin/sh

if [ -z $RAILS_ENV ]; then
  filename='development'
else
  filename=$RAILS_ENV
fi

touch log/$filename.log
tail -n 0 -f log/$filename.log