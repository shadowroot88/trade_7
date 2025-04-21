#!/bin/bash

# 1. Instalacja narzędzi systemowych i zależności
sudo apt-get update
sudo apt-get install -y python3-pip python3-venv build-essential wget git

# 2a. Instalacja TA-Lib ze źródeł (z dodatkowym debugowaniem)
cd /tmp
wget http://prdownloads.sourceforge.net/ta-lib/ta-lib-0.4.0-src.tar.gz
tar -xzf ta-lib-0.4.0-src.tar.gz
cd ta-lib
./configure --prefix=/usr/local
make
sudo make install
sudo ldconfig

# 2b. Weryfikacja instalacji TA-Lib i tworzenie linków symbolicznych
echo "Szukanie biblioteki TA-Lib..."
sudo find /usr -name "libta_lib*" 
TALIB_PATH=$(sudo find /usr -name "libta_lib.so*" | head -1)

if [ -n "$TALIB_PATH" ]; then
    echo "Znaleziono TA-Lib: $TALIB_PATH"
    sudo ln -sf $TALIB_PATH /usr/local/lib/libta_lib.so
    # Tworzenie dodatkowego linku z nazwą z myślnikiem (dla linkera)
    sudo ln -sf $TALIB_PATH /usr/local/lib/libta-lib.so
    sudo ldconfig
else
    echo "Nie znaleziono libta_lib.so, próbuję z wersją statyczną..."
    TALIB_STATIC=$(sudo find /usr -name "libta_lib.a" | head -1)
    if [ -n "$TALIB_STATIC" ]; then
        echo "Znaleziono statyczną bibliotekę: $TALIB_STATIC"
        sudo ln -sf $TALIB_STATIC /usr/local/lib/libta_lib.a
        # Tworzenie dodatkowego linku z nazwą z myślnikiem (dla linkera)
        sudo ln -sf $TALIB_STATIC /usr/local/lib/libta-lib.a
        sudo ldconfig
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
# Najpierw spróbuj gotowy wheel, jeśli nie zadziała, użyj alternatywnych metod
echo "Próbuję zainstalować TA-Lib..."
(pip install TA-Lib --no-deps || pip install --no-binary :all: ta-lib || pip install ta-lib==0.4.0) || {
    echo "Nie udało się zainstalować TA-Lib przez pip, próbuję alternatywne rozwiązanie"
    
    # Instalacja numpy (wymagane przed kompilacją)
    pip install numpy
    
    # Ręczna instalacja ta-lib z kodu źródłowego
    cd /tmp
    pip download ta-lib
    tar -xzf ta_lib-*.tar.gz
    cd ta_lib-*/
    
    # Modyfikacja pliku źródłowego: dodaj explicite ścieżki do biblioteki
    sed -i "s|libraries=\['ta_lib'\]|libraries=['ta_lib'], library_dirs=['/usr/local/lib', '/usr/lib']|g" setup.py
    
    # Kompilacja z ustawionymi zmiennymi środowiskowymi
    export LD_LIBRARY_PATH=/usr/local/lib:/usr/lib:$LD_LIBRARY_PATH
    export CFLAGS="-I/usr/local/include"
    export LDFLAGS="-L/usr/local/lib -L/usr/lib"
    pip install .
    
    cd /workspaces/trade_7
}

# 6. Kopiowanie plików config, render i strategii (jeśli istnieją)
[ -d config ] && cp -r config freqtrade/
[ -d render ] && cp -r render freqtrade/
[ -f SampleStrategy.py ] && mkdir -p freqtrade/user_data/strategies && cp SampleStrategy.py freqtrade/user_data/strategies/

echo "Instalacja zakończona. Freqtrade gotowy do użycia na Render."
