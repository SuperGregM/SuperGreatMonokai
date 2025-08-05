#!/usr/bin/env sh
# shellcheck disable=SC2034  # Unused variables left for readability

set -e # -e: exit on error

##################################################################################################################
# printf Colors and Formats

# General Formatting
FORMAT_RESET='\033[0m'
FORMAT_BRIGHT='\033[1m'
FORMAT_DIM='\033[2m'
FORMAT_ITALICS='\033[3m'
FORMAT_UNDERSCORE='\033[4m'
FORMAT_BLINK='\033[5m'
FORMAT_REVERSE='\033[7m'
FORMAT_HIDDEN='\033[8m'

# Foreground Colors
TEXT_BLACK='\033[30m'
TEXT_RED='\033[31m'    # Warning
TEXT_GREEN='\033[32m'  # Command Completed
TEXT_YELLOW='\033[33m' # Recommended Commands / Extras
TEXT_BLUE='\033[34m'
TEXT_MAGENTA='\033[35m'
TEXT_CYAN='\033[36m' # Info Needs
TEXT_WHITE='\033[37m'

# Background Colors
BACKGROUND_BLACK='\033[40m'
BACKGROUND_RED='\033[41m'
BACKGROUND_GREEN='\033[42m'
BACKGROUND_YELLOW='\033[43m'
BACKGROUND_BLUE='\033[44m'
BACKGROUND_MAGENTA='\033[45m'
BACKGROUND_CYAN='\033[46m'
BACKGROUND_WHITE='\033[47m'

# Example Usage
# printf ' %sThis is a warning%s\n' "$TEXT_RED" "$FORMAT_RESET"
# printf ' %s%sInfo:%s Details here\n' "$FORMAT_UNDERSCORE" "$TEXT_CYAN" "$FORMAT_RESET"

##################################################################################################################

show_usage() {
    printf "Usage: Build Extension [options [parameters]]\n"
    printf "\n"
    printf "Options:\n"
    printf '%s'" -${TEXT_YELLOW}fr${FORMAT_RESET}     |   --${TEXT_YELLOW}firstrun${FORMAT_RESET}           pkgx, Install Prettier, js-yaml, ovsx and vsce \n"
    printf '%s'" -${TEXT_YELLOW}tt${FORMAT_RESET}     |   --${TEXT_YELLOW}testtheme${FORMAT_RESET}          Test SuperGreatMonokai Theme JSON\n"
    printf '%s'" -${TEXT_YELLOW}uf${FORMAT_RESET}     |   --${TEXT_YELLOW}updatefish${FORMAT_RESET}         Update Fish JSON Files\n"
    printf '%s'" -${TEXT_YELLOW}un${FORMAT_RESET}     |   --${TEXT_YELLOW}updatenix${FORMAT_RESET}          Update Nix JSON Files\n"
    printf '%s'" -${TEXT_YELLOW}uv${FORMAT_RESET}     |   --${TEXT_YELLOW}updatevim${FORMAT_RESET}          Update VimL JSON Files\n"
    printf '%s'" -${TEXT_YELLOW}cl${FORMAT_RESET}     |   --${TEXT_YELLOW}changelog${FORMAT_RESET}          Generate Changelog\n"
    printf '%s'" -${TEXT_YELLOW}pack${FORMAT_RESET}   |   --${TEXT_YELLOW}package${FORMAT_RESET}            Package Extension for GitHub\n"
    printf '%s'" -${TEXT_YELLOW}pubv${FORMAT_RESET}   |   --${TEXT_YELLOW}publishvscode${FORMAT_RESET}      Publish Extension to VS Code Marketplace\n"
    printf '%s'" -${TEXT_YELLOW}pubo${FORMAT_RESET}   |   --${TEXT_YELLOW}publishopenvsx${FORMAT_RESET}     Publish Extension to Open-VSX.org\n"
    printf '%s'" -${TEXT_YELLOW}h${FORMAT_RESET}      |   --${TEXT_YELLOW}help${FORMAT_RESET}               Print this message\n"

    return 0
}

