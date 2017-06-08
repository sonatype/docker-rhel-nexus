while getopts ":n:s:" opt; do
  case $opt in
    n) nexusVersion="$OPTARG";;
    s) nexusVersionShort="$OPTARG";;
  esac
done

if [[ -z "${nexusVersion+set}" ]]; then
  echo 'Nexus Version must be provided with -n'
  exit 1
fi

if [[ -z "${nexusVersionShort+set}" ]]; then
  echo 'Nexus Version Short (Release Name) must be provided with -s'
  exit 1
fi

if ! [ -x "$(command -v md2man-roff)" ]; then
  echo 'md2man-roff must be installed to use this update script'
  exit 1
fi

sedStr="
  s!%%NEXUS_VERSION%%!$nexusVersion!g;
  s!%%NEXUS_VERSION_SHORT%%!$nexusVersionShort!g;
"

# Variants that are not compatible with TravisCI
for variant in rhel; do
  if [ ! -d "$nexusVersionShort/$variant" ]; then
    mkdir -p $nexusVersionShort/$variant
  fi
  sed -e "$sedStr" "Dockerfile-$variant.template" > $nexusVersionShort/$variant/Dockerfile
  md2man-roff help.md > $nexusVersionShort/$variant/help.1
  cp uid_entrypoint $nexusVersionShort/$variant/uid_entrypoint
done

travisEnv=
for variant in centos; do
  if [ ! -d "$nexusVersionShort/$variant" ]; then
    mkdir -p $nexusVersionShort/$variant
  fi
  sed -e "$sedStr" "Dockerfile-$variant.template" > $nexusVersionShort/$variant/Dockerfile
  md2man-roff help.md > $nexusVersionShort/$variant/help.1
  cp uid_entrypoint $nexusVersionShort/$variant/uid_entrypoint
  travisEnv='\n  - VERSION='"$nexusVersionShort VARIANT=$variant$travisEnv"
done

travis="$(awk -v 'RS=\n' '$1 == "env:" { $0 = "env:'"$travisEnv"'" } { printf "%s%s", $0, RS }' .travis.yml)"
echo "$travis" > .travis.yml
osCentos="$(sed -e 's#"contextDir": ".*/centos"#"contextDir": "'"${nexusVersionShort}"'/centos"#g' ./OpenShift/nexus-centos.json)"
echo "$osCentos" > ./OpenShift/nexus-centos.json
osRhel="$(sed -e 's#"contextDir": ".*/rhel"#"contextDir": "'"${nexusVersionShort}"'/rhel"#g' ./OpenShift/nexus-rhel.json)"
echo "$osRhel" > ./OpenShift/nexus-rhel.json
