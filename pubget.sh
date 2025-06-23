#!/bin/bash

flutter clean
cd example/android && ./gradlew clean && cd -
cd loans
flutter clean

cd ..
flutter pub get
cd loans
flutter pub get