PACKAGE_NAME=file_kvstore
VENV_DIR?=.venv
VENV_ACTIVATE=$(VENV_DIR)/bin/activate
WITH_VENV=. $(VENV_ACTIVATE);
REQUIREMENTS=$(wildcard requirements*.txt)

TEST_OUTPUT_DIR?=test-output
TEST_OUTPUT_XML?=nosetests.xml
COVERAGE_DIR?=htmlcov
COVERAGE_DATA?=coverage.xml

$(VENV_ACTIVATE): $(REQUIREMENTS)
	test -f $@ || virtualenv --python=python2.7 $(VENV_DIR)
	$(WITH_VENV) pip install --no-deps $(patsubst %,-r %,$^)
	touch $@

all:
	python setup.py check build

.PHONY: venv
venv: $(VENV_ACTIVATE)

.PHONY: setup
setup: venv

.PHONY: develop
develop: venv
	$(WITH_VENV) python setup.py develop

.PHONY: clean
clean:
	python setup.py clean
	rm -rf build/
	rm -rf dist/
	rm -rf *.egg*/
	rm -rf __pycache__/
	rm -f MANIFEST
	rm -rf $(TEST_OUTPUT_DIR)
	rm -rf $(COVERAGE_DIR)
	rm -f $(COVERAGE_DATA)
	find $(PACKAGE_NAME) -type f -name '*.pyc' -delete


.PHONY: nuke
nuke:
	rm -rf $(VENV_DIR)/

.PHONY: lint
lint: venv
	$(WITH_VENV) flake8 -v $(PACKAGE_NAME)/

.PHONY: quality
quality: venv
	$(WITH_VENV) radon cc -s $(PACKAGE_NAME)/
	$(WITH_VENV) radon mi $(PACKAGE_NAME)/

.PHONY: test
test: develop
	$(WITH_VENV) py.test -v \
		--doctest-modules \
		--ignore=setup.py \
		--ignore=$(VENV_DIR) \
		--junit-xml=$(TEST_OUTPUT_DIR)/$(TEST_OUTPUT_XML) \
		--cov=$(PACKAGE_NAME) \
		--cov-report=xml \
		--cov-report=term-missing

.PHONY: sdist
sdist:
	python setup.py sdist
