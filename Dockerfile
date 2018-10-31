FROM soxueren/tomcat:8.5-jre8-gdal

ENV GEOSERVER-VERSION 2.14.0

RUN wget https://excellmedia.dl.sourceforge.net/project/geoserver/GeoServer/${GEOSERVER-VERSION}/geoserver-${GEOSERVER-VERSION}-bin.zip -O /tmp/geoserver-${GEOSERVER-VERSION}-bin.zip
         unzip -o ~/geoserver-${GEOSERVER-VERSION}-bin.zip -d /tmp/ && \   
         mv /tmp/geoserver-${GEOSERVER-VERSION}-bin/webapps/geoserver  /usr/local/tomcat/webapps/ && \
         rm -rf  /tmp/*         

# add fonts
#ADD fontxp.zip /usr/share/fonts/

# cache fonts
RUN dpkg-reconfigure fontconfig-config && \
        dpkg-reconfigure fontconfig && \
        fc-cache -fv
        
EXPOSE 8080

CMD ["catalina.sh","run"]
         
