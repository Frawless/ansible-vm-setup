# Copyright 2017 Red Hat, Inc. and/or its affiliates
#
# Licensed under the Apache License, Version 2.0 (the "License");
# you may not use this file except in compliance with the License.
# You may obtain a copy of the License at
#
#     http://www.apache.org/licenses/LICENSE-2.0
#
# Unless required by applicable law or agreed to in writing, software
# distributed under the License is distributed on an "AS IS" BASIS,
# WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
# See the License for the specific language governing permissions and
# limitations under the License.

.PHONY: package_install clean
TEST_INVENTORY?=test/inventory
INVENTORY?=inventory
ANSIBLE_OPTS?=

containers = alain

all: package_install package_configure

clean:
	rm -rf ansible.cfg test/roles/epel test/roles/nodejs test/roles/rh_register test/roles/rh_subscribe test/roles/provision_docker test/roles/cli-rhea
	docker rm -f $(containers) || true

test-prepare: clean
	printf '[defaults]\nroles_path=./test/roles/\n' > ansible.cfg
	ansible-galaxy install -f -r test/requirements.yml
	printf '[defaults]\nroles_path=./test/roles:../\n' > ansible.cfg

test: test-prepare
	ansible-playbook $(ANSIBLE_OPTS) -i $(TEST_INVENTORY) test/test.yml
	rm -rf ansible.cfg ./build
	docker rm -f $(containers) || true

setup: test-prepare
	ansible-playbook $(ANSIBLE_OPTS) -i $(INVENTORY) test/test.yml
	rm -rf ansible.cfg ./build
	docker rm -f $(containers) || true
