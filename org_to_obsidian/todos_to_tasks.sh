#!/usr/bin/env sh

fd --full-path "/home/wacken/Files/Org_Bak" -e org -x perl -i -0777 -pe 's/^:PROPERTIES:\n:ID:.*?\n:END:\n//s;
s/^\#\+TITLE:.*\n//g;
s/^\#\+CREATED:.*\n//g;
s/\[\[(id:.*?)\]\[(.*?)\]\]/\"[[\2]]\"/g;
s/\[\[(.*?)\]\[(.*?)\]\]/[\2](\1)/g;
s/\*\*\*\* TODO/        - [ ]/g;
s/\*\*\* TODO/    - [ ]/g;
s/\*\* TODO/- [ ]/g;
s/\*\*\*\* DONE/        - [x]/g;
s/\*\*\* DONE/    - [x]/g;
s/\*\* DONE/- [x]/g;
s/\*\*\*\* NEXT/        - [\/]/g;
s/\*\*\* NEXT/    - [\/]/g;
s/\*\* NEXT/- [\/]/g;
s/\*\*\*\* CANCELLED/        - [-]/g;
s/\*\*\* CANCELLED/    - [-]/g;
s/\*\* CANCELLED/- [-]/g;
s/\*\*\*\* WAITING/        - [w]/g;
s/\*\*\* WAITING/    - [w]/g;
s/\*\* WAITING/- [w]/g;
s/\* PROJECT/#/g;
s/\*\*\*\*\*\*/######/g;
s/\*\*\*\*\*/#####/g;
s/\*\*\*\*/####/g;
s/\*\*\*/###/g;
s/\*\*/##/g;
s/\*/#/g;
' {}
