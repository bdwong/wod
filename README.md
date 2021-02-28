Overview
========

Use this docker-compose configuration to restore from backup, on your local PC. After a migration step, you can make changes to the site and test locally. It can also be used for testing and development of WordPress sites locally.

This is not the only way to run the site on your computer. You can use a portable installation like [Instant WordPress](http://www.instantwp.com/). Or you may wish to setup mysql, php and apache/IIS on your computer, and download and install WordPress from <https://wordpress.org/>. However that is beyond the scope of this document.

Adapted from my docker-templates/wordpress template.


Prerequisites
=============

Install Docker (https://www.docker.com/)
Install Docker-compose (https://docs.docker.com/compose/)


Installation
============

unzip the archive, then:

```
sudo make install
```

This will install the following scripts into /usr/bin:

- `wod` - WordPress on Docker script
- `wp` - script to run Docker image of wp-cli
- `wp-restore` - script to restore a WordPress backup

`wp` and `wp-restore` should be run in the directory created by `wod`.

# Example usage

```sh
# Create a new WordPress instance called "staging-b"
wod staging-b

# Restore backups of mysite into staging-b
wp-restore ~/backups/mysite
```

# Setting up a Development Environment

Make a copy of this folder. Open up a bash shell (git-bash is okay) and chdir to the folder.

## Self-signed certificates

If you need to generate certificates because the site uses SSL (e.g. restoring from backup) then use the following:

```bash
# NOTE This is good enough to get certificate errors that you can bypass. For full working certificates, see the stackoverflow reference. https://stackoverflow.com/questions/7580508/getting-chrome-to-accept-self-signed-localhost-certificate/43666288#43666288

# Answer the questions and use the domain name when prompted for CN.
# Copy the result into the docker directory, uncomment the certificate lines in the Dockerfile, and rebuild the image.
openssl req -newkey rsa:2048 -nodes -keyout cert.key -x509 -days 365 -out cert.pem
```

Reference:

https://stackoverflow.com/questions/7580508/getting-chrome-to-accept-self-signed-localhost-certificate/43666288#43666288

https://www.ibm.com/support/knowledgecenter/en/SSWHYP_4.0.0/com.ibm.apimgmt.cmc.doc/task_apionprem_gernerate_self_signed_openSSL.html

## wp-cron

WordPress scheduled jobs do not run in the default Docker setup. Use the alternate job scheduler to fix this.

```php
# Add this line to the wp_config.php file.
define('ALTERNATE_WP_CRON', true);
```

## Restore from backup (command line)

This is a fast way to get a backup running in your development environment.

```bash
# Select a URL and port for your site.
# Make sure the port number (8000 here) matches the port mapping in docker-compose.yml.
siteurl="http://127.0.0.1:8000"

# Create WordPress container
docker-compose up -d

# Install WordPress core. Autogenerate password.
./wp core install --url=${siteurl} --title="Testing WordPress" --admin_user="admin" --admin_email="admin@127.0.0.1"

# Use the wp-restore script to restore from backup.
# For example:
./wp-restore ~/Downloads/backup/20171220

# Change the site url:
./wp option set siteurl ${siteurl}
./wp option set home ${siteurl}

# Disable plugins as necessary. (E.g. no auto-backups, don't run plugins known to fail after a restore.)
./wp plugin deactivate wp-cerber
./wp plugin deactivate updraftplus
```

## Restore from backup (UpdraftPlus)

Another way to restore from backup is to install and use UpdraftPlus.
```bash
# Select a URL and port for your site.
# Make sure the port number (8000 here) matches the port mapping in docker-compose.yml.
siteurl="http://127.0.0.1:8000"

# Create WordPress container
docker-compose up -d

# Install WordPress core. Prompt for password.
./wp core install --url=${siteurl} --title="Testing WordPress" --admin_user="admin" --admin_email="admin@127.0.0.1" --prompt=admin_password

# Install updraft plus plugin (optional)
./wp plugin install updraftplus --activate

# From here you can navigate to http://127.0.0.1:8000 restore a site through UpdraftPlus.
```

After you restore the backup, you may need to update the site url before you can login again:

```bash
./wp option set siteurl ${siteurl}
./wp option set home ${siteurl}
```

Then login as an administrator and reset the backup schedule to manual.

# Teardown Development Environment

Do this to delete the site from your computer.

```bash
docker-compose down

# Delete all site files
sudo rm -rf site

# Examine volumes before deleting
# docker volume ls -f name=`basename $(pwd)|tr -d '-'`

# Delete database volume
docker volume rm `basename $(pwd)|tr -d '-'`_db_data
```

# Developing WOD

To ease development, you can override the location WOD looks for its commands.
You will still need to install the main WOD script.

```bash
# Look for sub-commands in ~/src/wod/lib
export SCRIPT_HOME=~/src/wod/lib
```

# Notes and References

- <https://dba.stackexchange.com/questions/6171/invalid-default-value-for-datetime-when-changing-to-utf8-general-ci>
- <https://stackoverflow.com/questions/9192027/invalid-default-value-for-create-date-timestamp-field>
- <https://korobochkin.wordpress.com/2017/02/25/import-and-export-wordpress-database-with-utf8mb4-charset/>
- <https://github.com/docker-library/wordpress/issues/256>

NOTE: Some plugins expect libraries to be present on the host system, e.g. the really simple captcha plugin, which requires *GD library and the FreeType library*. These must be built in the docker image. See: https://wordpress.org/support/topic/fatal-error-call-to-undefined-function-imagettftext-really-simple-captchaphp/

How to change the site_url and home_url of the restored copy:
See <https://codex.wordpress.org/Changing_The_Site_URL>
See <http://stackoverflow.com/questions/30853247/how-to-edit-file-after-i-shell-to-a-docker-container>

If you're using a nonstandard URL, update .htaccess file on your local computer. E.g. if the website is typically hosted under '/subdir', remove '/subdir' from the RewriteBase and RewriteRules.
