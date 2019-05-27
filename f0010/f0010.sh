#!/bin/bash

# Setup
#
# - Create a new Jenkins Job
# - Mark "None" for Source Control Management
# - Select the "Build Periodically" build trigger
#   - configure to run as frequently as you like
# - Add a new "Execute Shell" build step
#   - Paste the contents of this file as the command
# - Save
#
# NOTE: before this job will work, you'll need to manually navigate to the $JENKINS_HOME directory
# and do the initial set up of the git repository.
# Make sure the appropriate remote is added and the default remote/branch set up.
#

# Jenkins Configuraitons Directory
cd $JENKINS_HOME

# Add general configurations, job configurations, and user content
git add -- *.xml jobs/*/*.xml userContent/*

# only add user configurations if they exist
if [ -d users ]; then
    user_configs=`ls users/*/config.xml`

    if [ -n "$user_configs" ]; then
        git add $user_configs
    fi
fi

# mark as deleted anything that's been, well, deleted
to_remove=`git status | grep "deleted" | awk '{print $3}'`

if [ -n "$to_remove" ]; then
    git rm --ignore-unmatch $to_remove
fi

git commit -m "Automated Jenkins commit"

git push -q -u origin master
