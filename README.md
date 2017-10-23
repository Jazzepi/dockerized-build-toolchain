# dockerized-build-toolchain

1. Run `docker build -t sasquatch-technology-build-environment:1.0-SNAPSHOT .`
2. Add dockerized-build-toolchain/bin to your PATH variable. You can modify your ~/.bashrc file. Something like `PATH=$PATH:~/repos/dockerized-build-toolchain/bin`
3. Now you should be good to go. Try out the build process with `e mvn test` from the root of this project.
