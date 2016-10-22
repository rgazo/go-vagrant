# Golang Vagrant

Vagrant environment for Golang, with support for both [go](http://golang.org/doc/install) and [gb](https://github.com/constabulary/gb) tools.

## Install
```
> git clone https://github.com/rgazo/go-vagrant.git

> cd go-vagrant/vagrant

> vagrant up
```

## Usage

Log in to the vagrant box:
```
> vagrant ssh

> ll
```

There will be 2 directories
```
src/
vagrant/
```

* **vagrant** contains configuration for `haproxy`
* **src** will contain your project.

```
> vi src/README.md
```

**HAproxy**

Start haproxy:
```
sudo service haproxy start
```

**PostgreSQL**

Start PostgreSQL
```
sudo service postgresql start
```
