#!/bin/bash

# This script downloads the entire Passion Talks 2014 website at
# passiontalks.wordpress.com and transforms the files into a format
# appropriate for a statically hosted website. In theory this script would
# only need to be run once, but the process is fully automated anyway. Note
# that there will be differences between runs even if the original website
# has not changed, as both HTTrack and Wordpress include timestamps in their
# pages.

# Requirements:
#
#  * HTTrack (http://www.httrack.com/) 3.48 (Note: HTTrack has not
#    historically been backwards compatible in its CLI between releases.)
#
#  * A reasonably Unixy environment with bash, grep, perl, etc.

set -e

rm -rf pt14 cache

httrack \
--mirror \
--path pt14,cache \
--depth 5 \
--structure 100 \
--include-query-string 0 \
--index 0 \
--generate-errors 0 \
http://passiontalks.wordpress.com/ \
+s0.wp.com/_static/* \
+s1.wp.com/_static/* \
+s2.wp.com/_static/* \
+s0.wp.com/*.css +s1.wp.com/*.css +s2.wp.com/*.css \
+s0.wp.com/*.ico +s1.wp.com/*.ico +s2.wp.com/*.ico \
+s0.wp.com/*.js +s1.wp.com/*.js +s2.wp.com/*.js \
+s0.wp.com/*.png +s1.wp.com/*.png +s2.wp.com/*.png \
+botd2.wordpress.com/*.gif \
+passiontalks.files.wordpress.com/*.jpg \
+passiontalks.files.wordpress.com/*.png \
+passiontalks.files.wordpress.com/*.pdf \
+blog.ffpaladin.com/wp-content/uploads/*.jpg \
+blog.ffpaladin.com/wp-content/uploads/*.png \
+*.googleusercontent.com/*.jpg

# Remove files added by httrack.
rm -f pt14/backblue.gif pt14/fade.gif

# Remove other miscellaneous files.
rm -f pt14/osd.xml pt14/xmlrpc.php pt14/xmlrpc0db0.php pt14/wp-login.html
find pt14 -name 'feed' -exec rm -rf {} +

# Move index.html into place.
mv pt14/index-3.html pt14/index.html

# Remove sharing files.
find pt14 -name 'index5a58.html' -delete
find pt14 -name 'index9a7b.html' -delete
find pt14 -name 'indexdd8f.html' -delete

# Force rename CSS files to .css.
for f in $(grep "<link rel='stylesheet'" -h -r pt14 | egrep "([A-Za-z_]+/)*index[0-9a-f]*.html" -o | sort | uniq); do mv "pt14/$f" pt14/"$(dirname "$f")"/"$(basename "$f" .html)".css; done

# Fix links to strange .html?? files.
find pt14 -name '*.html*' -exec perl -pi -e 's/([.]html)[?][?][A-Za-z0-9=+&%\/;.-]+/\1/g' {} +

# Fix up links to CSS files.
find pt14 -name '*.html*' -exec perl -pi -e "s/(<link rel='stylesheet'( id='[A-Za-z0-9_-]+')? href='[A-Za-z0-9.\/_-]+)[.]html'/\1.css'/g" {} +

# Fix links to point to / instead of /index-3.html .
find pt14 -name '*.html*' -exec perl -pi -e "s/(<a( class=['\"][A-Za-z0-9_-]+['\"])? href=['\"]([A-Za-z0-9_.\/-]+\/)?)index-3.html/\1/g" {} +
find pt14 -name '*.html*' -exec perl -pi -e "s/(<link rel='canonical' href=')index-3.html'/\1.'/g" {} +

# Fix links to point to / instead of /index.html .
find pt14 -name '*.html*' -exec perl -pi -e "s/(<a href=['\"][A-Za-z0-9_.\/-]+)\/index.html/\1\//g" {} +

# Fix links to Google Fonts.
find pt14 -name '*.html*' -exec perl -pi -e "s/http:\/\/fonts.googleapis.com\//https:\/\/fonts.googleapis.com\//g" {} +
