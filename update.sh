while getopts ":n:s:" opt; do
  case $opt in
    n) nexusVersion="$OPTARG"
    ;;
    s) nexusVersionShort="$OPTARG"
    ;;
  esac
done

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
done

travisEnv=
for variant in centos; do
  if [ ! -d "$nexusVersionShort/$variant" ]; then
    mkdir -p $nexusVersionShort/$variant
  fi
  sed -e "$sedStr" "Dockerfile-$variant.template" > $nexusVersionShort/$variant/Dockerfile
  travisEnv='\n  - VERSION='"$nexusVersionShort VARIANT=$variant$travisEnv"
done

travis="$(awk -v 'RS=\n\n' '$1 == "env:" { $0 = "env:'"$travisEnv"'" } { printf "%s%s", $0, RS }' .travis.yml)"
echo "$travis" > .travis.yml
