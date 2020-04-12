ZIP_FILE_NAME="localizations.zip"
REQUEST_PATH="/api/localizations/v1.1"

DOMAINS_PATTERN=","
LOCALIZATION_DIRECTORY=${CONFIGURATION_BUILD_DIR}/${UNLOCALIZED_RESOURCES_FOLDER_PATH}/Localizations

if [ ! -d ${LOCALIZATION_DIRECTORY} ]; then
mkdir -p ${LOCALIZATION_DIRECTORY}
fi

if [ ! -d ${SRCROOT}/${TARGET_NAME} ]; then
mkdir -p ${SRCROOT}/${TARGET_NAME}
fi

APP_ID=$(/usr/libexec/PlistBuddy -c "Print :AppId" "${SRCROOT}/${TARGET_NAME}/Configuration.plist")
SECRET=$(/usr/libexec/PlistBuddy -c "Print :Secret" "${SRCROOT}/${TARGET_NAME}/Configuration.plist")
BASE_URL=$(/usr/libexec/PlistBuddy -c "Print :BaseUrl" "${SRCROOT}/${TARGET_NAME}/Configuration.plist")
DOMAINS=$(/usr/libexec/PlistBuddy -c "Print :Domains" "${SRCROOT}/${TARGET_NAME}/Configuration.plist")
SHA_VALUE=$(printf ${APP_ID}${SECRET} | shasum -a 256 | cut -f1 -d" ")

if grep -q "${SHA_VALUE}" "${SRCROOT}/${TARGET_NAME}/Configuration.plist"
then
    /usr/libexec/PlistBuddy -c "Set ShaValue ${SHA_VALUE}" "${SRCROOT}/${TARGET_NAME}/Configuration.plist"
else
    /usr/libexec/PlistBuddy -c "Add ShaValue string ${SHA_VALUE}" "${SRCROOT}/${TARGET_NAME}/Configuration.plist"
fi

# Get the domains between this symbols: {}
listedDomains=${DOMAINS#*{}
listedDomains=${listedDomains%%\}*}

# Get every domain and add it to string, separated with comma
domainsString=""

for value in ${listedDomains}
do
domainsString+="${value},"
done

# remove the last comma:
separatedStrings="${domainsString%?}"

# REQUEST FOR LOCALIZATIONS
echo "****** This is before compilation ******"
echo "Configuration is: ${CONFIGURATION}"  # can be Release or Debug
AUTH_HEADER="X-Authorization: ${SHA_VALUE}"
echo "****** HeaderValue: ${AUTH_HEADER} ******"
LOCALIZATION_URL="${BASE_URL}${REQUEST_PATH}?app_id=${APP_ID}&domain_id=${separatedStrings//$DOMAINS_PATTERN/&domain_id=}"
echo "****** Localization url: ${LOCALIZATION_URL}  *******"
echo "******  Download the file ${ZIP_FILE_NAME} to ${SRCROOT}/${TARGET_NAME}/ ****** "

# CHECK IF REQUEST IS SUCCESSFUL
if curl -o "${SRCROOT}/${TARGET_NAME}/${ZIP_FILE_NAME}" -H "${AUTH_HEADER}" -v "${LOCALIZATION_URL}" --fail -X GET ; then
    echo "Localizations request is successful."
else
    echo "Localizations request is NOT successful."
    if [ "$CONFIGURATION" = "Release" ]; then
        exit 1 # Meaning of exit codes: https://askubuntu.com/a/892605
    fi
fi

# END REQUEST FOR LOCALIZATIONS

# UNZIP ALL ZIP FILES
echo "****** Unzipping file ${ZIP_FILE_NAME} to ${LOCALIZATION_DIRECTORY} ****** "
unzip -o "${SRCROOT}/${TARGET_NAME}/${ZIP_FILE_NAME}" -d "${LOCALIZATION_DIRECTORY}"
echo "****** unzipping domain files ***** "

for domain_dir in ${LOCALIZATION_DIRECTORY}/*
do
    if [[ ${domain_dir} != ${LOCALIZATION_DIRECTORY}/project.json ]]
    then
        cd ${domain_dir}
        unzip -o "*.zip"
    fi
done

echo "****** This is end of before compilation ******"
