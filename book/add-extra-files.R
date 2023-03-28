# Copy the required webr js files into the build directory
file.copy("_extensions/coatless/webr/webr-serviceworker.js", "_book/webr-serviceworker.js")
file.copy("_extensions/coatless/webr/webr-worker.js", "_book/webr-worker.js")

# Copy the custom headers file for netlify to improve speed and security
# See https://docs.r-wasm.org/webr/latest/serving.html
file.copy("_headers", "_book/_headers")