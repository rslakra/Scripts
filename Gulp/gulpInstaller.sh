#!/bin/bash
# Before running this script, you must install node.js. Refer (http://nodejs.org/download/) for more information.
# As per my configuration, Node was installed at:"/usr/local/bin/node"
# and npm was installed at:"/usr/local/bin/npm".
# Make sure that /usr/local/bin is in your $PATH.
# Refer (http://markgoodyear.com/2014/01/getting-started-with-gulp/) for more information

# Bootstrap: Find and source script_utils.sh, then setup environment
_s="${BASH_SOURCE[0]}"; while [ -L "$_s" ]; do _l="$(readlink "$_s")"; [[ "$_l" != /* ]] && _s="$(cd "$(dirname "$_s")" && pwd)/$_l" || _s="$_l"; done; source "$(cd "$(dirname "$_s")/../.." && pwd)/script_utils.sh" && setup_scripts_env "${BASH_SOURCE[0]}"

print_header "Install Gulp"
echo -e "${INDIGO}Installing Gulp globally...${NC}"
# To install gulp, run the following command:
sudo npm install gulp -g

echo -e "${INDIGO}Installing Gulp locally (requires package.json)...${NC}"
# To install it locally to the project, cd into your project and run the following (make sure you have an existing package.json file):
sudo npm install gulp --save-dev

echo -e "${INDIGO}Installing Gulp plugins...${NC}"
# To install these plugins, run the following command:
sudo npm install gulp-debug gulp-minify-html gulp-concat gulp-replace gulp-concat-css gulp-uglify gulp-minify-css gulp-html-replace yargs gulp-angular-templatecache del gulp-manifest gulp-htmlbuild gulp-load-plugins event-stream --save-dev

#sudo npm install gulp-debug gulp-ruby-sass gulp-autoprefixer gulp-minify-css gulp-jshint gulp-concat gulp-uglify gulp-imagemin gulp-notify gulp-rename gulp-livereload gulp-cache del --save-dev
print_success "Gulp installed successfully!"
echo

