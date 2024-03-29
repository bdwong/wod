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

It will also install auxiliary scripts and templates into /usr/lib/wod.

You should also add the following line into your .bashrc file:

```bash
# coexist with system wp-cli.
eval `wod bootstrap`
```

Then start a new shell.

Example usage
=============

```sh
# Show list of commands
wod help

# Create a new WordPress instance called "staging-b"
# The default admin password the URL of the local site displayed
wod create staging-b

# Restore backups of mysite into staging-b
wod restore staging-b ~/backups/mysite

# Invoke wp-cli command on staging-b
wod wp staging-b search-replace http://mysite.com http://127.0.0.1:8000

# Show the current websites managed by wod and their status.
wod ls

# Disable the website.
wod down staging-b

# Delete staging-b.
wod rm staging-b
```

Under the hood, docker and docker-compose is being used to manage the WordPress instances and their databases.


# Setting up a Development Environment

Make a copy of this folder. Open up a bash shell (git-bash is okay) and chdir to the folder. If you are developing in Windows, WSL2 is recommended.

## Environment variable overrides

To ease development, you can override the location WOD looks for its commands.
You will still need to install the main WOD script.

```bash
# Look for sub-commands in ~/src/wod/lib
export SCRIPT_HOME=~/src/wod/lib
```

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

### Alternate domain names

If the website uses multiple domain names (e.g. for language plugins or redirects):

```bash
# See https://security.stackexchange.com/questions/74345/provide-subjectaltname-to-openssl-directly-on-the-command-line#answer-183973
# This works for OpenSSL 1.1.1 or later.
# NOTE: Do not repeat the subject domain in the subjectAltName section.

openssl req -newkey rsa:2048 \
 -addext "subjectAltName = DNS:alt.com, DNS:alt2.com" \
 -nodes -keyout cert.key -x509 -days 365 -out cert.pem

# Optional: Verify certificate
# See https://linuxhandbook.com/check-certificate-openssl/
openssl x509 -in cert.pem -text -noout
```

References:

- https://security.stackexchange.com/questions/74345/provide-subjectaltname-to-openssl-directly-on-the-command-line

## wp-cron

WordPress scheduled jobs do not run in the default Docker setup. Use the alternate job scheduler to fix this.

```php
# Add this line to the wp_config.php file.
define('ALTERNATE_WP_CRON', true);
```

# Older stuff

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
