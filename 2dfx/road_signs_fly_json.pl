use JSON;
use File::Slurp;
use Data::Dumper;

$json=decode_json(read_file('road_signs.json'));


$code="var sign=[];\n";


foreach $filename(
#grep{/sw_bit_09.dff/}
keys %{$json}){
$filejson=$json->{$filename};

foreach $sign(@{$filejson}){
#print Dumper($sign);
print "Rotations: ".join("\t|",@{$sign->{rot}})."\n";
($rot_x,$rot_y,$rot_z)=map{$_/180*3.14159265359}@{$sign->{rot}};
($drot_x,$drot_y,$drot_z)=map{int(($_+45+360)/90)}@{$sign->{rot}};

print "DRotations: ".join("\t|",$drot_x,$drot_y,$drot_z)."\n";

$len=2;





# heading in 0..360, 0=north, 90=west (left)
$heading=90-$rot_x/3.14159265359*180;
if($drot_y==5 && $drot_z==5){}
if($drot_y==4 && $drot_z==6){}
##if($drot_y==3 && $drot_z==3){$heading=90+$rot_x/3.14159265359*180;}
if($drot_x==5 && $drot_y==3 && $drot_z==3){$heading=180-90+$rot_x/3.14159265359*180;}
if($drot_x==4 && $drot_y==3 && $drot_z==3){$heading=180-90+$rot_x/3.14159265359*180;}


$h2=$heading/180*3.14159265359;
$cam_pos_x=$sign->{pos}->[0]+sin($h2)*$len;
$cam_pos_y=$sign->{pos}->[1]-cos($h2)*$len;
$cam_pos_z=$sign->{pos}->[2];



print @{$sign->{lines}};
print "\n";
$code.="sign=[$sign->{pos}->[0],$sign->{pos}->[1],$sign->{pos}->[2],$cam_pos_x,$cam_pos_y,$cam_pos_z];\n";
$code.="new Player(0).getChar().setHeading($heading).setCoordinates(sign[0],sign[1],sign[2]);\n";
###$code.="Camera.SetBehindPlayer();\n";
$code.="Camera.SetFixedPosition(sign[0],sign[1],sign[2],0,0,0);\n";
$code.="Camera.PointAtPoint(sign[0],sign[1],sign[2],1);\n";
$code.="Camera.SetZoom(100);\n";

$code.="Searchlight.Create(sign[0],sign[1],sign[2],sign[0],sign[1],sign[2]-10,10,1);\n";

$code.="wait(1500);\n";

for($t=0;$t<860;$t+=3){
$len=2+($t/100)**2/10;

$h2=$t/180*3.14159265359;
$cam_pos_x=$sign->{pos}->[0]+sin($h2)*$len;
$cam_pos_y=$sign->{pos}->[1]-cos($h2)*$len;
$cam_pos_z=$sign->{pos}->[2]+sin($t/100)*4;
$code.="Camera.SetFixedPosition($cam_pos_x,$cam_pos_y,$cam_pos_z,0,0,0);\n";
$code.="Camera.PointAtPoint(sign[0],sign[1],sign[2],2);\n";
$code.="wait(10);\n";
}

###Camera.PointAtPoint(x: float, y: float, z: float, switchStyle: int)
#SetFixedPosition(x: float, y: float, z: float, xRotation: float, yRotation: float, zRotation: float): void;

#xit;
}

}

write_file("test.js",$code);
