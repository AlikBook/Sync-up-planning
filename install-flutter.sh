#!/bin/bash

if [ ! -d "flutter" ]; then
  git clone https://github.com/flutter/flutter.git -b stable
fi


export PATH="$PATH:`pwd`/flutter/bin"

flutter doctor
flutter pub get
flutter build web --release