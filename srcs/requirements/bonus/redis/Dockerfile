FROM debian:bullseye

RUN apt-get update && \
    apt-get install -y redis-server && \
    rm -rf /var/lib/apt/lists/*

# Modify the Redis configuration so that Redis accepts all IP connections, not just native connections.
# sed: stream editor
# -i:  in-place edit (edit original file)
# "s|A|B|g": substitude A with B
# g: global (replace all A)
# only listen to local ->> listen to all IPs (need password to ensure security)
RUN sed -i "s|bind 127.0.0.1|bind 0.0.0.0|g" /etc/redis/redis.conf

EXPOSE 6379

# CMD: execute during container start-up
# RUN: execute when building a mirror
# when listening to public IPs, Redis opens "protected mode" (only listens to 127.0.0.1)
# therefore, we need to turn off "protected mode", allowing connection from outside
# but need a password to ensure security
# sh -c: Let SHell Command parse the variables ${REDIS_PASSWORD} (JSON array does not automatically expand the shell variable)
# /etc/redis/redis.conf： allow previous "sed" command changes works
# --daemonize no: do not run in background (/etc/redis/redis.conf has "daemonize yes", need to overwrite)
CMD ["sh", "-c", "redis-server /etc/redis/redis.conf --requirepass ${REDIS_PASSWORD} --protected-mode no --daemonize no"]