check_pkgx() {
    if ! command -v pkgx >/dev/null 2>&1; then
        printf "${TEXT_RED}\n%s\n${FORMAT_RESET}" "pkgx is not installed"
        exit
    fi
}

# Check if the system is macOS
case $(uname) in
Darwin)
    check_pkgx
    wgetCompatible='wget -q --show-progress'
    sedCompatible='gsed -i'
    vsceCompatible='npx @vscode/vsce'
    ovsx_Compatible='npx ovsx'
    prettierCompatible='npx prettier'
    js_yaml_Compatible='npx js-yaml'
    npm_Destination="$XDG_DATA_HOME/npm/bin/"
    ;;
Linux)
    wgetCompatible='wget'
    sedCompatible='sed -i'
    vsceCompatible='npx vsce'
    ovsx_Compatible='npx ovsx'
    prettierCompatible='npx prettier'
    js_yaml_Compatible='npx js-yaml'
    npm_Destination='/usr/local/bin/'
    ;;
*)
    printf "${TEXT_RED}\n%s\n${FORMAT_RESET}" "Unsupported system"
    exit
    ;;
esac

check_vsce() {
    vsce_Dir="$npm_Destination/vsce"
    if [ ! "$vsce_Dir" ]; then
        printf "${TEXT_RED}\n%s\n${FORMAT_RESET}" "VS Code Extension Manager is not installed"
        exit
    fi
}

check_ovsx() {
    ovsx_Dir="$npm_Destination/ovsx"
    if [ ! -e "$ovsx_Dir" ]; then
        printf "${TEXT_RED}\n%s\n${FORMAT_RESET}" "Open-VSX is not installed"
        exit
    fi
}

check_prettier() {
    prettier_Dir="$npm_Destination/prettier"
    if [ ! -e "$prettier_Dir" ]; then
        printf "${TEXT_RED}\n%s\n${FORMAT_RESET}" "Prettier is not installed"
        exit
    fi
}

check_js_yaml() {
    jsyaml_dir="$npm_Destination/js-yaml"
    if [ ! -e "$jsyaml_dir" ]; then
        printf "${TEXT_RED}\n%s\n${FORMAT_RESET}" "js-yaml is not installed"
        exit
    fi
}

publish_openvsx() {
    if [ ! "$OVSX_PAT" ]; then
        if [ -f "$HOME/.ssh/.env/EXT_DEPLOY_OVSX_PAT.env" ]; then
            # Set OVSX_PAT environment variable
            OVSX_PAT_VARIABLE=$(head -n 1 "$HOME/.ssh/.env/EXT_DEPLOY_OVSX_PAT.env")
            export OVSX_PAT="$OVSX_PAT_VARIABLE"
        else
            printf "${TEXT_RED}\n%s\n\n${FORMAT_RESET}" "   OVSX_PAT environment variable is not set"
            exit
        fi
    fi
    printf "${TEXT_GREEN}\n%s\n${FORMAT_RESET}" "Publishing SuperGreatMonokai to Open-VSX.org"
    # Publish to Open-VSX
    $ovsx_Compatible publish
}

publish_vscode() {
    if [ ! "$VSCE_PAT" ]; then
        if [ -f "$HOME/.ssh/.env/EXT_DEPLOY_VSCE_PAT.env" ]; then
            # Set VSCE_PAT environment variable
            VSCE_PAT_VARIABLE=$(head -n 1 "$HOME/.ssh/.env/EXT_DEPLOY_VSCE_PAT.env")
            export VSCE_PAT="$VSCE_PAT_VARIABLE"
        else
            printf "${TEXT_RED}\n%s\n\n${FORMAT_RESET}" "   VSCE_PAT environment variable is not set"
            exit
        fi
    fi
    printf "${TEXT_GREEN}\n%s\n${FORMAT_RESET}" "Publishing SuperGreatMonokai to VS Code Marketplace"
    # Publish to VS Code Marketplace
    $vsceCompatible publish --no-git-tag-version
}

test_theme() {
    printf "${TEXT_GREEN}\n%s\n${FORMAT_RESET}" "Testing SuperGreatMonokai Theme JSON"

    sed 's/\/\/.*//' themes/SuperGreatMonokai-color-theme.json | jq empty
}

