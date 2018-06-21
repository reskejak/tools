# tools
Short scripts for various bioinformatics applications.

#### Installation

1. Clone or copy raw code to text editor.
2. Make executable, e.g. `chmod u+x removeChrom`.
3. Call script via installation dir, e.g. `./removeChrom` or `/home/usr/bin/removeChrom`, or alternatively...
4. (Optional) **Carefully** add installation dir to PATH, e.g. `export PATH=$PATH:/home/usr/bin` and call anywhere via simply `removeChrom`.

### removeChrom

Simple bash script to remove reads from a specific chromosome from a bam file. Dependencies: [samtools](http://samtools.sourceforge.net/).

Usage: `removeChrom chr10 input.bam`

Command idea based on [this Biostars thread](https://www.biostars.org/p/128967/). Script format based on [Tao Liu's bdg2bw](https://gist.github.com/taoliu/2469050).

### removeChromSam

Simple bash script to remove reads from a specific chromosome from a bam file (output as sam). Dependencies: [samtools](http://samtools.sourceforge.net/).

Usage: `removeChromSam chr10 input.bam`

Command idea based on [this Biostars thread](https://www.biostars.org/p/128967/). Script format based on [Tao Liu's bdg2bw](https://gist.github.com/taoliu/2469050).

### sort.sh

Shell script to sort (in a file) each row of integers horizontally by increasing value. Specific application: converting standard BEDPE files to minimal format for macs2.

Usage: `bash sort.sh coords.bed > coords.sorted.bed`

Loop sourced from [this thread](https://www.unix.com/shell-programming-and-scripting/180835-sort-each-row-horizontally-awk-any.html
).
