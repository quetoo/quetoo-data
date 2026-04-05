# Makefile for Quetoo Data distributable, requires awscli.

TARGET = target

MAPS = $(wildcard $(TARGET)/default/maps/*.map)
BSPS = $(MAPS:.map=.bsp)

default: $(BSPS)

$(TARGET)/default/maps/%.bsp: $(TARGET)/default/maps/%.map
	quemap -w $(TARGET)/default -bsp maps/$*.map

QUETOO_DATA_S3_BUCKET = s3://quetoo-data

s3:
	git rev-parse --short HEAD > $(TARGET)/revision
	aws s3 sync --delete $(TARGET) $(QUETOO_DATA_S3_BUCKET)

# Prune deleted files from git history to reclaim disk space. Builds a list of
# every path that exists in history but not in the current working tree, then
# uses git-filter-repo to strip those paths. Current files are left untouched.
# After running, all other clones must be re-cloned or hard-reset to origin/main.
compact:
	@command -v git-filter-repo >/dev/null 2>&1 || { echo "Error: git-filter-repo is required (brew install git-filter-repo)"; exit 1; }
	@test -z "$$(git status --porcelain)" || { echo "Error: working tree must be clean"; exit 1; }
	@echo "=== Before ==="
	@du -sh .git
	@git log --all --pretty=format: --name-only --diff-filter=A | sort -u | sed '/^$$/d' > .git/paths-in-history.txt
	@git ls-files | sort -u > .git/paths-current.txt
	@comm -23 .git/paths-in-history.txt .git/paths-current.txt > .git/paths-to-prune.txt
	@rm -f .git/paths-in-history.txt .git/paths-current.txt
	@echo "Pruning $$(wc -l < .git/paths-to-prune.txt | tr -d ' ') deleted paths from history..."
	git filter-repo --paths-from-file .git/paths-to-prune.txt --invert-paths --force
	git remote add origin git@github.com:jdolan/quetoo-data.git
	git remote set-url --push --add origin git@github.com:quetoo/quetoo-data.git
	@echo "=== After ==="
	@du -sh .git
	@echo
	@echo "Review the result, then run: git push --force --set-upstream origin main"

