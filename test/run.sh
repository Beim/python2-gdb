docker run -d --name xkpydebug -p 5000:5000 \
    --cap-add=SYS_PTRACE \
    -v .:/usr/src/app xkpydebug:v0 
