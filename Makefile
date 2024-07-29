image_tag = 'testapp/proxy:0.1'

.PHONY: image

build: image

push:
	docker push -t $(image_tag)

image:
	docker build -t $(image_tag) .

test:
	docker run --rm -ti --ulimit nofile=65536:65536 --name http-proxy -p 8888:8888 $(image_tag)
