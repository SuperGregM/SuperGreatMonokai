#!/usr/bin/env sh
# shellcheck disable=SC2034  # Unused variables left for readability

set -e # -e: exit on error
# set -o nounset
set -o errexit

##################################################################################################################
# tput Text Colors

#tput setaf 0 = Black
#tput setaf 1 = Dark Red                    Warning
#tput setaf 2 = Dark Green                  Command Completed
#tput setaf 3 = Dark Yellow                 Recommended Commands / Extras
#tput setaf 4 = Dark Blue                   Info Needs
#tput setaf 5 = Dark Magenta/Dark Pink
#tput setaf 6 = Dark Cyan
#tput setaf 7 = Dark White/Light Grey
#tput setaf 8 = Light Black/Dark Grey
#tput setaf 9 = Light Red                   Warning
#tput setaf 10 = Light Green                Command Completed
#tput setaf 11 = Light Yellow               Recommended Commands / Extras
#tput setaf 12 = Light Blue                 Info Needs
#tput setaf 13 = Light Magenta/Light Pink
#tput setaf 14 = Light Cyan
#tput setaf 15 = Light White

# tput sgr0 = reset color

# tput setaf 1; echo "This text is Dark Red."; tput sgr0

##################################################################################################################
# printf Colors and Formats

# General Formatting
FORMATRESET="\x1B[0m"
FORMATBRIGHT="\x1B[1m"
FORMATDIM="\x1B[2m"
FORMATITALICS="\x1B[3m"
FORMATUNDERSCORE="\x1B[4m"
FORMATBLINK="\x1B[5m"
FORMATREGULAR="\x1B[6m"
FORMATREVERSE="\x1B[7m"
FORMATHIDDEN="\x1B[8m"

# Foreground Colors
TEXTBLACK="\x1B[30m"
TEXTRED="\x1B[31m"    #Warning
TEXTGREEN="\x1B[32m"  #Command Completed
TEXTYELLOW="\x1B[33m" #Recommended Commands / Extras
TEXTBLUE="\x1B[34m"   #Info Needs
TEXTMAGENTA="\x1B[35m"
TEXTCYAN="\x1B[36m"
TEXTWHITE="\x1B[37m"

# Background Colors
BACKGROUNDBLACK="\x1B[40m"
BACKGROUNDRED="\x1B[41m"
BACKGROUNDGREEN="\x1B[42m"
BACKGROUNDYELLOW="\x1B[43m"
BACKGROUNDBLUE="\x1B[44m"
BACKGROUNDMAGENTA="\x1B[45m"
BACKGROUNDCYAN="\x1B[46m"
BACKGROUNDWHITE="\x1B[47m"

# printf "${TEXTRED}\n%s\n${FORMATRESET}" "This text is Dark Red."

##################################################################################################################

show_usage() {
    printf "Usage: Build Extenion [options [parameters]]\n"
    printf "\n"
    printf "Options:\n"
    printf '%s'" -${TEXTYELLOW}tt${FORMATRESET}     |   --${TEXTYELLOW}testtheme${FORMATRESET}          Test SuperGreatMonokai Theme JSON\n"
    printf '%s'" -${TEXTYELLOW}uf${FORMATRESET}     |   --${TEXTYELLOW}updatefish${FORMATRESET}         Update Fish JSON Files\n"
    printf '%s'" -${TEXTYELLOW}un${FORMATRESET}     |   --${TEXTYELLOW}updatenix${FORMATRESET}          Update Nix JSON Files\n"
    printf '%s'" -${TEXTYELLOW}uv${FORMATRESET}     |   --${TEXTYELLOW}updatevim${FORMATRESET}          Update VimL JSON Files\n"
    printf '%s'" -${TEXTYELLOW}cl${FORMATRESET}     |   --${TEXTYELLOW}changelog${FORMATRESET}          Generate Changelog\n"
    printf '%s'" -${TEXTYELLOW}pack${FORMATRESET}   |   --${TEXTYELLOW}package${FORMATRESET}            Package Extenion for GitHub\n"
    printf '%s'" -${TEXTYELLOW}pubv${FORMATRESET}   |   --${TEXTYELLOW}publishvscode${FORMATRESET}      Publish Extenion to VS Code Marketplace\n"
    printf '%s'" -${TEXTYELLOW}pubo${FORMATRESET}   |   --${TEXTYELLOW}publishopenvsx${FORMATRESET}     Publish Extenion to Open-VSX.org\n"
    printf '%s'" -${TEXTYELLOW}h${FORMATRESET}      |   --${TEXTYELLOW}help${FORMATRESET}               Print this message\n"

    return 0
}

# Check if the system is macOS
case $(uname) in
Darwin)
    wgetCompatible='wget -q --show-progress'
    sedCompatible='gsed -i'
    ;;
Linux)
    wgetCompatible='wget'
    sedCompatible='sed -i'
    ;;
*)
    printf "${TEXTRED}\n%s\n${FORMATRESET}" "Unsupported system"
    exit
    ;;
esac

check_vsce() {
    if ! command -v vsce >/dev/null 2>&1; then
        printf "${TEXTRED}\n%s\n${FORMATRESET}" "VS Code Extension Manager is not installed"
        exit
    fi
}

