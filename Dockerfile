FROM ubuntu:14.04

# File Author / Maintainer
MAINTAINER Fernando Mangaratua Sianipar

# Set the enviroment variable
ENV DEBIAN_FRONTEND noninteractive

LABEL io.k8s.description="UsahawanXL S2I - Testing01" \
      io.k8s.display-name="apache2-php5-ubuntu14" \
      io.openshift.expose-services="8080:http" \
      io.openshift.tags="builder,php5,apache2" \
      io.openshift.s2i.scripts-url="image:///usr/local/s2i" 
#      io.openshift.s2i.destination="/tmp/s2icoba1"


COPY run.sh /

RUN chmod +x /run.sh


# Install required packages
RUN apt-get clean all
RUN apt-get update
RUN apt-get -y install apache2 \
	&& apt-get -y install php5 libapache2-mod-php5 php5-mysql php5-gd php-pear php-apc php5-curl curl lynx-cur git

# Dependencies utk CMS Pimcore
RUN apt-get -y install zip unzip bzip2 libpng-dev libbz2-dev

# Dependencies utk pgsql
RUN apt-get -y install php5-pgsql

RUN a2enmod rewrite

# Adding the Configuration File for host
ADD 000-default.conf /etc/apache2/sites-enabled/000-default.conf
RUN rm /etc/apache2/ports.conf
ADD ports.conf /etc/apache2/ports.conf


# Salin script s2i ke dalam image.
COPY ./s2i/bin/ /usr/local/s2i

RUN useradd -u 1002 -r -g 0 -d /var/www/html -s /sbin/nologin -c "Default Application User" default

RUN mkdir /var/www/html/public \ 
       && chown -R 1002:0 /var/www/html/public \
       && chown -R 1002:0 /var/log/apache2 \
       && chown -R 1002:0 /var/lock/apache2 \
       && chown -R 1002:0 /var/run/apache2 \ 
       && chmod -R 770 /var/log/apache2 \
       && chmod -R 770 /var/lock/apache2 \
       && chmod -R 770 /var/run/apache2


RUN apt-get clean all



# Set the port
EXPOSE 8080


# Add shell scripts for starting apache2
ADD run.sh /run.sh
RUN chmod 755 /*.sh

WORKDIR /var/www/html/public


USER 1002

# Execute the run.sh
CMD ["/run.sh"]
