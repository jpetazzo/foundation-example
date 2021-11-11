# Foundation image

This is an example of a common pattern when working with containerized
applications: multiple applications (in this case, `app1` and `app2`)
are using a common base image (in this case, `foundation`).

Ideally, we want to use the standard Docker Compose workflow to work
on individual applications, which means that to start an app, we want to:

1. Clone the code repository (`git clone ...`)
2. Change to the app's directory (`cd repo/appdir`)
3. Build and run the app (`docker-compose up`)

The base image might be an "expensive" image (taking a long time to
build), and it's important to make sure that everyone uses the same
one, too. And at the same time, we want to be able to update or customize
the common base image and rebuild an app with that image.

Achieving a perfectly reproducible build with Docker is difficult.
For instance, installing a package (with `apk add curl` or
`pip install Flask`) will install "whatever version is available on
the package mirrors". If we want to obtain perfectly reproducible
builds, it requires careful pinning of dependencies; and we can
still run into issues if mirrors are unavailable or packages get
withdrawn (like with the `left-pad` story a while ago).

An easier approach is to store the base image in a registry, so that
we can simply pull the base image instead of building it locally.
But, as mentioned earlier, we also want to be able to update that
image locally; ideally without having to edit Dockerfiles, and without
forcing us to round-trip images to a registry (i.e. push/pull them
if we only need them locally).

This is the solution proposed in this repository:

1. Host the image on a registry
   (e.g. `foundationrepository.azurecr.io/foundation`)
2. Reference that image in our app Dockerfiles
   (i.e. `FROM foundationrepository.azurecr.io/foundation`)
3. Provide a Compose file to build the base image,
   and in that Compose file, tag the image with the same
   name (i.e. `build: foundationrepository.azurecr.io/foundation`)

If we want to work on an app (without building the base image),
we go to the app directory and run `docker-compose up`. This will
pull the base image from the registry and use it to build the app
image.

If we want to tweak/update/edit the base image, we go to the base
image directory (`foundation/`), make changes, run `docker-compose build`.
Then we go go the app directory and run `docker-compose up --build`.
It will use the new base image.

If we want to revert the base image to the "official" one (the one
hosted in the registry), we go back to the base image directory
and run `docker-compose pull`.

## Azure Container Registry

This repository includes a small script showing how to create
an Azure Container Registry to host the base image privately, and how
to create read-only access to that registry.

Note that if we want to use private images, the "getting started"
workflow then becomes:

1. Log into the private registry (with `az login`+`az acr login`, or with `docker login`)
2. Clone the code repository (`git clone ...`)
3. Change to the app's directory (`cd repo/appdir`)
4. Build and run the app (`docker-compose up`)

Of course, using ACR here is completely arbitrary; any other registry
would work exactly the same way.

## Base image tags

For simplicity, this example uses the `:latest` tag for the base image.
If tags are needed, I suggest to use an environment variable and set it
in a `.env` file, possibly symlinking that file to a file at the root of
the repo. This allows to keep everything in sync by changing the tag in
a single place, rather than having to edit multiple files (which is
error-prone).
