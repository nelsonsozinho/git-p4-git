#!/bin/bash -e

### P4 path repository
P4_DEPOT="//remote/p4/repository"

### GIT related variable
GIT_PROJECT_PATH='/user/username/git/project/path'
GIT_P4_MASTER_BRANCH="p4/master"            # Branch that is a clone of P4
GIT_INTEGRATION_BRANCH="p4/integration"     # Branch used for integrating GIT and P4 commits
GIT_MASTER_BRANCH="master"                  # Branch with commits to be integrated

############ EXECUTION ############
# Enter the project path

configure() {
    export P4CLIENT="workspace"
    export P4HOST="p4serverhost"
    export P4PORT="$P4HOST:1666"
    export P4USER="p4login"
    export P4PASSWD="p4passwd"
}

update_sync_p4() {
    echo "update GIT branch with p4 repository"
    configure
    pushd $GIT_PROJECT_PATH
        git checkout -b $GIT_INTEGRATION_BRANCH & #p4/integration
        git p4 sync $P4_DEPOT &  #p4 remote repository 
        git p4 rebase $GIT_P4_MASTER_BRANCH & #p4/master
    popd
}

update_p4_sync() {
    echo "update P4 repository with GIT branch"
    configure
    pushd $GIT_PROJECT_PATH
        git checkout $GIT_INTEGRATION_BRANCH & #p4/integration
        git p4 rebase $GIT_P4_MASTER_BRANCH & #p4/master
        git p4 submit 
        git checkout $GIT_MASTER_BRANCH
        git branch -D $GIT_INTEGRATION_BRANCH
    popd
}

case "$1" in 
    config) 
        configure
        echo "P4CKIENT="$P4CLIENT
        echo "P4HOST="$P4HOST
        echo "P4PORT="$P4PORT
        echo "P4USER="$P4USER
        exit 0
    ;;

    status)
        git status
        exit 0
    ;;

    p4-git)
        update_sync_p4
        exit 0
    ;;

    git-p4)
        update_p4_sync
        exit 0
    ;;

    *)
        echo "Usage: { config | p4-git | git-p4 }" >&2
        exit 1
    ;;
esac

exit 0