check_ovsx() {
    if ! command -v ovsx >/dev/null 2>&1; then
        printf "${TEXTRED}\n%s\n${FORMATRESET}" "Open-VSX is not installed"
        exit
    fi
}

check_prettier() {
    if ! command -v prettier >/dev/null 2>&1; then
        printf "${TEXTRED}\n%s\n${FORMATRESET}" "Prettier is not installed"
        exit
    fi
}

check_js_yaml() {
    if ! command -v js-yaml >/dev/null 2>&1; then
        printf "${TEXTRED}\n%s\n${FORMATRESET}" "js-yaml is not installed"
        exit
    fi
}

publish_openvsx() {
    # Set OVSX_PAT environment variable
    OVSX_PAT_VARIABLE=$(head -n 1 "$HOME/.ssh/.env/EXT_DEPLOY_OVSX_PAT.env")
    export OVSX_PAT="$OVSX_PAT_VARIABLE"
    # Publish to Open-VSX
    npx ovsx publish
    # Delete OVSX_PAT environment variable
    unset OVSX_PAT
}

publish_vscode() {
    # Set VSCE_PAT environment variable
    VSCE_PAT_VARIABLE=$(head -n 1 "$HOME/.ssh/.env/EXT_DEPLOY_VSCE_PAT.env")
    export VSCE_PAT="$VSCE_PAT_VARIABLE"
    # Publish to VS Code Marketplace
    npx vsce publish "$2" --no-git-tag-version
    # Delete VSCE_PAT environment variable
    unset VSCE_PAT
}

test_theme() {
    printf "${TEXTGREEN}\n%s\n${FORMATRESET}" "Testing SuperGreatMonokai Theme JSON"

    sed 's/\/\/.*//' themes/SuperGreatMonokai-color-theme.json | jq empty
}

update_fish() {
    printf "${TEXTGREEN}\n%s\n${FORMATRESET}" "Updating Fish JSON Files"

    $wgetCompatible -O ./syntaxes/fish-codeblock.json https://raw.githubusercontent.com/SuperGregM/vscode-fish/master/syntaxes/codeblock.json
    $wgetCompatible -O ./syntaxes/fish.tmLanguage.json https://raw.githubusercontent.com/SuperGregM/vscode-fish/master/syntaxes/fish.tmLanguage.json
    $wgetCompatible -O ./language-configuration/fish-language-configuration.json https://raw.githubusercontent.com/SuperGregM/vscode-fish/master/language-configuration.json
}

update_nix() {
    printf "${TEXTGREEN}\n%s\n${FORMATRESET}" "Updating Nix JSON Files"

    $wgetCompatible -O ./syntaxes/nix-codeblock.yml https://raw.githubusercontent.com/SuperGregM/vscode-nix-ide/main/syntaxes/injection.yml
    $wgetCompatible -O ./syntaxes/nix.tmLanguage.yml https://raw.githubusercontent.com/SuperGregM/vscode-nix-ide/main/syntaxes/nix.YAML-tmLanguage
    $wgetCompatible -O ./language-configuration/nix-language-configuration.json https://raw.githubusercontent.com/SuperGregM/vscode-nix-ide/main/language-configuration.json

    npx js-yaml syntaxes/nix.tmLanguage.yml >syntaxes/nix.tmLanguage.json
    npx js-yaml syntaxes/nix-codeblock.yml >syntaxes/nix-codeblock.json
}

update_vim() {
    printf "${TEXTGREEN}\n%s\n${FORMATRESET}" "Updating VimL Files"

    $wgetCompatible -O ./syntaxes/viml.tmLanguage.json https://raw.githubusercontent.com/SuperGregM/viml-vscode/master/syntaxes/viml.tmLanguage.json
    $wgetCompatible -O ./language-configuration/viml-language-configuration.json https://raw.githubusercontent.com/SuperGregM/viml-vscode/master/language-configuration.json
}

change_log() {
    printf "${TEXTGREEN}\n%s\n${FORMATRESET}" "Generating Changelog"

    filename=./CHANGELOG.md

    git log --graph --pretty=format:'%Cgreen(%ad)%Creset -%C(yellow)%d%Creset  %s' --abbrev-commit --date=short >>"$filename"

    $sedCompatible 's/^\*/-/g' "$filename"

    npx prettier --cache-location "$HOME/.cache/prettier" --write "$filename"
}

package_extenison() {
    printf "${TEXTGREEN}\n%s\n${FORMATRESET}" "Packaging SuperGreatMonokai"

    rm -rf ./supergreatmonokai.vsix

    npx vsce package "$1" --no-git-tag-version --out ./supergreatmonokai.vsix
}

# Check if an argument is provided
case "$1" in
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
    package_extenison "$2"
    ;;
-pubv | --publishvscode)
    check_vsce
    printf "${TEXTGREEN}\n%s\n${FORMATRESET}" "Publishing SuperGreatMonokai to VS Code Marketplace"
    npx vsce publish "$2" --no-git-tag-version
    # publish_vscode
    ;;
-pubo | --publishopenvsx)
    check_ovsx
    printf "${TEXTGREEN}\n%s\n${FORMATRESET}" "Publishing SuperGreatMonokai to Open-VSX.org"
    npx ovsx publish
    # publish_openvsx
    ;;
-h | --help | *)
    show_usage
    exit
    ;;
esac
