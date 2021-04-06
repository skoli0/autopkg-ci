#!/bin/bash

AUTOPKGRECIPES=($(find $(pwd) -name '*.munki.*' -exec basename {} \;))
AUTOPKG=$(which autopkg)
MUNKIMAKECATALOGS="/usr/local/munki/makecatalogs"
MUNKIICONIMPORTER="/usr/local/munki/iconimporter"
MANIFESTUTIL="/usr/local/munki/manifestutil"

aLen=${#AUTOPKGRECIPES[@]}
echo "$aLen" "overrides to create"

for (( j=0; j<aLen; j++));
do
    echo "Adding ${AUTOPKGRECIPES[$j]} override"
    ${AUTOPKG} make-override -f "${AUTOPKGRECIPES[$j]}"
    echo "Updating trust info for ${AUTOPKGRECIPES[$j]}"
    ${AUTOPKG} update-trust-info "${AUTOPKGRECIPES[$j]}"
    echo "Added ${AUTOPKGRECIPES[$j]} override"
    echo "Running ${AUTOPKGRECIPES[$j]} recipe"
    ${AUTOPKG} run "${AUTOPKGRECIPES[$j]}"
done

${MANIFESTUTIL} new-manifest site_default
echo "site_default created"
${MANIFESTUTIL} add-catalog testing --manifest site_default
echo "Testing Catalog added to site_default"

listofpkgs=($(${MANIFESTUTIL} list-catalog-items testing))
echo "List of Packages for adding to repo:" ${listofpkgs[*]}

no_of_packages=${#listofpkgs[@]}
echo "$no_of_packages" " packages to add to manifest"

for (( i=0; i<no_of_packages; i++));
do
    echo "Adding ${listofpkgs[$i]} to site_default"
    ${MANIFESTUTIL} add-pkg ${listofpkgs[$i]} --manifest site_default
    echo "Added ${listofpkgs[$i]} to site_default"
done

find /Users/Shared/munki_repo
