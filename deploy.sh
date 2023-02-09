!#/bin/sh

# =================
# DEPLOYMENT SCRIPT
# =================

# project name
PROJECT_NAME=awesome

# git repository url
GIT_URL=git@github.com:project/awesome.git

# working directory where we put the download git repo and archive files
GIT_DIR=~/git-clones

# this is important, some repo doesn't use root dir as document root.
# for example /project.git/src/htdocs In this case htdocs is the document root not project.git
GIT_WWW_REL_DIR=src

GIT_REV=""

# path to document root of your project
PRODUCTION_DIR=~/backup/www

# relative path to upload dir, relative to WWW_REL_DIR
PRODUCTION_UPLOAD_REL_DIR=public/uploads

# ===============
# SYSTEM SETTINGS
# ===============

# Y-m-d H:i:s
DEPLOY_TIME=`date +"%Y%m%d-%H%M%S"` 

function helper_trim {
    str=$1
    del=$2
    echo $1 | sed "s|$del*$||g"
}

PRODUCTION_UPLOAD_DIR=`helper_trim $PRODUCTION_DIR/$PRODUCTION_UPLOAD_REL_DIR /`

PROJECT_DIR=$GIT_DIR/$PROJECT_NAME
PROJECT_TMP_DIR=$PROJECT_DIR/tmp
PROJECT_TMP_ROOT_DIR=`helper_trim $PROJECT_TMP_DIR/$GIT_WWW_REL_DIR /`
PROJECT_TMP_UPLOAD_DIR=`helper_trim $PROJECT_TMP_ROOT_DIR/$PRODUCTION_UPLOAD_REL_DIR /`
PROJECT_ARCHIVE_DIR=$PROJECT_DIR/archives
PROJECT_ARCHIVE_FILE=$PROJECT_ARCHIVE_DIR/$DEPLOY_TIME

# Create dir if not exists
function create_dir {

    case "$2" in

        # if directory exists delete if first
        delete )
            echo "Deleting existing dir $1"
            rm -rf $1
            ;;
    esac

    if [ ! -d $1 ]; then
        echo "Creating file $1"
        mkdir -p $1

    else
        echo "Directory $1 already exists, skipped"
    fi
}

function helper_create_dir {
    exit
}

# Check basic requirements
function check_requirements {

    echo "
START DEPLOYMENT
----------------
Git repository url:   $GIT_URL
Working directory:    $PROJECT_DIR
Archive directory:    $PROJECT_ARCHIVE_DIR
Repo's directory:     $PROJECT_TMP_DIR
Repo's document root: $PROJECT_TMP_ROOT_DIR
Repo's upload dir:    $PROJECT_TMP_UPLOAD_DIR
WWW document root:    $PRODUCTION_DIR
WWW upload dir:       $PRODUCTION_UPLOAD_DIR
"

    # check file permissions
    error=0

    for f in `dirname $GIT_DIR` `dirname $PRODUCTION_DIR`; do

        if [ ! -w $f ]; then
            echo "You don't have permission to write on $f"
            error=1
        fi
    done

    [ $error -eq 1 ] && exit -1

    echo -ne "Continue? [y/n]: "; 
    read continue

    if [ "$continue" != 'y' ]; then

        exit 0
    fi

    # create dirs
    create_dir $PROJECT_DIR
    create_dir $PRODUCTION_DIR
    # create_dir $PROJECT_TMP_DIR delete
    rm -rf $PROJECT_TMP_DIR
    create_dir $PROJECT_ARCHIVE_DIR
}

# Clone data from github
function deploy_clone_git_repo {

    echo "
Clone repository 
----------------
"
    # clone src repo into tmp dir
    git clone $GIT_URL $PROJECT_TMP_DIR
}

function deploy_copy_files {

    echo "
Copy src files
--------------
"

    # copy upload files
    # create_dir $PROJECT_TMP_UPLOAD_DIR
    # chmod 777 $PROJECT_TMP_UPLOAD_DIR

    # copy upload files from production to tmp
    if [ -d $PRODUCTION_UPLOAD_DIR ]; then

        echo "Copying data from $PRODUCTION_UPLOAD_DIR/ to $PROJECT_TMP_UPLOAD_DIR/"
        cp -R $PRODUCTION_UPLOAD_DIR/ $PROJECT_TMP_UPLOAD_DIR/
    fi

    # copy from tmp dir to production dir 
    echo "Copying data from $PROJECT_TMP_ROOT_DIR to $PRODUCTION_DIR.tmp"
    cp -R $PROJECT_TMP_ROOT_DIR $PRODUCTION_DIR.tmp

    # rename from /project/ dir to /project.tmp.original/
    echo "Renaming $PRODUCTION_DIR to $PRODUCTION_DIR.tmp.original"
    mv $PRODUCTION_DIR $PRODUCTION_DIR.tmp.original

    # replace production with our temp dir. /project.tmp/ to /project/
    echo "Renaming $PRODUCTION_DIR.tmp to $PRODUCTION_DIR"
    mv $PRODUCTION_DIR.tmp $PRODUCTION_DIR

    # arhive it
    create_dir $PROJECT_ARCHIVE_FILE
    mv $PRODUCTION_DIR.tmp.original $PROJECT_ARCHIVE_FILE
}

function deploy_to_version {

    # Deploy to specific commit
    if [ "$GIT_REV" ]; then

        cd $PROJECT_TMP_DIR
        git checkout $GIT_REV
        # git reset --hard $GIT_REV
    fi
}

check_requirements
deploy_clone_git_repo
deploy_copy_files