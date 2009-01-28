#!/bin/sh
if [ ! "`id | grep \"uid=[0-9]*(root)\"`" ] ; then
  echo "This script must be run as root! Aborting.";
  exit 1;
fi

pushd /home/talks > /dev/null

find app log public tmp -type d -exec chmod 775 '{}' ';'
find app log public tmp -type d -exec chmod g+s '{}' ';'
find app log public tmp -type f -exec chmod 664 '{}' ';'
chmod 755 public/*cgi

popd > /dev/null

echo "Done."
