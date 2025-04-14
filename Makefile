#Tools: Android SDK Build-Tools 33.0.0, Java8, Make for Windows (gnuwin32.sourceforge.net/packages/make.htm), https://github.com/Sable/android-platforms android-24 jar, platform-tools (ADB.exe)
#1.make
#2. adb install build.apk

ANDROID_APP_NAME = hello_world
ORG = com.markmuwonge

JAVA_SOURCE_FILE_PARENT_DIRECTORY_REL_PATH = src/$(subst .,/,${ORG})
JAVA_SOURCE_FILE_REL_PATHS = $(wildcard ${JAVA_SOURCE_FILE_PARENT_DIRECTORY_REL_PATH}/${ANDROID_APP_NAME}/*.java)
JAVA_SOURCE_FILE_REL_PATHS += $(wildcard ${JAVA_SOURCE_FILE_PARENT_DIRECTORY_REL_PATH}/${ANDROID_APP_NAME}/**/*.java)
JAVA_CLASS_FILE_REL_PATHS = $(JAVA_SOURCE_FILE_REL_PATHS:.java=.class)

ANDROID_API_LEVEL = 24
ANDROID_JAR_DIR = libs/android

DEX_FILE_REL_PATH = classes.dex

ANDROID_MANIFEST_REL_PATH = AndroidManifest.xml
ANDROID_MANIFEST_DIRECTORY_REL_PATH = 
ANDROID_APP_PACKAGE_NAME = ${ORG}.${ANDROID_APP_NAME}

APK_FILE_REL_PATH = build.apk

KEYSTORE_REL_PATH = debug.keystore
KEYSTORE_PASS = android
KEYSTORE_KEY_PASS = android
KEYSTORE_KEY_ALIAS = androiddebugkey
######################S######################
all: clean build post
######################E######################

######################S######################
clean:
	$(foreach JAVA_CLASS_FILE_REL_PATH,$(wildcard $(JAVA_CLASS_FILE_REL_PATHS)),\
	if exist $(subst /,\,${CURDIR}\$(JAVA_CLASS_FILE_REL_PATH))\
	del $(subst /,\,${CURDIR}\$(JAVA_CLASS_FILE_REL_PATH))${\n})

	if exist ${DEX_FILE_REL_PATH} del ${DEX_FILE_REL_PATH}

	if exist ${ANDROID_MANIFEST_REL_PATH} del ${ANDROID_MANIFEST_REL_PATH}

	if exist ${APK_FILE_REL_PATH} del ${APK_FILE_REL_PATH}
######################E######################

######################S######################
post:
	del $(addprefix $(subst /,\,${CURDIR})\,$(subst /,\,${JAVA_CLASS_FILE_REL_PATHS}))
	del ${DEX_FILE_REL_PATH}
	del ${ANDROID_MANIFEST_REL_PATH}
######################E######################

######################S######################
build: ${APK_FILE_REL_PATH} 
######################E######################

######################S######################
${APK_FILE_REL_PATH}:${DEX_FILE_REL_PATH} ${ANDROID_MANIFEST_REL_PATH}
	aapt package -f \
	-M ${ANDROID_MANIFEST_REL_PATH} \
	-I "${ANDROID_JAR_DIR}/android-${ANDROID_API_LEVEL}.jar" \
	-F ${APK_FILE_REL_PATH} \
	&& \
	aapt add ${APK_FILE_REL_PATH} ${DEX_FILE_REL_PATH} \
	&& \
	jarsigner -verbose \
	-keystore ${KEYSTORE_REL_PATH} \
    -storepass ${KEYSTORE_PASS} \
    -keypass ${KEYSTORE_KEY_PASS} \
    ${APK_FILE_REL_PATH} \
    ${KEYSTORE_KEY_ALIAS} \
    && \
    zipalign -f 4 ${APK_FILE_REL_PATH} aligned_${APK_FILE_REL_PATH} \
    && \
    del ${APK_FILE_REL_PATH} \
    && \
    ren aligned_${APK_FILE_REL_PATH} ${APK_FILE_REL_PATH}
######################E######################

######################S######################
${DEX_FILE_REL_PATH}: ${JAVA_CLASS_FILE_REL_PATHS}
	d8 $^ --classpath ${ANDROID_JAR_DIR}/android-${ANDROID_API_LEVEL}.jar 
######################E######################

######################S######################
${JAVA_CLASS_FILE_REL_PATHS}: ${JAVA_SOURCE_FILE_REL_PATHS}
	javac -cp $(addsuffix /android-${ANDROID_API_LEVEL}.jar, ${ANDROID_JAR_DIR}) $^ 
######################E######################

######################S######################
${ANDROID_MANIFEST_REL_PATH}:
	copy ${ANDROID_MANIFEST_REL_PATH}.template $(subst /,\,${CURDIR}${ANDROID_MANIFEST_DIRECTORY_REL_PATH}\${ANDROID_MANIFEST_REL_PATH})
	$(call file_contents_replace,$(subst /,\,${CURDIR}${ANDROID_MANIFEST_DIRECTORY_REL_PATH}\${ANDROID_MANIFEST_REL_PATH}),'$${ANDROID_API_LEVEL}','${ANDROID_API_LEVEL}')
	$(call file_contents_replace,$(subst /,\,${CURDIR}${ANDROID_MANIFEST_DIRECTORY_REL_PATH}\${ANDROID_MANIFEST_REL_PATH}),'$${PACKAGENAME}','${ANDROID_APP_PACKAGE_NAME}')
	$(call file_contents_replace,$(subst /,\,${CURDIR}${ANDROID_MANIFEST_DIRECTORY_REL_PATH}\${ANDROID_MANIFEST_REL_PATH}),'$${LABEL}','${ANDROID_APP_NAME}')
######################E######################

######################S######################
define \n


endef
######################E######################

######################S######################
define file_contents_replace
	powershell -command \
	"$$x=(Get-Content $(1) -Raw).replace($(2), $(3)); \
	$$x | Out-File -NoNewline -Encoding utf8 $(1)"
endef
######################E######################