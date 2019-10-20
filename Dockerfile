FROM ubuntu:18.04

ARG DEBIAN_FRONTEND=noninteractive
RUN apt -y update && apt -y install postgresql git python3-dev libxml2-dev libxslt-dev libldap2-dev libsasl2-dev wget python3-pip
RUN adduser --system --home=/opt/odoo --group odoo

USER postgres
RUN    /etc/init.d/postgresql start &&\
    psql --command "CREATE USER odoo WITH SUPERUSER PASSWORD '123456';"

USER root
WORKDIR /opt/odoo
RUN git clone https://github.com/odoo/odoo.git --depth 1 --branch 13.0 --single-branch

USER root

# RUN wget https://github.com/wkhtmltopdf/wkhtmltopdf/releases/download/0.12.5/wkhtmltox_0.12.5-1.bionic_amd64.deb

# RUN dpkg -i wkhtmltox_0.12.5-1.bionic_amd64.deb

WORKDIR /opt/odoo/odoo/
RUN apt -y install nodejs npm
RUN pip3 install -r requirements.txt
#RUN rm -rf node_modules
RUN npm cache clean
RUN npm config set registry "http://registry.npmjs.org/"
RUN apt install -y npm
RUN npm install -g less less-plugin-clean-css
RUN apt install -y node-less
RUN mkdir /var/log/odoo
RUN chown odoo:root /var/log/odoo
COPY ./odoo.conf /etc/odoo-server.conf
RUN chown odoo: /etc/odoo-server.conf
RUN chmod 640 /etc/odoo-server.conf
COPY ./odoo-server /etc/init.d/odoo-server
RUN chmod 755 /etc/init.d/odoo-server
RUN chown root: /etc/init.d/odoo-server
EXPOSE 5432
EXPOSE 8069
#RUN /etc/init.d/odoo-server start
RUN service odoo-server start
#EXPOSE 5432
#EXPOSE 8069
