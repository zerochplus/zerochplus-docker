FROM httpd:2.4

RUN apt-get update \
	&& apt-get install -y --no-install-recommends \
    curl \
    ca-certificates \
    perl \
    make \
    gcc \
    libxml-parser-perl \
    libc6-dev \
	&& rm -rf /var/lib/apt/lists/*

RUN curl -L http://cpanmin.us | perl - App::cpanminus \
	&& cpanm local::lib CGI::Session Digest::SHA::PurePerl List::MoreUtils Net::DNS XML::Simple LWP::UserAgent JSON

RUN sed -i.bak -e \
  's%#LoadModule cgid_module%LoadModule cgid_module%g; \
   s%#AddHandler cgi-script .cgi%AddHandler cgi-script .pl .cgi%g; \
   s%#ServerName www.example.com:80%ServerName localhost:80%g; \
   s%Options Indexes FollowSymLinks%Options Indexes FollowSymLinks ExecCGI%g;' \
   /usr/local/apache2/conf/httpd.conf

ARG ZEROCHPLUS_VERSION=0.7.5

RUN mkdir -p /tmp/zerochplus \
  && curl -L https://ja.osdn.net/dl/zerochplus/zerochplus_${ZEROCHPLUS_VERSION}.tar.gz -o /tmp/zerochplus/zerochplus_${ZEROCHPLUS_VERSION}.tar.gz \
  && tar xvzf /tmp/zerochplus/zerochplus_${ZEROCHPLUS_VERSION}.tar.gz -C /tmp/zerochplus \
  && cp -R /tmp/zerochplus/zerochplus_${ZEROCHPLUS_VERSION}/test /usr/local/apache2/htdocs \
  && rm -rf /tmp/zerochplus \
  && cd /usr/local/apache2/htdocs \
  && chmod 707 . \
  && chmod 705 test \
  && find test -maxdepth 1 -name *.cgi | xargs chmod 705 \
  && find test -name *.pl | xargs chmod 604 \
  && find test -name index.html | xargs chmod 600 \
  && chmod 705 test/datas test/module test/mordor test/plugin test/perllib \
  && find test/perllib -type d | xargs chmod 705 \
  && chmod 707 test/info test/info/.session test/plugin_conf
