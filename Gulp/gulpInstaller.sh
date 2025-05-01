#!/bin/bash
# Before running this script, you must install node.js. Refer (http://nodejs.org/download/) for more information.
# As per my configuration, Node was installed at:"/usr/local/bin/node"
# and npm was installed at:"/usr/local/bin/npm".
# Make sure that /usr/local/bin is in your $PATH.
# Refer (http://markgoodyear.com/2014/01/getting-started-with-gulp/) for more information

# To install gulp, run the following command:
sudo npm install gulp -g

# To install it locally to the project, cd into your project and run the following (make sure you have an existing package.json file):
sudo npm install gulp --save-dev

# To install these plugins, run the following command:
sudo npm install gulp-debug gulp-minify-html gulp-concat gulp-replace gulp-concat-css gulp-uglify gulp-minify-css gulp-html-replace yargs gulp-angular-templatecache del gulp-manifest gulp-htmlbuild gulp-load-plugins event-stream --save-dev

#sudo npm install gulp-debug gulp-ruby-sass gulp-autoprefixer gulp-minify-css gulp-jshint gulp-concat gulp-uglify gulp-imagemin gulp-notify gulp-rename gulp-livereload gulp-cache del --save-dev

