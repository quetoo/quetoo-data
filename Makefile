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

# Binary extensions whose history is not worth keeping. Only the HEAD revision
# is retained after compaction. Text-based formats (.map, .obj, .mat, .skin,
# .cfg, .mtl, .txt, .fgd, .svg, .py, .md, etc.) keep full history.
BINARY_EXTS = 7z ai bsp blend blend1 gtx ico icns jpg kra kra~ max mdl \
              md3 mtr nav ogg otf pak pcx pfm pk3 png png~ psd shader \
              sib swp tga tga~ ttf wav xcf zip

# Compact git history to reclaim disk space. Strips all revisions of binary
# files, then re-adds the current versions in a single commit. Also prunes
# deleted text files that no longer exist in the working tree.
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
	@echo "Stripping history for binary extensions: $(BINARY_EXTS)"
	git filter-repo \
		--paths-from-file .git/paths-to-prune.txt \
		$(foreach ext,$(BINARY_EXTS),--path-glob '*.$(ext)') \
		--invert-paths --force
	git remote add origin git@github.com:jdolan/quetoo-data.git
	git remote set-url --push origin git@github.com:jdolan/quetoo-data.git
	git remote set-url --push --add origin git@github.com:quetoo/quetoo-data.git
	git add -A
	git commit -m "Re-add binary assets after history compaction"
	@echo "=== After ==="
	@du -sh .git
	@echo
	@echo "Review the result, then run: git push --force --set-upstream origin main"

