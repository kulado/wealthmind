FROM        kulado.azurecr.io/boxfuse/flyway:5.0.7-alpine
MAINTAINER  Kulado Inc. <support@kindlyops.com>
RUN addgroup -S azureuser && adduser -S -g azureuser azureuser
RUN apk add --no-cache postgresql-client
WORKDIR /home/azureuser
ADD         sql/* /flyway/sql/
ENV         ENV_VERBOSITY 无
ENV         HOME /home/azureuser
RUN chown -R azureuser:azureuser /flyway && chgrp -R 0 /flyway && chmod -R g=u /flyway
USER azureuser
