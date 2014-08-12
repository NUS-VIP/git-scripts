#!/bin/bash
DIR=`dirname "$0"`


repos_dir="./caffe"


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

#create branch 
new_branch(){

    branch_name=$1
    upstream_branch=$2
    
    if [ "$branch_name" = "" ] || [ "$upstream_branch" = "" ] ; then
        echo "Usage: new_branch <local branch name> <upstream branch name>"
        exit
    fi

    git remote update
    git checkout -b $branch_name upstream/$upstream_branch  
    #push branch to forked
    git push forked $branch_name


}

#update
upstream_down() {

    local_branch=$1
    remote_branch=$2

    if [ "$remote_branch" = "" ] || [ "$local_branch" = "" ] ; then
        echo "Usage: upstream_down <local branch> <upstream branch>"
        exit
    fi

    git remote update
    git checkout $local_branch
    git rebase upstream/$remote_branch

}


forked_down(){

    branch=$1

    if [ "$branch" = "" ] ; then
        echo "Usage: forked_down <branch> "
        exit
    fi

    git remote update
    git checkout -b $branch
    git rebase forked/$branch

}

forked_up(){
    branch=$1

    if [ "$branch" = "" ] ; then
        echo "Usage: forked_up <branch> "
        exit
    fi

    git remote update
    git checkout $branch
    if [ $? != 0 ]; then 
        exit
    fi
    git rebase forked/$branch 
    git push forked
    
}

delete_branch(){
    branch=$1

    if [ "$branch" = "" ] ; then
        echo "Usage: forked_up <branch> "
        exit
    fi

    git remote update
    #delete local branch
    git checkout master 
    git branch -D $branch 
    #delete forked branch
    git push forked :$branch
}

usage() {

    echo -e "Usage: cmd <s | -setup> <nb |-new-branch> <ud | -upstream-down> <fu | -forked-up> <fd | -forked-down> <db | -delete-branch> <h|-help>"
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
        nb | -new-branch )    shift
                                lobal_branch=$1
                              shift
                                upstream_branch=$1
                                new_branch $lobal_branch $upstream_branch
                                ;;
        ud | -upstream-down ) shift
                                local_branch=$1
                              shift
                                remote_branch=$1
                                upstream_down $local_branch $remote_branch
                                ;;

        fu | -forked-up )       shift
                                branch=$1
                                forked_up $branch
                                ;;

        fd | -forked-down )     shift
                                branch=$1
                                forked_down $branch
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
