# Bazowy obraz z Pythonem
FROM python:3.11-slim

# Instalacja zależności systemowych i TA-Lib
RUN apt-get update && apt-get install -y \
    build-essential \
    wget \
    libta-lib0 \
    libta-lib0-dev \
    && cd /tmp \
    && wget http://prdownloads.sourceforge.net/ta-lib/ta-lib-0.4.0-src.tar.gz \
    && tar -xzf ta-lib-0.4.0-src.tar.gz \
    && cd ta-lib \
    && ./configure --prefix=/usr \
    && make \
    && make install \
    && ldconfig \
    && rm -rf /tmp/ta-lib /tmp/ta-lib-0.4.0-src.tar.gz \
    && apt-get clean

# Ustawienie katalogu roboczego
WORKDIR /app

# Instalacja zależności Pythona
COPY requirements.txt .
RUN pip install --no-cache-dir -r requirements.txt

# Kopiowanie plików aplikacji
COPY . .

# Komenda startowa
CMD ["bash", "start.sh"]
