Docker контейнер с apcupsd
==========================
В конфиг файл не вносились изменения, в связи с этим Вам необходимо внести собственные правки для подключения к Вашему ИБП.

Использование под Linux
-----------------------
Установите Docker
```bash
apt update
apt install docker
```
Загрузите образ на свой сервер
```bash
docker pull rzolotuhin/apcupsd
```
Создайте на сервере каталог в котором будут лежать примонтрованные файлы для `apcupsd`, в том числе и Ваш файл конфигурации `apcupsd.conf`
```bash
mkdir -p /srv/docker/apcupsd/
```
Создайте и заполните файл конфигурации `apcupsd.conf`
```bash
cd /srv/docker/apcupsd/
touch apcupsd.conf
nano apcupsd.conf
```
Вот пример файла конфигурации `apcupsd.conf` который я использую у себя для подключения к ИБП APC Smart-UPS 1500 через Network Management Card по протоколу SNMP. На мой взгляд это лучший способ подключения, позволяющий не держать ИБП в непосредственной близости от сервера.
```
UPSNAME apc1500
UPSTYPE snmp
DEVICE 192.168.0.5:161:APC:public
POLLTIME 30
LOCKFILE /var/lock
SCRIPTDIR /etc/apcupsd
PWRFAILDIR /etc/apcupsd
NOLOGINDIR /etc
ONBATTERYDELAY 6
BATTERYLEVEL -1
MINUTES 0
TIMEOUT 0
ANNOY 300
ANNOYDELAY 60
NOLOGON disable
KILLDELAY 0
NETSERVER on
NISIP 0.0.0.0
NISPORT 3551
EVENTSFILE /var/log/apcupsd.events
EVENTSFILEMAX 10
UPSCLASS standalone
UPSMODE disable
STATTIME 0
STATFILE /var/log/apcupsd.status
LOGSTATS off
DATATIME 0
```
Обратите внимание на параметры:
- `UPSTYPE snmp` - Способ подключения к ИБП
- `DEVICE 192.168.0.5:161:APC:public` - hostname:port:vendor:community

Следующие параметры гарантируют, что apcupsd не будет пытаться выключить сервер (в нашем случае это контейнер)
- `BATTERYLEVEL -1`
- `MINUTES 0`
- `TIMEOUT 0`

Также необходимо поднять сетевую службу позволяющую других участникам сети получать ифнормацию о состоянии ИБП
- `NETSERVER on`
- `NISIP 0.0.0.0`
- `NISPORT 3551`

Запустите контейнер
```bash
docker run -d --name="apcupsd" -p 3551:3551 -v /srv/docker/apcupsd/apcupsd.conf:/etc/apcupsd/apcupsd.conf rzolotuhin/apcupsd
```
В параметрах мы указали, что из контейнера необходимо пробросить сетевой порт 3551, а также путь для монтирования файла конфигурации `apcupsd.conf` из Вашего сервера в контейнер.

