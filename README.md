# WealthMind is a modern risk & compliance dashboard for the cloud

[![CircleCI](https://circleci.com/gh/kulado/wealthmind.svg?style=svg)](https://circleci.com/gh/kulado/wealthmind) [![experimental](http://badges.github.io/stability-badges/dist/experimental.svg)](http://github.com/badges/stability-badges) [![Say Thanks!](https://img.shields.io/badge/Say%20Thanks-!-1EAEDB.svg)](https://saythanks.io/to/statik) [![Maintainability](https://api.codeclimate.com/v1/badges/d2af9dcd5ad434172a27/maintainability)](https://codeclimate.com/github/kulado/wealthmind/maintainability)

We use [BrowserStack](http://browserstack.com) to efficiently check cross-browser compatibility while building Haven. We are using snyk.io and codeclimate.com for static scanning.

<!-- markdownlint-disable MD033 -->
[<img height="53" src="https://p3.zdusercontent.com/attachment/1015988/xfvLD5CuyeUcq2i40RYcw494H?token=eyJhbGciOiJkaXIiLCJlbmMiOiJBMTI4Q0JDLUhTMjU2In0..BvyIxRLJz4phFf7cbIr8_Q.Fl9BR-ARcgvq38p546lM4djFcalediYWQaXV1_U_xi_zr5stXNUKLQNkTt-2zQbXWIIffLSoG8dUSZqL-GsqaTMbBX8OZi14qIHWmBIOPoRmyhwIcQfYIa79ngad69fKDltmq2H2KKWLByI-NWE9ygYpNs2IAXOQ72NICuWLbSyXIDGFVsq5VlV5ok7iCY0WxwXzIAiHbFu_BPufmP951-dpnBIGJAl4KfGk0eSbHKDOYvVkqHU2yZvNL8itCqkThmE7WNgPCS_KL6TyQiPxUQ.0ypOzE6XBmafR82vKRcIKg">](http://browserstack.com/)

## What is WealthMind?

We help organizations avoid getting bogged down in rules that no longer make sense, and empower people to update practices to use modern tools and techniques without abandoning responsible oversight and administrative controls.

By connecting controls to policies to values & customer requirements, we break the cycle of inability to improve things "because security reasons".

![screenshot of app](demo.png)

## setting up the dev environment

The db schema and migrations are managed using flyway. The postgresql server, the postgrest API server, and the flyway tool are all run from docker containers to reduce the need for local toolchain installation (java, haskell, postgresql)

To check and see if you have docker available and set up

    docker -v
    docker-compose -v
    docker info

If you don't have docker running, use [these instructions](https://docs.docker.com/docker-for-mac/). At the time of writing, this is working fine with docker 1.12.

### Windows users

Before you continue, you need to configure git to auto-correct line ending formats:

     git config --global core.autocrlf false

## running the service

You will normally run all the services using:

    docker-compose up
    docker-compose run flyway # applies database migrations

From this point on, you just just be able to use docker-compose up/down normally. Move on to access the main webUI in the next section.

## to access the main webUI

Open [localhost:2015](http://localhost:2015/), click the login button. You can login with user1\@havengrc.com/password or user2\@havengrc.com/password. User2 will prompt you to configure 2Factor authentication.

If you cannot connect to [localhost](http://localhost:2015), try getting the docker machine ip using the command `docker-machine ip default` and use that instead.

## to access the swagger-ui for the postgrest API

Open [localhost:3002](http://localhost:3002/)

The swagger browser is loading the authenicated api by default. To view the public API, adjust the file being loaded to public.json.

To refresh the swagger documentation, such as after modifying postgres to expose additional APIs, use these commands

    curl http://localhost:2015/api/ > webui/public/swagger/public.json
    export TOKEN=`./get-token`
    curl -H "Authorization: Bearer $TOKEN" http://localhost:2015/api/ > webui/public/swagger/authenticated.json

## to access keycloak

Open [localhost:8080](http://localhost:8080/), you can sign in with admin/admin

## to access the GitBook documentation site

Open [localhost:4000](http://localhost:4000/)

## to see the REST API

    curl -s http://localhost:3001/ | jq

# to see emails sent from Haven / keycloak

Open [localhost:8025](http://localhost:8025), you can use mailhog to see messages stored in memory

## to export keycloak realm data (to refresh the dev users)

After keycloak is running and you have made any desired config changes:

    docker-compose exec keycloak /opt/jboss/keycloak/bin/standalone.sh \
      -Dkeycloak.migration.action=export \
      -Dkeycloak.migration.provider=singleFile \
      -Dkeycloak.migration.file=/keycloak/kuladodev-realm.json \
      -Djboss.http.port=8888 \
      -Djboss.https.port=9999 \
      -Djboss.management.http.port=7777

## To clear local storage in Chrome for your local site

Sometimes messing with logins and cookies you get stuff corrupted and need to invalidate a session/drop some cookies/tokens that were in localstorage. Visit chrome://settings/cookies\#cont and search for localhost.

## Testing on a real mobile device

It's often useful to test your dev code on a variety of real world phones and tablets so you can confirm UI behavior. The easiest way to do this is with a tool called [ngrok](https://ngrok.com). ngrok creates a public URL to a local webserver. If you use ngrok, it's worth signing up for the free plan at least. You will be able to inspect the traffic going over the tunnel, and use http auth credentials to protect access to your tunnel and those you share it with.

If you have a free ngrok plan, something like this should work

    ngrok http -auth "user:password" 2015

If you have a paid ngrok plan, something like this should work

    ngrok http -auth "user:password" -subdomain=$USER-haven 2015

## add a database migration

Add a new sql file in flyway/sql, following the naming convention for versions.

``` {.sql}
CREATE TABLE mappa.foo
(
  name text NOT NULL PRIMARY KEY
);
```

    docker-compose run flyway # applies migrations
    docker-compose run flyway # reverts last migration
    # repeat until satisfied
    git add .
    git commit -m "Adding foo table"

## look around inside the database

The psql client is installed in the flyway image, and can connect to the DB server running in the database container.

    docker-compose run --entrypoint="psql -h db -U postgres wealthmind_dev" flyway
    \l                          # list databases in this server
    \dn                         # show the schemas
    \dt mappa.*                 # show the tables in the mappa schema
    SET ROLE member;            # assume the member role
    SELECT * from foo LIMIT 1;  # run arbitrary queries
    \q                          # disconnect

We also have pgadmin4 running on http://localhost:8081. You can sign in using user1\@havengrc.com/password. Once inside pgadmin4, you will need to add a server, the server hostname is 'db' and the credentials are postgres/postgres.

## Use REST client to interact with the API

[Postman](https://www.getpostman.com/) is a free GUI REST client that makes exploration easy. Run postman, and import a couple of predefined requests from the collection at postman/ComplianceOps.postman\_collection.json. Then execute the POST and GET requests to see how the API behaves.

## More info on postgrest

A tutorial is available [here](http://blog.jonharrington.org/postgrest-introduction/)

## Authentication with JWT and Keycloak

### roles and permissions

Keycloak has very complex and sophisticated support for realms, roles, client roles, and custom mappers. For now, we use a simple scheme of a custom user attribute called role. role must be set to "member" or "admin", and a custom mapper has been configured so that a role claim will be included in the JWT access token. PostgREST will check the role claim and switch to the member or admin role defined in PostgREST. Inside the database, fields can access other parts of the JWT to store user identity.

### multi-tenancy

Multi-tenancy is still a work in progress. Initially we will use a single Keycloak ream, and enhance the signup flow to create an organization-per-user. Initially there will be no real organization support, but we will record organization\_id along with user\_id for all data stored. Later we will add support for creating organizations/teams, and will allow users to be a member of multiple organizations. They will only be able to have a single organization active at a time in a login session, and so we'll need an additional page in the login flow to allow the user to select which organization they are activating (once authentication completes).

### Low level JWT interactions

In order to be able to get a token for a user, the user must have no pending actions in keycloak (like email verification or password change). To exchange a username and password for a Keycloak JWT token with curl:

    TOKEN=`curl -s --data \
    "grant_type=password&client_id=kuladodev&scope=openid&username=user1@havengrc.com&password=password"\
    http://localhost:2015/auth/realms/kuladodev/protocol/openid-connect/token \
    | jq -r '.access_token'`

We also have a shortcut helper script you can use

    export TOKEN=`./get-token`

Then you can use that token by passing it in an Authorization header:

    curl -v -H "Authorization: Bearer $TOKEN" http://localhost:3001/comment

To read a file from the database:

    curl -H "Authorization: Bearer $TOKEN" -H "Accept: application/octet-stream" \
     http://localhost:3001/file?select=file --output result.pdf

To upload a base64 encoded file to the database via postgrest:

    curl -X POST -H "Authorization: Bearer $TOKEN"\
     -H 'Content-Type: application/json' \
     http://localhost:3001/file \
     -d '{"file": "'"$(base64 apitest/features/minimal.pdf)"'"}'

We will need an upgraded version of postgrest with a fix for [this postgrest bug](https://github.com/begriffs/postgrest/issues/906). We also need to modify the user signup process to set up the roles correctly.

To upload a file to the database via kuladoapi:

    curl -X POST -H "Authorization: Bearer $TOKEN" -F "name=filename.pdf" \
      -F "file=@apitest/features/minimal.pdf" \
      http://localhost:3000/api/files

You can decode the token to inspect the contents at jwt.io. You will need to get the public cert from the Keycloak Admin interface: Havendev-\>Realm Settings-\>Keys-\>Public Key and enter it into the jwt.io page to decode the token.

## Learning Elm

16 minute video by Richard Feldman that explains the framework architecture choices that Elm makes compared to jQuery and Flux. [From jQuery to Flux to Elm](https://www.youtube.com/watch?v=NgwQHGqIMbw).

Elm is also a language that compiles to javascript. Here are some resources for learning Elm. In particular, the DailyDrip course is quite good, and provides several wonderful example applications that are MIT licensed and have been used to help bootstrap this application. You should subscribe to DailyDrip and support their work.

-   [Free elm course](http://courses.knowthen.com/p/elm-for-beginners)
-   Daily Drip has an [excellent elm course](https://www.dailydrip.com/topics/elm) that sends you a little bit of code each day to work on
-   [Pragmatic Programmers course](https://pragmaticstudio.com/elm)
-   [Frontend Masters 2-day elm workshop](https://frontendmasters.com/workshops/elm/)

### Design framework and tooling

We are making use of the [Material Design](https://material.io/guidelines/) system as a base for our design. We are also using the implementation at [Daemonite](http://daemonite.github.io/material/).

Within the app we are using [SASS](http://sass-lang.com/), and the guidance from [Inverted Triangle CSS](https://www.xfive.co/blog/itcss-scalable-maintainable-css-architecture/) and [Reasonable CSS](http://rscss.io/) to try and keep the CSS manageable.

## Deploying with kubernetes / OpenShift

Branches merged to master will push new docker images to the OpenShift cluster.

### Using OpenShift

Talk to your administrator about getting an OpenShift account set up. Once you have access to Kubernetes / OpenShift, you can use the `oc` command to interact with the platform and update WealthMind deployments.

To get useful information to get oriented and find out what is happening:

    oc whoami
    oc project
    oc status -v
    oc get events

OpenShift CLI versions vary depending on where you installed from. Installing via homebrew `brew install openshift-cli` on macOS is fresher than installing from the link in OpenShift web console. (We ran into a difference in command flags needed with different versions of `oc`).

### Using helm

To set up helm, first download and unpack the current helm release, then make sure your openshift client is authenticated to haven-production.

    oc whoami
    oc project
    export TILLER_NAMESPACE=haven-tiller # this will be unique to your OpenShift cluster
    helm init --client-only
    helm version

To update the deployment of helm to a new version, you must edit the tag used and then apply the update.

    oc project $TILLER_NAMESPACE # switch to your tiller project
    vim k8s/tiller-template.yaml # edit the tiller image tag to the desired version
    oc process -f k8s/tiller-template.yaml \
    -p TILLER_NAMESPACE="${TILLER_NAMESPACE}" | oc replace -f -
    oc rollout status deployment tiller # watch the status of the rollout
    helm versions # confirm the version change took effect.

### Database resource

In your Kubernetes cluster there must be an ExternalName Service defined named `db`. If your administrator has already set this up, you can see the endpoint by running:

    oc get services

There must also be secrets set up with the DB credentials.

### TLS

You can provision certificates from Let's Encrypt in manual mode with certbot. The key material should be stored in a k8s secret which the kuladoweb pod loads as a volume so that Caddy can serve the certificate.

    certbot certonly --manual --preferred-challenge=dns

    # to verify if the dns challenge record has been published,
    dig -t txt _acme-challenge.staging.havengrc.com

Once you complete the challenge and get the key material, edit the secret.

    base64 -i /etc/letsencrypt/live/staging.havengrc.com/fullchain.pem | pbcopy
    oc edit secrets/secretname

Replace the values for fullkey.pem and privkey.pem with base64 encoded versions of the new certificates. Save and exit.

### Bazel

We are experimenting with the bazel build tool. Get it from https://bazel.build/

To build the keycloak service providers jar

    bazel build //keycloak-service-providers:spi_deploy.jar

### Security scanning with Zed Attack Proxy

You can run the ZAP baseline scan with

    docker-compose run zap


