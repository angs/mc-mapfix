#!/bin/bash
unamestr=`uname`
if [[ "$unamestr" == 'Darwin' ]]; then
  cd $HOME/Library/Application\ Support/minecraft/versions/
else
  cd $HOME/.minecraft/versions/
fi

version="1.8.1"
offset=$((16#923))
newvalue="\xFF"
classfile="buc.class"
postfix="_mapfix"

if [ -d "$version" ]; then
  if [ -d "${version}${postfix}" ]; then
    echo "Folder ${version}${postfix} already exists!"
  else
    mkdir ${version}${postfix}
    cp ${version}/{*.jar,*.json} ${version}${postfix}
    cd ${version}${postfix}
    jar xf $version.jar $classfile
    echo -e -n "$newvalue" | dd of=$classfile count=1 bs=1 seek=$offset conv=notrunc
    mv $version.jar ${version}${postfix}.jar
    jar Muf ${version}${postfix}.jar $classfile
    cat ${version}.json | sed -e "s/^[[:space:]]*\"id\":.*/  \"id\": \"${version}${postfix}\",/g" > ${version}${postfix}.json
    rm ${version}.json
    rm $classfile
  fi
else
  echo "Folder $version not found"
fi

