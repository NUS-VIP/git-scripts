#!/bin/bash
DIR=`dirname "$0"`



#clone
setup() {

    forked_repo_url=$1    
    upstream_repo_url=$2
    repos_dir=$3

    if [ "$upstream_repo_url" = "" ] || [ "$forked_repo_url" = "" ] || [ "$repos_dir" = "" ] ; then
        echo "Usage: setup <forked repos name> <upstream repos name> <repos dir>"
        exit
    fi

    #add remote url
    git clone "$forked_repo_url" $repos_dir
    pushd $DIR
    cd $repos_dir  
    git remote rename origin forked
    git remote add upstream "$upstream_repo_url"
    git remote -v
    git remote update

    popd
}


#update
remote_down() {
    
    remote_repos="$1"
    remote_branch="$2"
    local_branch="$3"

    if [ "$remote_repos" = "" ] || [ "$remote_branch" = "" ] || [ "$local_branch" = "" ] ; then
        echo "$remote_repos, $local_branch, $remote_branch"
        echo "Usage: down <remote repos> <remote branch> <local branch>"
        exit
    fi

    git remote update

    if git branch | grep -sw "$local_branch" 2>&1>/dev/null; then
        git checkout $local_branch
    else
        git checkout -b $local_branch $remote_repos/$remote_branch
    fi
    git rebase $remote_repos/$remote_branch

}


remote_up(){

    remote_repos=$1
    local_branch=$3
    remote_branch=$2

    if [ "$remote_repos" = "" ] || [ "$remote_branch" = "" ] || [ "$local_branch" = "" ] ; then
        echo "Usage: up <remote repos> <remote branch> <local branch> "
        exit
    fi

    git remote update
    git checkout $local_branch
    if git ls-remote $remote_repos | grep -sw "$remote_branch" 2>&1>/dev/null; then 
        echo "remote branch exists, syncing it first"
        git rebase $remote_repos/$remote_branch 
    fi
    git push $remote_repos $local_branch:$remote_branch
}

delete_branch(){
    remote_repos=$1
    branch=$2

    if [ "$branch" = "" ] || [ "$remote_repos" = "" ] ; then
        echo "Usage: delete <branch> - this will delete the branches with input name both locally and remotely "
        exit
    fi

    git remote update
    #delete local branch
    git checkout master 
    git branch -D $branch 
    #delete forked branch
    git push $remote_repos :$branch
}

usage() {

    echo -e "Usage: cmd < s | -setup>  < d | -down > < u | -up> < db | -delete-branch > <h|-help>"
}

if [ ! $# -gt 0 ]; then
    usage
fi

while [ "$1" != "" ]; do
    case $1 in
        s  | -setup )         shift
                                forked=$1
                              shift
                                upstream=$1
                              shift
                                reposdir=$1
                                setup $forked $upstream $reposdir
                                ;; 

        u | -up )             shift
                                remote_repos=$1
                              shift
                                remote_branch=$1
                              shift
                                local_branch=$1
                              remote_up $remote_repos $remote_branch $local_branch
                                ;;

        d | -down )           shift
                                remote_repos=$1
                              shift  
                                remote_branch=$1
                              shift
                                local_branch=$1
                              remote_down $remote_repos $remote_branch $local_branch
                                ;;        
        db | -delete-branch ) shift
                                branch=$1
                                delete_branch $branch
                                ;;
        h | -help )           usage
                                exit
                                ;;
        * )                     usage
                                exit 1
    esac
    shift
done
