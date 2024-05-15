#!/bin/bash

flutter clean
cd loans
flutter clean

cd ..
flutter pub get
cd loans
flutter pub get