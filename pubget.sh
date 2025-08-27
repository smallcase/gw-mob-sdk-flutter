#!/bin/bash

cd smart_investing && flutter clean && cd ..
cd scgateway && flutter clean && cd ..
cd loans && flutter clean && cd ..

cd scgateway && flutter pub get && cd ..
cd loans && flutter pub get && cd ..
cd smart_investing && flutter pub get && cd ..