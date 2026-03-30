use utf8;
use JSON;
use File::Find;
use Data::Dumper;
use File::Path qw(make_path remove_tree);
use File::Basename;
use Digest::CRC qw(crc64 crc32 crc16);
use File::Slurp;

binmode(STDOUT,":utf8");

%uniqtexts=();
# SAN_FIERRO_#____Garver_Bridge_#_Easter_Bay______Airport_}_#_____
#  # -> upper-right-arrow ↗
#  } -> plane-character (airport icon) ✈ 

#✈ (U+2708) — Стандартный символ самолета (Airplane).✈ (U+2708 + U+FE0F) — Emoji-версия (Airplane).🛩 (U+1F6E9) — Маленький самолет (Small Airplane).🛫 (U+1F6EB) — Взлет самолета (Airplane Departure
#🛬 (U+1F6EC) — Посадка самолета (Airplane Arrival)

$mainjson={};
@files_with_signs=qw/exclbrsign01_lvs.dff ne_bit_11.dff cunte_roads72.dff cs_roads02.dff sw_bit_01.dff sw_bit_02.dff sw_bit_05.dff sw_bit_06.dff sw_bit_08.dff sw_bit_09.dff cuntwroad68.dff cuntwroad71.dff nw_bit_07.dff nw_bit_08.dff nw_bit_10.dff vegasn_motorway1.dff triadcasign_lvs.dff airtun1_las.dff airtun3_las.dff cunte_roads05a.dff cunte_roads47.dff se_bit_03.dff se_bit_12.dff se_bit_16.dff bchcostair_las.dff bchcostrd1_las.dff bchcostrd4fuk_las.dff bchcostrd4_las.dff bchcostrd6v_las2.dff bchcostrd6_las2.dff cenwhiltest5.dff cunte_roads31.dff cunte_roads33.dff cunte_roads35.dff cunte_roads38.dff cunte_roads40.dff cunte_roads42.dff cunte_roads43.dff cunte_roads44.dff cunte_roads46.dff cs_roads29.dff lawroads_law01.dff lawroads_law05.dff lawroads_law12.dff laroadsbrk_05_las.dff roadssfse63.dff roadssfse72.dff roadssfse81.dff roads28_law2.dff cuntwroad08.dff cuntwroad17.dff cuntwroad23.dff lae2_roads17.dff road05_lan2.dff road06_sfe.dff lae2_roads78.dff road_lawn12.dff road_lawn22.dff vegaswedge27.dff lawroads_law16.dff lawroads_law21.dff roadfromlan2.dff roads01_law2.dff roads02_law2.dff freeway10_lan2.dff freeway11_lan2.dff freeway1_lan2.dff laeroad23.dff cunte_roads73.dff cunte_roads75.dff cunte_roads76.dff cunte_roads78.dff cunte_roads79.dff cunte_roads83.dff vegasnroad17b.dff vegasnroad19.dff vegasnroad21.dff vegasnroad22.dff vegasnroad23.dff lae2_roads27.dff lae2_roads44.dff nwcstrd2_las2.dff vegaseroad008.dff cunteroads_58.dff cuntetownrd1.dff cunte_flyover2.dff cunte_roads01.dff cunte_roads02.dff cunte_roads04.dff cunte_roads05.dff roads36_law2.dff roads40_ce.dff ceroadtemp2.dff vegassroad047.dff des_stmedicentre_.dff vegaseroad071.dff vegaseroad072.dff lae2_roadscoast04.dff lae2_roadscoast06.dff roadssfse15.dff roadssfse25.dff roadssfse28.dff roadssfse29.dff rdsigns4_lae03.dff rdsigns4_lae05.dff ne_bit_06.dff ne_bit_07.dff ne_bit_08.dff laeroad37.dff laeroad47.dff cunte_roads49.dff cunte_roads50.dff cunte_roads51.dff cunte_roads52.dff cunte_roads54.dff cunte_roads59.dff cunte_roads60.dff cunte_roads61.dff cunte_roads62.dff cunte_roads66.dff cunte_roads68.dff cunte_roads71.dff obcity1_las.dff vegasnroad622.dff vegasnroad624.dff cunte_roads07.dff cunte_roads08.dff cunte_roads10.dff cunte_roads11.dff cunte_roads11a.dff cunte_roads12.dff cunte_roads13.dff cunte_roads14.dff cunte_roads15.dff cunte_roads16.dff cunte_roads17.dff cunte_roads18.dff cunte_roads23.dff cunte_roads25.dff cunte_roads26.dff cunte_roads29.dff cunte_roads30.dff vegaswedge03.dff vegaswedge04.dff vegaswedge111.dff vegaswedge16.dff vegaswedge22.dff cuntwland50b.dff cuntwland54b.dff cuntwland65b.dff laeroad16.dff lae2_roads03.dff s_bit_17.dff freeway2_lan2.dff se_bit_17.dff vegaseroad023.dff vegaseroad036.dff vegaseroad066.dff vegaseroad067.dff vegaseroad068.dff cen_bit_08.dff cen_bit_20.dff n_bit_07.dff n_bit_08.dff cuntsrod01.dff vgseedge05.dff laroadsx_04_las.dff laroads_042e_las.dff gsfreeway2_lan.dff gsfreeway3_lan.dff gsfreeway4_lan.dff gsfreeway5_lan.dff gsfreeway6_lan.dff gsfreeway7_lan.dff gsfreeway8_lan.dff laeroad03.dff laeroad03b.dff laeroad10.dff cs_roads09.dff cs_roads10.dff cs_roads13.dff cs_roads17.dff vegasnedge08.dff s_bit_06_4.dff s_bit_08.dff s_bit_09.dff s_bit_10.dff s_bit_12.dff s_bit_14.dff s_bit_15.dff s_bit_16.dff vgngamblsign1.dff sw_bit_14.dff nw_bit_18.dff nw_bit_22.dff nw_bit_23.dff nw_bit_24.dff nw_bit_26.dff nw_bit_29.dff freeway3_lan2.dff freeway4_lan2.dff freeway5_lan2.dff ne_bit_16.dff ne_bit_20.dff ne_bit_22.dff ne_bit_26.dff/;
$path='/dev/shm/t/gta/unpacked_mini/models/gta3/';

