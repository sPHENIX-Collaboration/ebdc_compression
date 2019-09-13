
usage() { echo "Usage: $0 [-f <folder>] [-p <port>] [-j <port>]" 1>&2; exit 1; }

folder = `/mnt/nvme/fnal_June2019/beam`
find . -name "${folder}/*.evt" |  parallel --joblog parallel.log --progress -j1 'lzop -1 -vc {} | ncat 127.0.0.1 1234 2>>zip{#}.log '
port = 1234
job = 24

while getopts ":s:p:" o; do
    case "${o}" in
        f)
            folder=${OPTARG}
            ;;
        p)
            port=${OPTARG}
            ;;
        j)
            job=${OPTARG}
            ;;
        *)
            usage
            ;;
    esac
done
shift $((OPTIND-1))

echo "folder = ${folder}"
echo "port = ${port}"
echo "job = ${job}"

find . -name "${folder}/*.evt" |  parallel --joblog parallel.log --progress -j${job} "lzop -1 -vc {} | ncat 127.0.0.1 ${port} 2>>zip{#}.log "