После запуска можно проверить работу контейнера.
```bash
docker ps
```
В выводе мы получим список запущенных контейнеров. Найдите контейнер `rzolotuhin/apcupsd` и его `NAMES`, это уникальное значение мы будем использовать для доступа к контейнеру
```
CONTAINER ID        IMAGE                COMMAND              CREATED             STATUS              PORTS                    NAMES
e65d8bc12075        rzolotuhin/apcupsd   "/sbin/apcupsd -b"   About an hour ago   Up About an hour    0.0.0.0:3551->3551/tcp   apcupsd
```
Запросим статус у `apcupsd` выполнив команду `/etc/init.d/apcupsd status` внутри контейнера с именем `apcupsd` которое мы задали при запуске через параметр `--name="apcupsd"`
```bash
docker exec -i -t apcupsd /etc/init.d/apcupsd status
```
В ответ мы должны получить информацию о состоянии ИБП
```
APC      : 001,046,1056
DATE     : 2020-03-09 13:50:05 +0000
HOSTNAME : e65d8bc12075
VERSION  : 3.14.14 (31 May 2016) debian
UPSNAME  : apc
CABLE    : Ethernet Link
DRIVER   : SNMP UPS Driver
UPSMODE  : Stand Alone
STARTTIME: 2020-03-09 12:35:55 +0000
MODEL    : Smart-UPS 1500
STATUS   : ONLINE
LINEV    : 239.0 Volts
LOADPCT  : 24.0 Percent
BCHARGE  : 100.0 Percent
TIMELEFT : 40.0 Minutes
MBATTCHG : 0 Percent
MINTIMEL : 0 Minutes
MAXTIME  : 0 Seconds
MAXLINEV : 240.0 Volts
MINLINEV : 230.0 Volts
OUTPUTV  : 240.0 Volts
SENSE    : High
DWAKE    : 0 Seconds
DSHUTD   : 180 Seconds
DLOWBATT : 2 Minutes
LOTRANS  : 208.0 Volts
HITRANS  : 253.0 Volts
RETPCT   : 15.0 Percent
ITEMP    : 37.0 C
ALARMDEL : No alarm
BATTV    : 27.0 Volts
LINEFREQ : 50.0 Hz
LASTXFER : Automatic or explicit self test
NUMXFERS : 0
TONBATT  : 0 Seconds
CUMONBATT: 0 Seconds
XOFFBATT : N/A
SELFTEST : OK
STESTI   : 336
STATFLAG : 0x05000008
MANDATE  : 01/27/07
SERIALNO : AS0704212043
BATTDATE : 11/14/18
NOMOUTV  : 220 Volts
EXTBATTS : 0
FIRMWARE : 653.13.I
END APC  : 2020-03-09 13:50:14 +0000
```
Если Вам нужно подключить ИБП через USB, то в команде запуска контейнера можно явно указать какое устройство прокинуть
```bash
--device=/dev/ttyUSB0
```

Использование в Synology (XPEnlogy)
-----------------------------------
Первым делом необходимо установить Docker на Ваше файловое хранилище

![install docker](https://github.com/rzolotuhin/docker-apcupsd/raw/master/images/synology-docker-apcupsd1.png)

В разделе `Образ` загружаем образ apcupsd по прямой ссылке с Docker HUB `https://hub.docker.com/r/rzolotuhin/apcupsd`

![add apcupsd container](https://github.com/rzolotuhin/docker-apcupsd/raw/master/images/synology-docker-apcupsd2.png)

После загрузки выбираем контейнер и жмем `Запустить` в верхнем меню. Откроется диалоговое окно, в котором можно указать желаемое имя контейнера и выставить дополнительные параметры

![add apcupsd container](https://github.com/rzolotuhin/docker-apcupsd/raw/master/images/synology-docker-apcupsd3.png)

Включаем автоматический запуск контейнера

![enable auto start container](https://github.com/rzolotuhin/docker-apcupsd/raw/master/images/synology-docker-apcupsd4.png)

Обязательно указываем где находится файл конфигурации и куда он будет монтироваться внутри контейнера. Лично я, для файлов конфигурации различных контейнеров создал отдельную сетевую папку `docker` с ограниченным доступом. В ней содержатся подкаталоги соответствующие каждому из запущенных контейнеров, например, `/docker/apcupsd/`

![add mount parameters](https://github.com/rzolotuhin/docker-apcupsd/raw/master/images/synology-docker-apcupsd5.png)

Если требуется получать доступ к сетевым службам контейнера, то обязательно выбираем в разделе `Сеть` параметр `Использовать ту же сеть, что и сеть хоста Docker`. В данном случае это позволит получить доступ к `apcupsd` по фдресу сетевого хранилища и порту `3551`, по сути это простой проброс порта

![settings port forwarding](https://github.com/rzolotuhin/docker-apcupsd/raw/master/images/synology-docker-apcupsd6.png)

Применяем настройки. Проверить состояния контейнера можно в разделе `Контейнер`

![show running containers](https://github.com/rzolotuhin/docker-apcupsd/raw/master/images/synology-docker-apcupsd7.png)

На этом все
