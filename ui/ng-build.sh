#!/usr/bin/env bash

set -eo pipefail

source "./bash-include.sh"

uname=$(uname)
MAC_SED=no

if [[ ${uname} =~ "Darwin" ]]; then
  MAC_SED=yes
fi

dump_config() {
  local format="  %-25s%s\n"

  greenecho "CONFIGURATION"

  printf "${format}" "NPM" "${NPM}"
  printf "${format}" "NPX" "${NPX}"
  printf "${format}" "Plugin UI Folder" "${UI_DIR}"
  printf "${format}" "Plugin JS Folder" "${JS_DIR}"
  printf "${format}" "Plugin CSS Folder" "${CSS_DIR}"
  printf "${format}" "Angular app Folder" "${APP_DIR}"
  printf "${format}" "page.xhtml template" "${TEMPLATE}"
  printf "${format}" "page.xhtml target" "${PAGE}"
  printf "\n"
}

NPM="$(which npm)"
NPX="$(which npx)"

if [[ -z "${NPM}" ]]; then
	redecho "The 'npm' executable is not on the execution path."
	exit 1
fi

if [[ -z "${NPX}" ]]; then
	redecho "The 'npx' executable is not on the execution path."
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

mkdir -p "${JS_DIR}/app"
mkdir -p "${CSS_DIR}/app"

APP_DIR="${UI_DIR}/app/angular-plugin-ui"
SRC_DIR="${APP_DIR}/src"
DIST_DIR="${APP_DIR}/dist/angular-plugin-ui/browser"

if [[ ! -e "${TEMPLATE}" ]]; then
    redecho "This script must be run with 'ui' as its working directory"
    exit 2
fi

if [[ ! -e "${APP_DIR}" ]]; then
    redecho "The Angular app directory '${APP_DIR}' does not appear to exist in the working directory"
    exit 2
fi

dump_config

find "${CSS_DIR}" -name "styles*.css" -delete
find "${JS_DIR}/app" -delete

mkdir -p "${JS_DIR}/app"

pushd "${APP_DIR}"

greenecho "Executing Angular build..."

( "${NPM}" i && \
  "${NPM}" run ng-dev ) || \
  { redecho "ERROR: Angular build failed"; exit 2; }

if [[ ! -e "${DIST_DIR}" ]]; then
  redecho "After 'ng build', the '${DIST_DIR}' directory does not seem to exist??"
  exit 2
fi

greenecho "Copying files to '${JS_DIR}/app' directories..."

cp -rf "${DIST_DIR}"/assets/* "${JS_DIR}/app/"
cp -r "${DIST_DIR}"/*.js "${JS_DIR}/app/"
cp "${DIST_DIR}"/styles*.css "${CSS_DIR}/app/"
cp "${DIST_DIR}"/styles*.css.map "${CSS_DIR}/app/"

popd > /dev/null

temp="${TEMP_DIR}/page-temp.xhtml"

greenecho "Generating page.xhtml..."

( sed 's#</body></html>##' ${APP_DIR}/dist/angular-plugin-ui/browser/index.html |
  sed 's#<html><body>##' |
  sed 's(src="(src="#{plugins.requestContextPath}/plugin/IDWAngularDemo/ui/js/app/(g' |
  sed 's(href="(href="#{plugins.requestContextPath}/plugin/IDWAngularDemo/ui/css/app/(g' |
  sed 's#\(<link.*>\)#\1</link>#g' > ${temp} ) || \
  { redecho "ERROR: 'sed' substitution failed"; exit 2; }


line=$(sed -n '/NG INSERT/=' ${TEMPLATE})

echo " Inserting after line ${line}"

sed "${line}r ${temp}" ${TEMPLATE} > ${PAGE}

greenecho "Done."

exit 0