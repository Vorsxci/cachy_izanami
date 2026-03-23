#!/bin/bash
root=$HOME/Tenjin

#zotero=$root/storage
zotero=$root/storage

#filenames=$(ls -R $zotero | cut -d "'" -f 2 | grep --after-context=1 --group-separator="\n" pdf )

#list=$(ls -R $zotero | cut -d "'" -f 2 | grep pdf | sed -E "s/^.* - [0-9]{4} - //;s/\.pdf//")

#echo $(ls -R $zotero | awk '{print $2}')

#echo $(ls -R $zotero | grep pdf | sed -E "s/^(.* - ([0-9]{4} -)?)//;s/\.pdf//")

#mapfile -t list < <(ls -R $zotero | grep pdf | sed -E "s/^(.* - ([0-9]{4} -)?)//;s/\.pdf//")
#mapfile -t filenames < <(ls -R $zotero | cut -d "'" -f 2 | grep pdf )

mapfile -t filenames < <(find -L "$zotero" -type f -iname '*.pdf' -printf '%f\n')

mapfile -t list < <(
  find -L "$zotero" -type f -iname '*.pdf' -printf '%f\n' |
    sed -E "s/^(.* - ([0-9]{4} -)?)//; s/\.pdf$//"
)

mapfile -t obsidianfiles < <(find -L "$root" -type f -iname '*.md' -printf '%f\n' | sed -e "s/\.md//g")

#echo "Array elements:"

for item in "${filenames[@]}"; do
  echo "$item"
done
echo ""
echo ""

for item in "${list[@]}"; do
  echo "$item"
done
echo ""
echo ""
for item in "${obsidianfiles[@]}"; do
  echo $item
done

declare -A seen
nonExist=()

for title in "${obsidianfiles[@]}"; do
  seen["$title"]=1
done

for title in "${list[@]}"; do
  if [[ -z "${seen["$title"]}" ]]; then
    #echo "$title"
    nonExist+=("$title")
  fi
done

#echo "$filenames"
# echo "yo"
# for item in "${nonExist[@]}"; do
#   for file in "${filenames[@]}"; do
#     echo "$file" | grep "$item"
#   done
# done
# echo "yo"

for item in "${nonExist[@]}"; do
  for file in "${filenames[@]}"; do
    if echo "$file" | grep "$item"; then
      echo "---
aliases:
tags:
---" >>$root/Sources/"${item}.md"
      echo -n '![[' >>$root/Sources/"${item}.md"
      echo -n "$file" | grep "$item" | head -c-1 >>$root/Sources/"${item}.md"
      echo -n ']]' >>$root/Sources/"${item}.md"
    fi
  done
  #echo $item
done
