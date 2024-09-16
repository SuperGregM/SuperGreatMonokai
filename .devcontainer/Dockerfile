FROM library/node:alpine

# Install necessary packages
RUN apk update && apk upgrade && apk add --no-cache shadow

# Create user 'dev_code' with no password, home directory, and default shell
RUN useradd -m -s /bin/sh dev_code

# install Dependencies
RUN apk update && apk add --no-cache git jq shellcheck

# install Publishing Tools
RUN npm install -g @vscode/vsce ovsx prettier js-yaml
