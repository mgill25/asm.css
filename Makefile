MAKEFLAGS := -r

TRANSPILE := node_modules/.bin/postcss
TRANSPILE_OPTS := --local-plugins -u postcss-import -u postcss-colormin -u postcss-cssnext --postcss-cssnext.browser "> 2%" -u stylelint -u postcss-reporter -u postcss-browser-reporter
MERGE_OPTS := --local-plugins -u --postcss-merge-rules -u css-mqpacker
MIN := node_modules/.bin/postcss
MIN_OPTS := --local-plugins -u postcss-clean
COMPRESS := gzip
COMPRESS_OPTS := -9
ANALYZE := node_modules/.bin/parker
BUILD_DIR := build

BROWSERS ?= ie mozilla opera webkit

#[make]: filter out any duplicate files in $BROWSERS

CORE_SRC := $(foreach d, core $(addprefix core/, $(BROWSERS)), $(wildcard $(d)/*.css))
CORE_DST := $(addprefix $(BUILD_DIR)/, $(CORE_SRC))
CORE_DST_MIN := $(CORE_DST:.css=.min.css)
CORE_DST_COMPRESS := $(addsuffix .gz, $(CORE_DST_MIN))
CORE_DST_MERGE := $(BUILD_DIR)/asmcore.css
CORE_DST_MERGE_MIN := $(CORE_DST_MERGE:.css=.min.css)
CORE_DST_MERGE_COMPRESS := $(addsuffix .gz, $(CORE_DST_MERGE_MIN))

EXT_SRC := $(foreach d, ext $(addprefix ext/, $(BROWSERS)), $(wildcard $(d)/*.css))
EXT_DST := $(addprefix $(BUILD_DIR)/, $(EXT_SRC))
EXT_DST_MIN := $(EXT_DST:.css=.min.css)
EXT_DST_COMPRESS := $(addsuffix .gz, $(EXT_DST_MIN))
EXT_DST_MERGE := $(BUILD_DIR)/asmext.css
EXT_DST_MERGE_MIN := $(EXT_DST_MERGE:.css=.min.css)
EXT_DST_MERGE_COMPRESS := $(addsuffix .gz, $(EXT_DST_MERGE_MIN))

VAR_SRC_BROWSERS := $(foreach d, var $(addprefix var/, $(BROWSERS)), $(wildcard $(d)/*.css))
VAR_SRC := $(foreach d, var $(addprefix var, $(BROWSERS)), $(wildcard $(d)/*.css))
VAR_DST := $(addprefix $(BUILD_DIR)/, $(VAR_SRC))
VAR_DST_MIN := $(VAR_DST:.css=.min.css)
VAR_DST_COMPRESS := $(addsuffix .gz, $(VAR_MERGE_MIN))
VAR_DST_MERGE := $(BUILD_DIR)/asmvar.css
VAR_DST_MERGE_MIN := $(VAR_DST_MERGE:.css=.min.css)
VAR_DST_MERGE_COMPRESS := $(addsuffix .gz, $(VAR_DST_MERGE_MIN))

.PHONY: all analyze clean compress min

all: $(CORE_DST) $(CORE_DST_MERGE) $(EXT_DST) $(EXT_DST_MERGE) $(VAR_DST) $(VAR_DST_MERGE)

analyze: $(CORE_DST_MERGE) $(EXT_DST_MERGE) $(VAR_DST_MERGE)
	$(ANALYZE) $^

clean:
	rm -rf $(BUILD_DIR)

min: $(CORE_DST_MIN) $(CORE_DST_MERGE_MIN) $(EXT_DST_MIN) $(EXT_DST_MERGE_MIN) $(VAR_DST_MIN) $(VAR_DST_MERGE_MIN)

compress: $(CORE_DST_COMPRESS) $(CORE_DST_MERGE_COMPRESS) $(EXT_DST_COMPRESS) $(EXT_DST_MERGE_COMPRESS) $(VAR_DST_COMPRESS) $(VAR_DST_MERGE_COMPRESS)

$(BUILD_DIR)/%.css: %.css | $(BUILD_DIR)
	$(TRANSPILE) $(TRANSPILE_OPTS) $< -o $@

$(BUILD_DIR)/%.min.css: $(BUILD_DIR)/%.css
	$(MIN) $(MIN_OPTS) $< -o $@

$(BUILD_DIR)/%.min.css.gz: $(BUILD_DIR)/%.min.css
	$(COMPRESS) $(COMPRESS_OPTS) < $< > $@

$(CORE_DST_MERGE): $(CORE_DST)
	cat $^ > $@
	$(TRANSPILE) $(MERGE_OPTS) $@ -o $@
$(EXT_DST_MERGE): $(EXT_DST)
	cat $^ > $@
	$(TRANSPILE) $(MERGE_OPTS) $@ -o $@
$(VAR_DST_MERGE): $(VAR_DST)
	cat $^ > $@
	$(TRANSPILE) $(MERGE_OPTS) $@ -o $@

$(BUILD_DIR):
	mkdir -p $@



