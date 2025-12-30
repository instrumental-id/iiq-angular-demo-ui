#!/usr/bin/env bash

set -eo pipefail

source "./bash-include.sh"

# These should be passed in the environment, but we will set defaults for this project

# The name of the project as defined in angular.json
# Build files should end up at dist/PROJECT_NAME/browser
export PROJECT_NAME=${PROJECT_NAME:-angular-demo-plugin}

# The name of the plugin - used to adjust paths in the generated page.xhtml
export PLUGIN_NAME=${PLUGIN_NAME:AngularDemoPlugin}

uname=$(uname)
export MAC_SED=no

if [[ ${uname} =~ "Darwin" ]]; then
  MAC_SED=yes
fi

dump_config() {
  local format="  %-25s%s\n"

  greenecho "CONFIGURATION"

  printf "${format}" "NPM" "${NPM}"
  printf "${format}" "Node version" "${NODE_VERSION}"
  printf "${format}" "Plugin UI Folder" "${UI_DIR}"
  printf "${format}" "Plugin JS Folder" "${JS_DIR}"
  printf "${format}" "Plugin CSS Folder" "${CSS_DIR}"
  printf "${format}" "Angular app Folder" "${APP_DIR}"
  printf "${format}" "page.xhtml template" "${TEMPLATE}"
  printf "${format}" "page.xhtml target" "${PAGE}"
  printf "\n"
}

NPM="$(which npm)"
NODE="$(which node)"

if [[ -z "${NPM}" ]]; then
	redecho "The 'npm' executable is not on the execution path."
	exit 1
fi

NODE_VERSION=$("${NODE}" --version | sed 's/v//g' | cut -d. -f1)
if [[ "${NODE_VERSION}" -lt 20 ]]; then
  redecho "Node.js version 20 or greater is required. Detected version: ${NODE_VERSION}"
  exit 1
fi

TEMP_DIR="$(mktemp -d)"
if [[ ! -d "${TEMP_DIR}" ]]; then
  redecho "Temporary directory could not be created??"
  exit 1
fi

trap 'rm -rf -- "${TEMP_DIR}"' EXIT

UI_DIR=$(realpath '.')

PAGE="${UI_DIR}/page.xhtml"
TEMPLATE="${UI_DIR}/page-template.xhtml"

JS_DIR="${UI_DIR}/js"
CSS_DIR="${UI_DIR}/css"

APP_DIR="${UI_DIR}/src/app"
DIST_DIR="${UI_DIR}/dist/${PROJECT_NAME}/browser"

if [[ ! -e "${TEMPLATE}" ]]; then
    redecho "ERROR: This script must be run with 'ui' as its working directory"
    exit 2
fi

if [[ ! -e "${APP_DIR}" ]]; then
    redecho "ERROR: The Angular app directory '${APP_DIR}' does not appear to exist in the working directory"
    exit 2
fi

dump_config

if [[ -d "${UI_DIR}/dist" ]]; then
  find "${UI_DIR}/dist" -delete
fi

if [[ -d "${JS_DIR}/app" ]]; then
  find "${JS_DIR}/app"  -delete
fi

if [[ -d "${CSS_DIR}/app" ]]; then
  find "${CSS_DIR}/app"  -delete
fi

mkdir -p "${JS_DIR}/app"
mkdir -p "${CSS_DIR}/app"

greenecho "Executing Angular and Typescript builds..."

( "${NPM}" i && \
  "${NPM}" run ng-dev ) || \
  { redecho "ERROR: Angular or Typescript build failed"; exit 2; }

if [[ ! -e "${DIST_DIR}" ]]; then
  redecho "ERROR: After 'ng build' and 'tsc', the 'dist/${PROJECT_NAME}' directory does not seem to exist??"
  exit 2
fi

greenecho "Restructuring Javascript files for plugin purposes..."
echo " Copying build output to 'js/app' and 'css/app' directories..."

if [[ -d "${DIST_DIR}/assets" ]]; then
  cp -r "${DIST_DIR}"/assets/* "${JS_DIR}/app/"
fi
cp "${DIST_DIR}"/*.js "${JS_DIR}/app"
cp "${DIST_DIR}"/*.js.map "${JS_DIR}/app"
cp "${DIST_DIR}"/styles*.css "${CSS_DIR}/app"
cp "${DIST_DIR}"/styles*.css.map "${CSS_DIR}/app"


temp="${TEMP_DIR}/page-temp.xhtml"

echo " Modifying generated index.html..."

( sed 's#</body></html>##' "${DIST_DIR}/index.html" |
  sed 's#<html><body>##' |
  sed 's(src="(src="#{plugins.requestContextPath}/plugin/PLUGIN_NAME/ui/js/app/(g' |
  sed 's(href="(href="#{plugins.requestContextPath}/plugin/PLUGIN_NAME/ui/css/app/(g' |
  sed 's#\(<link.*css">\)#\1</link>#g' |
  sed "s#PLUGIN_NAME#${PLUGIN_NAME}#g"> "${temp}" ) || \
  { redecho "ERROR: 'sed' substitution failed"; exit 2; }


line=$(sed -n '/NG INSERT/=' "${TEMPLATE}")

echo " Inserting generated code into page template after line ${line}..."

sed "${line}r ${temp}" "${TEMPLATE}" > "${PAGE}"

echo " Updated page.xhtml generated at: ${PAGE}"

echo ""

greenecho "Angular build and transform complete"

exit 0