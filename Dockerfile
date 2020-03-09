FROM ubuntu:latest
MAINTAINER rzolotuhin <r.zolotuhin@it4it.club>
RUN apt update && apt install -y apcupsd && sed -i "s/ISCONFIGURED=no/ISCONFIGURED=yes/" /etc/default/apcupsd
EXPOSE 3551
CMD [ "/sbin/apcupsd", "-b" ]
