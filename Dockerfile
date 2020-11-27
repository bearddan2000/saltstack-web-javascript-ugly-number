FROM ubuntu:latest

RUN apt-get update \
    && apt-get -y install software-properties-common \
    && add-apt-repository ppa:deadsnakes/ppa \
    && apt-get update \
    && apt-get -y install curl python3.7 git \
    && curl -L https://bootstrap.saltstack.com -o install_salt.sh \
    && sh install_salt.sh -P

COPY ./top.sls /srv/salt/

RUN git clone https://github.com/bearddan2000/saltstack-lib-pillars.git \
    && chmod -R +x saltstack-lib-pillars \
    && cp saltstack-lib-pillars/masterless.conf /etc/salt/minion.d \
    && cp saltstack-lib-pillars/webservers/apache-default.sls /srv/salt \
    && rm -Rf saltstack-lib-pillars

RUN service salt-minion stop \
    && salt-call --local state.highstate \
    && rm -f /var/www/html/index.html

COPY bin/ /var/www/html

RUN chown -R www-data:www-data /var/www/html \
    && chmod -R +x /var/www/html

CMD ["/usr/sbin/apache2ctl", "-D", "FOREGROUND"]

