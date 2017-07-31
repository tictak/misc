
trap "kill 0" SIGINT

sleep 100 &

function sss(){
sleep 200&
}
sss
