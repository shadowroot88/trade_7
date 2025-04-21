#!/bin/bash
cd freqtrade
source .env/bin/activate
# Przykładowe uruchomienie freqtrade, dostosuj do potrzeb:
freqtrade trade --config config/config.json --strategy SampleStrategy
