# The _site folder cannot be kept under source control
# due to a bug: https://github.com/mojombo/jekyll/issues/534
# that probably won't be address.
rm -rf _cache
cp -r _site/* . && rm -rf _site/ && touch .nojekyll