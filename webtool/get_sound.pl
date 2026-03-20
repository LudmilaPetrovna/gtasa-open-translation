#!/usr/bin/perl

use CGI::Carp qw(fatalsToBrowser);

use utf8;
use Encode;
use File::Slurp;
use File::Path qw(make_path remove_tree);
use File::Basename;
use Data::Dumper;

my $audio_root='/dev/shm/t/gta/Grand Theft Auto - San Andreas/audio';

foreach(split(/&/,$ENV{QUERY_STRING})){
($nn,$vv)=split(/=/);
$nn =~ tr/+/ /;
$vv =~ tr/+/ / if defined $vv;
$nn=~ s/%([0-9a-fA-F]{2})/chr(hex($1))/ge;
$vv=~ s/%([0-9a-fA-F]{2})/chr(hex($1))/ge if defined $vv;
$opts{$nn}=$vv;
}

$sound_id=$opts{sound_id};
$bank_id=$opts{bank_id};
if($bank_id<10){die "wrong id";}

$pak=read_file($audio_root.'/CONFIG/PakFiles.dat');
$look=read_file($audio_root.'/CONFIG/BankLkup.dat');

$bank_count=length($look)/12;
for($q=0;$q<$bank_count;$q++){
($package_id,$null,$bank_offset,$bank_size)=unpack("CA3II",substr($look,$q*12,12));
push(@banks,[$q,$package_id,$bank_offset,$bank_size]);
}

($bank_id2,$package_id,$bank_offset,$bank_size)=@{$banks[$bank_id]};
$package_name=unpack("Z52",substr($pak,$package_id*52,52));

open(dd,$audio_root.'/SFX/'.$package_name) or die $!;
binmode(dd);

seek(dd,$bank_offset,0);read(dd,$buf,4);
($num_sounds,$padding)=unpack("SS",$buf);
if($num_sounds>400){die "Num sounds is $num_sounds, must not be more than 400!";}
if($padding!=0){die "Padding not 0! This is not error, but very strange!";}

read(dd,$buf,12*400);

@sounds=();
for($q=0;$q<$num_sounds;$q++){
($buffer_offset,$loop_offset,$sample_rate,$headroom)=unpack("IiSs",substr($buf,$q*12,12));
$sounds[$q]=[$sample_rate,$buffer_offset,0,0,$q];
}

# calc len of sound
for($q=0;$q<$num_sounds;$q++){
$sounds[$q]->[2]=($q==($num_sounds-1)?$bank_size:$sounds[$q+1]->[1])-$sounds[$q]->[1]; # in bytes
$sounds[$q]->[3]=$sounds[$q]->[2]/2/$sounds[$q]->[0]; # in seconds
}

#print map{join("\t|",@{$_})."\n"}@sounds;

$snd=$sounds[$sound_id];
$tmpfilename="/dev/shm/cache/dub_web/tmp-resample-bank${bank_id}_sound${sound_id}.ogg";
$buf_offset=$snd->[1]+$bank_offset+4+400*12;
$buf_len=$snd->[2];
$samplerate=$snd->[0];

if($buf_len&1){die "Buffer size must be aligned to 16 bits!";}
if($buf_len<0){die "Buffer size must not be negative!";}

seek(dd,$buf_offset,0);read(dd,$buf,$buf_len);


open(oo,"|ffmpeg -v 0 -f s16le -ar $samplerate -ac 1 -i - -ar 48000 -ac 1 -y \"$tmpfilename\"");
binmode(oo);
print oo $buf;
close(oo);

print "Content-type: audio/ogg\n\n".read_file($tmpfilename);

