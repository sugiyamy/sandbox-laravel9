#!/usr/bin/env bash

## enviroment variables
PROJECT_ROOT="$( cd "$( dirname "${0}" )" && pwd -P )"
LARAVEL_DIR="${PROJECT_ROOT}/laravel"

### php-cs-fixer
PCF_DIR="${LARAVEL_DIR}/tools/php-cs-fixer"
PCF_CMD="${PCF_DIR}/vendor/bin/php-cs-fixer"

### larastan
LRS_DIR="${LARAVEL_DIR}/tools/larastan"
LRS_CMD="${LRS_DIR}/vendor/bin/phpstan"

## utility
function get-modified-files() {
    git diff --name-status main | grep -e '^[AM]\(.*\).php$' | cut -c 3- |
        sed -e "s#^#${PROJECT_ROOT}/#"
}

## php-cs-fixer
function pcf() {
    "${PCF_CMD}" "${@}"
}

function pcf-fix() {
    get-modified-files |
        xargs "${PCF_CMD}" fix -r -v --config="${LARAVEL_DIR}/.php-cs-fixer.dist.php"
}

function pcf-fix-all() {
    "${PCF_CMD}" fix -v --config=$LARAVEL_DIR/.php-cs-fixer.dist.php
}

function pcf-dry() {
    get-modified-files |
        xargs "${PCF_CMD}" fix -r -v --dry-run --config="${LARAVEL_DIR}/.php-cs-fixer.dist.php"
}

function pcf-dry-all() {
    "${PCF_CMD}" fix -v --dry-run --config="${LARAVEL_DIR}/.php-cs-fixer.dist.php"
}

function pcf-dry-diff() {
    get-modified-files |
        xargs "${PCF_CMD}" fix -r -v --dry-run --diff --config="${LARAVEL_DIR}/.php-cs-fixer.dist.php"
}

function pcf-dry-diff-all() {
    "${PCF_CMD}" fix -v --dry-run --diff --config="${LARAVEL_DIR}/.php-cs-fixer.dist.php"
}

function pcf-install() {
    composer install --working-dir="${PCF_DIR}"
}

## larastan
function lrs() {
    "${LRS_CMD}" "${@}"
}

function lrs-analyse() {
    (
        cd "${LARAVEL_DIR}" &&
            "${LRS_CMD}" analyse --memory-limit=1G --configuration "${LARAVEL_DIR}/phpstan.dist.neon"
    )
}

function lrs-gen-bl() {
    (
        cd "${LARAVEL_DIR}" &&
            "${LRS_CMD}" analyse --memory-limit=1G --configuration "${LARAVEL_DIR}/phpstan.dist.neon" --generate-baseline
    )
}

function lrs-install() {
    composer install --working-dir="${LRS_DIR}"
}

## other
function install() {
    pcf-install
    lrs-install
}

function help() {
    cat - <<EOT
Usage:
    run.sh [command]
Commands:
    pcf              run php-cs-fixer with arguments
    pcf:fix          fix changed files
    pcf:fix-all      fix all files
    pcf:dry          dry run changed files
    pcf:dry-all      dry run all files
    pcf:dry-diff     dry run with diff changed files
    pcf:dry-diff-all dry run with diff all files
    pcf:install      install php-cs-fixer
    lrs              run larastan(phpstan) with arguments
    lrs:analyse      run larastan
    lrs:gen-bl       generate basefile
    lrs:install      install larastan
    help             show this message
EOT
}

function main() {
    local cmd

    cmd=""
    if (( $# >= 1 )); then
        cmd="${1}"
    fi

    case $cmd in
        ("pcf:dry-diff")
            pcf-dry-diff;;
        ("pcf:dry-diff-all")
            pcf-dry-diff-all;;
        ("pcf:dry")
            pcf-dry;;
        ("pcf:dry-all")
            pcf-dry-all;;
        ("pcf:fix")
            pcf-fix ${@:2};;
        ("pcf:fix-all")
            pcf-fix-all;;
        ("pcf:install")
            pcf-install;;
        ("pcf")
            pcf "${@:2}";;
        ("lrs:analyse")
            lrs-analyse;;
        ("lrs:gen-bl")
            lrs-gen-bl;;
        ("lrs:install")
            lrs-install;;
        ("lrs")
            lrs "${@:2}";;
        ("install")
            install;;
        ("help")
            help;;
        (*)
            help;;
    esac
}

main "${@}"
