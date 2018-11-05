FROM alpine:3.6
MAINTAINER Ivan Bertona <ivan@ibrt.me>

# Install packages.
RUN apk add --no-cache curl

# Install support files.
ADD support/tests.sh /tests.sh

# Configure image.
CMD ["/tests.sh"]