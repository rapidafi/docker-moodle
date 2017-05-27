docker-moodle
=============

A Dockerfile that installs and runs the latest Moodle 3.2 stable, with external MySQL Database. Additionally gets Certbot certificate and alters Apache for HTTP to HTTPS redirect. Also installs Finnish language pack and two themes to Moodle.

## Installation

```
git clone https://github.com/rapidafi/docker-moodle
cd docker-moodle
docker build -t moodle .
```

## Usage

To spawn a new instance of Moodle:
(do replace "example.com" and "your-host" etc. with appropriate values)

```
docker network create moodlenet
docker run -d --name moodledb --network moodlenet -e MYSQL_DATABASE=moodle -e MYSQL_ROOT_PASSWORD=moodle -e MYSQL_USER=moodle -e MYSQL_PASSWORD=moodle mysql
docker run -d --name moodle --network moodlenet -e CERT_EMAIL=webmaster@example.como -e CERT_DOMAIN=moodle.example.com -e MOODLE_URL=https://moodle.example.com -e DB_PORT_3306_TCP_ADDR=moodledb -e DB_ENV_MYSQL_DATABASE=moodle -e DB_ENV_MYSQL_USER=moodle -e DB_ENV_MYSQL_PASSWORD=moodle -p 80:80 -p 443:443 moodle
```

You can visit the following URL in a browser to get started:

```
http://your-host
```


## Caveats
The following aren't handled, considered, or need work: 
* moodle cronjob (should be called from cron container)
* log handling (stdout?)
* email (does it even send?)

## Credits

This is a fork of [Jonathan Hardison's](https://github.com/jmhardison/docker-moodle) Dockerfile.
This is a fork of [Jon Auer's](https://github.com/jda/docker-moodle) Dockerfile.
This is a reductionist take on [sergiogomez](https://github.com/sergiogomez/)'s docker-moodle Dockerfile.
