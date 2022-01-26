cd ./spec

# Convert markdown to XML and HTML versions
docker run -v `pwd`:/data or13/markdown2rfc spec.md || exit 1

# Delete XML version
rm dilithium-jose-00.xml

# Rename the HTML version for hosting with GH pages
mv dilithium-jose-00.html ../docs/spec/index.html

# # github pages 
# cp ./docs/index.html ./docs/404.html

cd ..