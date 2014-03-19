test-proxy
==========

This is a simple HTTP and HTTPS proxy for use with tests. Primarily
it is for use with TravisCI, where feature tests may be configured to
actually require HTTPS.

## Configuration

Create a certificate and a key pem file for your domain. Check them into
your repository in `spec/support` somewhere.

```
TBD
```

Add a script to your repository to install the test-proxy and run it:

```bash
#!/bin/bash

echo "Installing GVM"
bash < <(curl -s https://raw.github.com/moovweb/gvm/master/binscripts/gvm-installer)
source $HOME/.gvm/scripts/gvm

echo "Installing go1.2.1"
gvm install go1.2.1
gvm use go1.2.1

echo "Found Go at:"
echo $(which go)
GO=$(which go)

echo "Installing root certificates"
TRAVIS_BUILD_DIR=${TRAVIS_BUILD_DIR:-$PWD}
sudo cp $TRAVIS_BUILD_DIR/spec/support/features/cert.pem /etc/ssl/certs && sudo update-ca-certificates

echo "Check out test proxy"
cd /tmp
git clone https://github.com/wanelo/test-proxy.git test-proxy
cd test-proxy

echo "Building proxy"
make
sudo /tmp/test-proxy/bin/test-proxy --port 7171 \
                  --cert $TRAVIS_BUILD_DIR/spec/support/features/cert.pem \
                  --key $TRAVIS_BUILD_DIR/spec/support/features/key.pem &

```

Add the following to your `.travis.yml`:

```yaml
before_script:
  - sudo script/start_test_proxy.sh
after_script:
  - sudo pkill -f test-proxy
```

## Development

```bash
make
./bin/test-proxy --help
```
