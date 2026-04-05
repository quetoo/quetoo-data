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

# Strip accumulated .bsp and .pk3 blobs from git history to reclaim disk space.
# Game data is distributed via S3, so history of binary artifacts is not needed.
# After running, all other clones must be re-cloned or hard-reset to origin/main.
compact:
	@command -v git-filter-repo >/dev/null 2>&1 || { echo "Error: git-filter-repo is required (brew install git-filter-repo)"; exit 1; }
	@test -z "$$(git status --porcelain)" || { echo "Error: working tree must be clean"; exit 1; }
	@echo "=== Before ==="
	@du -sh .git
	git filter-repo --path-glob '*.bsp' --path-glob '*.pk3' --invert-paths --force
	git remote add origin git@github.com:jdolan/quetoo-data.git
	git remote set-url --push --add origin git@github.com:quetoo/quetoo-data.git
	git add -A
	git commit -m "Re-add binary assets after history compaction"
	@echo "=== After ==="
	@du -sh .git
	@echo
	@echo "Review the result, then run: git push --force --set-upstream origin main"

