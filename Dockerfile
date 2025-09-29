# intentionally-vulnerable/Dockerfile
FROM python:3.7-slim

# metadata
LABEL maintainer="security-testing@example.com"
WORKDIR /app

# install OS build tools (needed to build some wheels)
RUN apt-get update && \
    apt-get install -y --no-install-recommends \
      build-essential git curl ca-certificates wget gnupg2 ruby-full nodejs npm && \
    rm -rf /var/lib/apt/lists/*

# copy language dependency manifests
COPY requirements.txt /app/requirements.txt
COPY package.json /app/package.json
COPY Gemfile /app/Gemfile

# upgrade pip (but still install old packages)
RUN python -m pip install --upgrade pip setuptools wheel

# install python dependencies (old/vulnerable versions pinned in requirements.txt)
RUN python -m pip install --no-cache-dir -r /app/requirements.txt

# install node deps (old versions in package.json will be installed)
RUN npm install --unsafe-perm

# install ruby/bundler and gems
RUN gem install bundler -v 1.17.3 && bundle _1.17.3_ install --jobs=2 || true

# add a trivial app file so image is not empty
COPY . /app

# sleep to keep container alive for testing interactively
CMD ["sleep", "infinity"]
