.PHONY: build

IMAGE_NAME ?= codeclimate/codeclimate-shellcheck

data/env.yml:
	git submodule init
	git submodule update
	./data/prepare.rb

data_volume:
	(docker volume ls | grep "codeclimate_shellcheck_data") || docker volume create "codeclimate_shellcheck_data"

build:
	docker build \
	  --tag $(IMAGE_NAME)-build \
	  --file $(PWD)/docker/Build.plan .

.local/bin/codeclimate-shellcheck: build data_volume
	docker run --rm \
	  --volume codeclimate_shellcheck_data:/root/.local/bin \
	  --volume $(PWD)/.local/.stack:/root/.stack \
	  --volume $(PWD)/.local/.stack-work:/home/app/.stack-work \
	  $(IMAGE_NAME)-build stack install

compress: .local/bin/codeclimate-shellcheck data_volume
	docker run \
	  --volume codeclimate_shellcheck_data:/data \
	  lalyos/upx codeclimate-shellcheck

image: .local/bin/codeclimate-shellcheck data/env.yml data_volume
	mkdir -p .local/bin
	docker run --volume codeclimate_shellcheck_data:/data \
		--name codeclimate_shellcheck_build_helper \
		$(IMAGE_NAME)-build true
	docker cp codeclimate_shellcheck_build_helper:/data/codeclimate-shellcheck .local/bin
	docker rm codeclimate_shellcheck_build_helper
	docker build \
	  --tag $(IMAGE_NAME) \
	  --file $(PWD)/docker/Release.plan .
