# Glacier Backup

This script creates a `tar.gz` backup file of a set of specified directories and MySQL Databases, which is then in turn uploaded to Amazon Glacier for long term storage. The script is designed to run on a Unix File system, and assumes that the MySQL server is running within a docker container to perform the dumps.

The Name of the docker container, as well as which files/folders, and SQL Databases you would like to include in the archive is configurable in the top of the script; along with the Temporary Directory path on your system and AWS IAM credentials.

Full documentation of the setup and methodology behind the script can be found on my blog at: https://blog.tompaulus.com/back-up-with-glacier/

## AWS Setup
You will need to create an IAM programmatic access user that has full access to glacier (the `AmazonGlacierFullAccess` includes the minimum necessary access for the script to work correctly). You will need to create a Vault ahead of time via the AWS Management Console, whose name is given as a parameter in the script file.

## System Setup
The script, `backup.sh`, allows you to choose which folders or files you would like to backup. Simple include the full path in double quotes in the list, the script can backup both directories and files, symlinks may not backup as intended. Same goes for MySQL Directories. The script is designed to access the MySQL Server running from within a Docker container. The name of the Docker container can be set via the `MYSQLCONTAINER` variable. The root password does not need to be supplied, as it is set as an environment variable in the container by default.

The `glacieruploader.jar` comes from [MoriTanosuke](https://github.com/MoriTanosuke)'s open source [glacieruploader](https://github.com/MoriTanosuke/glacieruploader) project; which is licensed under GNU General Public License, Version 3.
