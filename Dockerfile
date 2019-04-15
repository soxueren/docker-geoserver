FROM soxueren/tomcat:8.5-jre8-alpine

RUN mkdir /data
RUN mkdir /root/data
RUN mkdir /root/data/jdbcconfig
RUN mkdir /root/data/jdbcstore

#install geoserver
COPY ./geoserver.zip /data
COPY ./data.zip /data
COPY ./fonts.zip /data

RUN unzip -o /data/geoserver.zip -d /usr/local/tomcat/webapps
RUN unzip -n /data/fonts.zip -d /usr/share/fonts
RUN rm -rf /data/fonts.zip /data/geoserver.zip

# refresh system fonts
RUN cd /usr/share/fonts     &&  chmod 644 *     &&  mkfontscale     &&  mkfontdir     &&  fc-cache -fv

#install jai-1_1_3 and jai-imageio
COPY ./imageio/jai_imageio-1_1/lib/*.so /usr/local/tomcat/native-jni-lib
COPY ./imageio/jai-1_1_3/lib/*.so /usr/local/tomcat/native-jni-lib

ADD ./start.sh /start.sh
RUN chmod +x /start.sh

EXPOSE 8080

ENTRYPOINT ["/start.sh"]
