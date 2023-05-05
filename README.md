# python2-gdb

This repository contains a Dockerfile that allows you to build a docker image based on `debian:buster-slim` with Python 2.7, pip 20.0.2, and gdb installed. 

To build the docker image, use the `build.sh` script. To verify that gdb with Python is working, use the `build-debug.sh` script to build a docker image. 

To run a container, execute the `run.sh` script. If you need to enter the container, use the `exec.sh` script. 

Inside the container, run `gdb python 1` to enter gdb interactive mode. You can verify that everything is working by running `py-bt` and `py-list`.

```
(gdb) py-bt
Traceback (most recent call first):
  <built-in function sleep>
  File "./main.py", line 9, in <module>
    time.sleep(10)

(gdb) py-list
   4        return "<p>Hello, World!</p>"
   5    
   6    if __name__ == "__main__":
   7        while True:
   8            print('sleep...')
  >9            time.sleep(10)
  10            hello_world()
```

# Reference

- [dockerhub python:2.7-slim](https://hub.docker.com/layers/library/python/2.7-slim/images/sha256-03b82b530ec868d72556e6c1030431c12e60bb7c85b7789c12c68d416ad249a5)
- [Building and Using a Debug Version of Python](https://pythonextensionpatterns.readthedocs.io/en/latest/debugging/debug_python.html)
- [GDB support](https://devguide.python.org/advanced-tools/gdb/)
