# Image de base
FROM debian:latest

# Mainteneur du containeur
MAINTAINER Tony BOUCHEAU <boucheau.tony@neuf.fr>

LABEL description="Container avec Ruby, Ruby on Rails et MySql pour les dev"


# Installation des outils nécessaire avec apt-get
RUN apt-get update \
&& apt-get install -y wget tar gcc make zlib1g-dev libssl-dev libreadline-dev libgdbm-dev openssl nodejs \
&& rm -rf /var/lib/apt/lists/*

# Installation de Ruby à partir du site officiel
RUN wget https://cache.ruby-lang.org/pub/ruby/2.3/ruby-2.3.0.tar.gz \
&& tar xvfz ruby-2.3.0.tar.gz \
&& rm ruby-2.3.0.tar.gz \
&& cd ruby-2.3.0 \
&& ./configure \
&& make \
&& make install \
&& chmod +x ruby

# Installation de Ruby on Rails
RUN gem install rails \
&& gem install execjs \
&& gem install uglifier 

# Création d'un blog avec RoR
RUN cd /home \
&& rails new blog

# Changement du repertoire courant
WORKDIR /home/blog

# On expose le port 80
EXPOSE 80

# On partage un dossier du blog
VOLUME /home/blog

# On lance le serveur quand on démarre le conteneur
CMD "sudo rails server -b 0.0.0.0 -p 80"