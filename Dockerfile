# Image de base
FROM debian:latest

# Mainteneur du containeur
MAINTAINER Tony BOUCHEAU <boucheau.tony@neuf.fr>

LABEL description="Container avec Ruby, Ruby on Rails et MySql pour tester les possibilités (inclut un blog expliquant la création de ce container)"
LABEL version="0.1"

# Installation des outils nécessaire avec apt-get
RUN apt-get update \
	&& apt-get install -y wget tar gcc make zlib1g-dev libssl-dev libreadline-dev libgdbm-dev openssl nodejs git

# Installation de mysql sans mot de passe puis configuration du mot de passe 'root'
RUN /bin/bash -c '\
	debconf-set-selections <<< "mysql-server-5.5 mysql-server/root_password password 'root'" \
	&& debconf-set-selections <<< "mysql-server-5.5 mysql-server/root_password_again password 'root'" \
	&& debconf-set-selections <<< "mysql-server mysql-server/root_password password 'root'" \
	&& debconf-set-selections <<< "mysql-server mysql-server/root_password_again password 'root'" \
	&& export DEBIAN_FRONTEND=noninteractive \
	&& apt-get install -y -q mysql-server \
	&& apt-get install -y libmysqlclient-dev'

# Installation de Ruby à partir du site officiel
RUN wget https://cache.ruby-lang.org/pub/ruby/2.3/ruby-2.3.0.tar.gz \
	&& tar xvfz ruby-2.3.0.tar.gz \
	&& rm ruby-2.3.0.tar.gz \
	&& cd ruby-2.3.0 \
	&& ./configure \
	&& make \
	&& make install \
	&& chmod +x ruby

# Installation de Rails et ses dépendances
RUN gem install rails \
	&& gem install mysql2 -v '0.4.5' \
	&& gem install bundler rubygems-bundler --no-rdoc --no-ri

# Récupération du blog de test
RUN cd /home \
	&& git clone https://github.com/tboucheau/Blog-Ror-Lab.git blog \
	&& cd blog \
	&& bundle install

# Chargement des données (seeding)
RUN service mysql start \
	&& mysql -u root -proot -e "create database blog_development; GRANT ALL PRIVILEGES ON blog_development.* TO root@localhost IDENTIFIED BY 'root'" \
	&& mysql -u root -proot blog_development < /home/blog/dump.sql
	
# Changement du repertoire courant
WORKDIR /home/blog

# Exposition du port 80
EXPOSE 80

# On partage un dossier du blog
VOLUME /home/blog

# On lance le moteur MySQL et le blog sur le port 80
ENTRYPOINT ["sh", "-c", "service mysql start && rails s -b 0.0.0.0 -p 80"]