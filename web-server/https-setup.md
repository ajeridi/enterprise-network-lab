# HTTPS on the Ubuntu web server

Self-signed certificate for the lab. In production, the certificate would come from a certificate authority.

## 1. Generate the certificate and the private key

```bash
sudo openssl req -x509 -nodes -days 365 -newkey rsa:2048 -sha256 \
    -out /etc/apache2/server.crt \
    -keyout /etc/apache2/server.key
```

- `-x509`: self-signed X.509 certificate instead of a certificate request
- `-nodes`: the private key is not protected by a passphrase, so Apache can start without user input
- `-days 365`: valid for one year
- `-newkey rsa:2048`: new 2048-bit RSA key

OpenSSL then asks for the identification details (country, locality, server name...).

## 2. Point Apache to the certificate

In `/etc/apache2/sites-available/default-ssl.conf`:

```apache
SSLEngine on
SSLCertificateFile    /etc/apache2/server.crt
SSLCertificateKeyFile /etc/apache2/server.key
```

## 3. Enable SSL and reload Apache

```bash
sudo a2enmod ssl
sudo a2ensite default-ssl
sudo service apache2 reload
```

## 4. Publish port 443

On pfSense, a NAT port forward sends port 443 on the WAN interface to the web server (172.16.39.11), next to the existing one for port 80.

The browser shows a warning about the certificate, as expected for a self-signed certificate.
