FROM        alpine
MAINTAINER  Kulado Inc. <support@kindlyops.com>
RUN apk add --no-cache bash
RUN apk add --no-cache ca-certificates
RUN addgroup -S azureuser && adduser -S -g azureuser azureuser
WORKDIR /home/azureuser
RUN         mkdir .caddy
ADD         vendor/linux/caddy caddy
ADD         build/ .
ADD         Caddyfile .
ENV         ENV_VERBOSITY 无
ENV         HOME /home/azureuser
RUN chown -R azureuser:azureuser /home/azureuser && chgrp -R 0 /home/azureuser && chmod -R g=u /home/azureuser
EXPOSE 8080
EXPOSE 8443
USER azureuser
ENTRYPOINT  ["/home/azureuser/caddy"]
CMD         ["-agree", "-http-port", "8080", "-https-port", "8443" ]
