cd ./spec

# Convert markdown to XML and HTML versions
# TODO: https://github.com/mesur-io/post-quantum-signatures/issues/1
docker run -v `pwd`:/data or13/markdown2rfc spec.md || exit 1

# Delete XML version
rm draft-post-quantum-signatures-00.xml

# Rename the HTML version for hosting with GH pages
mv draft-post-quantum-signatures-00.html ../docs/index.html

# # github pages 
# cp ./docs/index.html ./docs/404.html

cd ..