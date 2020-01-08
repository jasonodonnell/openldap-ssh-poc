.PHONY: all 
all: image run

image:
	docker build . -f Dockerfile.centos7 -t sshtest:1.0.0

run:
	$(PWD)/run.sh

clean:
	$(PWD)/cleanup.sh
