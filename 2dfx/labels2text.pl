use File::Slurp;

$file=read_file("labels.txt");
foreach $line(map{substr($_,0,16),substr($_,16,16),substr($_,32,16),substr($_,48,16)}split(/\n/,$file)){
$line=~s/[<^>%#]//sg;
$line=~s/_/ /gs;
$line=~s/^\s+|\s+$//gs;
$line=lc($line);

print "$line\n";



}