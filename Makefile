.PHONY: all policy-agent policy-tool docker-image clean

SRCDIR=.
IMAGE_NAME=freznicek/k8s-policy-agent

default: all
all: policy-agent policy-tool 
policy-agent: dist/policy_agent
policy-tool: dist/policy
docker-image: image.created

dist/policy_agent: 
	# Build the kubernetes policy agent
	sudo docker run --rm \
	-v `pwd`:/code \
	calico/build \
	pyinstaller policy_agent.py -ayF 

dist/policy: 
	# Build NetworkPolicy install tool. 
	sudo docker run --rm \
	-v `pwd`:/code \
	calico/build \
	pyinstaller policy.py -ayF 

image.created: dist/policy_agent 
	sudo docker build -t $(IMAGE_NAME) .
	touch image.created

docker-build: image.created

docker-rebuild: clean image.created

docker-run:
	sudo docker run -it $(IMAGE_NAME)

clean:
	find . -name '*.pyc' -exec rm -f {} +
	rm -f ./image.created
	sudo rm -rf ./dist
#	-sudo docker run -v /var/run/docker.sock:/var/run/docker.sock -v /var/lib/docker:/var/lib/docker --rm martin/docker-cleanup-volumes
#	-sudo docker rmi caseydavenport/k8s-policy-agent
