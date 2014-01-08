
if [ "$1" == "" ];then
    echo "usage: halfreg.sh <input1> <input2> <output1> <output2> [flirt opts]"
    echo ""
    exit 1
fi


i1=$1
i2=$2
o1=$3
o2=$4
shift;
shift;
shift;
shift;
opts=$*

flirt -in $i1 -ref $i2 -omat mat1 $opts
flirt -in $i2 -ref $i1 -omat mat2 $opts


avscale --allparams mat1 | grep -A 4 "Forward half transform" | tail -n 4 > halfmat1
avscale --allparams mat2 | grep -A 4 "Forward half transform" | tail -n 4 > halfmat2


applywarp -i $i1 -r $i2 --premat=halfmat1 -o $o1 --interp=spline
applywarp -i $i2 -r $i1 --premat=halfmat2 -o $o2 --interp=spline


