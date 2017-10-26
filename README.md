This tool works on a *nix evironment. copy the build.properties.template file to build.properties and set the userid/password along with the server url.

add components you dont want to extract data for in the exclusions file and these will not be added to the package.xml that will be generated.

add standard objects that need to be part of the inclusions file and these will be populated in the manifest file.

change the mode on generate_package.sh to execute and run the script.
