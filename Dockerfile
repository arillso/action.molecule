FROM alpine:3.16.0 as builder

RUN apk --update --no-cache add \
	gcc \
	libffi-dev \
	make \
	musl-dev \
	python3 \
	bc \
	ca-certificates \
	git \
	openssh-client \
	rsync \
	&& apk --update --no-cache add --virtual \
	.build-deps \
	sshpass \
	python3-dev \
	libffi-dev \
	openssl-dev \
	build-base \
	py3-pip \
	rust \
	cargo \
	libxslt-dev

COPY requirements.txt /requirements.txt 

RUN set -eux \
	&& pip3 install --ignore-installed --no-cache-dir --upgrade -r /requirements.txt \
	&& find /usr/lib/ -name '__pycache__' -print0 | xargs -0 -n1 rm -rf \
	&& find /usr/lib/ -name '*.pyc' -print0 | xargs -0 -n1 rm -rf

FROM alpine:3.16.0

COPY --from=builder /usr/lib/python3.9/site-packages/ /usr/lib/python3.9/site-packages/
COPY --from=builder /usr/bin/ansible /usr/bin/ansible
COPY --from=builder /usr/bin/ansible-connection /usr/bin/ansible-connection
COPY --from=builder /usr/bin/flake8    /usr/bin/flake8
COPY --from=builder /usr/bin/molecule  /usr/bin/molecule
COPY --from=builder /usr/bin/pytest    /usr/bin/pytest
COPY --from=builder /usr/bin/yamllint  /usr/bin/yamllint
COPY --from=builder /usr/bin/ansible-lint  /usr/bin/ansible-lint

RUN set -eux \
	&& apk add --no-cache \
	bash \
	git \
	gnupg \
	jq \
	openssh-client \
	python3 \
	sshpass \
	rsync \
	docker \
	&& ln -sf /usr/bin/python3 /usr/bin/python \
	&& ln -sf ansible /usr/bin/ansible-config \
	&& ln -sf ansible /usr/bin/ansible-console \
	&& ln -sf ansible /usr/bin/ansible-doc \
	&& ln -sf ansible /usr/bin/ansible-galaxy \
	&& ln -sf ansible /usr/bin/ansible-inventory \
	&& ln -sf ansible /usr/bin/ansible-playbook \
	&& ln -sf ansible /usr/bin/ansible-pull \
	&& ln -sf ansible /usr/bin/ansible-test \
	&& ln -sf ansible /usr/bin/ansible-vault \
	&& find /usr/lib/ -name '__pycache__' -print0 | xargs -0 -n1 rm -rf \
	&& find /usr/lib/ -name '*.pyc' -print0 | xargs -0 -n1 rm -rf

RUN ansible-galaxy collection install community.docker community.general \
    && mkdir -p /usr/share/ansible \
    && ln -s /root/.ansible/collections/ /usr/share/ansible/collections

CMD ["sh", "-c", "cd ${WORKING_DIRECTORY}; PY_COLORS=1 ANSIBLE_FORCE_COLOR=1 molecule ${COMMAND:-test} --scenario-name ${SCENARIO:-default}"]
