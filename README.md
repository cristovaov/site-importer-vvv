Existing site importer for VVV.
Based on Simon Wheatley's demo examples and existing scripts in the VVV project.

Assuming that you are already using [Varying Vagrants Vagrant](https://github.com/10up/varying-vagrant-vagrants/).
Recommended: Vagrant Hosts Updater and Triggers installed

Steps:

1. Copy your existing site in your `www` folder inside your VVV installation.
2. Clone or extract this repo in a folder named `vvv-import` inside your site's local copy. 
3. Replace `samplesite.sql` with your DB backup.
4. Modify all instances of `samplesite.dev` inside the files `vvv-host` and `vvv-nginx.conf`.
5. Change the MySQL credentials inside wp-config.php to VVV's default -don't forget to back it up or copy/rename before!
6. If Vagrant is running, stop it with `vagrant halt`...
7. follow this with a `vagrant up --provision`. -> optional: drop the `provision-custom.sh` file from the extra folder in the provision folder as to not go through the full provisioning
8. Probably needed: Vagrant SSH to your imported site and do a WP-CLI search and replace.

You should be good to go. 