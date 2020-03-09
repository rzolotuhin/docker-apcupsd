FROM ubuntu:latest
MAINTAINER rzolotuhin <r.zolotuhin@it4it.club>
RUN apt update && apt install -y apcupsd && sed -i "s/ISCONFIGURED=no/ISCONFIGURED=yes/" /etc/default/apcupsd
EXPOSE 3551
CMD [ "sed", "-i", "-E", "'s/^(\s+)?(MINUTES|TIMEOUT)\s+.+$/\2 0/g'", "/etc/apcupsd/apcupsd.conf" ]
CMD [ "sed", "-i", "-E", "'s/^(\s+)?(BATTERYLEVEL)\s+.+$/\2 -1/g'", "/etc/apcupsd/apcupsd.conf" ]
CMD [ "sed", "-i", "-E", "'s/^(\s+)?(NISIP)\s+.+$/\2 0.0.0.0/g'", "/etc/apcupsd/apcupsd.conf" ]
CMD [ "/sbin/apcupsd", "-b" ]
