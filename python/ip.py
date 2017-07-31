import netaddr
import random


network = netaddr.IPNetwork('1.1.1.1/30')

iplist = [str(ip) for ip in network.iter_hosts()]
print iplist
random.shuffle(iplist)
print iplist

def gen_ip(ipnet):
        print (netaddr.IPAddress(netaddr.IPNetwork(ipnet).first))
        print (netaddr.IPAddress(netaddr.IPNetwork(ipnet).last))
        for i in netaddr.IPNetwork(ipnet).iter_hosts():
                        yield  str(i)
def gen_ip2(ipnet):
        first = netaddr.IPNetwork(ipnet).first
        last = netaddr.IPNetwork(ipnet).last
        for i in list(netaddr.iter_iprange(first,last)):
                yield str(i)

g = gen_ip2('30.30.31.96/29')
for i in g:
        print i


a={
        "a":"b",
        "c":"d"
}
for i in a:
        print a[i]
