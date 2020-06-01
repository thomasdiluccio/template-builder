# move into place our config. We are not using the platform_sh_rails helper GEM
mv config/discourse.platformsh.conf config/discourse.conf
# move into place required binaries
mv public/ _public/
# create symbolic link form app/tmp to /tmp so Bootsnap doesn't die.
ln -s /tmp tmp
# install nvm

unset NPM_CONFIG_PREFIX
curl -o- https://raw.githubusercontent.com/creationix/nvm/$NVM_VERSION/install.sh | dash
export NVM_DIR="$PLATFORM_APP_DIR/.nvm"
[ -s "$NVM_DIR/nvm.sh" ] && \. "$NVM_DIR/nvm.sh"
nvm current
nvm install $NODE_VERSION
# Install globally some more required npm packages that are not in package.json
npm i -g "yarn" "svgo" "gifsicle@4.0.1" "uglify@<3"
# install the version of bundler specified in Gemfile.lock (should not be necessary with ruby 2.7 and up. This is a Gem bug.)
bundle update --bundler
gem install bundler -v "$(grep -A 1 "BUNDLED WITH" Gemfile.lock | tail -n 1)"
# Export the current ruby version
RUBY_VERSION=$(ruby -e"puts RUBY_VERSION")
# Install official plugins
# To install plugins ... uncomment the following lines
# git clone --depth=1 https://github.com/discourse/discourse-backup-uploads-to-s3.git plugins/discourse-backup-uploads-to-s3
# git clone --depth=1 https://github.com/discourse/discourse-spoiler-alert.git plugins/discourse-spoiler-alert
# git clone --depth=1 https://github.com/discourse/discourse-cakeday.git plugins/discourse-cakeday
# git clone --depth=1 https://github.com/discourse/discourse-canned-replies.git plugins/discourse-canned-replies
# git clone --depth=1 https://github.com/discourse/discourse-chat-integration.git plugins/discourse-chat-integration
# git clone --depth=1 https://github.com/discourse/discourse-assign.git plugins/discourse-assign
# git clone --depth=1 https://github.com/discourse/discourse-patreon.git plugins/discourse-patreon
# git clone --depth=1 https://github.com/discourse/discourse-user-notes.git plugins/discourse-user-notes
# git clone --depth=1 https://github.com/discourse/discourse-group-tracker
# Install Gems
bundle install --retry 3 --jobs 4
bundle exec rake plugin:install_all_gems
# Optionally install the CLI
# curl -sS https://platform.sh/cli/installer | php