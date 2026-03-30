use utf8;
use Encode;
use GD;
use File::Slurp;


$ttf_font='/usr/share/fonts/truetype/dejavu/DejaVuSans.ttf';
$ttf_font='/usr/share/fonts/truetype/dejavu/DejaVuSansCondensed-Bold.ttf';
#$ttf_font='overpass-bold.ttf';
#$ttf_font='russianroadsign-medium.ttf';
$src_font='roadsignfont.png';
$use_debug=1;

# todo: add mapping using character-with-based relations

#From tube3f1f59c7: Прописные:А-A, Б-B, В-B, Г-T, Д-D, Е-E, Ж-X, З-3, И-N, Й-N, К-K, Л-L, М-M, Н-H, О-O, П-N, Р-P, С-C, Т-T, У-Y, Ф-F, Х-X, Ц-U, Ч-4, Ш-W, Щ-W, Ъ-b, Ы-bl, Ь-b, Э-9, Ю-IO, Я-R
#From tube3f1f59c7: Строчные: а-a, б-6, в-b, г-r, д-g, е-e, ж-x, з-3, и-u, й-u, к-k, л-n, м-m, н-h, о-o, п-n, р-p, с-c, т-m, у-y, ф-f, х-x, ц-u, ч-4, ш-w, щ-w, ъ-b, ы-b, ь-b, э-9, ю-io, я-r
#From tube3f1f59c7: Как видишь, некоторые символы (особенно Ж, Ы, Ю, Я) адекватно не заменить, придётся либо жертвовать читаемостью, либо использовать двухсимвольные костыли. В итоге получится текст, который будет читать
#From tube3f1f59c7: больно, но возможно.
#highway gothic
#From tube30525bb4: overpass это и есть highway gothic по сути



$chars=<<CODE;
!\"&\'
()+.
-./0
1234
5678
9;:?
ABCD
EFGH
IJKL
MNOP
QRST
UVWX
YZ[/
]abc
defg
hijk
lmno
pqrs
tuvw
xyz{
CODE

#|}<>

$mapen='ABVGDE:JZIYKLMNOPRSTUFHCawWghjdef';
$mapru='АБВГДЕЁЖЗИЙКЛМНОПРСТУФХЦЧШЩЪЫЬЭЮЯ';

$rus=GD::Image->new(32*4,512,1);
$rus->alphaBlending(0);
$rus->saveAlpha(1);

$gl=GD::Image->new(100,100,1);
$gl->alphaBlending(0);
$gl->saveAlpha(1);


# for testing
if($use_debug){
$rus->alphaBlending(1);
$rus->filledRectangle(0,0,70,512,0x008800);
}

# copy original chars
$orig = GD::Image->newFromPng($src_font,1);
$rus->copy($orig,0,0,0,0,32,512);
$rus->copy($orig,32,0,0,0,32,512);

$chars=~s/\n//gs;

for($q=0;$q<256;$q++){
$inch=substr($chars,$q,1);
if($inch eq ""){last;}
print "Processing char #$q: $inch\n";

$newch=$inch;
$ii=index($mapen,$inch);
if($ii>=0){
$newch=substr($mapru,$ii,1);
}

$px=$q%4;
$py=int($q/4);
$ox=$px*8;
$oy=$py*16;

print "Drawing at ${ox}x${oy} with $newch\n";

$gl->alphaBlending(1);
$gl->filledRectangle(0,0,100,100,0x008800);
@bounds=$gl->stringFT(0xFFFFFF,$ttf_font,12,0,20,20,$newch);


$rus->alphaBlending(0);
$rus->copyResampled($gl,$ox,$oy,20,6,8,16,16,18);

}

for($w=0;$w<512;$w++){
for($q=0;$q<32;$q++){
$rus->setPixel($q+80,$w,$rus->getPixel($q,$w)^$rus->getPixel($q+32,$w));
}
}


write_file("new_font.png",$rus->png(9));

