# cli
This is the source repository of [https://cli.pignat.org](https://cli.pignat.org).

## Install
### Tested on unbunt 20.04.1
```
sudo apt install -y git ruby-bundler ruby-dev libxml2-dev libz-dev ftp
mkdir -p ~/git && cd ~/git
git clone git@github.com:RandomReaper/cli.git
cd cli/site
bundle install
```

## Testing
```
cd ~/git/cli
./serve.sh
```
Now the test site is available at [http://localhost:4000/](http://localhost:4000/).
