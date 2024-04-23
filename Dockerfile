# syntax=docker/dockerfile:1
#
ARG IMAGEBASE=frommakefile
#
FROM ${IMAGEBASE}
#
# enable if adding extra binaries as per architecture
# ARG TARGETPLATFORM
#
ENV \
    AWSEBCLI_VENV=/usr/local/awsebcli-venv \
    CRYPTOGRAPHY_DONT_BUILD_RUST=1 \
    PYTHONUNBUFFERED=1
#
RUN set -xe \
    && apk add --no-cache --purge -uU \
        ca-certificates \
        # curl \
        groff \
        less \
        libffi \
        openssh \
        openssl \
        py3-bcrypt \
        py3-cryptography \
# enable if required rebuilding from GLibC base-image (for SAM-cli)
        # py3-pip \
        # py3-setuptools \
        # py3-wheel \
        py3-pynacl \
        py3-ruamel.yaml.clib \
        py3-yaml \
    && apk --update add --virtual .build-dependencies \
        build-base \
        libffi-dev \
        openssl-dev \
        python3-dev \
        unzip \
    && pip3 install --no-cache-dir --break-system-packages -U \
        pip \
        setuptools \
        wheel \
    && pip3 install --no-cache-dir --break-system-packages \
        awscli \
        # awsebcli \
        boto3 \
        # cryptography \
        cfn-flip \
        cfn-lint \
        requests \
        s3cmd \
        sceptre \
        # yamlfmt \
#
# 20240420 ebcli pulls incompatible dependencies(e.g. botocore)
# keeping ebcli separate as a venv package,
# and adding a wrapper script in local/bin
    && python3 -m venv ${AWSEBCLI_VENV} \
        && source ${AWSEBCLI_VENV}/bin/activate \
        && pip3 install --no-cache-dir \
                awsebcli \
        && deactivate \
    && echo -e '#!/bin/sh\nsource ${AWSEBCLI_VENV}/bin/activate;\neb $@;\ndeactivate;' > /usr/local/bin/eb \
    && chmod +x /usr/local/bin/eb \
#
# optionally add extra binaries as needed (prebuilts only available for x86_64 and aarch64)
# remember to enable TARGETPLATFORM as ARG
    # && case ${TARGETPLATFORM} in \
    #     "linux/amd64") \
    #         # grab latest copilot
    #         curl -jSsL \
    #             --retry 3 --retry-all-errors \
    #             -o /usr/local/bin/copilot-linux \
    #             https://github.com/aws/copilot-cli/releases/latest/download/copilot-linux \
    #         && mv \
    #             /usr/local/bin/copilot-linux \
    #             /usr/local/bin/copilot \
    #         && chmod +x /usr/local/bin/copilot \
    #         && copilot --version \
    #         #
    #         # grab latest ecs-cli
    #         && curl -jSsL \
    #             --retry 3 --retry-all-errors \
    #             -o /usr/local/bin/ecs-cli-linux-amd64-latest \
    #             https://amazon-ecs-cli.s3.amazonaws.com/ecs-cli-linux-amd64-latest \
    #         # && curl -jSsL \
    #         #     -o /usr/local/bin/ecs-cli-linux-amd64-latest.md5 \
    #         #     https://amazon-ecs-cli.s3.amazonaws.com/ecs-cli-linux-amd64-latest.md5 \
    #         # && md5sum -c /usr/local/bin/ecs-cli-linux-amd64-latest.md5 \
    #         && mv \
    #             /usr/local/bin/ecs-cli-linux-amd64-latest \
    #             /usr/local/bin/ecs-cli \
    #         && chmod +x /usr/local/bin/ecs-cli \
    #         # && rm -f /usr/local/bin/ecs-cli-linux-amd64-latest.md5 \
    #         && ecs-cli --version \
    #         #
    #         # grab latest sam cli (requires rebuild with GLibC as base-image)
    #         && curl -jSsL \
    #             --retry 3 --retry-all-errors \
    #             -o /tmp/aws-sam-cli-linux-x86_64.zip \
    #             https://github.com/aws/aws-sam-cli/releases/latest/download/aws-sam-cli-linux-x86_64.zip \
    #         && unzip -q \
    #             -d /tmp/sam \
    #             /tmp/aws-sam-cli-linux-x86_64.zip \
    #         && /tmp/sam/install \
    #         && sam --version \
    #         ;; \
    #     "linux/arm64"|"linux/arm/v8") \
    #         # grab latest copilot
    #         curl -jSsL \
    #             --retry 3 --retry-all-errors \
    #             -o /usr/local/bin/copilot-linux-arm64 \
    #             https://github.com/aws/copilot-cli/releases/latest/download/copilot-linux-arm64 \
    #         && mv \
    #             /usr/local/bin/copilot-linux-arm64 \
    #             /usr/local/bin/copilot \
    #         && chmod +x /usr/local/bin/copilot \
    #         && copilot --version \
    #         #
    #         # grab latest ecs-cli
    #         && curl -jSsL \
    #             --retry 3 --retry-all-errors \
    #             -o /usr/local/bin/ecs-cli-linux-arm64-latest \
    #             https://amazon-ecs-cli.s3.amazonaws.com/ecs-cli-linux-arm64-latest \
    #         # && curl -jSsL \
    #         #     --retry 3 --retry-all-errors \
    #         #     -o /usr/local/bin/ecs-cli-linux-arm64-latest.md5 \
    #         #     https://amazon-ecs-cli.s3.amazonaws.com/ecs-cli-linux-arm64-latest.md5 \
    #         # && md5sum -c /usr/local/bin/ecs-cli-linux-arm64-latest.md5 \
    #         && mv \
    #             /usr/local/bin/ecs-cli-linux-arm64-latest \
    #             /usr/local/bin/ecs-cli \
    #         && chmod +x /usr/local/bin/ecs-cli \
    #         # && rm -f /usr/local/bin/ecs-cli-linux-arm64-latest.md5 \
    #         && ecs-cli --version \
    #         #
    #         # grab latest sam cli (requires rebuild with GLibC as base-image)
    #         && curl -jSsL \
    #             --retry 3 --retry-all-errors \
    #             -o /tmp/aws-sam-cli-linux-arm64.zip \
    #             https://github.com/aws/aws-sam-cli/releases/latest/download/aws-sam-cli-linux-arm64.zip \
    #         && unzip -q \
    #             -d /tmp/sam \
    #             /tmp/aws-sam-cli-linux-arm64.zip \
    #         && /tmp/sam/install \
    #         && sam --version \
    #         ;; \
    #    esac \
    && apk del --purge .build-dependencies \
    && rm -rf /var/cache/apk/* /tmp/* /root/.cache
#
ENTRYPOINT ["/usershell"]
#
CMD ["aws", "--version"]
