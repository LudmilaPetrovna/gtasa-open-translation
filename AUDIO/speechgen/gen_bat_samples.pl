use Encode;
use File::Slurp;

#$voice='ScanSoft Katerina_Full_22kHz';
$voice='ELAN TTS Russian (Nicolai 16Khz)';

$o="";
for($q=0;$q<750;$q++){
#$o.="balabolka.exe -snq \"Банк $q\" bank_$q.wav \"$voice\" r-5\r\n";
}

for($q=0;$q<400;$q++){
$o.="balabolka.exe -snq \"Звук $q\" sound_$q.wav \"$voice\" r-5\r\n";
}

$o.="balabolka.exe -snq \"Это зацикленный звук\" sound_loop.wav \"$voice\" r-5\r\n";


write_file("gen_samples.bat",encode("cp866",decode_utf8($o)));
