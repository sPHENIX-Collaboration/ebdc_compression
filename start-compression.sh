
usage() { echo "Usage: $0 [-f <folder>] [-s <sink server>] [-p <port>] [-j <job>] [-n <portrange>] [-z <zipcommand>] [-l <ziplevel>]" 1>&2; exit 1; }

folder='/mnt/nvme/fnal_June2019/beam'
port=12340
portrange=8
job=20
zipcmd='lz4'
ziplevel=1
sinkserver='localhost'

workdir='./data/'

while getopts ":f:s:p:j:n:z:l:" o; do
    case "${o}" in
        f)
            folder=${OPTARG}
            ;;
        s)
            sinkserver=${OPTARG}
            ;;
        p)
            port=${OPTARG}
            ;;
        n)
            portrange=${OPTARG}
            ;;
        j)
            job=${OPTARG}
            ;;
        z)
            zipcmd=${OPTARG}
            ;;
        l)
            ziplevel=${OPTARG}
            ;;
        *)
            usage
            ;;
    esac
done
shift $((OPTIND-1))

jobname="${workdir}/${zipcmd}-${ziplevel}-${job}"

echo "folder = ${folder}"
echo "port = ${port} - " `expr ${port} + ${portrange} - 1`
echo "job = ${job}"
echo "zip = ${zipcmd} -${ziplevel}"

if [ -d "$jobname" ] 
then
    echo "Backup $jobname" 
    tar zcfv $jobname.tar.gz $jobname
    rm -f $jobname/*
else
    echo "Use directory $jobname"
    mkdir -pv $jobname
fi
# exit;

# find ${folder} -name "*.evt" |  parallel --joblog parallel.log --progress -j${job} "lzop -1 -vc {} 2>>zip.log | ncat 127.0.0.1 \`expr {#} % ${portrange} + ${port}\` "

lshw > ${jobname}/hardware.log 2>/dev/null

find ${folder} -name "*.evt" |  parallel --joblog ${jobname}/parallel.log --progress -j${job} "cat {} | pv -btrnf -i 1000  2>>${jobname}/pv_in_{#}.log  | ${zipcmd} -${ziplevel} -c | pv -btrnf -i 1000  2>>${jobname}/pv_out_{#}.log  | ncat $sinkserver \`expr {#} % ${portrange} + ${port}\` "
# find ${folder} -name "*.evt" |  parallel --joblog ${jobname}/parallel.log --progress -j${job} "gzip -1 -vc {} 2>>zip{#}.log | ncat 127.0.0.1 \`expr {#} % ${portrange} + ${port}\` "
# find ${folder} -name "*.evt" |  parallel --joblog parallel.log --progress -j${job} "echo lzop -1 -vc {} port \`expr {#} % ${portrange} + ${port}\` "