update_fish() {
    printf "${TEXT_GREEN}\n%s\n${FORMAT_RESET}" "Updating Fish JSON Files"

    $wgetCompatible -O ./syntaxes/fish-codeblock.json https://raw.githubusercontent.com/SuperGregM/vscode-fish/master/syntaxes/codeblock.json
    $wgetCompatible -O ./syntaxes/fish.tmLanguage.json https://raw.githubusercontent.com/SuperGregM/vscode-fish/master/syntaxes/fish.tmLanguage.json
    $wgetCompatible -O ./language-configuration/fish-language-configuration.json https://raw.githubusercontent.com/SuperGregM/vscode-fish/master/language-configuration.json
}

update_nix() {
    printf "${TEXT_GREEN}\n%s\n${FORMAT_RESET}" "Updating Nix JSON Files"

    $wgetCompatible -O ./syntaxes/nix-codeblock.yml https://raw.githubusercontent.com/SuperGregM/vscode-nix-ide/main/syntaxes/injection.yml
    $wgetCompatible -O ./syntaxes/nix.tmLanguage.yml https://raw.githubusercontent.com/SuperGregM/vscode-nix-ide/main/syntaxes/nix.YAML-tmLanguage
    $wgetCompatible -O ./language-configuration/nix-language-configuration.json https://raw.githubusercontent.com/SuperGregM/vscode-nix-ide/main/language-configuration.json

    $js_yaml_Compatible syntaxes/nix.tmLanguage.yml >syntaxes/nix.tmLanguage.json
    $js_yaml_Compatible syntaxes/nix-codeblock.yml >syntaxes/nix-codeblock.json
}

update_vim() {
    printf "${TEXT_GREEN}\n%s\n${FORMAT_RESET}" "Updating VimL Files"

    $wgetCompatible -O ./syntaxes/viml.tmLanguage.json https://raw.githubusercontent.com/SuperGregM/viml-vscode/master/syntaxes/viml.tmLanguage.json
    $wgetCompatible -O ./language-configuration/viml-language-configuration.json https://raw.githubusercontent.com/SuperGregM/viml-vscode/master/language-configuration.json
}

change_log() {
    printf "${TEXT_GREEN}\n%s\n${FORMAT_RESET}" "Generating Changelog"

    filename=./CHANGELOG.md

    git log --graph --pretty=format:'%Cgreen(%ad)%Creset -%C(yellow)%d%Creset  %s' --abbrev-commit --date=short >>"$filename"

    $sedCompatible 's/^\*/-/g' "$filename"

    $prettierCompatible --cache-location "$HOME/.cache/prettier" --write "$filename"
}

package_extension() {
    printf "${TEXT_GREEN}\n%s\n${FORMAT_RESET}" "Packaging SuperGreatMonokai"

    rm -rf ./supergreatmonokai.vsix

    $vsceCompatible package "$1" --no-git-tag-version --out ./supergreatmonokai.vsix
}

first_run() {
    printf "${TEXT_GREEN}\n%s\n${FORMAT_RESET}" "First Run.  Installing Apps with pkgx"
    pkgx install npx@latest
    pkgx npm install -g @vscode/vsce@latest
    pkgx npm install -g ovsx@latest
    pkgx npm install -g js-yaml@latest
    pkgx npm install -g prettier@latest
}

# Check if an argument is provided
case "$1" in
-fr | --firstrun)
    first_run
    ;;
-tt | --testtheme)
    test_theme
    ;;
-uf | --updatefish)
    update_fish
    ;;
-un | --updatenix)
    check_js_yaml
    update_nix
    ;;
-uv | --updatevim)
    update_vim
    ;;
-cl | --changelog)
    check_prettier
    change_log
    ;;
-pack | --package)
    check_vsce
    package_extension "$2"
    ;;
-pubv | --publishvscode)
    check_vsce
    publish_vscode
    ;;
-pubo | --publishopenvsx)
    check_ovsx
    publish_openvsx
    ;;
-h | --help | *)
    show_usage
    exit
    ;;
esac
