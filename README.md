# plutosdr-readsb-fr24feed
PlutoSDR standalone ADS-B decoder and FR24 feeder (using readsb)

### Building image
Building this image is done using qemu-user-static (by running the ArchLinux ARM image in user/static emulation) and does quite a bit of modifications to your system (installing packages, changing binfmt settings, putting stuff in /opt, etc.).  
__Please don't run this on your computer! Use a VM, Docker, GitHub Actions, etc.__  

Using docker:  
```bash
docker run --rm -it --privileged --entrypoint bash debian:bullseye-slim

git clone https://github.com/Manawyrm/plutosdr-readsb-fr24feed
cd plutosdr-readsb-fr24feed

./build_host.sh
```
