FROM soxueren/tomcat:8.5-jre8-gdal

ENV GEOSERVER-VERSION 2.14.0

RUN mkdir /root/data
RUN mkdir /root/data/jdbcconfig
RUN mkdir /root/data/jdbcstore

RUN wget https://excellmedia.dl.sourceforge.net/project/geoserver/GeoServer/${GEOSERVER-VERSION}/geoserver-${GEOSERVER-VERSION}-bin.zip -O /tmp/geoserver-${GEOSERVER-VERSION}-bin.zip
         unzip -o ~/geoserver-${GEOSERVER-VERSION}-bin.zip -d /tmp/ && \   
         mv /tmp/geoserver-${GEOSERVER-VERSION}-bin/webapps/geoserver  /usr/local/tomcat/webapps/ && \
         mv /tmp/geoserver-${GEOSERVER-VERSION}-bin/data_dir  /root/data && \
         rm -rf  /tmp/*         

COPY ./web.xml /usr/local/tomcat/webapps/geoserver/WEB-INF/web.xml
COPY ./imageio/jai_imageio-1_1/lib/*.so /usr/local/tomcat/native-jni-lib
COPY ./imageio/jai-1_1_3/lib/*.so /usr/local/tomcat/native-jni-lib

# add fonts
#ADD fontxp.zip /usr/share/fonts/

# cache fonts
RUN dpkg-reconfigure fontconfig-config && \
        dpkg-reconfigure fontconfig && \
        fc-cache -fv
        
EXPOSE 8080

CMD [" /usr/local/tomcat/bin/catalina.sh","run"]
         