$filename='/dev/shm/t/gta/unpacked_mini/models/gta3/sw_bit_09.dff';

foreach $f(@files_with_signs){
$filename=$path.'/'.$f;
print "Processing $filename...\n";

$sa_version=0x1803FFFF;
$type=pack("I",0x0253F2F8);
$subtype=7;

$file=read_file($filename);
$idx=index($file,$type,0);
if($idx<0){
print STDERR "Here no 2dfx road sign entry!\n";
die;
}

# F8 F2 53 02 70 00 00 00 FF FF 03 18 01 00 00 00
# ^^^^^^^^^^^ - signature
#             ^^^^^^^^^^^ - struct size?
#                         ^^^^^^^^^^^ - RW-version
#                                     ^^^^^^^^^^^ - count of effects
($sign,$struct_size,$version,$count)=unpack("IIII",substr($file,$idx,16));
if($version!=$sa_version){die "Wrong version or wrong index found";}

$struct_pos=$idx+16;
$current_pos=0;
$struct_size-=24;
while($current_pos<$struct_size){
print "reading structures at $current_pos of $struct_size\n";
printf("position in file: 0x%08x\n",$struct_pos+$current_pos);
($pos_x,$pos_y,$pos_z,$entry_type,$data_size)=unpack("fffII",substr($file,$struct_pos+$current_pos,20));
$current_pos+=20;
print "Found road sign: ${pos_x}x${pos_y}x${pos_z}, type:$entry_type, size:$data_size\n";

if($entry_type!=7){
print "Wrong entry type: $entry_type, must be 7, skipping data!\n";
$current_pos+=$data_size;
next;
}
if($data_size!=88 && $data_size!=86){die "Wrong data size: $data_size";}



($size_x,$size_y,$rot_x,$rot_y,$rot_z,$flags,$text,$pad)=unpack("fffffSA64S",substr($file,$struct_pos+$current_pos,$data_size));
####if($pad!=0){die "Padding must be zero, but: $pad";}

$used_lines=-1;
$used_columns=-1;
$text_color=0x123456;
$text_name="undefined";

#Bits 0-1 - Number of used lines
if(($flags&3)==0){$used_lines=4;}
if(($flags&3)==1){$used_lines=1;}
if(($flags&3)==2){$used_lines=2;}
if(($flags&3)==3){$used_lines=3;}

#Bits 2-3 - Max number of symbols in one line

if((($flags>>2)&3)==0){$used_columns=16;}
if((($flags>>2)&3)==1){$used_columns=2;}
if((($flags>>2)&3)==2){$used_columns=4;}
if((($flags>>2)&3)==3){$used_columns=8;}

#Bits 4-5 - Text color

if((($flags>>4)&3)==0){$text_color=0xFFFFFF;$text_name="white";}
if((($flags>>4)&3)==1){$text_color=0x000000;$text_name="black";}
if((($flags>>4)&3)==2){$text_color=0x808080;$text_name="gray";}
if((($flags>>4)&3)==3){$text_color=0x0000FF;$text_name="red";}

print "text ${used_columns}x${used_lines} in $text_name: ".$text." (size: ${size_x}x${size_y}, $rot_x,$rot_y,$rot_z,$flags,padding:$pad)\n";
@lines=();
@texts=();

for($q=0;$q<$used_lines;$q++){
$lines[$q]=substr($text,$q*16,$used_columns);
$lt=$lines[$q];
$lt=~s/_/ /gs;
$lt=~s/#/↗/gs;
$lt=~s/}/✈./gs;
$lt=~s/^\s+|\s+$//gs;
$texts[$q]=$lt;
print "... |$lines[$q]          \t| $texts[$q]\n";

$lt=lc($lines[$q]);
$lt=~s/_/ /gs;
$lt=~s/[<^>%{}!~\|\*#]//gs;
$lt=~s/^\s+|\s+$//gs;
$uniqtexts{$lt}++;
}

$json={};
$json->{pos}=[$pos_x,$pos_y,$pos_z];
$json->{size}=[$size_x,$size_y];
$json->{rot}=[$rot_x,$rot_y,$rot_z];
$json->{flags}=[$flags,$used_lines,$used_columns,$text_color,$text_name];
$json->{texts}=[@texts];
$json->{lines}=[@lines];
print encode_json($json);

if(!exists $mainjson->{$f}){$mainjson->{$f}=[];}
push(@{$mainjson->{$f}},$json);

print "\n\n\n";

$current_pos+=$data_size;
}

}

write_file("road_signs.json",encode_json($mainjson));

#print Dumper(\%uniqtexts);

print map{"$_\n"}sort keys %uniqtexts;


=pod
find({no_chdir=>1,follow=>1,wanted=>sub{
if(-d($File::Find::name)){return;}
if($File::Find::name=~/\.dff$/i){

open(dd,$File::Find::name);
read(dd,$file,-s(dd));
close(dd);
$t1=index($file,$type);
if($t1>=0){
$t2=unpack("I",substr($file,$t1+28,4));
if($t2==$subtype){

}
}
}

}},"/dev/shm/t/gta/unpacked_mini/models/");

=cut