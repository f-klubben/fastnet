#!/bin/sh
# Symlinker repoets filer ind i Asterisks mapper.
# Kør på Pi'en:  cd ~/fastnet && sudo ./sync.sh
# Idempotent: findes der en almindelig fil i mål-mappen, gemmes den som <navn>.pre-fastnet.
set -eu

REPO=$(cd "$(dirname "$0")" && pwd)

# Asterisk-brugeren skal kunne læse filerne gennem hele stien
p=$REPO
while [ "$p" != "/" ]; do
	chmod o+rx "$p" 2>/dev/null || true
	p=$(dirname "$p")
done

link_dir() {
	src=$REPO/$1 dst=$2 mode=$3
	[ -d "$dst" ] || install -d -o asterisk -g asterisk -m 755 "$dst"
	for f in "$src"/*; do
		[ -f "$f" ] || continue
		chmod "$mode" "$f"
		t=$dst/$(basename "$f")
		if [ -e "$t" ] && [ ! -L "$t" ]; then
			b=$t.pre-fastnet
			[ -e "$b" ] || { cp -a "$t" "$b"; echo "gemt: $b"; }
			rm -f "$t"
		fi
		ln -sfn "$f" "$t"
		echo "$t -> $f"
	done
}

# repo-mappe               mål-mappe                            fil-tilstand
link_dir asterisk/etc      /etc/asterisk                        644
link_dir asterisk/agi-bin  /usr/share/asterisk/agi-bin          755

echo "Færdig. Se ./reload-dialplan.sh for genindlæsning."
