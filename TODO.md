# TODO

- verify the WordPress image tag is valid
- verify the MySQL image tag is valid
- Substitute port number in docker-compose.yml
- If relocating to a non-default directory, then:
    - touch index.php, wp-config.php, wp-includes/version.php
    - otherwise the docker image will re-install wordpress.
- Suppress overwriting the .htaccess file, or at least back it up.
- Use `docker pull wordpress:<tag>` to test if an image exists.
    - Try backup formats before declaring the image does not exist.
- Determine default WordPress version by examining the db files.
- Extract either of .sql.gz or db.gz for database files.
    - db.gz for Updraft plus
    - .sql.gz for Backup WP Database plugin.
- Allow installing an arbitrary WordPress version from https://wordpress.org/download/releases/