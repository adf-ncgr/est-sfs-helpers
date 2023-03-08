# est-sfs-helpers
scripts for working with https://sourceforge.net/projects/est-usfs/
using VCF files that include both in and outgroups.

NB: I had made some compilation tweaks to get est-sfs itself running on the scale of data we get from next gene data:
```
diff est-sfs-release-2.03/est-sfs.c est-sfs-release-2.03-not-tweaked/est-sfs.c
18,20c18
< //needed to bump this up for genome-scale calling, otherwise core dump; see associated tweak in Makefile
< //#define max_config 100000
< #define max_config 10000000
---
> #define max_config 100000
Only in est-sfs-release-2.03-not-tweaked/: .est-sfs.c.swp
diff est-sfs-release-2.03/Makefile est-sfs-release-2.03-not-tweaked/Makefile
2,4c2
< #CFLAGS   += -lm -lgsl -lgslcblas -O4
< #added -mcmodel option after finding some discussion of the error generated at compile-time when altering max_config to large values without using a non-default value https://www.technovelty.org/c/relocation-truncated-to-fit-wtf.html
< CFLAGS   += -lm -lgsl -lgslcblas -O4 -mcmodel=medium
---
> CFLAGS   += -lm -lgsl -lgslcblas -O4
```
