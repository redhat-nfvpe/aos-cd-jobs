# usage: ./merge_ocp.sh ./working/ enterprise-3.11 release-3.11
set -e
set -x
WORKING_DIR=$1
OSE_SOURCE_BRANCH=$2
UPSTREAM_SOURCE_BRANCH=$3

GITHUB_BASE="git@github.com:openshift"

pushd ${WORKING_DIR}

# pull OSE
git clone ${GITHUB_BASE}/ose.git
cd ose

if [ "${OSE_SOURCE_BRANCH}" != "master" ]
then
    git checkout -b ${OSE_SOURCE_BRANCH} origin/${OSE_SOURCE_BRANCH}
fi

# Add origin remote so we can merge it in
git remote add upstream ${GITHUB_BASE}/origin.git --no-tags
git fetch upstream "${UPSTREAM_SOURCE_BRANCH}"

# Enable fake merge driver used in our .gitattributes
git config merge.ours.driver true
# Use fake merge driver on specific packages
echo 'pkg/assets/bindata.go merge=ours' >> .gitattributes
echo 'pkg/assets/java/bindata.go merge=ours' >> .gitattributes
git merge -m "Merge remote-tracking branch ${UPSTREAM_SOURCE_BRANCH}" "upstream/${UPSTREAM_SOURCE_BRANCH}"

# git push # probabaly don't run this yet

popd
