#!/bin/bash

# 1. Instalacja narzędzi systemowych i zależności
apt-get update
apt-get install -y python3-pip python3-venv build-essential wget git

# 2a. Instalacja TA-Lib ze źródeł (z dodatkowym debugowaniem)
cd /tmp
wget http://prdownloads.sourceforge.net/ta-lib/ta-lib-0.4.0-src.tar.gz
tar -xzf ta-lib-0.4.0-src.tar.gz
cd ta-lib
./configure --prefix=/usr
make
make install
ldconfig

# 2b. Weryfikacja instalacji TA-Lib i tworzenie linków symbolicznych
echo "Szukanie biblioteki TA-Lib..."
find /usr -name "libta_lib*" 
TALIB_PATH=$(find /usr -name "libta_lib.so*" | head -1)

if [ -n "$TALIB_PATH" ]; then
    echo "Znaleziono TA-Lib: $TALIB_PATH"
    ln -sf $TALIB_PATH /usr/lib/libta_lib.so
    ln -sf $TALIB_PATH /usr/lib/libta-lib.so
    ldconfig
else
    echo "Nie znaleziono libta_lib.so, próbuję z wersją statyczną..."
    TALIB_STATIC=$(find /usr -name "libta_lib.a" | head -1)
    if [ -n "$TALIB_STATIC" ]; then
        echo "Znaleziono statyczną bibliotekę: $TALIB_STATIC"
        ln -sf $TALIB_STATIC /usr/lib/libta_lib.a
        ln -sf $TALIB_STATIC /usr/lib/libta-lib.a
        ldconfig
    fi
fi

# 3. Tworzenie virtualenv
cd /workspaces/trade_7
python3 -m venv .env
source .env/bin/activate

# 4. Instalacja freqtrade (zalecana przez pip)
pip install --upgrade pip
pip install freqtrade

# 5. Instalacja ta-lib dla Pythona 
echo "Próbuję zainstalować TA-Lib..."
pip install numpy
pip install --global-option=build_ext --global-option="-I/usr/include" --global-option="-L/usr/lib" ta-lib

# 6. Kopiowanie plików config, render i strategii (jeśli istnieją)
[ -d config ] && cp -r config freqtrade/
[ -d render ] && cp -r render freqtrade/
[ -f SampleStrategy.py ] && mkdir -p freqtrade/user_data/strategies && cp SampleStrategy.py freqtrade/user_data/strategies/

echo "Instalacja zakończona. Freqtrade gotowy do użycia na Render."
